import 'dart:convert';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/logs/logs_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockSystemApi extends Mock implements SystemApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

LogFile _logFile({
  String name = 'jellyfin.log',
  DateTime? dateModified,
}) =>
    LogFile(
      (b) => b
        ..name = name
        ..dateModified = dateModified,
    );

void main() {
  late _MockJellyfinApi api;
  late _MockSystemApi systemApi;

  setUp(() {
    api = _MockJellyfinApi();
    systemApi = _MockSystemApi();
    when(() => api.getSystemApi()).thenReturn(systemApi);
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('adminServerLogsProvider', () {
    test('returns log files sorted by dateModified descending', () async {
      final now = DateTime.utc(2025);
      final logs = BuiltList<LogFile>.of([
        _logFile(name: 'old.log', dateModified: now.subtract(const Duration(days: 7))),
        _logFile(name: 'recent.log', dateModified: now),
        _logFile(name: 'mid.log', dateModified: now.subtract(const Duration(days: 1))),
      ]);
      when(() => systemApi.getServerLogs())
          .thenAnswer((_) async => _ok(logs));

      final c = makeContainer();
      final list = await c.read(adminServerLogsProvider.future);

      expect(list.length, 3);
      expect(list.first.name, 'recent.log');
      expect(list.last.name, 'old.log');
    });

    test('returns empty list when server has no logs', () async {
      when(() => systemApi.getServerLogs()).thenAnswer(
        (_) async => _ok(BuiltList<LogFile>.of([])),
      );

      final c = makeContainer();
      final list = await c.read(adminServerLogsProvider.future);

      expect(list, isEmpty);
    });

    test('exposes AsyncError when API throws', () async {
      when(() => systemApi.getServerLogs()).thenThrow(Exception('not found'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminServerLogsProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminServerLogsProvider).hasError, isTrue);
    });
  });

  group('adminLogFileProvider', () {
    test('decodes UTF-8 bytes from server response', () async {
      const content = 'Hello Jellyfin log';
      final bytes = Uint8List.fromList(utf8.encode(content));
      when(() => systemApi.getLogFile(name: any(named: 'name')))
          .thenAnswer((_) async => _ok(bytes));

      final c = makeContainer();
      final text = await c.read(adminLogFileProvider('jellyfin.log').future);

      expect(text, content);
    });

    test('passes filename to getLogFile', () async {
      final bytes = Uint8List.fromList(utf8.encode('log content'));
      when(() => systemApi.getLogFile(name: any(named: 'name')))
          .thenAnswer((_) async => _ok(bytes));

      final c = makeContainer();
      await c.read(adminLogFileProvider('server.log').future);

      verify(() => systemApi.getLogFile(name: 'server.log')).called(1);
    });

    test('returns empty string when data is null', () async {
      when(() => systemApi.getLogFile(name: any(named: 'name')))
          .thenAnswer((_) async => _ok(Uint8List(0)));

      final c = makeContainer();
      final text = await c.read(adminLogFileProvider('empty.log').future);

      expect(text, isEmpty);
    });

    test('exposes AsyncError when API throws', () async {
      when(() => systemApi.getLogFile(name: any(named: 'name')))
          .thenThrow(Exception('file not found'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminLogFileProvider('missing.log').future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
    });
  });
}
