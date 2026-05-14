import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/activity/activity_log_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockActivityLogApi extends Mock implements ActivityLogApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

ActivityLogEntry _entry({int id = 1, String name = 'Login'}) =>
    ActivityLogEntry(
      (b) => b
        ..id = id
        ..name = name,
    );

ActivityLogEntryQueryResult _queryResult(
  List<ActivityLogEntry> items, {
  int? total,
}) =>
    ActivityLogEntryQueryResult(
      (b) => b
        ..items = ListBuilder(items)
        ..totalRecordCount = total ?? items.length,
    );

void main() {
  late _MockJellyfinApi api;
  late _MockActivityLogApi activityApi;

  setUp(() {
    api = _MockJellyfinApi();
    activityApi = _MockActivityLogApi();
    when(() => api.getActivityLogApi()).thenReturn(activityApi);
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('AdminActivityLogNotifier', () {
    test('build loads first page and sets hasMore correctly', () async {
      final entries = List.generate(50, (i) => _entry(id: i));
      when(() => activityApi.getLogEntries(
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => _ok(_queryResult(entries, total: 120)));

      final c = makeContainer();
      final state = await c.read(adminActivityLogProvider.future);

      expect(state.entries.length, 50);
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
    });

    test('build returns empty state when server returns empty list', () async {
      when(() => activityApi.getLogEntries(
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => _ok(_queryResult([])));

      final c = makeContainer();
      final state = await c.read(adminActivityLogProvider.future);

      expect(state.entries, isEmpty);
      expect(state.hasMore, isFalse);
    });

    test('build exposes AsyncError when API throws', () async {
      when(() => activityApi.getLogEntries(
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
          )).thenThrow(Exception('server error'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminActivityLogProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminActivityLogProvider).hasError, isTrue);
    });

    test('loadMore appends entries to existing list', () async {
      final firstPage = List.generate(50, (i) => _entry(id: i));
      final secondPage = List.generate(30, (i) => _entry(id: 50 + i));

      var callCount = 0;
      when(() => activityApi.getLogEntries(
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return _ok(_queryResult(firstPage, total: 80));
        }
        return _ok(_queryResult(secondPage, total: 80));
      });

      final c = makeContainer();
      await c.read(adminActivityLogProvider.future);
      await c.read(adminActivityLogProvider.notifier).loadMore();

      final state = c.read(adminActivityLogProvider).requireValue;
      expect(state.entries.length, 80);
      expect(state.hasMore, isFalse);
    });

    test('setFilterLast7Days resets to first page and updates filter flag',
        () async {
      when(() => activityApi.getLogEntries(
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
            minDate: any(named: 'minDate'),
            hasUserId: any(named: 'hasUserId'),
          )).thenAnswer(
        (_) async => _ok(_queryResult([_entry()], total: 1)),
      );

      final c = makeContainer();
      await c.read(adminActivityLogProvider.future);
      await c
          .read(adminActivityLogProvider.notifier)
          .setFilterLast7Days(value: true);

      final state = c.read(adminActivityLogProvider).requireValue;
      expect(state.filterLast7Days, isTrue);
      expect(state.entries.length, 1);
    });

    test('setFilterUserOnly resets to first page and updates filter flag',
        () async {
      when(() => activityApi.getLogEntries(
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
            hasUserId: any(named: 'hasUserId'),
          )).thenAnswer(
        (_) async => _ok(_queryResult([_entry()], total: 1)),
      );

      final c = makeContainer();
      await c.read(adminActivityLogProvider.future);
      await c
          .read(adminActivityLogProvider.notifier)
          .setFilterUserOnly(value: true);

      final state = c.read(adminActivityLogProvider).requireValue;
      expect(state.filterUserOnly, isTrue);
    });

    test('loadMore is no-op when hasMore is false', () async {
      when(() => activityApi.getLogEntries(
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
          )).thenAnswer(
        (_) async => _ok(_queryResult([_entry()], total: 1)),
      );

      final c = makeContainer();
      await c.read(adminActivityLogProvider.future);
      await c.read(adminActivityLogProvider.notifier).loadMore();

      // getLogEntries should only have been called once (build), not for loadMore
      verify(() => activityApi.getLogEntries(
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
          )).called(1);
    });
  });
}
