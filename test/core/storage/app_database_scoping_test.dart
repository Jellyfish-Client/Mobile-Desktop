// `drift/drift.dart` exports an `isNull` Drift query helper that collides
// with the `isNull` matcher from `package:matcher` (re-exported by
// `flutter_test`). We only need `Value` from drift here, so hide the rest of
// the matcher-shaped symbols.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/storage/app_database.dart';

/// Verifies that Drift reads filter rows by `accountKey` and that writes stamp
/// the key correctly. Runs against an in-memory `NativeDatabase` so no
/// platform plugins or on-disk files are required.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('CachedResponses scoping', () {
    test('write stamps accountKey, read filters on it', () async {
      await db.writeCachedResponse('alice', 'home', 'A-home-payload');
      await db.writeCachedResponse('bob', 'home', 'B-home-payload');

      final aliceRow = await db.readCachedResponse('alice', 'home');
      final bobRow = await db.readCachedResponse('bob', 'home');
      final ghostRow = await db.readCachedResponse('ghost', 'home');

      expect(aliceRow?.payload, 'A-home-payload');
      expect(bobRow?.payload, 'B-home-payload');
      expect(ghostRow, isNull);
    });

    test(
      'upsert on (accountKey, key) collision overwrites the same row',
      () async {
        await db.writeCachedResponse('alice', 'k', 'v1');
        await db.writeCachedResponse('alice', 'k', 'v2');
        final row = await db.readCachedResponse('alice', 'k');
        expect(row?.payload, 'v2');
        // bob did NOT see his row stomped on, because the PK is composite.
        await db.writeCachedResponse('bob', 'k', 'B');
        expect((await db.readCachedResponse('bob', 'k'))?.payload, 'B');
        expect((await db.readCachedResponse('alice', 'k'))?.payload, 'v2');
      },
    );

    test('clearCachedResponsesFor wipes only the targeted account', () async {
      await db.writeCachedResponse('alice', 'k', 'A');
      await db.writeCachedResponse('bob', 'k', 'B');

      await db.clearCachedResponsesFor('alice');

      expect(await db.readCachedResponse('alice', 'k'), isNull);
      expect((await db.readCachedResponse('bob', 'k'))?.payload, 'B');
    });
  });

  group('SyncQueue scoping', () {
    test('enqueueSync stamps accountKey, pendingSyncBatch filters', () async {
      await db.enqueueSync(
        accountKey: 'alice',
        itemId: 'item-1',
        operation: SyncOperation.markPlayed,
      );
      await db.enqueueSync(
        accountKey: 'bob',
        itemId: 'item-2',
        operation: SyncOperation.markPlayed,
      );

      final aliceBatch = await db.pendingSyncBatch('alice');
      final bobBatch = await db.pendingSyncBatch('bob');

      expect(aliceBatch.map((r) => r.itemId), ['item-1']);
      expect(bobBatch.map((r) => r.itemId), ['item-2']);
    });

    test('upsertPlaybackProgress is scoped per (account, item)', () async {
      // Same itemId, two accounts: each one keeps its own progress row.
      await db.upsertPlaybackProgress(
        accountKey: 'alice',
        itemId: 'show-1',
        payloadJson: '{"positionTicks": 100}',
      );
      await db.upsertPlaybackProgress(
        accountKey: 'bob',
        itemId: 'show-1',
        payloadJson: '{"positionTicks": 999}',
      );
      // A second alice update should replace alice's progress, not bob's.
      await db.upsertPlaybackProgress(
        accountKey: 'alice',
        itemId: 'show-1',
        payloadJson: '{"positionTicks": 200}',
      );

      final aliceRows = await db.pendingSyncBatch('alice');
      final bobRows = await db.pendingSyncBatch('bob');
      expect(aliceRows, hasLength(1));
      expect(aliceRows.single.payloadJson, contains('"positionTicks": 200'));
      expect(bobRows, hasLength(1));
      expect(bobRows.single.payloadJson, contains('"positionTicks": 999'));
    });
  });

  group('Downloads scoping', () {
    test('upsertRow + findByItemId are isolated per account', () async {
      await db.upsertRow(
        DownloadsCompanion.insert(
          accountKey: const Value('alice'),
          itemId: 'movie-1',
          itemType: 'Movie',
          name: 'Alice movie',
          status: DownloadStatus.completed,
          createdAt: DateTime.utc(2025),
        ),
      );
      await db.upsertRow(
        DownloadsCompanion.insert(
          accountKey: const Value('bob'),
          itemId: 'movie-1',
          itemType: 'Movie',
          name: 'Bob movie',
          status: DownloadStatus.completed,
          createdAt: DateTime.utc(2025),
        ),
      );

      expect((await db.findByItemId('alice', 'movie-1'))?.name, 'Alice movie');
      expect((await db.findByItemId('bob', 'movie-1'))?.name, 'Bob movie');
      expect(await db.findByItemId('ghost', 'movie-1'), isNull);
    });
  });

  group('claimLegacyRowsFor', () {
    test(
      're-stamps every empty-accountKey row onto the migrated account',
      () async {
        // Seed rows with the legacy default accountKey (empty string).
        await db.writeCachedResponse(legacyAccountKey, 'home', 'legacy-home');
        await db.upsertRow(
          DownloadsCompanion.insert(
            itemId: 'legacy-movie',
            itemType: 'Movie',
            name: 'Legacy movie',
            status: DownloadStatus.completed,
            createdAt: DateTime.utc(2024),
          ),
        );
        await db.enqueueSync(
          accountKey: legacyAccountKey,
          itemId: 'legacy-movie',
          operation: SyncOperation.markPlayed,
        );

        await db.claimLegacyRowsFor('alice');

        // After the claim, everything is visible from alice's scope.
        expect(
          (await db.readCachedResponse('alice', 'home'))?.payload,
          'legacy-home',
        );
        expect(
          (await db.findByItemId('alice', 'legacy-movie'))?.name,
          'Legacy movie',
        );
        expect(await db.pendingSyncBatch('alice'), hasLength(1));
        // And gone from the legacy bucket.
        expect(await db.readCachedResponse(legacyAccountKey, 'home'), isNull);
      },
    );

    test('refuses to claim into the legacy bucket itself', () async {
      await db.writeCachedResponse(legacyAccountKey, 'k', 'v');
      // No-op when called with the legacy sentinel — guards against turning
      // the migration into an identity write.
      await db.claimLegacyRowsFor(legacyAccountKey);
      expect(
        (await db.readCachedResponse(legacyAccountKey, 'k'))?.payload,
        'v',
      );
    });
  });
}
