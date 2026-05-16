import 'dart:async';

import 'package:logging/logging.dart';

import 'playback_event_sink.dart';

/// Owns the lifecycle of Jellyfin's `/Sessions/Playing*` reporting for a
/// single playback session. Delegates the actual transport to a
/// [PlaybackEventSink] so the same orchestrator handles both online
/// (`OnlinePlaybackSink`) and offline (`OfflinePlaybackSink`) modes.
class PlaybackReportingService {
  PlaybackReportingService({
    required this.sink,
    required this.positionTicksProvider,
    this.isSyncPlayActive,
  });

  static final _log = Logger('PlaybackReporting');

  final PlaybackEventSink sink;
  final int Function() positionTicksProvider;

  /// Garde optionnelle : si elle retourne `true`, on saute tous les reports
  /// `Start`/`Progress`/`Stop`. Le `SyncPlayPlayerBridge` la branche pour
  /// éviter un double-reporting (le serveur Jellyfin gère lui-même la
  /// session SyncPlay côté `/Sessions/*`).
  final bool Function()? isSyncPlayActive;

  Timer? _timer;
  bool _isPaused = false;
  bool _stopped = false;

  bool get _muted => isSyncPlayActive?.call() ?? false;

  Future<void> start({required int startTicks}) async {
    if (_muted) {
      _log.fine('start skipped: SyncPlay session owns reporting');
    } else {
      try {
        await sink.start(positionTicks: startTicks);
      } on Object catch (e) {
        _log.warning('sink.start failed: $e');
      }
    }
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _sendProgress(),
    );
  }

  void onPauseChanged({required bool paused}) {
    _isPaused = paused;
    _sendProgress();
  }

  void onSeek() => _sendProgress();

  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    _timer?.cancel();
    _timer = null;
    if (_muted) return;
    try {
      await sink.stop(positionTicks: positionTicksProvider());
    } on Object catch (e) {
      _log.warning('sink.stop failed: $e');
    }
  }

  Future<void> _sendProgress() async {
    if (_stopped) return;
    if (_muted) return;
    try {
      await sink.progress(
        positionTicks: positionTicksProvider(),
        isPaused: _isPaused,
      );
    } on Object catch (e) {
      _log.fine('sink.progress failed: $e');
    }
  }
}
