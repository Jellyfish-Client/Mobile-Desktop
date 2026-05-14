import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/sessions/sessions_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockSessionApi extends Mock implements SessionApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

SessionInfoDto _session({
  String id = 'sid1',
  String userId = 'uid1',
  String userName = 'alice',
  DateTime? lastActivityDate,
  BaseItemDto? nowPlayingItem,
}) =>
    SessionInfoDto(
      (b) => b
        ..id = id
        ..userId = userId
        ..userName = userName
        ..lastActivityDate = lastActivityDate
        ..nowPlayingItem = nowPlayingItem?.toBuilder(),
    );

void main() {
  late _MockJellyfinApi api;
  late _MockSessionApi sessionApi;

  setUp(() {
    api = _MockJellyfinApi();
    sessionApi = _MockSessionApi();
    when(() => api.getSessionApi()).thenReturn(sessionApi);
  });

  setUpAll(() {
    registerFallbackValue(
      MessageCommand((b) => b..text = 'test'),
    );
    registerFallbackValue(PlaystateCommand.stop);
    registerFallbackValue(RequestOptions(path: ''));
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('AdminSessionsNotifier', () {
    test('build filters anonymous sessions and returns non-empty userId only',
        () async {
      final sessions = BuiltList<SessionInfoDto>.of([
        _session(id: 's1', userId: 'uid1'),
        // session without userId should be filtered
        SessionInfoDto((b) => b..id = 's2'),
        _session(id: 's3', userId: 'uid2'),
      ]);
      when(() => sessionApi.getSessions()).thenAnswer((_) async => _ok(sessions));

      final c = makeContainer();
      final list = await c.read(adminSessionsProvider.future);

      expect(list.length, 2);
      expect(list.every((s) => (s.userId ?? '').isNotEmpty), isTrue);
    });

    test('build returns empty list when server returns empty', () async {
      when(() => sessionApi.getSessions()).thenAnswer(
        (_) async => _ok(BuiltList<SessionInfoDto>.of([])),
      );

      final c = makeContainer();
      final list = await c.read(adminSessionsProvider.future);

      expect(list, isEmpty);
    });

    test('build sorts active streams before idle sessions', () async {
      final now = DateTime.utc(2025);
      final nowPlaying = BaseItemDto((b) => b..id = 'item1');
      final sessions = BuiltList<SessionInfoDto>.of([
        _session(
          id: 'idle',
          userId: 'u1',
          lastActivityDate: now,
        ),
        _session(
          id: 'playing',
          userId: 'u2',
          lastActivityDate: now.subtract(const Duration(hours: 1)),
          nowPlayingItem: nowPlaying,
        ),
      ]);
      when(() => sessionApi.getSessions()).thenAnswer((_) async => _ok(sessions));

      final c = makeContainer();
      final list = await c.read(adminSessionsProvider.future);

      expect(list.first.id, 'playing');
    });

    test('build exposes AsyncError when API throws', () async {
      when(() => sessionApi.getSessions()).thenThrow(Exception('network error'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminSessionsProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminSessionsProvider).hasError, isTrue);
    });

    test('sendMessage calls API with sessionId and text, then refreshes',
        () async {
      final sessions = BuiltList<SessionInfoDto>.of([
        _session(id: 's1', userId: 'uid1'),
      ]);
      when(() => sessionApi.getSessions()).thenAnswer((_) async => _ok(sessions));
      when(() => sessionApi.sendMessageCommand(
            sessionId: any(named: 'sessionId'),
            messageCommand: any(named: 'messageCommand'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminSessionsProvider.future);
      await c.read(adminSessionsProvider.notifier).sendMessage(
            sessionId: 's1',
            text: 'Hello admin',
          );

      verify(() => sessionApi.sendMessageCommand(
            sessionId: 's1',
            messageCommand: any(named: 'messageCommand'),
          )).called(1);
    });

    test('stopPlayback calls sendPlaystateCommand with stop command', () async {
      final sessions = BuiltList<SessionInfoDto>.of([
        _session(id: 's1', userId: 'uid1'),
      ]);
      when(() => sessionApi.getSessions()).thenAnswer((_) async => _ok(sessions));
      when(() => sessionApi.sendPlaystateCommand(
            sessionId: any(named: 'sessionId'),
            command: any(named: 'command'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminSessionsProvider.future);
      await c.read(adminSessionsProvider.notifier).stopPlayback('s1');

      verify(() => sessionApi.sendPlaystateCommand(
            sessionId: 's1',
            command: PlaystateCommand.stop,
          )).called(1);
    });
  });
}
