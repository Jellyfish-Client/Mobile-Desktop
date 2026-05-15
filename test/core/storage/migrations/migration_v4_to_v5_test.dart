@TestOn('vm')
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/storage/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// End-to-end migration test for schema v4 → v5 (PR-DB1).
///
/// We don't depend on `drift_dev`'s schema-verifier dumps: instead we hand-roll
/// the v4 DDL via raw `sqlite3` calls (matching exactly what `app_database.g`
/// produced before the bump), seed a few representative rows, set
/// `user_version = 4`, then open `AppDatabase` on top of the file. Drift's
/// `MigrationStrategy.onUpgrade` runs naturally and we assert post-conditions.
void main() {
  late Directory tmpDir;
  late File dbFile;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('jellyfish_migration_test_');
    dbFile = File(p.join(tmpDir.path, 'app.sqlite'));
  });

  tearDown(() {
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  test('v4 → v5 adds retry columns and backfills next_retry_at', () async {
    _seedV4Database(dbFile.path);

    // Opening AppDatabase on the seeded file triggers MigrationStrategy with
    // from=4, to=5.
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    // Force a query so the lazy migration actually fires before our asserts.
    final pending = await db.pendingSyncBatch('alice');
    expect(pending, hasLength(1));

    // user_version must now be 5 — Drift writes this at the end of the
    // upgrade transaction.
    final raw = sqlite.sqlite3.open(dbFile.path);
    try {
      final userVersion = raw
          .select('PRAGMA user_version')
          .first
          .columnAt(0) as int;
      // Drift runs every onUpgrade step between `from` and `to`, so a
      // database seeded at v4 ends up at the current schemaVersion (6 since
      // the cached_responses PK rebuild landed). The v5 retry-column
      // assertions below still validate the v4→v5 step independently.
      expect(userVersion, 6);

      // Both tables must now expose the four retry columns.
      final syncCols = raw
          .select('PRAGMA table_info(sync_queue)')
          .map((r) => r['name'] as String)
          .toSet();
      expect(syncCols, containsAll(<String>['attempts', 'last_error']));
      expect(syncCols, containsAll(<String>['last_attempt_at', 'next_retry_at']));

      final dlCols = raw
          .select('PRAGMA table_info(downloads)')
          .map((r) => r['name'] as String)
          .toSet();
      expect(
        dlCols,
        containsAll(<String>[
          'attempts',
          'last_attempt_at',
          'next_retry_at',
          'last_error',
        ]),
      );

      // Backfill: the seeded sync_queue row had created_at=1700000000 and
      // next_retry_at=NULL → migration must stamp next_retry_at to created_at.
      final rows = raw.select(
        'SELECT id, created_at, next_retry_at FROM sync_queue',
      );
      expect(rows, hasLength(1));
      final row = rows.first;
      expect(row['next_retry_at'], row['created_at']);
      expect(row['next_retry_at'], 1700000000);

      // Brand-new download columns default to 0 / NULL: existing v4 download
      // rows must survive untouched (and now satisfy
      // `RetryableQueueEntry.attempts == 0`).
      final dl = raw.select('SELECT attempts, last_error FROM downloads').first;
      expect(dl['attempts'], 0);
      expect(dl['last_error'], isNull);
    } finally {
      raw.dispose();
    }
  });

  test('inserts written after migration round-trip the new columns', () async {
    _seedV4Database(dbFile.path);

    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    // New enqueue does NOT pass nextRetryAt → stays NULL, which the worker
    // treats as "eligible immediately" via BackoffPolicy.isEligible.
    await db.enqueueSync(
      accountKey: 'alice',
      itemId: 'item-new',
      operation: SyncOperation.markPlayed,
    );

    final batch = await db.pendingSyncBatch('alice');
    expect(batch, hasLength(2));
    final fresh = batch.firstWhere((r) => r.itemId == 'item-new');
    expect(fresh.attempts, 0);
    expect(fresh.lastAttemptAt, isNull);
    expect(fresh.nextRetryAt, isNull);
    expect(fresh.lastError, isNull);
  });
}

/// Recreates the exact v4 schema using raw SQL so the migration has a real
/// fixture to upgrade. The DDL mirrors what `drift_dev` produced at v4 (epoch-
/// second `INTEGER` for DateTime columns, `TEXT` enums, etc.).
void _seedV4Database(String path) {
  final raw = sqlite.sqlite3.open(path);
  try {
    // Schema version 4 — matches the pre-PR-DB1 generated code.
    raw
      ..execute('''
        CREATE TABLE downloads (
          account_key TEXT NOT NULL DEFAULT '',
          item_id TEXT NOT NULL,
          item_type TEXT NOT NULL,
          name TEXT NOT NULL,
          series_id TEXT,
          series_name TEXT,
          season_id TEXT,
          season_number INTEGER,
          episode_number INTEGER,
          runtime_ticks INTEGER,
          image_path TEXT,
          backdrop_image_path TEXT,
          series_image_path TEXT,
          overview TEXT,
          production_year INTEGER,
          community_rating REAL,
          official_rating TEXT,
          genres TEXT,
          local_file_path TEXT,
          container TEXT,
          size_bytes INTEGER,
          status TEXT NOT NULL,
          progress REAL NOT NULL DEFAULT 0,
          task_id TEXT,
          error_message TEXT,
          created_at INTEGER NOT NULL,
          completed_at INTEGER,
          PRIMARY KEY (account_key, item_id)
        )
      ''')
      ..execute('''
        CREATE INDEX downloads_task_id_idx ON downloads (task_id)
      ''')
      ..execute('''
        CREATE INDEX downloads_account_idx ON downloads (account_key)
      ''')
      ..execute('''
        CREATE TABLE cached_responses (
          account_key TEXT NOT NULL DEFAULT '',
          key TEXT NOT NULL,
          payload TEXT NOT NULL,
          fetched_at INTEGER NOT NULL,
          PRIMARY KEY (account_key, key)
        )
      ''')
      ..execute('''
        CREATE INDEX cached_responses_account_idx
          ON cached_responses (account_key)
      ''')
      ..execute('''
        CREATE TABLE sync_queue (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          account_key TEXT NOT NULL DEFAULT '',
          item_id TEXT NOT NULL,
          operation TEXT NOT NULL,
          payload_json TEXT NOT NULL DEFAULT '{}',
          created_at INTEGER NOT NULL,
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT
        )
      ''')
      ..execute('''
        CREATE INDEX sync_queue_item_idx ON sync_queue (item_id)
      ''')
      ..execute('''
        CREATE INDEX sync_queue_account_idx ON sync_queue (account_key)
      ''')
      // Seed: one queued sync op with NULL next_retry_at (the migration must
      // backfill it to created_at) and one completed download.
      ..execute(
        'INSERT INTO sync_queue (account_key, item_id, operation, '
        'payload_json, created_at, attempts) VALUES '
        "('alice', 'item-1', 'markPlayed', '{}', 1700000000, 0)",
      )
      ..execute(
        'INSERT INTO downloads (account_key, item_id, item_type, name, '
        'status, progress, created_at) VALUES '
        "('alice', 'movie-1', 'Movie', 'Test movie', 'completed', 1, "
        '1700000000)',
      )
      // Pin the user_version so Drift treats this as a v4 DB on next open.
      ..execute('PRAGMA user_version = 4');
  } finally {
    raw.dispose();
  }
}
