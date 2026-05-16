import 'dart:async';

// SyncPlayGroup contains a `List<SyncPlayMember>` (not const-constructible)
// so the analyzer can't const-eval the literals we build in this test file.
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart' as jf;
import 'package:jellyfish/core/playback/player_backend.dart';
import 'package:jellyfish/features/syncplay/data/sync_play_clock_offset.dart';
import 'package:jellyfish/features/syncplay/data/sync_play_player_bridge.dart';
import 'package:jellyfish/features/syncplay/data/sync_play_service.dart';
import 'package:jellyfish/features/syncplay/data/sync_play_session_controller.dart';
import 'package:jellyfish/features/syncplay/domain/sync_play_session.dart';

void main() {
  group('SyncPlayPlayerBridge', () {
    test('remote pause → backend.pause is called', () async {
      final backend = _FakeBackend();
      final service = _RecordingService();
      final controller = ProviderContainer(
        overrides: [
          syncPlayServiceProvider.overrideWithValue(service),
          syncPlayClockOffsetProvider.overrideWith((_) async => Duration.zero),
          syncPlaySessionProvider.overrideWith(_PreloadedController.new),
        ],
      );
      addTearDown(controller.dispose);
      // Trigger build, then warm up the listen pipeline before attaching the
      // bridge so the bridge's `fireImmediately: true` only sees the initial
      // `disconnected` state and not a pre-buffered paused one.
      await controller.read(syncPlaySessionProvider.future);
      // Sanity: post-build state should be `disconnected`.
      expect(
        controller.read(syncPlaySessionProvider).valueOrNull,
        isA<SyncPlaySessionDisconnected>(),
      );

      // Debug listener: makes sure the container does fire state changes.
      var listenerCalls = 0;
      final sub = controller.listen<AsyncValue<SyncPlaySession>>(
        syncPlaySessionProvider,
        (_, _) => listenerCalls += 1,
      );
      addTearDown(sub.close);

      // Same listener but routed through the adapter the bridge will use.
      var adapterCalls = 0;
      final adapter = ContainerBridgeRef(controller);
      final adapterSub = adapter.listen<AsyncValue<SyncPlaySession>>(
        syncPlaySessionProvider,
        (_, _) => adapterCalls += 1,
      );
      addTearDown(adapterSub.close);

      final bridge = SyncPlayPlayerBridge.fromBridgeRef(
        ref: ContainerBridgeRef(controller),
        backend: backend,
        onSwitchItem: (_) {},
      )..attach();
      addTearDown(bridge.detach);

      // Push paused.
      (controller.read(syncPlaySessionProvider.notifier)
              as _PreloadedController)
          .pushState(
            SyncPlaySession.paused(
              group: SyncPlayGroup(id: 'g-1', name: 'g', members: []),
              position: Duration(seconds: 5),
              playlistItemId: 'p-1',
            ),
          );
      // Sanity check : le state Riverpod reflète bien le push.
      expect(
        controller.read(syncPlaySessionProvider).valueOrNull,
        isA<SyncPlaySessionPaused>(),
      );

      // Microtask drain so the `container.listen` invocation gets flushed.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(listenerCalls, greaterThanOrEqualTo(1));
      expect(adapterCalls, greaterThanOrEqualTo(1));
      expect(backend.pauseCalls, greaterThanOrEqualTo(1));
      // Remote pauses should NOT bubble back into a SyncPlay pause request.
      expect(service.pauseCalls, 0);
    });

    test('local seek pushes service.seek with the target position', () async {
      final backend = _FakeBackend();
      final service = _RecordingService();
      final controller = ProviderContainer(
        overrides: [
          syncPlayServiceProvider.overrideWithValue(service),
          syncPlayClockOffsetProvider.overrideWith((_) async => Duration.zero),
          syncPlaySessionProvider.overrideWith(_PreloadedController.new),
        ],
      );
      addTearDown(controller.dispose);
      await controller.read(syncPlaySessionProvider.future);

      final bridge = SyncPlayPlayerBridge.fromBridgeRef(
        ref: ContainerBridgeRef(controller),
        backend: backend,
        onSwitchItem: (_) {},
      )..attach();
      addTearDown(bridge.detach);

      (controller.read(syncPlaySessionProvider.notifier)
              as _PreloadedController)
          .pushState(
            SyncPlaySession.playing(
              group: SyncPlayGroup(id: 'g-1', name: 'g', members: []),
              positionAtAnchor: Duration.zero,
              anchorServerUtc: DateTime.now().toUtc(),
              playlistItemId: 'p-1',
            ),
          );
      // Le bridge programme un timer + flag anti-rebond de 200 ms après une
      // commande remote. On attend que la fenêtre se referme avant de
      // simuler le seek manuel.
      await Future<void>.delayed(const Duration(milliseconds: 300));

      bridge.notifyLocalSeek(Duration(seconds: 42));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(service.seekCalls, [Duration(seconds: 42)]);
    });
  });
}

class _PreloadedController extends SyncPlaySessionController {
  @override
  Future<SyncPlaySession> build() async {
    // Bypass the parent's WS hookup — tests inject state via [pushState].
    return const SyncPlaySession.disconnected();
  }

  void pushState(SyncPlaySession next) {
    state = AsyncData(next);
  }
}

class _FakeBackend implements PlayerBackend {
  int pauseCalls = 0;
  int playCalls = 0;
  final List<Duration> seekTargets = [];
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  final _stateCtl = StreamController<BackendState>.broadcast();

  @override
  Future<void> dispose() async {
    await _stateCtl.close();
  }

  @override
  Future<void> open(
    String url, {
    Duration startPosition = Duration.zero,
  }) async {
    _position = startPosition;
  }

  @override
  Future<void> play() async {
    playCalls += 1;
    _isPlaying = true;
    _stateCtl.add(BackendState.playing);
  }

  @override
  Future<void> pause() async {
    pauseCalls += 1;
    _isPlaying = false;
    _stateCtl.add(BackendState.paused);
  }

  @override
  Future<void> seek(Duration position) async {
    seekTargets.add(position);
    _position = position;
  }

  @override
  Future<void> setAudioTrack(int trackIndex) async {}

  @override
  Future<void> setSpeed(double rate) async {}

  @override
  Future<void> setSubtitleTrack(int trackIndex) async {}

  @override
  List<AudioTrackInfo> get audioTracks => const [];

  @override
  Stream<Duration> get bufferedPositionStream => const Stream.empty();

  @override
  bool get isBuffering => false;

  @override
  Stream<bool> get bufferingStream => const Stream.empty();

  @override
  Stream<bool> get completedStream => const Stream.empty();

  @override
  int get currentAudioIndex => -1;

  @override
  int get currentSubtitleIndex => -1;

  @override
  Duration get duration => const Duration(minutes: 30);

  @override
  Stream<Duration> get durationStream => const Stream.empty();

  @override
  Stream<String> get errorStream => const Stream.empty();

  @override
  bool get isPlaying => _isPlaying;

  @override
  Duration get position => _position;

  @override
  Stream<Duration> get positionStream => const Stream.empty();

  @override
  BackendState get state =>
      _isPlaying ? BackendState.playing : BackendState.paused;

  @override
  Stream<BackendState> get stateStream => _stateCtl.stream;

  @override
  List<SubtitleTrackInfo> get subtitleTracks => const [];

  @override
  Object? get videoController => null;
}

class _RecordingService implements SyncPlayService {
  int pauseCalls = 0;
  int unpauseCalls = 0;
  final List<Duration> seekCalls = [];

  @override
  Future<SyncPlayGroup> createGroup({required String name}) async =>
      throw UnimplementedError();

  @override
  Future<void> joinGroup(String groupId) async {}

  @override
  Future<void> leaveGroup() async {}

  @override
  Future<List<SyncPlayGroup>> listOpenGroups() async => const [];

  @override
  Future<void> pause() async {
    pauseCalls += 1;
  }

  @override
  Future<void> unpause() async {
    unpauseCalls += 1;
  }

  @override
  Future<void> seek(Duration position) async {
    seekCalls.add(position);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> reportBuffering({
    required Duration position,
    required String playlistItemId,
    bool isPlaying = false,
  }) async {}

  @override
  Future<void> reportReady({
    required Duration position,
    required String playlistItemId,
    bool isPlaying = false,
  }) async {}

  @override
  Future<void> ping(Duration latency) async {}

  @override
  Future<void> setNewQueue({
    required List<String> itemIds,
    int startIndex = 0,
    Duration startPosition = Duration.zero,
  }) async {}

  @override
  Future<void> setRepeatMode(jf.GroupRepeatMode mode) async {}

  @override
  Future<void> setShuffleMode(jf.GroupShuffleMode mode) async {}
}
