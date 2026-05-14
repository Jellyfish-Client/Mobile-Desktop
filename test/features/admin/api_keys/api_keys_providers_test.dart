import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/api_keys/api_keys_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockApiKeyApi extends Mock implements ApiKeyApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

AuthenticationInfo _key({
  String accessToken = 'tok1',
  String appName = 'MyApp',
  DateTime? dateCreated,
}) =>
    AuthenticationInfo(
      (b) => b
        ..accessToken = accessToken
        ..appName = appName
        ..dateCreated = dateCreated,
    );

AuthenticationInfoQueryResult _queryResult(List<AuthenticationInfo> items) =>
    AuthenticationInfoQueryResult(
      (b) => b..items = ListBuilder(items),
    );

void main() {
  late _MockJellyfinApi api;
  late _MockApiKeyApi apiKeyApi;

  setUp(() {
    api = _MockJellyfinApi();
    apiKeyApi = _MockApiKeyApi();
    when(() => api.getApiKeyApi()).thenReturn(apiKeyApi);
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('AdminApiKeysNotifier', () {
    test('build returns keys sorted by dateCreated descending', () async {
      final now = DateTime.utc(2025);
      final keys = [
        _key(accessToken: 'old', dateCreated: now.subtract(const Duration(days: 30))),
        _key(accessToken: 'newest', dateCreated: now),
        _key(accessToken: 'mid', dateCreated: now.subtract(const Duration(days: 7))),
      ];
      when(() => apiKeyApi.getKeys()).thenAnswer(
        (_) async => _ok(_queryResult(keys)),
      );

      final c = makeContainer();
      final list = await c.read(adminApiKeysProvider.future);

      expect(list.length, 3);
      expect(list.first.accessToken, 'newest');
      expect(list.last.accessToken, 'old');
    });

    test('build returns empty list when server returns empty', () async {
      when(() => apiKeyApi.getKeys()).thenAnswer(
        (_) async => _ok(_queryResult([])),
      );

      final c = makeContainer();
      final list = await c.read(adminApiKeysProvider.future);

      expect(list, isEmpty);
    });

    test('build exposes AsyncError when API throws', () async {
      when(() => apiKeyApi.getKeys()).thenThrow(Exception('forbidden'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminApiKeysProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminApiKeysProvider).hasError, isTrue);
    });

    test('create calls createKey with correct appName and refreshes', () async {
      final keys = [_key()];
      when(() => apiKeyApi.getKeys()).thenAnswer(
        (_) async => _ok(_queryResult(keys)),
      );
      when(() => apiKeyApi.createKey(app: any(named: 'app')))
          .thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminApiKeysProvider.future);
      await c.read(adminApiKeysProvider.notifier).create('HomeAssistant');

      verify(() => apiKeyApi.createKey(app: 'HomeAssistant')).called(1);
      verify(() => apiKeyApi.getKeys()).called(2);
    });

    test('revoke calls revokeKey with correct accessToken and refreshes',
        () async {
      final keys = [_key(accessToken: 'tok-abc')];
      when(() => apiKeyApi.getKeys()).thenAnswer(
        (_) async => _ok(_queryResult(keys)),
      );
      when(() => apiKeyApi.revokeKey(key: any(named: 'key')))
          .thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminApiKeysProvider.future);
      await c.read(adminApiKeysProvider.notifier).revoke('tok-abc');

      verify(() => apiKeyApi.revokeKey(key: 'tok-abc')).called(1);
    });

    test('create propagates error when API throws', () async {
      final keys = [_key()];
      when(() => apiKeyApi.getKeys()).thenAnswer(
        (_) async => _ok(_queryResult(keys)),
      );
      when(() => apiKeyApi.createKey(app: any(named: 'app')))
          .thenThrow(Exception('quota exceeded'));

      final c = makeContainer();
      await c.read(adminApiKeysProvider.future);

      expect(
        () => c.read(adminApiKeysProvider.notifier).create('BadApp'),
        throwsException,
      );
    });
  });
}
