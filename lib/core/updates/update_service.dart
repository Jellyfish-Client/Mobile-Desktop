import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'update_models.dart';

/// Pure logic: hits the GitHub releases API, picks the Windows installer
/// asset, streams the download, and launches the Inno Setup installer
/// silently. No Riverpod / no Flutter — testable.
class UpdateService {
  UpdateService({
    required Dio dio,
    required this.repoSlug,
    Logger? logger,
  }) : _dio = dio,
       _log = logger ?? Logger('UpdateService');

  final Dio _dio;
  final Logger _log;

  /// `owner/repo` slug, e.g. `Jellyfish-Client/Mobile-Desktop`.
  final String repoSlug;

  /// Calls `GET /repos/<slug>/releases/latest` and selects the
  /// `_Setup.exe` asset (Inno Setup installer published by `build.yml`).
  /// Returns null on any network/parse failure — caller decides whether to
  /// surface this to the user.
  Future<UpdateInfo?> fetchLatestRelease() async {
    try {
      final res = await _dio.getUri<Map<String, dynamic>>(
        Uri.https('api.github.com', '/repos/$repoSlug/releases/latest'),
        options: Options(
          headers: const {
            'Accept': 'application/vnd.github+json',
            'User-Agent': 'JellyfishUpdateChecker/1.0',
          },
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final data = res.data;
      if (data == null) return null;

      final tagName = data['tag_name']?.toString();
      if (tagName == null || tagName.trim().isEmpty) return null;

      final htmlUrl =
          data['html_url']?.toString() ??
          'https://github.com/$repoSlug/releases/latest';
      final publishedAtStr = data['published_at']?.toString();
      final notes = data['body']?.toString();

      final assetsJson = data['assets'];
      final assets = <Map<String, dynamic>>[];
      if (assetsJson is List) {
        for (final a in assetsJson) {
          if (a is Map<String, dynamic>) assets.add(a);
        }
      }

      // Prefer the Inno Setup installer (silent install supported); fall
      // back to any .exe so a malformed release doesn't completely break
      // the check.
      var asset = _firstAssetEndingWith(assets, '_setup.exe');
      asset ??= _firstAssetEndingWith(assets, '.exe');
      if (asset == null) return null;

      final name = asset['name']?.toString() ?? '';
      final url = asset['browser_download_url']?.toString() ?? '';
      if (name.isEmpty || url.isEmpty) return null;

      return UpdateInfo(
        version: tagName,
        assetName: name,
        downloadUrl: url,
        releaseNotesUrl: htmlUrl,
        publishedAt: publishedAtStr != null
            ? DateTime.tryParse(publishedAtStr)
            : null,
        releaseNotes: notes,
      );
    } on Object catch (e, st) {
      _log.warning('fetchLatestRelease failed', e, st);
      return null;
    }
  }

  Map<String, dynamic>? _firstAssetEndingWith(
    List<Map<String, dynamic>> assets,
    String suffix,
  ) {
    final s = suffix.toLowerCase();
    for (final a in assets) {
      final n = a['name']?.toString().toLowerCase() ?? '';
      if (n.endsWith(s)) return a;
    }
    return null;
  }

  /// Downloads the installer to system temp, yielding progress events. The
  /// terminal event carries `filePath` (success) or completes the stream
  /// with an error (failure).
  Stream<UpdateDownloadEvent> downloadInstaller(UpdateInfo info) async* {
    final tmp = await getTemporaryDirectory();
    final dir = Directory(p.join(tmp.path, 'jellyfish_updates'));
    await dir.create(recursive: true);
    final dest = File(p.join(dir.path, info.assetName));

    // Always wipe any previous file: a partial/truncated installer from
    // an interrupted run would share the same filename (assetName) and a
    // length-based skip would hand back a corrupt installer. Re-fetch.
    if (dest.existsSync()) {
      await dest.delete();
    }

    final controller = StreamController<UpdateDownloadEvent>();
    unawaited(() async {
      try {
        await _dio.download(
          info.downloadUrl,
          dest.path,
          options: Options(
            headers: const {
              'User-Agent': 'JellyfishUpdateChecker/1.0',
            },
            receiveTimeout: const Duration(minutes: 10),
          ),
          onReceiveProgress: (received, total) {
            controller.add(
              UpdateDownloadEvent.progress(
                total > 0 ? received / total : -1,
              ),
            );
          },
        );
        controller.add(UpdateDownloadEvent.done(dest.path));
        await controller.close();
      } on Object catch (e, st) {
        _log.warning('downloadInstaller failed', e, st);
        controller.addError(e, st);
        await controller.close();
      }
    }());

    yield* controller.stream;
  }

  /// Spawns a detached `.bat` wrapper that waits for the running app to
  /// exit, then runs the Inno Setup installer silently and relaunches the
  /// app. Finally calls `exit(0)` so the installer can replace files. The
  /// `installer.iss` declares `PrivilegesRequired=lowest`, so no UAC
  /// prompt fires.
  Future<void> launchInstaller(String installerPath) async {
    if (!Platform.isWindows) {
      throw StateError('Silent install is Windows-only');
    }
    final exePath = Platform.resolvedExecutable;
    final rawExeName = p.basename(exePath);
    // Defensive: the wait-loop interpolates exeName into a tasklist filter
    // and into a `find /I` arg. We control this (it's our own exe), but a
    // path-injection from a corrupt resolvedExecutable would be ugly.
    // Keep alphanumerics, dot, dash, underscore.
    final exeName = rawExeName.replaceAll(RegExp('[^A-Za-z0-9._-]'), '');
    final tmp = await getTemporaryDirectory();
    final bat = File(p.join(tmp.path, 'jellyfish_apply_update.bat'));
    await bat.writeAsString(
      _updaterBat(
        exeName: exeName,
        exePath: exePath,
        installerPath: installerPath,
        batPath: bat.path,
      ),
    );

    await Process.start(
      'cmd.exe',
      ['/c', 'start', '', '/min', bat.path],
      mode: ProcessStartMode.detached,
      includeParentEnvironment: true,
    );
    // Hold long enough for the spawned cmd to attach AND read the .bat
    // into the parser. The .bat itself also pings 127.0.0.1 three times
    // (~2 s) before its first tasklist call to absorb any remaining lag.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    exit(0);
  }

  String _updaterBat({
    required String exeName,
    required String exePath,
    required String installerPath,
    required String batPath,
  }) {
    // The only character we still have to fix is `%` (cmd expands `%foo%`
    // as a variable even inside double-quoted strings). Filename forbids
    // `"`, `<`, `>`, `|` on Windows, so the surrounding double-quotes are
    // sufficient for the rest.
    String esc(String v) => v.replaceAll('%', '%%');
    final eExe = esc(exePath);
    final eInstaller = esc(installerPath);
    final eBat = esc(batPath);
    return '''
@echo off
ping -n 3 127.0.0.1 >NUL
set /a tries=0
:wait
tasklist /FI "IMAGENAME eq $exeName" 2>NUL | find /I "$exeName" >NUL
if "%ERRORLEVEL%"=="0" (
  set /a tries+=1
  if %tries% GEQ 60 goto runinstaller
  timeout /t 1 /nobreak >NUL
  goto wait
)
:runinstaller
"$eInstaller" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS
start "" "$eExe"
del "$eBat" >NUL 2>&1
''';
  }

  /// Compares two semver-ish strings. Returns true iff `candidate` > `current`.
  /// Strips a leading `v`/`V`, drops `-prerelease` and `+build` suffixes,
  /// pads to at least 3 numeric segments.
  static bool isNewer(String candidate, String current) {
    final c = _parseSemver(candidate);
    final r = _parseSemver(current);
    final n = c.length > r.length ? c.length : r.length;
    for (var i = 0; i < n; i++) {
      final left = i < c.length ? c[i] : 0;
      final right = i < r.length ? r[i] : 0;
      if (left > right) return true;
      if (left < right) return false;
    }
    return false;
  }

  static List<int> _parseSemver(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [0, 0, 0];
    final stripped = (trimmed.startsWith('v') || trimmed.startsWith('V'))
        ? trimmed.substring(1)
        : trimmed;
    final core = stripped.split('-').first.split('+').first;
    final parts = core
        .split('.')
        .map(
          (s) => int.tryParse(s.replaceAll(RegExp('[^0-9]'), '')) ?? 0,
        )
        .toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts;
  }
}

/// Progress event emitted by [UpdateService.downloadInstaller].
sealed class UpdateDownloadEvent {
  const UpdateDownloadEvent();

  const factory UpdateDownloadEvent.progress(double fraction) =
      UpdateDownloadProgress;
  const factory UpdateDownloadEvent.done(String filePath) =
      UpdateDownloadDone;
}

final class UpdateDownloadProgress extends UpdateDownloadEvent {
  const UpdateDownloadProgress(this.fraction);

  /// Fraction in [0, 1], or -1 when the size is unknown.
  final double fraction;
}

final class UpdateDownloadDone extends UpdateDownloadEvent {
  const UpdateDownloadDone(this.filePath);
  final String filePath;
}
