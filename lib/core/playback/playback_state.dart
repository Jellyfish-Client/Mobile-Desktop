import 'player_backend.dart';

/// Snapshot of the player surface state exposed to the UI. Updated on a 250ms
/// timer by `playbackStateNotifierProvider` to avoid widget rebuilds on every
/// libmpv position tick.
class PlaybackState {
  const PlaybackState({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.backendState = BackendState.idle,
    this.speed = 1.0,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final BackendState backendState;
  final double speed;

  double get progress {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  PlaybackState copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
    BackendState? backendState,
    double? speed,
  }) {
    return PlaybackState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      backendState: backendState ?? this.backendState,
      speed: speed ?? this.speed,
    );
  }
}
