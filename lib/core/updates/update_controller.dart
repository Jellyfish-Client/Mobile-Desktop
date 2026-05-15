import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'update_models.dart';
import 'update_service.dart';

const _kRepoSlug = 'Jellyfish-Client/Mobile-Desktop';
const _kAutoCheckEnabledKey = 'app_updates.auto_check_enabled';
const _kLastCheckMsKey = 'app_updates.last_check_ms';
const _kCheckCooldown = Duration(hours: 24);

/// True when the running platform has an in-app updater. Restricted to
/// Windows: macOS unsigned builds can't replace themselves (Gatekeeper),
/// mobile platforms ship through stores, Linux uses distro packages.
bool get updatesSupportedHere => Platform.isWindows;

/// Fresh Dio for GitHub API + asset download. We deliberately don't reuse
/// `jellyfinDioProvider` here — that one carries Jellyfin auth headers.
final updateServiceProvider = Provider<UpdateService>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 10),
    ),
  );
  ref.onDispose(dio.close);
  return UpdateService(dio: dio, repoSlug: _kRepoSlug);
});

class UpdateController extends AsyncNotifier<UpdateState> {
  late SharedPreferences _prefs;
  StreamSubscription<UpdateDownloadEvent>? _downloadSub;

  UpdateService get _service => ref.read(updateServiceProvider);

  @override
  Future<UpdateState> build() async {
    // Cancel any in-flight subscription left by a previous build cycle
    // (hot restart / ref invalidation).
    await _downloadSub?.cancel();
    _downloadSub = null;
    ref.onDispose(() {
      unawaited(_downloadSub?.cancel());
      _downloadSub = null;
    });
    try {
      _prefs = await SharedPreferences.getInstance();
      final pkg = await PackageInfo.fromPlatform();
      final auto = _prefs.getBool(_kAutoCheckEnabledKey) ?? true;
      return UpdateState(
        currentVersion: pkg.version,
        phase: const UpdateIdle(),
        autoCheckEnabled: auto,
      );
    } on Object {
      // SharedPreferences or PackageInfo can fail on corrupt storage or
      // a broken native plugin. Surface a minimal state so the About
      // screen renders instead of hanging on a forever-loading spinner.
      return const UpdateState(
        currentVersion: '0.0.0',
        phase: UpdateIdle(),
        autoCheckEnabled: false,
      );
    }
  }

  /// App-launch auto-check: respects the cooldown + user toggle. Safe to
  /// call on any platform — returns immediately when unsupported.
  Future<void> maybeAutoCheck() async {
    if (!updatesSupportedHere) return;
    // `await future` can re-throw if `build()` was rebuilt and ended in
    // AsyncError. The current `build()` catches its own failures, but stay
    // defensive so a future refactor that removes the catch doesn't
    // silently break app launch.
    final UpdateState s;
    try {
      s = state.valueOrNull ?? await future;
    } on Object {
      return;
    }
    if (!s.autoCheckEnabled) return;
    final lastMs = _prefs.getInt(_kLastCheckMsKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastMs < _kCheckCooldown.inMilliseconds) return;
    await checkNow(silent: true);
  }

  /// Manual or auto-triggered check. With `silent: true`, network failures
  /// dissolve back into `UpdateIdle` (no error toast). Manual taps from the
  /// About screen pass `silent: false` so the user sees what happened.
  Future<UpdateCheckOutcome> checkNow({bool silent = false}) async {
    if (!updatesSupportedHere) return UpdateCheckOutcome.unsupportedPlatform;
    final s = state.valueOrNull;
    if (s == null) return UpdateCheckOutcome.failed;

    // Refuse to interrupt an installing process (irreversible side-effect
    // already kicked off). Cancel any in-flight download before re-checking.
    if (s.phase is UpdateInstalling) return UpdateCheckOutcome.available;
    await _downloadSub?.cancel();
    _downloadSub = null;

    state = AsyncData(s.copyWith(phase: const UpdateChecking()));
    await _prefs.setInt(
      _kLastCheckMsKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    final info = await _service.fetchLatestRelease();
    if (info == null) {
      state = AsyncData(
        s.copyWith(
          phase: silent
              ? const UpdateIdle()
              : const UpdateFailed('check_failed'),
        ),
      );
      return UpdateCheckOutcome.failed;
    }

    if (!UpdateService.isNewer(info.version, s.currentVersion)) {
      state = AsyncData(s.copyWith(phase: const UpdateUpToDate()));
      return UpdateCheckOutcome.upToDate;
    }

    state = AsyncData(s.copyWith(phase: UpdateDownloading(info, -1)));
    unawaited(_startDownload(info));
    return UpdateCheckOutcome.available;
  }

  Future<void> _startDownload(UpdateInfo info) async {
    // Cancel + null synchronously so a parallel caller can't race past
    // this point and end up with two concurrent subscriptions.
    final previous = _downloadSub;
    _downloadSub = null;
    await previous?.cancel();
    _downloadSub = _service.downloadInstaller(info).listen(
      (event) {
        final s = state.valueOrNull;
        if (s == null) return;
        switch (event) {
          case UpdateDownloadProgress(:final fraction):
            state = AsyncData(
              s.copyWith(phase: UpdateDownloading(info, fraction)),
            );
          case UpdateDownloadDone(:final filePath):
            state = AsyncData(
              s.copyWith(phase: UpdateReady(info, filePath)),
            );
        }
      },
      onError: (Object _, StackTrace _) {
        final s = state.valueOrNull;
        if (s == null) return;
        state = AsyncData(
          s.copyWith(phase: const UpdateFailed('download_failed')),
        );
      },
    );
  }

  /// User-triggered install. Quits the app once the wrapper script has
  /// been spawned. On failure, surfaces `UpdateFailed('install_failed')`
  /// so the About screen can show a snackbar.
  Future<void> installNow() async {
    final s = state.valueOrNull;
    if (s == null) return;
    final phase = s.phase;
    if (phase is! UpdateReady) return;
    state = AsyncData(s.copyWith(phase: UpdateInstalling(phase.info)));
    try {
      await _service.launchInstaller(phase.filePath);
    } on Object {
      state = AsyncData(
        s.copyWith(phase: const UpdateFailed('install_failed')),
      );
    }
  }

  Future<void> setAutoCheck({required bool enabled}) async {
    await _prefs.setBool(_kAutoCheckEnabledKey, enabled);
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(autoCheckEnabled: enabled));
  }
}

final updateControllerProvider =
    AsyncNotifierProvider<UpdateController, UpdateState>(
      UpdateController.new,
    );
