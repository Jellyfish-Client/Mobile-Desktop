import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/playback/media_session_service.dart';
import 'package:jellyfish/core/playback/player_backend.dart';

// ---------------------------------------------------------------------------
// Fake backend — exposes StreamControllers so each test drives events manually
// ---------------------------------------------------------------------------

class _FakePlayerBackend extends Fake implements PlayerBackend {
  _FakePlayerBackend({
    BackendState initialState = BackendState.idle,
    bool initialIsPlaying = false,
    Duration initialPosition = Duration.zero,
  })  : state = initialState,
        isPlaying = initialIsPlaying,
        position = initialPosition;

  @override
  BackendState state;

  @override
  bool isPlaying;

  @override
  Duration position;

  @override
  Duration get duration => Duration.zero;

  @override
  bool get isBuffering => false;

  final _stateCtrl = StreamController<BackendState>.broadcast();
  final _positionCtrl = StreamController<Duration>.broadcast();
  final _completedCtrl = StreamController<bool>.broadcast();
  final _errorCtrl = StreamController<String>.broadcast();
  final _durationCtrl = StreamController<Duration>.broadcast();
  final _bufferingCtrl = StreamController<bool>.broadcast();
  final _bufferedPositionCtrl = StreamController<Duration>.broadcast();

  @override
  Stream<BackendState> get stateStream => _stateCtrl.stream;
  @override
  Stream<Duration> get positionStream => _positionCtrl.stream;
  @override
  Stream<bool> get completedStream => _completedCtrl.stream;
  @override
  Stream<String> get errorStream => _errorCtrl.stream;
  @override
  Stream<Duration> get durationStream => _durationCtrl.stream;
  @override
  Stream<bool> get bufferingStream => _bufferingCtrl.stream;
  @override
  Stream<Duration> get bufferedPositionStream => _bufferedPositionCtrl.stream;

  // Tracked calls
  int playCalls = 0;
  int pauseCalls = 0;
  final List<Duration> seekCalls = [];

  @override
  Future<void> play() async => playCalls++;
  @override
  Future<void> pause() async => pauseCalls++;
  @override
  Future<void> seek(Duration position) async => seekCalls.add(position);

  @override
  List<SubtitleTrackInfo> get subtitleTracks => [];
  @override
  List<AudioTrackInfo> get audioTracks => [];
  @override
  int get currentSubtitleIndex => -1;
  @override
  int get currentAudioIndex => -1;
  @override
  Object? get videoController => null;

  @override
  Future<void> open(String url, {Duration startPosition = Duration.zero}) async {}
  @override
  Future<void> setSubtitleTrack(int trackIndex) async {}
  @override
  Future<void> setAudioTrack(int trackIndex) async {}
  @override
  Future<void> setSpeed(double rate) async {}
  @override
  Future<void> dispose() async {
    await _stateCtrl.close();
    await _positionCtrl.close();
    await _completedCtrl.close();
    await _errorCtrl.close();
    await _durationCtrl.close();
    await _bufferingCtrl.close();
    await _bufferedPositionCtrl.close();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MediaItem _mediaItem({String id = 'item-1', String title = 'Test Item'}) {
  return MediaItem(id: id, title: title);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late JellyfishAudioHandler handler;

  setUp(() {
    handler = JellyfishAudioHandler();
  });

  tearDown(() async {
    await handler.detachBackend();
  });

  // -------------------------------------------------------------------------
  group('attachBackend', () {
    test('sets mediaItem and reflects initial backend state', () {
      final backend = _FakePlayerBackend(
        initialState: BackendState.playing,
        initialIsPlaying: true,
      );
      final item = _mediaItem();

      handler.attachBackend(
        backend: backend,
        item: item,
        onSkipNext: null,
      );

      expect(handler.mediaItem.value, equals(item));
      expect(handler.playbackState.value.playing, isTrue);
      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.ready,
      );
    });

    test('re-attaching to a second backend cancels subscriptions on the first',
        () async {
      final backendA = _FakePlayerBackend(
        initialState: BackendState.paused,
        initialIsPlaying: false,
      );
      final backendB = _FakePlayerBackend(
        initialState: BackendState.paused,
        initialIsPlaying: false,
      );

      handler
        ..attachBackend(
          backend: backendA,
          item: _mediaItem(id: 'a'),
          onSkipNext: null,
        )
        ..attachBackend(
          backend: backendB,
          item: _mediaItem(id: 'b'),
          onSkipNext: null,
        );

      // Allow pending async operations (detachBackend future) to complete
      await Future<void>.delayed(Duration.zero);

      // mediaItem must reflect B
      expect(handler.mediaItem.value?.id, 'b');

      // Capture stable state, then emit on A — subs on A must be cancelled
      // so this event should be silently dropped
      final stateBeforeEventOnA = handler.playbackState.value;
      backendA._stateCtrl.add(BackendState.playing);
      await Future<void>.delayed(Duration.zero);

      expect(
        handler.playbackState.value.processingState,
        stateBeforeEventOnA.processingState,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('play()', () {
    test('is no-op when no backend is attached', () async {
      await expectLater(handler.play(), completes);
    });

    test('calls backend.play() once when attached', () async {
      final backend = _FakePlayerBackend();
      handler.attachBackend(
        backend: backend,
        item: _mediaItem(),
        onSkipNext: null,
      );

      await handler.play();

      expect(backend.playCalls, equals(1));
    });
  });

  // -------------------------------------------------------------------------
  group('pause()', () {
    test('propagates paused state to playbackState', () async {
      final backend = _FakePlayerBackend(
        initialState: BackendState.playing,
        initialIsPlaying: true,
      );
      handler.attachBackend(
        backend: backend,
        item: _mediaItem(),
        onSkipNext: null,
      );

      // Simulate backend transitioning to paused
      backend
        ..isPlaying = false
        ..state = BackendState.paused;
      backend._stateCtrl.add(BackendState.paused);
      await Future<void>.delayed(Duration.zero);

      expect(handler.playbackState.value.playing, isFalse);
      final controls = handler.playbackState.value.controls;
      expect(controls.contains(MediaControl.play), isTrue);
      expect(controls.contains(MediaControl.pause), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('skipToNext()', () {
    test('is no-op when onSkipNext is null', () async {
      final backend = _FakePlayerBackend();
      handler.attachBackend(
        backend: backend,
        item: _mediaItem(),
        onSkipNext: null,
      );

      await expectLater(handler.skipToNext(), completes);
    });

    test('invokes callback once when provided', () async {
      var callCount = 0;
      final backend = _FakePlayerBackend();
      handler.attachBackend(
        backend: backend,
        item: _mediaItem(),
        onSkipNext: () async => callCount++,
      );

      await handler.skipToNext();

      expect(callCount, equals(1));
    });
  });

  // -------------------------------------------------------------------------
  group('skipToPrevious()', () {
    test('calls backend.seek(Duration.zero)', () async {
      final backend = _FakePlayerBackend();
      handler.attachBackend(
        backend: backend,
        item: _mediaItem(),
        onSkipNext: null,
      );

      await handler.skipToPrevious();

      expect(backend.seekCalls, equals([Duration.zero]));
    });
  });

  // -------------------------------------------------------------------------
  group('completedStream', () {
    test('sets processingState to completed and playing to false', () async {
      final backend = _FakePlayerBackend(
        initialState: BackendState.playing,
        initialIsPlaying: true,
      );
      handler.attachBackend(
        backend: backend,
        item: _mediaItem(),
        onSkipNext: null,
      );

      backend._completedCtrl.add(true);
      await Future<void>.delayed(Duration.zero);

      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.completed,
      );
      expect(handler.playbackState.value.playing, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('updateSkipNext()', () {
    test('adds skipToNext control when callback is set', () {
      final backend = _FakePlayerBackend();
      handler
        ..attachBackend(
          backend: backend,
          item: _mediaItem(),
          onSkipNext: null,
        )
        ..updateSkipNext(() async {});
      final controls = handler.playbackState.value.controls;
      expect(controls.contains(MediaControl.skipToNext), isTrue);
    });

    test('removes skipToNext control when callback is null', () {
      final backend = _FakePlayerBackend();
      handler
        ..attachBackend(
          backend: backend,
          item: _mediaItem(),
          onSkipNext: () async {},
        )
        ..updateSkipNext(null);
      final controls = handler.playbackState.value.controls;
      expect(controls.contains(MediaControl.skipToNext), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('detachBackend()', () {
    test('emits idle state and cancels subscriptions', () async {
      final backend = _FakePlayerBackend(
        initialState: BackendState.playing,
        initialIsPlaying: true,
      );
      handler.attachBackend(
        backend: backend,
        item: _mediaItem(),
        onSkipNext: null,
      );

      await handler.detachBackend();

      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.idle,
      );
      expect(handler.playbackState.value.playing, isFalse);

      // Emit on detached backend — no crash and state stays idle
      backend._stateCtrl.add(BackendState.playing);
      await Future<void>.delayed(Duration.zero);

      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.idle,
      );
    });
  });
}
