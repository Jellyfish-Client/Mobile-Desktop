import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/auth/account_key.dart';
import 'package:jellyfish/core/auth/auth_controller.dart';
import 'package:jellyfish/core/auth/session.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/core/network/connectivity_provider.dart';
import 'package:jellyfish/core/storage/app_database.dart';
import 'package:jellyfish/core/storage/app_database_provider.dart';
import 'package:jellyfish/core/sync/backoff_policy.dart';
import 'package:jellyfish/core/sync/sync_service.dart';

/// Authoritative test session. Only `serverId`/`userId` matter — they end up
/// concatenated into the accountKey used to filter the queue rows below.
const _session = Session(
  serverUrl: 'https://srv.test',
  serverId: 'srv',
  userId: 'alice',
  userName: 'alice',
  accessToken: 'tok',
);

String get _accountKey => accountKeyForSession(_session);

/// Minimal AuthController override: returns a single-session state without
/// touching disk or the SecureKv. SyncService only reads `state.valueOrNull
/// ?.session` so we don't need to implement any of the mutator methods.
class _FakeAuthController extends AuthController {
  @override
  Future<SessionState> build() async => const SessionState(session: _session);
}

JellyfinClient _dummyJellyfinClient() {
  // Real JellyfinClient instance, but with a fresh Dio that's never wired to
  // any server. Our injected SyncApplier never invokes any client method, so
  // these refs stay inert.
  final dio = Dio();
  return JellyfinClient(dio, _session, JellyfinApi(dio: dio));
}

/// Builds a ProviderContainer that wires SyncService onto an in-memory Drift
/// DB with the connectivity listener deliberately silenced (it would
/// otherwise auto-trigger a flush on the first `fireImmediately` callback,
/// racing with our explicit `await svc.flush()` calls below).
ProviderContainer _container({
  required AppDatabase db,
  required BackoffPolicy policy,
  required SyncApplier applier,
  required DateTime Function() clock,
  Random? random,
}) {
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      authControllerProvider.overrideWith(_FakeAuthController.new),
      // Empty stream → no `fireImmediately` value → listener stays dormant.
      connectivityStreamProvider.overrideWith(
        (ref) => const Stream<bool>.empty(),
      ),
      jellyfinClientProvider.overrideWithValue(_dummyJellyfinClient()),
      syncServiceProvider.overrideWith((ref) {
        final svc = SyncService(
          ref,
          policy: policy,
          applier: applier,
          clock: clock,
          random: random,
        );
        ref.onDispose(svc.dispose);
        return svc;
      }),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Inserts one queue row with sensible defaults and returns its id.
Future<int> _enqueue(
  AppDatabase db, {
  String itemId = 'item-1',
  SyncOperation op = SyncOperation.markPlayed,
  DateTime? createdAt,
}) {
  return db.into(db.syncQueue).insert(
    SyncQueueCompanion.insert(
      accountKey: Value(_accountKey),
      itemId: itemId,
      operation: op,
      createdAt: createdAt ?? DateTime.utc(2026),
    ),
  );
}

/// Reads the freshly-stored row back, bypassing any helper that could mask
/// raw column values.
Future<SyncQueueRow> _readRow(AppDatabase db, int id) {
  return (db.select(db.syncQueue)..where((t) => t.id.equals(id))).getSingle();
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncService.flush retry/backoff', () {
    test(
      'on simulated 503 failure, attempts is incremented and '
      'nextRetryAt is scheduled in the future',
      () async {
        final id = await _enqueue(db);
        // Drift stores DateTime values as local-time epoch seconds; using a
        // local DateTime (not UTC) avoids a round-trip offset on read.
        final fixedNow = DateTime(2026, 5, 15, 12);

        // Applier that mimics a 503 — always throws. Counts invocations so we
        // know flush actually attempted the row exactly once.
        var calls = 0;
        Future<void> applier(JellyfinClient _, SyncQueueRow __) async {
          calls++;
          throw StateError('simulated 503');
        }

        final container = _container(
          db: db,
          policy: BackoffPolicy.exponential(),
          applier: applier,
          clock: () => fixedNow,
          random: Random(1),
        );
        // AsyncNotifierProvider state is unresolved until we await its
        // future; SyncService.flush() reads `valueOrNull?.session` and would
        // otherwise see null and bail out without trying anything.
        await container.read(authControllerProvider.future);
        final svc = container.read(syncServiceProvider);

        await svc.flush();

        expect(calls, 1, reason: 'row should be attempted exactly once');
        final row = await _readRow(db, id);
        expect(row.attempts, 1);
        expect(row.lastAttemptAt, fixedNow);
        expect(row.lastError, contains('simulated 503'));
        expect(
          row.nextRetryAt,
          isNotNull,
          reason: 'first failure → scheduled retry',
        );
        expect(row.nextRetryAt!.isAfter(fixedNow), isTrue);
      },
    );

    test(
      'rows whose nextRetryAt is still in the future are skipped on the '
      'next flush pass',
      () async {
        final id = await _enqueue(db);

        // Pre-stamp the row with a future nextRetryAt as if a previous flush
        // had already failed and scheduled a retry one hour out.
        final flushNow = DateTime.utc(2026, 5, 15, 12);
        await db.recordSyncFailure(
          id: id,
          attempts: 1,
          lastAttemptAt: flushNow.subtract(const Duration(minutes: 5)),
          nextRetryAt: flushNow.add(const Duration(hours: 1)),
          lastError: 'previous 503',
        );

        var calls = 0;
        Future<void> applier(JellyfinClient _, SyncQueueRow __) async {
          calls++;
        }

        final container = _container(
          db: db,
          policy: BackoffPolicy.exponential(),
          applier: applier,
          clock: () => flushNow,
        );
        // AsyncNotifierProvider state is unresolved until we await its
        // future; SyncService.flush() reads `valueOrNull?.session` and would
        // otherwise see null and bail out without trying anything.
        await container.read(authControllerProvider.future);
        final svc = container.read(syncServiceProvider);

        await svc.flush();

        expect(calls, 0, reason: 'row still in backoff window must be skipped');
        final row = await _readRow(db, id);
        expect(row.attempts, 1, reason: 'untouched: attempts unchanged');
      },
    );

    test(
      'after maxAttempts failures, row is dead-lettered (nextRetryAt = null) '
      'and no longer selected on subsequent flushes',
      () async {
        const policy = BackoffPolicy(
          base: Duration(seconds: 30),
          cap: Duration(hours: 1),
          jitterFactor: 0, // deterministic delay
          maxAttempts: 3,
        );
        final id = await _enqueue(db);

        var calls = 0;
        Future<void> applier(JellyfinClient _, SyncQueueRow __) async {
          calls++;
          throw StateError('still failing');
        }

        // Walk wall-clock forward enough between flushes that the next retry
        // window always elapses; otherwise the second/third flush would be a
        // no-op for the very reason we tested above.
        var now = DateTime.utc(2026, 5, 15, 12);
        DateTime clock() => now;

        final container = _container(
          db: db,
          policy: policy,
          applier: applier,
          clock: clock,
          random: Random(2),
        );
        await container.read(authControllerProvider.future);
        final svc = container.read(syncServiceProvider);

        // Attempt 1.
        await svc.flush();
        var row = await _readRow(db, id);
        expect(row.attempts, 1);
        expect(row.nextRetryAt, isNotNull);

        // Jump past the scheduled retry, attempt 2.
        now = row.nextRetryAt!.add(const Duration(seconds: 1));
        await svc.flush();
        row = await _readRow(db, id);
        expect(row.attempts, 2);
        expect(row.nextRetryAt, isNotNull);

        // Jump past the next scheduled retry, attempt 3 — this hits
        // maxAttempts, so policy returns null and the row is dead-lettered.
        now = row.nextRetryAt!.add(const Duration(seconds: 1));
        await svc.flush();
        row = await _readRow(db, id);
        expect(row.attempts, 3);
        expect(
          row.nextRetryAt,
          isNull,
          reason: 'dead-lettered: no more retries scheduled',
        );
        expect(calls, 3, reason: 'three attempts total');

        // A further flush at any time must not re-pick the dead-lettered row.
        now = now.add(const Duration(days: 365));
        await svc.flush();
        expect(calls, 3, reason: 'dead-lettered row stays untouched');
        row = await _readRow(db, id);
        expect(row.attempts, 3, reason: 'attempts column unchanged');
        // And it must remain physically present (we don't delete dead-letter
        // rows — that's a future cleanup task's job).
        final all = await db.select(db.syncQueue).get();
        expect(all, hasLength(1));
      },
    );

    test(
      'successful applier deletes the row and emits a SyncFlushEvent',
      () async {
        await _enqueue(db);
        await _enqueue(db, itemId: 'item-2');

        Future<void> applier(JellyfinClient _, SyncQueueRow __) async {
          // no-op success
        }

        final container = _container(
          db: db,
          policy: BackoffPolicy.exponential(),
          applier: applier,
          clock: () => DateTime.utc(2026, 5, 15, 12),
        );
        await container.read(authControllerProvider.future);
        final svc = container.read(syncServiceProvider);

        final eventFuture = svc.events.first;
        await svc.flush();
        final event = await eventFuture.timeout(const Duration(seconds: 2));

        expect(event.flushedCount, 2);
        expect(event.failedCount, 0);
        final remaining = await db.select(db.syncQueue).get();
        expect(remaining, isEmpty);
      },
    );
  });

  group('AppDatabase.pendingSyncBatchEligible', () {
    test('filters out rows whose nextRetryAt is in the future', () async {
      final now = DateTime.utc(2026, 5, 15, 12);
      final readyId = await _enqueue(db, itemId: 'ready');
      final pendingId = await _enqueue(db, itemId: 'pending');

      // `ready` had its retry scheduled in the past → still eligible.
      await db.recordSyncFailure(
        id: readyId,
        attempts: 1,
        lastAttemptAt: now.subtract(const Duration(hours: 2)),
        nextRetryAt: now.subtract(const Duration(seconds: 1)),
        lastError: 'old',
      );
      // `pending` is still inside its backoff window.
      await db.recordSyncFailure(
        id: pendingId,
        attempts: 1,
        lastAttemptAt: now.subtract(const Duration(minutes: 1)),
        nextRetryAt: now.add(const Duration(hours: 1)),
        lastError: 'fresh',
      );

      final eligible = await db.pendingSyncBatchEligible(
        _accountKey,
        maxAttempts: 5,
        now: now,
      );
      expect(eligible.map((r) => r.itemId), ['ready']);
    });

    test('filters out rows that have already reached maxAttempts', () async {
      final now = DateTime.utc(2026, 5, 15, 12);
      final liveId = await _enqueue(db, itemId: 'live');
      final deadId = await _enqueue(db, itemId: 'dead');

      await db.recordSyncFailure(
        id: liveId,
        attempts: 1,
        lastAttemptAt: now,
        nextRetryAt: now.subtract(const Duration(seconds: 1)),
        lastError: 'one shot',
      );
      // Dead-lettered: attempts == maxAttempts AND nextRetryAt is null.
      await db.recordSyncFailure(
        id: deadId,
        attempts: 5,
        lastAttemptAt: now,
        nextRetryAt: null,
        lastError: 'too many',
      );

      final eligible = await db.pendingSyncBatchEligible(
        _accountKey,
        maxAttempts: 5,
        now: now,
      );
      expect(eligible.map((r) => r.itemId), ['live']);
    });
  });
}
