import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
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
  JellyfishAudioHandler() {
    unawaited(_initAudioSession());
  }

  static final _log = Logger('AudioHandler');

  PlayerBackend? _backend;

  StreamSubscription<BackendState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<Duration>? _bufferedPositionSub;

  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _becomingNoisySub;

  /// Latest known buffered position. Updated by the backend's
  /// `bufferedPositionStream` and surfaced through [_emitState] so iOS
  /// lockscreen / Android notification can draw the buffer-ahead band
  /// correctly.
  Duration _lastBufferedPosition = Duration.zero;

  /// Latest position received from `positionStream`. Updated silently on every
  /// tick so the periodic timer can read the most recent value without
  /// subscribing to individual position events for each update. The timer
  /// itself calls [_emitState] once per second, which is the maximum rate
  /// needed by the OS media session / lock-screen controls.
  Duration _lastKnownPosition = Duration.zero;

  /// Periodic 1Hz timer that propagates position to the OS media session.
  /// Started in [attachBackend], cancelled in [detachBackend].
  Timer? _positionTimer;

  /// True when we paused playback in response to an audio focus interruption
  /// (incoming call, Siri, etc.). On the matching `end` event with a
  /// resumable type, we transparently restart playback.
  bool _pausedByInterruption = false;

  Future<void> Function()? _onSkipNext;

  /// Configures the system audio session and subscribes to interruption /
  /// becoming-noisy notifications. Called once from the constructor; failures
  /// degrade gracefully (the audio session may not be available on some test
  /// hosts), and we never throw out of the constructor path.
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      _interruptionSub =
          session.interruptionEventStream.listen(_onInterruption);
      _becomingNoisySub =
          session.becomingNoisyEventStream.listen((_) => _onBecomingNoisy());
    } on Object catch (e, st) {
      _log.warning('AudioSession init failed', e, st);
    }
  }

  void _onInterruption(AudioInterruptionEvent event) {
    if (event.type == AudioInterruptionType.duck) {
      // audio_service handles ducking automatically — leave playback alone.
      return;
    }
    if (event.begin) {
      _pausedByInterruption = true;
      unawaited(pause());
      return;
    }
    // Interruption ended — only resume when we were the ones who paused, and
    // the OS hint says "resume is allowed" (pause type on iOS/Android).
    if (_pausedByInterruption &&
        event.type == AudioInterruptionType.pause) {
      _pausedByInterruption = false;
      unawaited(play());
    } else {
      _pausedByInterruption = false;
    }
  }

  void _onBecomingNoisy() {
    // Headphones unplugged / BT disconnect — pause unconditionally. This is
    // the iOS HIG + Play Store policy mandated behavior.
    unawaited(pause());
  }

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
    _lastBufferedPosition = Duration.zero;

    mediaItem.add(item);

    _stateSub = backend.stateStream.listen(_onBackendState);
    // Position stream updates _lastKnownPosition silently — the 1Hz periodic
    // timer is the only path that calls _emitState for position ticks.
    _positionSub = backend.positionStream.listen((pos) {
      _lastKnownPosition = pos;
    });
    _bufferedPositionSub =
        backend.bufferedPositionStream.listen(_onBackendBufferedPosition);
    _completedSub = backend.completedStream.listen((_) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.completed,
          playing: false,
        ),
      );
    });

    // 1Hz ticker: propagates the latest position to the OS media session.
    // This is sufficient for lock-screen / notification accuracy and avoids
    // spamming audio_service at the raw ~1Hz position stream rate.
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final b = _backend;
      if (b == null) return;
      _emitState(
        playing: b.isPlaying,
        processing: _mapProcessing(b.state),
        position: _lastKnownPosition,
        bufferedPosition: _lastBufferedPosition,
        hasNext: _onSkipNext != null,
      );
    });

    _emitState(
      playing: backend.isPlaying,
      processing: _mapProcessing(backend.state),
      position: backend.position,
      bufferedPosition: _lastBufferedPosition,
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
    _positionTimer?.cancel();
    _positionTimer = null;
    await _stateSub?.cancel();
    await _positionSub?.cancel();
    await _bufferedPositionSub?.cancel();
    await _completedSub?.cancel();
    _stateSub = null;
    _positionSub = null;
    _bufferedPositionSub = null;
    _completedSub = null;
    _backend = null;
    _onSkipNext = null;
    _lastBufferedPosition = Duration.zero;
    _lastKnownPosition = Duration.zero;
    _pausedByInterruption = false;
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

  /// Tears down audio-session subscriptions. Call at app shutdown; safe to
  /// invoke repeatedly.
  Future<void> dispose() async {
    await _interruptionSub?.cancel();
    await _becomingNoisySub?.cancel();
    _interruptionSub = null;
    _becomingNoisySub = null;
  }

  void _onBackendState(BackendState s) {
    final b = _backend;
    if (b == null) return;
    _emitState(
      playing: b.isPlaying,
      processing: _mapProcessing(s),
      position: b.position,
      bufferedPosition: _lastBufferedPosition,
      hasNext: _onSkipNext != null,
    );
  }

  void _onBackendBufferedPosition(Duration buffered) {
    _lastBufferedPosition = buffered;
    final b = _backend;
    if (b == null) return;
    _emitState(
      playing: b.isPlaying,
      processing: _mapProcessing(b.state),
      position: b.position,
      bufferedPosition: buffered,
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
