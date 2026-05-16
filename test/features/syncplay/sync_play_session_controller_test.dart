import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart' as jf;
import 'package:jellyfish/core/network/jellyfin_websocket.dart';
import 'package:jellyfish/core/network/jellyfin_websocket_provider.dart';
import 'package:jellyfish/features/syncplay/data/sync_play_providers.dart';
import 'package:jellyfish/features/syncplay/data/sync_play_service.dart';
import 'package:jellyfish/features/syncplay/domain/sync_play_session.dart';
import 'package:stream_channel/stream_channel.dart';

void main() {
  group('SyncPlaySessionController state machine', () {
    test(
      'joins → idle → playing → paused as frames stream in',
      () async {
        final wsCtl = StreamChannelController<dynamic>();
        final ws = JellyfinWebSocket(
          accessToken: 'tok',
          deviceId: 'dev',
          serverUrl: 'http://example.com/',
          channelFactory: (_) => wsCtl.foreign,
        )..start();

        addTearDown(ws.dispose);

        final container = ProviderContainer(
          overrides: [
            jellyfinWebSocketProvider.overrideWith((_) => ws),
            jellyfinWebSocketFramesProvider.overrideWith((_) => ws.frames),
            syncPlayServiceProvider.overrideWithValue(_FakeService()),
          ],
        );
        addTearDown(container.dispose);

        // Wait for the AsyncNotifier to resolve.
        await container.read(syncPlaySessionProvider.future);
        expect(
          container.read(syncPlaySessionProvider).valueOrNull,
          isA<SyncPlaySessionDisconnected>(),
        );

        // Push a GroupJoined frame on the wire.
        wsCtl.local.sink.add('''
{
  "MessageType":"SyncPlayGroupUpdate",
  "Data":{
    "GroupId":"g-1",
    "Type":"GroupJoined",
    "Data":{
      "GroupId":"g-1",
      "GroupName":"Cinéma",
      "State":"Idle",
      "Participants":["alice","bob"]
    }
  }
}
''');
        await _waitFor(() {
          final state = container.read(syncPlaySessionProvider).valueOrNull;
          return state is SyncPlaySessionIdle;
        });
        var state = container.read(syncPlaySessionProvider).valueOrNull;
        expect(state, isA<SyncPlaySessionIdle>());
        expect(state!.group?.id, 'g-1');
        expect(state.group?.name, 'Cinéma');
        expect(state.group?.members.length, 2);

        // StateUpdate → Playing
        wsCtl.local.sink.add('''
{
  "MessageType":"SyncPlayGroupUpdate",
  "Data":{
    "GroupId":"g-1",
    "Type":"StateUpdate",
    "Data":{"State":"Playing","Reason":"Unpause"}
  }
}
''');
        await _waitFor(() {
          final state = container.read(syncPlaySessionProvider).valueOrNull;
          return state is SyncPlaySessionPlaying;
        });
        expect(
          container.read(syncPlaySessionProvider).valueOrNull,
          isA<SyncPlaySessionPlaying>(),
        );

        // SyncPlayCommand Pause @ 12000 ticks
        wsCtl.local.sink.add('''
{
  "MessageType":"SyncPlayCommand",
  "Data":{
    "GroupId":"g-1",
    "Command":"Pause",
    "PositionTicks":120000000,
    "When":"2026-05-16T12:00:00Z",
    "EmittedAt":"2026-05-16T12:00:00Z"
  }
}
''');
        await _waitFor(() {
          final state = container.read(syncPlaySessionProvider).valueOrNull;
          return state is SyncPlaySessionPaused;
        });
        state = container.read(syncPlaySessionProvider).valueOrNull;
        expect(state, isA<SyncPlaySessionPaused>());
        expect(
          (state! as SyncPlaySessionPaused).position,
          const Duration(seconds: 12),
        );

        // LibraryAccessDenied → Error
        wsCtl.local.sink.add('''
{
  "MessageType":"SyncPlayGroupUpdate",
  "Data":{
    "GroupId":"g-1",
    "Type":"LibraryAccessDenied",
    "Data":""
  }
}
''');
        await _waitFor(() {
          final state = container.read(syncPlaySessionProvider).valueOrNull;
          return state is SyncPlaySessionError;
        });
        state = container.read(syncPlaySessionProvider).valueOrNull;
        expect(state, isA<SyncPlaySessionError>());
        expect(
          (state! as SyncPlaySessionError).kind,
          SyncPlayErrorKind.libraryAccessDenied,
        );
      },
      // Le test attend des notifications stream — on borne pour ne pas figer
      // la suite de tests si le matching échoue.
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });
}

Future<void> _waitFor(
  bool Function() predicate, {
  Duration step = const Duration(milliseconds: 50),
  Duration max = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(max);
  while (DateTime.now().isBefore(deadline)) {
    if (predicate()) return;
    await Future<void>.delayed(step);
  }
  throw StateError('Predicate not satisfied within $max');
}

class _FakeService implements SyncPlayService {
  @override
  Future<SyncPlayGroup> createGroup({required String name}) async =>
      SyncPlayGroup(id: 'g-1', name: name, members: const []);

  @override
  Future<void> joinGroup(String groupId) async {}

  @override
  Future<void> leaveGroup() async {}

  @override
  Future<List<SyncPlayGroup>> listOpenGroups() async => const [];

  @override
  Future<void> pause() async {}

  @override
  Future<void> unpause() async {}

  @override
  Future<void> seek(Duration position) async {}

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
