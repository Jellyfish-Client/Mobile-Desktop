import 'dart:math';

// `drift/drift.dart` exports an `isNull` Drift query helper that collides
// with the `isNull` matcher from `package:matcher` (re-exported by
// `flutter_test`). We only need `Value` from drift here, so hide the rest of
// the matcher-shaped symbols.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/storage/app_database.dart';
import 'package:jellyfish/core/sync/backoff_policy.dart';

/// Verifies the BackoffPolicy → Downloads-table wiring introduced by PR-DB3.
///
/// We don't spin up a real `DownloadManager` (it owns a `FileDownloader`
/// singleton wired to platform channels we can't run in `flutter test`):
/// instead we exercise the DAO directly and re-implement the per-failure
/// bookkeeping the manager performs (`attempts + 1`, `nextRetryAt`,
/// truncated `lastError`). That keeps the assertions focused on the
/// contract any future caller — including the manager — has to honour.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  // Inserts a fresh `failed`-status download row tied to `account`.
  Future<void> seedFailed(
    String account,
    String itemId, {
    DateTime? createdAt,
    int attempts = 0,
    DateTime? nextRetryAt,
  }) async {
    await db
        .into(db.downloads)
        .insert(
          DownloadsCompanion.insert(
            accountKey: Value(account),
            itemId: itemId,
            itemType: 'Movie',
            name: itemId,
            status: DownloadStatus.failed,
            createdAt: createdAt ?? DateTime(2026),
            attempts: Value(attempts),
            nextRetryAt: Value(nextRetryAt),
          ),
        );
  }

  Future<DownloadRow> readRow(String account, String itemId) async {
    final row = await db.findByItemId(account, itemId);
    expect(row, isNotNull, reason: 'fixture seeded $itemId');
    return row!;
  }

  group('AppDatabase.recordDownloadFailure', () {
    test(
      'on simulated failure, attempts is incremented and nextRetryAt > now',
      () async {
        await seedFailed('alice', 'movie-1');
        final policy = BackoffPolicy.exponential();
        final now = DateTime(2026, 5, 15, 12);

        final current = await readRow('alice', 'movie-1');
        // Re-runs the bookkeeping the DownloadManager applies in
        // `_recordFailure`: bump attempts, stamp `lastAttemptAt`, schedule
        // `nextRetryAt` via the policy and capture a truncated `lastError`.
        final attempts = current.attempts + 1;
        final next = policy.nextRetryAt(attempts, now: now, random: Random(1));
        await db.recordDownloadFailure(
          accountKey: 'alice',
          itemId: 'movie-1',
          attempts: attempts,
          lastAttemptAt: now,
          nextRetryAt: next,
          lastError: 'simulated 503',
        );

        final after = await readRow('alice', 'movie-1');
        expect(after.attempts, 1);
        expect(after.lastAttemptAt, now);
        expect(after.status, DownloadStatus.failed);
        expect(after.nextRetryAt, isNotNull);
        expect(after.nextRetryAt!.isAfter(now), isTrue);
        expect(after.lastError, contains('simulated 503'));
      },
    );

    test('errorMessage mirrors lastError so UI surfaces stay in sync', () async {
      await seedFailed('alice', 'movie-1');
      await db.recordDownloadFailure(
        accountKey: 'alice',
        itemId: 'movie-1',
        attempts: 1,
        lastAttemptAt: DateTime(2026, 5, 15, 12),
        nextRetryAt: DateTime(2026, 5, 15, 12, 1),
        lastError: 'connection reset',
      );
      final row = await readRow('alice', 'movie-1');
      expect(row.errorMessage, 'connection reset');
      expect(row.lastError, 'connection reset');
    });
  });

  group('AppDatabase.pendingDownloadsEligibleForRetry', () {
    test('filters out rows whose nextRetryAt is in the future', () async {
      final now = DateTime(2026, 5, 15, 12);

      await seedFailed(
        'alice',
        'ready',
        attempts: 1,
        nextRetryAt: now.subtract(const Duration(seconds: 1)),
      );
      await seedFailed(
        'alice',
        'pending',
        attempts: 1,
        nextRetryAt: now.add(const Duration(hours: 1)),
      );

      final eligible = await db.pendingDownloadsEligibleForRetry(
        'alice',
        maxAttempts: 5,
        now: now,
      );
      expect(eligible.map((r) => r.itemId), ['ready']);
    });

    test('legacy rows with null nextRetryAt are eligible immediately', () async {
      final now = DateTime(2026, 5, 15, 12);
      await seedFailed('alice', 'legacy');
      final eligible = await db.pendingDownloadsEligibleForRetry(
        'alice',
        maxAttempts: 5,
        now: now,
      );
      expect(eligible.map((r) => r.itemId), ['legacy']);
    });

    test('filters out rows that have reached maxAttempts', () async {
      final now = DateTime(2026, 5, 15, 12);
      await seedFailed(
        'alice',
        'live',
        attempts: 1,
        nextRetryAt: now.subtract(const Duration(seconds: 1)),
      );
      await seedFailed(
        'alice',
        'dead',
        attempts: 5,
      );

      final eligible = await db.pendingDownloadsEligibleForRetry(
        'alice',
        maxAttempts: 5,
        now: now,
      );
      expect(eligible.map((r) => r.itemId), ['live']);
    });

    test('scopes results to the requested account', () async {
      final now = DateTime(2026, 5, 15, 12);
      await seedFailed('alice', 'a');
      await seedFailed('bob', 'b');

      final aliceEligible = await db.pendingDownloadsEligibleForRetry(
        'alice',
        maxAttempts: 5,
        now: now,
      );
      final bobEligible = await db.pendingDownloadsEligibleForRetry(
        'bob',
        maxAttempts: 5,
        now: now,
      );
      expect(aliceEligible.map((r) => r.itemId), ['a']);
      expect(bobEligible.map((r) => r.itemId), ['b']);
    });
  });

  group('Dead-letter behaviour after maxAttempts', () {
    test(
      'after maxAttempts failures, nextRetryAt is null and the row is no '
      'longer returned by pendingDownloadsEligibleForRetry',
      () async {
        const policy = BackoffPolicy(
          base: Duration(seconds: 30),
          cap: Duration(hours: 1),
          jitterFactor: 0,
          maxAttempts: 3,
        );
        await seedFailed('alice', 'movie-1');

        var now = DateTime(2026, 5, 15, 12);

        // Attempt 1: bump attempts to 1, schedule a retry.
        var current = await readRow('alice', 'movie-1');
        var attempts = current.attempts + 1;
        var next = policy.nextRetryAt(attempts, now: now, random: Random(2));
        await db.recordDownloadFailure(
          accountKey: 'alice',
          itemId: 'movie-1',
          attempts: attempts,
          lastAttemptAt: now,
          nextRetryAt: next,
          lastError: 'fail',
        );
        current = await readRow('alice', 'movie-1');
        expect(current.attempts, 1);
        expect(current.nextRetryAt, isNotNull);

        // Attempt 2: jump past the retry window.
        now = current.nextRetryAt!.add(const Duration(seconds: 1));
        attempts = current.attempts + 1;
        next = policy.nextRetryAt(attempts, now: now, random: Random(3));
        await db.recordDownloadFailure(
          accountKey: 'alice',
          itemId: 'movie-1',
          attempts: attempts,
          lastAttemptAt: now,
          nextRetryAt: next,
          lastError: 'fail',
        );
        current = await readRow('alice', 'movie-1');
        expect(current.attempts, 2);
        expect(current.nextRetryAt, isNotNull);

        // Attempt 3: this hits maxAttempts → policy returns null →
        // dead-lettered.
        now = current.nextRetryAt!.add(const Duration(seconds: 1));
        attempts = current.attempts + 1;
        next = policy.nextRetryAt(attempts, now: now, random: Random(4));
        await db.recordDownloadFailure(
          accountKey: 'alice',
          itemId: 'movie-1',
          attempts: attempts,
          lastAttemptAt: now,
          nextRetryAt: next,
          lastError: 'fail',
        );
        current = await readRow('alice', 'movie-1');
        expect(current.attempts, 3);
        expect(current.nextRetryAt, isNull);

        // Dead-lettered row must not be picked up by the retry sweep.
        final eligible = await db.pendingDownloadsEligibleForRetry(
          'alice',
          maxAttempts: policy.maxAttempts,
          now: now.add(const Duration(days: 365)),
        );
        expect(eligible, isEmpty);

        // And it physically stays in the DB for debugging.
        final all = await db.select(db.downloads).get();
        expect(all, hasLength(1));
      },
    );
  });

  group('AppDatabase.rebindDownloadTaskId', () {
    test('rebinds taskId, flips status, preserves attempts', () async {
      await seedFailed(
        'alice',
        'movie-1',
        attempts: 2,
        nextRetryAt: DateTime(2026, 5, 15, 11),
      );

      await db.rebindDownloadTaskId(
        accountKey: 'alice',
        itemId: 'movie-1',
        taskId: 'new-task-uuid',
      );

      final row = await readRow('alice', 'movie-1');
      expect(row.taskId, 'new-task-uuid');
      expect(row.status, DownloadStatus.queued);
      // Attempts must NOT be reset by rebinding: the whole point is to keep
      // climbing the backoff curve if the retry fails again.
      expect(row.attempts, 2);
    });
  });

  group('AppDatabase.resetDownloadRetry', () {
    test('clears attempts / nextRetryAt / lastError', () async {
      await seedFailed(
        'alice',
        'movie-1',
        attempts: 3,
        nextRetryAt: DateTime(2026, 5, 15, 14),
      );
      await db.recordDownloadFailure(
        accountKey: 'alice',
        itemId: 'movie-1',
        attempts: 3,
        lastAttemptAt: DateTime(2026, 5, 15, 12),
        nextRetryAt: DateTime(2026, 5, 15, 14),
        lastError: 'boom',
      );

      await db.resetDownloadRetry('alice', 'movie-1');

      final row = await readRow('alice', 'movie-1');
      expect(row.attempts, 0);
      expect(row.lastAttemptAt, isNull);
      expect(row.nextRetryAt, isNull);
      expect(row.lastError, isNull);
    });
  });
}
