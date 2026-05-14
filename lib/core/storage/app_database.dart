import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

enum DownloadStatus { queued, running, paused, completed, failed, cancelled }

/// Operation pending sync with Jellyfin once the device is back online.
enum SyncOperation {
  playbackProgress,
  playbackStopped,
  markPlayed,
  markUnplayed,
  addFavorite,
  removeFavorite,
}

/// Sentinel used as `accountKey` for rows written before multi-account support
/// landed (schema < v4). New writes always stamp the active account's key.
const String legacyAccountKey = '';

@DataClassName('DownloadRow')
@TableIndex(name: 'downloads_task_id_idx', columns: {#taskId})
@TableIndex(name: 'downloads_account_idx', columns: {#accountKey})
class Downloads extends Table {
  // Composite-key prefix. Empty for legacy v3 rows that pre-date multi-account.
  TextColumn get accountKey =>
      text().withDefault(const Constant(legacyAccountKey))();
  TextColumn get itemId => text()();
  TextColumn get itemType => text()();
  TextColumn get name => text()();
  TextColumn get seriesId => text().nullable()();
  TextColumn get seriesName => text().nullable()();
  TextColumn get seasonId => text().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  IntColumn get runtimeTicks => integer().nullable()();
  // Local path to the poster image (Primary type). Legacy column name kept
  // (`image_path`) so existing rows in v1/v2 dbs survive the migration.
  TextColumn get imagePath => text().nullable()();
  // Local path to the backdrop image (Backdrop type).
  TextColumn get backdropImagePath => text().nullable()();
  // Local path to the series-level poster, used when the row is an episode.
  TextColumn get seriesImagePath => text().nullable()();
  TextColumn get overview => text().nullable()();
  IntColumn get productionYear => integer().nullable()();
  RealColumn get communityRating => real().nullable()();
  TextColumn get officialRating => text().nullable()();
  // JSON-encoded list of genre names.
  TextColumn get genres => text().nullable()();
  TextColumn get localFilePath => text().nullable()();
  TextColumn get container => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get status => textEnum<DownloadStatus>()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn get taskId => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {accountKey, itemId};
}

/// Generic key/value store for stale-while-revalidate caches: we persist the
/// JSON payload of network responses (home rails today, possibly more later)
/// so cold starts can paint instantly from disk before revalidating.
@TableIndex(name: 'cached_responses_account_idx', columns: {#accountKey})
class CachedResponses extends Table {
  TextColumn get accountKey =>
      text().withDefault(const Constant(legacyAccountKey))();
  TextColumn get key => text()();
  TextColumn get payload => text()();
  IntColumn get fetchedAt => integer()(); // epoch milliseconds

  @override
  Set<Column<Object>> get primaryKey => {accountKey, key};
}

/// Pending operations queued while offline. Drained by `SyncService` when
/// connectivity is restored.
@DataClassName('SyncQueueRow')
@TableIndex(name: 'sync_queue_item_idx', columns: {#itemId})
@TableIndex(name: 'sync_queue_account_idx', columns: {#accountKey})
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountKey =>
      text().withDefault(const Constant(legacyAccountKey))();
  TextColumn get itemId => text()();
  TextColumn get operation => textEnum<SyncOperation>()();
  // JSON-encoded payload: depends on operation. For playback events it carries
  // positionTicks/playSessionId/mediaSourceId/isPaused; for play/favorite
  // toggles the body is `{}`.
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

@DriftDatabase(tables: [Downloads, CachedResponses, SyncQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test entry point: lets unit tests inject an in-memory
  /// `NativeDatabase.memory()` instead of opening the on-disk SQLite file.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(cachedResponses);
      }
      if (from < 3) {
        await m.addColumn(downloads, downloads.backdropImagePath);
        await m.addColumn(downloads, downloads.seriesImagePath);
        await m.addColumn(downloads, downloads.overview);
        await m.addColumn(downloads, downloads.productionYear);
        await m.addColumn(downloads, downloads.communityRating);
        await m.addColumn(downloads, downloads.officialRating);
        await m.addColumn(downloads, downloads.genres);
        await m.createTable(syncQueue);
        // `createTable` alone does not create the @TableIndex; on
        // upgrades we have to add it explicitly.
        await m.createIndex(syncQueueItemIdx);
      }
      if (from < 4) {
        // Multi-account scoping: every row now carries the `accountKey` of
        // the account that owns it. Pre-existing rows keep the legacy default
        // (empty string) and stay invisible to scoped reads until the
        // AccountsRepository explicitly claims them for the migrated account.
        await m.addColumn(downloads, downloads.accountKey);
        await m.addColumn(cachedResponses, cachedResponses.accountKey);
        await m.addColumn(syncQueue, syncQueue.accountKey);
        await m.createIndex(downloadsAccountIdx);
        await m.createIndex(cachedResponsesAccountIdx);
        await m.createIndex(syncQueueAccountIdx);
        // Backfill an index that has always been declared on the Downloads
        // table but never created on the v1 → v2 → v3 upgrade path. Without
        // it, every `findByTaskId` (called from the background_downloader
        // update handler) does a full scan. Wrap in try/catch because users
        // who upgraded v3 fresh already have the index via createAll(), and
        // `CREATE INDEX` (no IF NOT EXISTS) would throw on a duplicate.
        try {
          await m.createIndex(downloadsTaskIdIdx);
        } on Object {
          // Already exists — fine.
        }
      }
    },
  );

  // ---------------------------------------------------------------------------
  // Downloads queries (account-scoped)
  // ---------------------------------------------------------------------------

  Stream<List<DownloadRow>> watchAll(String accountKey) =>
      (select(downloads)
            ..where((t) => t.accountKey.equals(accountKey))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<DownloadRow?> watchByItemId(String accountKey, String id) =>
      (select(downloads)..where(
            (t) => t.accountKey.equals(accountKey) & t.itemId.equals(id),
          ))
          .watchSingleOrNull();

  Stream<List<DownloadRow>> watchInProgress(String accountKey) =>
      (select(downloads)
            ..where(
              (t) =>
                  t.accountKey.equals(accountKey) &
                  t.status.isInValues(const <DownloadStatus>[
                    DownloadStatus.queued,
                    DownloadStatus.running,
                    DownloadStatus.paused,
                  ]),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Stream<List<DownloadRow>> watchCompleted(String accountKey) =>
      (select(downloads)
            ..where(
              (t) =>
                  t.accountKey.equals(accountKey) &
                  t.status.equalsValue(DownloadStatus.completed),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .watch();

  Future<DownloadRow?> findByItemId(String accountKey, String id) =>
      (select(downloads)..where(
            (t) => t.accountKey.equals(accountKey) & t.itemId.equals(id),
          ))
          .getSingleOrNull();

  /// Task-id lookups intentionally bypass the accountKey filter: a TaskUpdate
  /// event from `background_downloader` carries no account context, and the
  /// taskId itself is uniquely generated per row so there's no collision risk.
  Future<DownloadRow?> findByTaskId(String taskId) => (select(
    downloads,
  )..where((t) => t.taskId.equals(taskId))).getSingleOrNull();

  Future<List<DownloadRow>> bySeason(String accountKey, String seasonId) =>
      (select(downloads)..where(
            (t) =>
                t.accountKey.equals(accountKey) & t.seasonId.equals(seasonId),
          ))
          .get();

  Future<List<DownloadRow>> bySeries(String accountKey, String seriesId) =>
      (select(downloads)..where(
            (t) =>
                t.accountKey.equals(accountKey) & t.seriesId.equals(seriesId),
          ))
          .get();

  Future<List<DownloadRow>> findActive(String accountKey) =>
      (select(downloads)..where(
            (t) =>
                t.accountKey.equals(accountKey) &
                t.status.isInValues(const <DownloadStatus>[
                  DownloadStatus.queued,
                  DownloadStatus.running,
                ]),
          ))
          .get();

  Future<void> upsertRow(DownloadsCompanion row) =>
      into(downloads).insertOnConflictUpdate(row);

  Future<void> updateProgress(
    String accountKey,
    String itemId,
    double progress,
  ) =>
      (update(downloads)..where(
            (t) => t.accountKey.equals(accountKey) & t.itemId.equals(itemId),
          ))
          .write(DownloadsCompanion(progress: Value(progress)));

  Future<void> setStatus(
    String accountKey,
    String itemId,
    DownloadStatus status, {
    String? error,
  }) =>
      (update(downloads)..where(
            (t) => t.accountKey.equals(accountKey) & t.itemId.equals(itemId),
          ))
          .write(
            DownloadsCompanion(
              status: Value(status),
              errorMessage: error == null ? const Value.absent() : Value(error),
            ),
          );

  Future<void> markCompleted(
    String accountKey,
    String itemId,
    String localPath,
    int? sizeBytes,
  ) =>
      (update(downloads)..where(
            (t) => t.accountKey.equals(accountKey) & t.itemId.equals(itemId),
          ))
          .write(
            DownloadsCompanion(
              status: const Value(DownloadStatus.completed),
              progress: const Value(1),
              localFilePath: Value(localPath),
              sizeBytes: sizeBytes == null
                  ? const Value.absent()
                  : Value(sizeBytes),
              completedAt: Value(DateTime.now()),
            ),
          );

  Future<void> setImagePaths(
    String accountKey,
    String itemId, {
    String? posterPath,
    String? backdropPath,
    String? seriesPosterPath,
  }) =>
      (update(downloads)..where(
            (t) => t.accountKey.equals(accountKey) & t.itemId.equals(itemId),
          ))
          .write(
            DownloadsCompanion(
              imagePath: posterPath == null
                  ? const Value.absent()
                  : Value(posterPath),
              backdropImagePath: backdropPath == null
                  ? const Value.absent()
                  : Value(backdropPath),
              seriesImagePath: seriesPosterPath == null
                  ? const Value.absent()
                  : Value(seriesPosterPath),
            ),
          );

  Future<void> deleteByItemId(String accountKey, String itemId) =>
      (delete(downloads)..where(
            (t) => t.accountKey.equals(accountKey) & t.itemId.equals(itemId),
          ))
          .go();

  /// Sum of `sizeBytes` for completed downloads on the given account.
  Future<int> totalDownloadedBytes(String accountKey) async {
    final sum = downloads.sizeBytes.sum();
    final q = selectOnly(downloads)
      ..where(
        downloads.accountKey.equals(accountKey) &
            downloads.status.equalsValue(DownloadStatus.completed),
      )
      ..addColumns([sum]);
    final row = await q.getSingleOrNull();
    return row?.read(sum) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Cached responses (SWR), account-scoped
  // ---------------------------------------------------------------------------

  Future<CachedResponse?> readCachedResponse(String accountKey, String key) =>
      (select(cachedResponses)
            ..where((t) => t.accountKey.equals(accountKey) & t.key.equals(key)))
          .getSingleOrNull();

  Future<void> writeCachedResponse(
    String accountKey,
    String key,
    String payload,
  ) => into(cachedResponses).insertOnConflictUpdate(
    CachedResponsesCompanion.insert(
      accountKey: Value(accountKey),
      key: key,
      payload: payload,
      fetchedAt: DateTime.now().millisecondsSinceEpoch,
    ),
  );

  /// Wipes cached responses for a single account — used on logout of that
  /// account. Other accounts keep their warm SWR cache.
  Future<void> clearCachedResponsesFor(String accountKey) => (delete(
    cachedResponses,
  )..where((t) => t.accountKey.equals(accountKey))).go();

  /// Nukes the entire cache. Used by tests and by the legacy "wipe everything"
  /// path; switching accounts no longer calls this thanks to scoping.
  Future<void> clearAllCachedResponses() => delete(cachedResponses).go();

  // ---------------------------------------------------------------------------
  // Sync queue, account-scoped
  // ---------------------------------------------------------------------------

  Future<int> enqueueSync({
    required String accountKey,
    required String itemId,
    required SyncOperation operation,
    String payloadJson = '{}',
  }) => into(syncQueue).insert(
    SyncQueueCompanion.insert(
      accountKey: Value(accountKey),
      itemId: itemId,
      operation: operation,
      createdAt: DateTime.now(),
      payloadJson: Value(payloadJson),
    ),
  );

  /// Replaces any existing playbackProgress row for [itemId] (within
  /// [accountKey]) so we only keep the most recent position. PlaybackStopped
  /// events are NOT collapsed — the queue may legitimately contain one stopped
  /// event per session.
  Future<void> upsertPlaybackProgress({
    required String accountKey,
    required String itemId,
    required String payloadJson,
  }) async {
    await transaction(() async {
      await (delete(syncQueue)..where(
            (t) =>
                t.accountKey.equals(accountKey) &
                t.itemId.equals(itemId) &
                t.operation.equalsValue(SyncOperation.playbackProgress),
          ))
          .go();
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          accountKey: Value(accountKey),
          itemId: itemId,
          operation: SyncOperation.playbackProgress,
          createdAt: DateTime.now(),
          payloadJson: Value(payloadJson),
        ),
      );
    });
  }

  Stream<int> watchPendingSyncCount(String accountKey) {
    final count = syncQueue.id.count();
    final q = selectOnly(syncQueue)
      ..where(syncQueue.accountKey.equals(accountKey))
      ..addColumns([count]);
    return q.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Future<List<SyncQueueRow>> pendingSyncBatch(
    String accountKey, {
    int limit = 20,
  }) =>
      (select(syncQueue)
            ..where((t) => t.accountKey.equals(accountKey))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<void> deleteSyncRow(int id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  Future<void> incrementSyncAttempts(int id, String error) async {
    final current = await (select(
      syncQueue,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (current == null) return;
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        attempts: Value(current.attempts + 1),
        lastError: Value(error),
      ),
    );
  }

  Stream<List<SyncQueueRow>> watchPendingSyncByItem(
    String accountKey,
    String itemId,
  ) =>
      (select(syncQueue)
            ..where(
              (t) => t.accountKey.equals(accountKey) & t.itemId.equals(itemId),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  // ---------------------------------------------------------------------------
  // Multi-account migration helpers
  // ---------------------------------------------------------------------------

  /// One-shot "claim" performed by the AccountsRepository after migrating a
  /// legacy `session_v1` blob into an `accounts_v1` entry: re-stamps every row
  /// that still carries the empty legacyAccountKey so the migrated user
  /// inherits its own download history / cache / pending syncs instead of
  /// losing them on first launch after the upgrade.
  Future<void> claimLegacyRowsFor(String accountKey) async {
    if (accountKey == legacyAccountKey) return;
    await batch((b) {
      b
        ..update(
          downloads,
          DownloadsCompanion(accountKey: Value(accountKey)),
          where: (t) => t.accountKey.equals(legacyAccountKey),
        )
        ..update(
          cachedResponses,
          CachedResponsesCompanion(accountKey: Value(accountKey)),
          where: (t) => t.accountKey.equals(legacyAccountKey),
        )
        ..update(
          syncQueue,
          SyncQueueCompanion(accountKey: Value(accountKey)),
          where: (t) => t.accountKey.equals(legacyAccountKey),
        );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'jellyfish.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    return NativeDatabase.createInBackground(file);
  });
}
