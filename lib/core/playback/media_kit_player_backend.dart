import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'player_backend.dart';

class MediaKitPlayerBackend implements PlayerBackend {
  MediaKitPlayerBackend() {
    _player = Player();
    _videoController = VideoController(_player);
    _wireStreams();
  }

  late final Player _player;
  late final VideoController _videoController;

  final StreamController<BackendState> _stateController =
      StreamController<BackendState>.broadcast();
  final StreamController<bool> _completedController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  final List<StreamSubscription<Object?>> _subs = [];

  BackendState _state = BackendState.idle;
  List<SubtitleTrackInfo> _subtitleTracks = const [];
  List<AudioTrackInfo> _audioTracks = const [];
  int _currentSubtitleIndex = -1;
  int _currentAudioIndex = -1;

  void _wireStreams() {
    _subs
      ..add(
        _player.stream.playing.listen((playing) {
          if (_player.state.completed) return;
          _setState(playing ? BackendState.playing : BackendState.paused);
        }),
      )
      ..add(
        _player.stream.completed.listen((completed) {
          if (completed) {
            _setState(BackendState.ended);
            _completedController.add(true);
          }
        }),
      )
      ..add(
        _player.stream.buffering.listen((buffering) {
          if (buffering && _state != BackendState.error) {
            _setState(BackendState.loading);
          } else if (!buffering &&
              _state == BackendState.loading &&
              _player.state.duration > Duration.zero) {
            _setState(
              _player.state.playing
                  ? BackendState.playing
                  : BackendState.paused,
            );
          }
        }),
      )
      ..add(
        _player.stream.tracks.listen((tracks) {
          _subtitleTracks = _mapSubtitleTracks(tracks);
          _audioTracks = _mapAudioTracks(tracks);
        }),
      )
      ..add(
        _player.stream.track.listen((track) {
          _currentSubtitleIndex = _subtitleTracks.indexWhere(
            (t) => t.id == track.subtitle.id,
          );
          _currentAudioIndex = _audioTracks.indexWhere(
            (t) => t.id == track.audio.id,
          );
        }),
      )
      ..add(
        _player.stream.error.listen((msg) {
          if (msg.isEmpty) return;
          _setState(BackendState.error);
          _errorController.add(msg);
        }),
      );
  }

  void _setState(BackendState s) {
    if (_state == s) return;
    _state = s;
    _stateController.add(s);
  }

  List<SubtitleTrackInfo> _mapSubtitleTracks(Tracks tracks) {
    final result = <SubtitleTrackInfo>[];
    var i = 0;
    for (final t in tracks.subtitle) {
      // Skip the placeholder "auto" / "no" entries — handled separately.
      if (t.id == 'auto' || t.id == 'no') continue;
      result.add(
        SubtitleTrackInfo(
          index: i,
          id: t.id,
          language: t.language,
          label: t.title,
        ),
      );
      i++;
    }
    return result;
  }

  List<AudioTrackInfo> _mapAudioTracks(Tracks tracks) {
    final result = <AudioTrackInfo>[];
    var i = 0;
    for (final t in tracks.audio) {
      if (t.id == 'auto' || t.id == 'no') continue;
      result.add(
        AudioTrackInfo(
          index: i,
          id: t.id,
          language: t.language,
          label: t.title,
        ),
      );
      i++;
    }
    return result;
  }

  @override
  Future<void> open(
    String url, {
    Duration startPosition = Duration.zero,
  }) async {
    _setState(BackendState.loading);
    await _player.open(Media(url), play: false);
    // Wait for the demuxer to report a real duration before seeking — seeking
    // too early on libmpv silently no-ops.
    await _player.stream.duration
        .firstWhere((d) => d > Duration.zero)
        .timeout(const Duration(seconds: 15), onTimeout: () => Duration.zero);
    if (startPosition > Duration.zero) {
      await _player.seek(startPosition);
    }
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSubtitleTrack(int trackIndex) async {
    if (trackIndex < 0) {
      await _player.setSubtitleTrack(SubtitleTrack.no());
      return;
    }
    if (trackIndex >= _subtitleTracks.length) return;
    final mapped = _subtitleTracks[trackIndex];
    final native = _player.state.tracks.subtitle.firstWhere(
      (t) => t.id == mapped.id,
      orElse: SubtitleTrack.no,
    );
    await _player.setSubtitleTrack(native);
  }

  @override
  Future<void> setAudioTrack(int trackIndex) async {
    if (trackIndex < 0 || trackIndex >= _audioTracks.length) return;
    final mapped = _audioTracks[trackIndex];
    final native = _player.state.tracks.audio.firstWhere(
      (t) => t.id == mapped.id,
      orElse: AudioTrack.auto,
    );
    await _player.setAudioTrack(native);
  }

  @override
  Future<void> setSpeed(double rate) => _player.setRate(rate);

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    await _stateController.close();
    await _completedController.close();
    await _errorController.close();
    await _player.dispose();
  }

  @override
  Stream<Duration> get positionStream => _player.stream.position;

  @override
  Stream<Duration> get durationStream => _player.stream.duration;

  @override
  Stream<bool> get bufferingStream => _player.stream.buffering;

  @override
  Stream<Duration> get bufferedPositionStream => _player.stream.buffer;

  @override
  Stream<bool> get completedStream => _completedController.stream;

  @override
  Stream<BackendState> get stateStream => _stateController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Duration get position => _player.state.position;

  @override
  Duration get duration => _player.state.duration;

  @override
  bool get isPlaying => _player.state.playing;

  @override
  bool get isBuffering => _player.state.buffering;

  @override
  BackendState get state => _state;

  @override
  List<SubtitleTrackInfo> get subtitleTracks => _subtitleTracks;

  @override
  List<AudioTrackInfo> get audioTracks => _audioTracks;

  @override
  int get currentSubtitleIndex => _currentSubtitleIndex;

  @override
  int get currentAudioIndex => _currentAudioIndex;

  @override
  VideoController get videoController => _videoController;
}
