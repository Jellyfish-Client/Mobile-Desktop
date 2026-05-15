import 'package:flutter/foundation.dart';

/// Resolved info for a GitHub release that's newer than the running build.
@immutable
class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.assetName,
    required this.downloadUrl,
    required this.releaseNotesUrl,
    required this.publishedAt,
    this.releaseNotes,
  });

  final String version;
  final String assetName;
  final String downloadUrl;
  final String releaseNotesUrl;
  final DateTime? publishedAt;
  final String? releaseNotes;
}

/// Outcome of a check call — used by callers to surface a snackbar.
enum UpdateCheckOutcome {
  available,
  upToDate,
  failed,
  unsupportedPlatform,
}

/// Lifecycle phase observed by the UI. `Idle` means we haven't checked yet
/// in this session (or the platform is unsupported); `UpToDate` means we
/// checked and the running build is current; the rest cover the download /
/// install flow.
sealed class UpdatePhase {
  const UpdatePhase();
}

final class UpdateIdle extends UpdatePhase {
  const UpdateIdle();
}

final class UpdateChecking extends UpdatePhase {
  const UpdateChecking();
}

final class UpdateUpToDate extends UpdatePhase {
  const UpdateUpToDate();
}

final class UpdateDownloading extends UpdatePhase {
  const UpdateDownloading(this.info, this.progress);
  final UpdateInfo info;

  /// Fractional progress in [0, 1], or -1 when the server didn't send a
  /// `Content-Length` header.
  final double progress;
}

final class UpdateReady extends UpdatePhase {
  const UpdateReady(this.info, this.filePath);
  final UpdateInfo info;
  final String filePath;
}

final class UpdateInstalling extends UpdatePhase {
  const UpdateInstalling(this.info);
  final UpdateInfo info;
}

final class UpdateFailed extends UpdatePhase {
  const UpdateFailed(this.reason);

  /// Stable identifier ('check_failed' / 'download_failed' / 'install_failed')
  /// so the UI can map it to a translated message.
  final String reason;
}

@immutable
class UpdateState {
  const UpdateState({
    required this.currentVersion,
    required this.phase,
    required this.autoCheckEnabled,
  });

  /// Version of the running build (without the `+build` suffix).
  final String currentVersion;
  final UpdatePhase phase;
  final bool autoCheckEnabled;

  UpdateState copyWith({
    String? currentVersion,
    UpdatePhase? phase,
    bool? autoCheckEnabled,
  }) => UpdateState(
    currentVersion: currentVersion ?? this.currentVersion,
    phase: phase ?? this.phase,
    autoCheckEnabled: autoCheckEnabled ?? this.autoCheckEnabled,
  );
}
