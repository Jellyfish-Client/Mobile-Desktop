import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'player_backend.dart';

/// Global Riverpod handle on the singleton [JellyfishAudioHandler]. The real
/// instance is created by `AudioService.init(...)` in `main.dart` and wired
/// here via an override on the root ProviderContainer.
final audioHandlerProvider = Provider<JellyfishAudioHandler>((ref) {
  throw UnimplementedError(
    'audioHandlerProvider must be overridden in main() after AudioService.init',
  );
});

/// Bridge between media_kit and the OS-level media session (Android
/// MediaSessionCompat + iOS MPNowPlayingInfoCenter). Created once at boot via
/// [AudioService.init] and reused across PlayerScreen instances.
///
/// PlayerScreen calls [attachBackend] right after `backend.open()` to push
/// the initial MediaItem and start forwarding stream events to
/// `playbackState`. On dispose, it calls [detachBackend] to cancel
/// subscriptions and emit a terminal `idle` state that clears the
/// notification.
///
/// Decision: this handler is intentionally transport-only — it never talks
/// to the Jellyfin server. All `/Sessions/Playing*` reporting stays owned by
/// `PlaybackReportingService`. A media-button pause hits `backend.pause()`,
/// which surfaces on `backend.stateStream`; PlayerScreen's existing listener
/// on that stream forwards the transition to the reporting service — no
/// duplication, no parallel path.
class JellyfishAudioHandler extends BaseAudioHandler with SeekHandler {
  JellyfishAudioHandler();

  static final _log = Logger('AudioHandler');

  PlayerBackend? _backend;

  StreamSubscription<BackendState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _completedSub;

  Future<void> Function()? _onSkipNext;

  /// Wires this handler to a freshly-opened [PlayerBackend] and pushes the
  /// initial [MediaItem]. Detaches a previous backend first if one is
  /// attached — safe to call repeatedly.
  void attachBackend({
    required PlayerBackend backend,
    required MediaItem item,
    Future<void> Function()? onSkipNext,
  }) {
    if (_backend != null) {
      detachBackend();
    }
    _backend = backend;
    _onSkipNext = onSkipNext;

    mediaItem.add(item);

    _stateSub = backend.stateStream.listen(_onBackendState);
    _positionSub = backend.positionStream.listen(_onBackendPosition);
    _completedSub = backend.completedStream.listen((_) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.completed,
          playing: false,
        ),
      );
    });

    _emitState(
      playing: backend.isPlaying,
      processing: _mapProcessing(backend.state),
      position: backend.position,
      bufferedPosition: backend.position,
      hasNext: _onSkipNext != null,
    );
  }

  /// Replaces the active MediaItem mid-session (e.g. duration finalized after
  /// demuxing). No-op when no backend is attached.
  @override
  Future<void> updateMediaItem(MediaItem item) async {
    if (_backend == null) return;
    mediaItem.add(item);
  }

  /// Toggles the system "Next" button availability without re-attaching.
  void updateSkipNext(Future<void> Function()? onSkipNext) {
    _onSkipNext = onSkipNext;
    final s = playbackState.value;
    playbackState.add(
      s.copyWith(
        controls: _controlsFor(playing: s.playing, hasNext: onSkipNext != null),
        systemActions: _systemActions,
      ),
    );
  }

  /// Tears down all subscriptions and emits a terminal `idle` state to
  /// dismiss the system notification.
  Future<void> detachBackend() async {
    final hadBackend = _backend != null;
    await _stateSub?.cancel();
    await _positionSub?.cancel();
    await _completedSub?.cancel();
    _stateSub = null;
    _positionSub = null;
    _completedSub = null;
    _backend = null;
    _onSkipNext = null;
    if (hadBackend) {
      playbackState.add(
        PlaybackState(
          controls: const [],
          systemActions: const {},
          processingState: AudioProcessingState.idle,
          playing: false,
        ),
      );
    }
  }

  void _onBackendState(BackendState s) {
    final b = _backend;
    if (b == null) return;
    _emitState(
      playing: b.isPlaying,
      processing: _mapProcessing(s),
      position: b.position,
      bufferedPosition: b.position,
      hasNext: _onSkipNext != null,
    );
  }

  void _onBackendPosition(Duration position) {
    final b = _backend;
    if (b == null) return;
    _emitState(
      playing: b.isPlaying,
      processing: _mapProcessing(b.state),
      position: position,
      bufferedPosition: position,
      hasNext: _onSkipNext != null,
    );
  }

  void _emitState({
    required bool playing,
    required AudioProcessingState processing,
    required Duration position,
    required Duration bufferedPosition,
    required bool hasNext,
  }) {
    playbackState.add(
      PlaybackState(
        controls: _controlsFor(playing: playing, hasNext: hasNext),
        systemActions: _systemActions,
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processing,
        playing: playing,
        updatePosition: position,
        bufferedPosition: bufferedPosition,
        speed: 1,
      ),
    );
  }

  AudioProcessingState _mapProcessing(BackendState s) {
    switch (s) {
      case BackendState.idle:
        return AudioProcessingState.idle;
      case BackendState.loading:
        return AudioProcessingState.loading;
      case BackendState.playing:
      case BackendState.paused:
        return AudioProcessingState.ready;
      case BackendState.ended:
        return AudioProcessingState.completed;
      case BackendState.error:
        return AudioProcessingState.error;
    }
  }

  List<MediaControl> _controlsFor({
    required bool playing,
    required bool hasNext,
  }) {
    return [
      MediaControl.skipToPrevious,
      if (playing) MediaControl.pause else MediaControl.play,
      if (hasNext) MediaControl.skipToNext,
      MediaControl.stop,
    ];
  }

  static const Set<MediaAction> _systemActions = {
    MediaAction.seek,
    MediaAction.seekForward,
    MediaAction.seekBackward,
    MediaAction.play,
    MediaAction.pause,
    MediaAction.stop,
    MediaAction.skipToNext,
    MediaAction.skipToPrevious,
  };

  @override
  Future<void> play() async {
    final b = _backend;
    if (b == null) return;
    try {
      await b.play();
    } on Object catch (e, st) {
      _log.warning('handler.play failed', e, st);
    }
  }

  @override
  Future<void> pause() async {
    final b = _backend;
    if (b == null) return;
    try {
      await b.pause();
    } on Object catch (e, st) {
      _log.warning('handler.pause failed', e, st);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    final b = _backend;
    if (b == null) return;
    try {
      await b.seek(position);
    } on Object catch (e, st) {
      _log.warning('handler.seek failed', e, st);
    }
  }

  @override
  Future<void> skipToNext() async {
    final cb = _onSkipNext;
    if (cb == null) return;
    try {
      await cb();
    } on Object catch (e, st) {
      _log.warning('handler.skipToNext failed', e, st);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final b = _backend;
    if (b == null) return;
    // Soft "restart current item" — Jellyfin doesn't expose a stable
    // previous-episode endpoint without an extra fetch.
    try {
      await b.seek(Duration.zero);
    } on Object catch (e, st) {
      _log.warning('handler.skipToPrevious failed', e, st);
    }
  }

  @override
  Future<void> stop() async {
    final b = _backend;
    if (b != null) {
      try {
        await b.pause();
      } on Object catch (e, st) {
        _log.warning('handler.stop->pause failed', e, st);
      }
    }
    await super.stop();
  }
}
