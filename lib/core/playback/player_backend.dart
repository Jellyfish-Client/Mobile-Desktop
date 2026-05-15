enum BackendState { idle, loading, playing, paused, ended, error }

class SubtitleTrackInfo {
  const SubtitleTrackInfo({
    required this.index,
    required this.id,
    this.language,
    this.label,
  });
  final int index;
  final String id;
  final String? language;
  final String? label;

  String displayLabel() {
    final l = label?.trim();
    if (l != null && l.isNotEmpty) return l;
    final lang = language?.trim();
    if (lang != null && lang.isNotEmpty) return lang.toUpperCase();
    return 'Track ${index + 1}';
  }
}

class AudioTrackInfo {
  const AudioTrackInfo({
    required this.index,
    required this.id,
    this.language,
    this.label,
  });
  final int index;
  final String id;
  final String? language;
  final String? label;

  String displayLabel() {
    final l = label?.trim();
    if (l != null && l.isNotEmpty) return l;
    final lang = language?.trim();
    if (lang != null && lang.isNotEmpty) return lang.toUpperCase();
    return 'Audio ${index + 1}';
  }
}

/// Platform-agnostic playback engine. Implementations wrap a concrete native
/// player (currently media_kit; a Media3/ExoPlayer impl can be added later).
abstract class PlayerBackend {
  Future<void> open(String url, {Duration startPosition = Duration.zero});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);

  /// `-1` disables subtitles entirely.
  Future<void> setSubtitleTrack(int trackIndex);
  Future<void> setAudioTrack(int trackIndex);
  Future<void> setSpeed(double rate);
  Future<void> dispose();

  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get bufferingStream;

  /// Continuously emits the latest buffered position — i.e. the timestamp up
  /// to which the player has pre-loaded data. Used by the system media
  /// session to draw the buffer ahead of the play head on the lockscreen.
  Stream<Duration> get bufferedPositionStream;

  /// Edge-only stream — emits a single `true` when the source ends naturally.
  Stream<bool> get completedStream;
  Stream<BackendState> get stateStream;
  Stream<String> get errorStream;

  Duration get position;
  Duration get duration;
  bool get isPlaying;
  bool get isBuffering;
  BackendState get state;

  List<SubtitleTrackInfo> get subtitleTracks;
  List<AudioTrackInfo> get audioTracks;
  int get currentSubtitleIndex;
  int get currentAudioIndex;

  /// media_kit-only — the concrete `VideoController` instance. Other backends
  /// return null; the UI layer downcasts.
  Object? get videoController;
}
