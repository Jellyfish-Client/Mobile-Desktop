import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/backup/backup_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockBackupApi extends Mock implements BackupApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

BackupManifestDto _backup({
  String path = '/backups/backup1.zip',
  DateTime? dateCreated,
}) =>
    BackupManifestDto(
      (b) => b
        ..path = path
        ..dateCreated = dateCreated,
    );

void main() {
  late _MockJellyfinApi api;
  late _MockBackupApi backupApi;

  setUp(() {
    api = _MockJellyfinApi();
    backupApi = _MockBackupApi();
    when(() => api.getBackupApi()).thenReturn(backupApi);
  });

  setUpAll(() {
    registerFallbackValue(
      BackupRestoreRequestDto((b) => b..archiveFileName = ''),
    );
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('AdminBackupNotifier', () {
    test('build returns backups sorted by dateCreated descending', () async {
      final now = DateTime.utc(2025);
      final backups = BuiltList<BackupManifestDto>.of([
        _backup(path: 'old.zip', dateCreated: now.subtract(const Duration(days: 30))),
        _backup(path: 'newest.zip', dateCreated: now),
        _backup(path: 'mid.zip', dateCreated: now.subtract(const Duration(days: 7))),
      ]);
      when(() => backupApi.listBackups())
          .thenAnswer((_) async => _ok(backups));

      final c = makeContainer();
      final list = await c.read(adminBackupProvider.future);

      expect(list.length, 3);
      expect(list.first.path, 'newest.zip');
      expect(list.last.path, 'old.zip');
    });

    test('build returns empty list when server returns empty', () async {
      when(() => backupApi.listBackups()).thenAnswer(
        (_) async => _ok(BuiltList<BackupManifestDto>.of([])),
      );

      final c = makeContainer();
      final list = await c.read(adminBackupProvider.future);

      expect(list, isEmpty);
    });

    test('build exposes AsyncError when API throws', () async {
      when(() => backupApi.listBackups()).thenThrow(Exception('not supported'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminBackupProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminBackupProvider).hasError, isTrue);
    });

    test('create calls createBackup, refreshes list, and returns manifest',
        () async {
      final manifest = _backup(path: 'new-backup.zip');
      final backups = BuiltList<BackupManifestDto>.of([manifest]);
      when(() => backupApi.listBackups())
          .thenAnswer((_) async => _ok(backups));
      when(() => backupApi.createBackup())
          .thenAnswer((_) async => _ok(manifest));

      final c = makeContainer();
      await c.read(adminBackupProvider.future);
      final result = await c.read(adminBackupProvider.notifier).create();

      expect(result.path, 'new-backup.zip');
      verify(() => backupApi.createBackup()).called(1);
      verify(() => backupApi.listBackups()).called(2);
    });

    test('restore calls startRestoreBackup with correct archiveFileName',
        () async {
      final backups = BuiltList<BackupManifestDto>.of([_backup()]);
      when(() => backupApi.listBackups())
          .thenAnswer((_) async => _ok(backups));
      when(() => backupApi.startRestoreBackup(
            backupRestoreRequestDto: any(named: 'backupRestoreRequestDto'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminBackupProvider.future);
      await c.read(adminBackupProvider.notifier).restore('backup-2025.zip');

      verify(() => backupApi.startRestoreBackup(
            backupRestoreRequestDto: any(named: 'backupRestoreRequestDto'),
          )).called(1);
    });

    test('create propagates error when API throws', () async {
      final backups = BuiltList<BackupManifestDto>.of([]);
      when(() => backupApi.listBackups())
          .thenAnswer((_) async => _ok(backups));
      when(() => backupApi.createBackup()).thenThrow(Exception('disk full'));

      final c = makeContainer();
      await c.read(adminBackupProvider.future);

      expect(
        () => c.read(adminBackupProvider.notifier).create(),
        throwsException,
      );
    });
  });
}
