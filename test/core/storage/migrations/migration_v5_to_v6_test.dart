@TestOn('vm')
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/storage/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// End-to-end migration test for schema v5 → v6.
///
/// The bug fixed by v6: users who installed the app at v2 (or earlier paths
/// that built the `cached_responses` table without `account_key` in its
/// primary key) ended up with `PRIMARY KEY (key)` on-disk. The v4 migration
/// added the `account_key` column but SQLite can't ALTER a primary key, so
/// the composite PK declared in the Dart `CachedResponses` table
/// (`{accountKey, key}`) never reached those databases. Drift's
/// `insertOnConflictUpdate` then emits `ON CONFLICT(account_key, key)` which
/// SQLite rejects with "ON CONFLICT clause does not match any PRIMARY KEY or
/// UNIQUE constraint" — every SWR `cache.write` throws and the home screen
/// shows a black body with no rails.
///
/// The v6 migration drops `cached_responses` and recreates it from the
/// current Dart definition so the on-disk PK matches the code. Cache
/// content is regenerable (SWR), so we lose the warm payload but the next
/// fetch repopulates it.
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

  test('v5 → v6 rebuilds cached_responses with composite PK', () async {
    _seedV5DatabaseWithSingleColumnPK(dbFile.path);

    // Opening AppDatabase on the seeded file triggers MigrationStrategy
    // from=5, to=6 — the v6 step drops and recreates cached_responses.
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    // Force a write so the lazy migration actually fires AND the new PK is
    // exercised end-to-end. Without v6 this throws SqliteException with
    // "ON CONFLICT clause does not match any PRIMARY KEY or UNIQUE
    // constraint".
    await db.writeCachedResponse('alice', 'home/resume', '{}');

    // user_version must now be 6.
    final raw = sqlite.sqlite3.open(dbFile.path);
    try {
      final userVersion = raw
          .select('PRAGMA user_version')
          .first
          .columnAt(0) as int;
      expect(userVersion, 6);

      // The on-disk schema must now declare the composite PK on
      // `(account_key, key)`. `PRAGMA table_info` exposes the PK ordinal
      // via the `pk` column (0 = not in PK, 1+ = position in PK).
      final cols = raw.select('PRAGMA table_info(cached_responses)');
      final pkCols = {
        for (final row in cols.where((r) => (r['pk'] as int) > 0))
          row['name'] as String: row['pk'] as int,
      };
      expect(
        pkCols.keys,
        unorderedEquals(<String>['account_key', 'key']),
        reason: 'composite PK must cover both account_key and key',
      );

      // Account-scoped index must also be present after the rebuild.
      final indexes = raw
          .select('PRAGMA index_list(cached_responses)')
          .map((r) => r['name'] as String)
          .toSet();
      expect(
        indexes,
        contains('cached_responses_account_idx'),
        reason: 'rebuild must recreate the account-scoped index',
      );
    } finally {
      raw.dispose();
    }
  });

  test('insertOnConflictUpdate works after v6 migration', () async {
    _seedV5DatabaseWithSingleColumnPK(dbFile.path);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    // First write seeds the row; second write must overwrite via ON
    // CONFLICT instead of throwing.
    await db.writeCachedResponse('alice', 'home/resume', '{"a":1}');
    await db.writeCachedResponse('alice', 'home/resume', '{"a":2}');

    final row = await db.readCachedResponse('alice', 'home/resume');
    expect(row, isNotNull);
    expect(row!.payload, '{"a":2}');

    // Same key but different account must coexist (composite PK).
    await db.writeCachedResponse('bob', 'home/resume', '{"b":1}');
    final aliceRow = await db.readCachedResponse('alice', 'home/resume');
    final bobRow = await db.readCachedResponse('bob', 'home/resume');
    expect(aliceRow!.payload, '{"a":2}');
    expect(bobRow!.payload, '{"b":1}');
  });
}

/// Recreates a v5 database where `cached_responses` was originally created at
/// v2 with `PRIMARY KEY (key)` and only had the `account_key` column added in
/// v4 — never picking up the composite PK declared in Dart. Matches the
/// on-disk shape of users who upgraded from old installs.
void _seedV5DatabaseWithSingleColumnPK(String path) {
  final raw = sqlite.sqlite3.open(path);
  try {
    raw
      // Downloads + sync_queue mirror the v5 shape (post-PR-DB1 retry
      // columns). Only `cached_responses` carries the legacy single-column
      // PK — that's what v6 has to fix.
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
          attempts INTEGER NOT NULL DEFAULT 0,
          last_attempt_at INTEGER,
          next_retry_at INTEGER,
          last_error TEXT,
          PRIMARY KEY (account_key, item_id)
        )
      ''')
      ..execute('CREATE INDEX downloads_account_idx ON downloads (account_key)')
      ..execute('CREATE INDEX downloads_task_id_idx ON downloads (task_id)')
      // ── The buggy bit: PK on `key` only, no composite covering account_key.
      ..execute('''
        CREATE TABLE cached_responses (
          account_key TEXT NOT NULL DEFAULT '',
          key TEXT NOT NULL PRIMARY KEY,
          payload TEXT NOT NULL,
          fetched_at INTEGER NOT NULL
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
          last_attempt_at INTEGER,
          next_retry_at INTEGER,
          last_error TEXT
        )
      ''')
      ..execute('CREATE INDEX sync_queue_item_idx ON sync_queue (item_id)')
      ..execute('CREATE INDEX sync_queue_account_idx ON sync_queue (account_key)')
      ..execute('PRAGMA user_version = 5');
  } finally {
    raw.dispose();
  }
}
