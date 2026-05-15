import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../auth/account_key.dart';
import '../auth/auth_controller.dart';
import '../jellyfin/jellyfin_client.dart';
import '../network/connectivity_provider.dart';
import '../storage/app_database.dart';
import '../storage/app_database_provider.dart';
import 'backoff_policy.dart';

class SyncFlushEvent {
  const SyncFlushEvent({required this.flushedCount, required this.failedCount});

  final int flushedCount;
  final int failedCount;
}

/// Signature for the per-row applicator: takes a `JellyfinClient` plus the
/// queue row and replays the operation against the server. Pulled out as a
/// typedef so unit tests can swap in a fake that throws on demand without
/// having to mock the whole `JellyfinClient` Dio stack.
typedef SyncApplier =
    Future<void> Function(JellyfinClient client, SyncQueueRow row);

/// Hard cap for the persisted `last_error` text. Keeps a runaway exception
/// string (full stack trace serialised by some Dio errors) from bloating the
/// DB row indefinitely.
const int _maxLastErrorChars = 500;

/// Drains the offline `SyncQueue` against Jellyfin whenever connectivity is
/// restored. Holds a stream of completion events so UI surfaces can show a
/// toast after a successful flush.
///
/// Retries are governed by [BackoffPolicy]: failed rows get an
/// exponentially-spaced `nextRetryAt` stamp and are filtered out of the next
/// flush pass until their backoff window elapses. After `maxAttempts` failures
/// the row is dead-lettered (it stays in the DB for debugging but
/// `nextRetryAt` is null and it never gets picked up again).
class SyncService {
  SyncService(
    this._ref, {
    BackoffPolicy? policy,
    SyncApplier? applier,
    DateTime Function()? clock,
    Random? random,
  }) : _policy =
           policy ??
           BackoffPolicy.exponential(
             base: const Duration(seconds: 30),
             cap: const Duration(hours: 1),
           ),
       _applier = applier ?? _defaultApplier,
       _clock = clock ?? DateTime.now,
       _random = random ?? Random() {
    _start();
  }

  final Ref _ref;
  final BackoffPolicy _policy;
  final SyncApplier _applier;
  final DateTime Function() _clock;
  final Random _random;
  static final _log = Logger('SyncService');

  final StreamController<SyncFlushEvent> _events =
      StreamController<SyncFlushEvent>.broadcast();
  ProviderSubscription<AsyncValue<bool>>? _sub;
  bool _flushing = false;
  bool _wasOnline = false;

  Stream<SyncFlushEvent> get events => _events.stream;

  /// Exposes the active policy for diagnostics / tests.
  BackoffPolicy get policy => _policy;

  void _start() {
    _sub = _ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (
      prev,
      next,
    ) {
      final online = next.valueOrNull ?? false;
      if (online && !_wasOnline) {
        unawaited(flush());
      }
      _wasOnline = online;
    }, fireImmediately: true);
  }

  Future<void> flush() async {
    if (_flushing) return;
    final session = _ref.read(authControllerProvider).valueOrNull?.session;
    if (session == null) return;
    final accountKey = accountKeyForSession(session);
    _flushing = true;
    const limit = 50;
    var flushed = 0;
    var failed = 0;
    try {
      final db = _ref.read(appDatabaseProvider);
      final client = _ref.read(jellyfinClientProvider);
      // Loop while a full batch comes back, otherwise long offline sessions
      // would leave anything past the first 50 rows stuck until the next
      // online toggle. Pending rows for *other* accounts are intentionally
      // left alone — they will flush when their owner becomes active again.
      while (true) {
        final batch = await db.pendingSyncBatchEligible(
          accountKey,
          maxAttempts: _policy.maxAttempts,
          now: _clock(),
          limit: limit,
        );
        if (batch.isEmpty) break;
        var progressedThisBatch = 0;
        for (final row in batch) {
          try {
            await _applier(client, row);
            await db.deleteSyncRow(row.id);
            flushed++;
            progressedThisBatch++;
          } on Object catch (e, s) {
            _log.warning(
              'Sync op ${row.operation} for ${row.itemId} failed',
              e,
              s,
            );
            await _recordFailure(db, row, e);
            failed++;
          }
        }
        // Safety valve: if nothing progressed (everything failed or capped),
        // bail out instead of looping forever.
        if (progressedThisBatch == 0) break;
        if (batch.length < limit) break;
      }
    } on Object catch (e, s) {
      _log.warning('Sync flush errored', e, s);
    } finally {
      _flushing = false;
      if (flushed > 0 || failed > 0) {
        _events.add(SyncFlushEvent(flushedCount: flushed, failedCount: failed));
      }
    }
  }

  /// Stamps the failed row with bumped `attempts`, fresh `lastAttemptAt`, the
  /// next backoff-driven `nextRetryAt` (null when dead-lettering kicks in)
  /// and a truncated `lastError` string. Single DB write per failure.
  Future<void> _recordFailure(
    AppDatabase db,
    SyncQueueRow row,
    Object error,
  ) async {
    final attempts = row.attempts + 1;
    final now = _clock();
    final next = _policy.nextRetryAt(attempts, now: now, random: _random);
    final truncated = _truncateError(error.toString());
    if (next == null) {
      _log.info(
        'Sync row ${row.id} (${row.operation} ${row.itemId}) '
        'dead-lettered after $attempts attempts',
      );
    } else {
      _log.info(
        'Sync row ${row.id} (${row.operation} ${row.itemId}) '
        'rescheduled for $next (attempt $attempts/${_policy.maxAttempts})',
      );
    }
    await db.recordSyncFailure(
      id: row.id,
      attempts: attempts,
      lastAttemptAt: now,
      nextRetryAt: next,
      lastError: truncated,
    );
  }

  /// Caps the persisted error string so a runaway exception (full stack trace
  /// in `toString()`) can't bloat the DB row. UI never displays this; it's
  /// for `adb logcat`-style debugging only.
  String _truncateError(String raw) {
    if (raw.length <= _maxLastErrorChars) return raw;
    return raw.substring(0, _maxLastErrorChars);
  }

  /// Default applier wired to the real `JellyfinClient`. Pulled out so tests
  /// can inject their own without touching the production switch statement.
  static Future<void> _defaultApplier(
    JellyfinClient client,
    SyncQueueRow row,
  ) async {
    switch (row.operation) {
      case SyncOperation.playbackProgress:
        final p = _decode(row.payloadJson);
        await client.reportPlaybackProgress(
          itemId: row.itemId,
          playSessionId: p['playSessionId'] as String? ?? row.itemId,
          mediaSourceId: p['mediaSourceId'] as String? ?? row.itemId,
          positionTicks: (p['positionTicks'] as num?)?.toInt() ?? 0,
          isPaused: p['isPaused'] as bool? ?? true,
        );
      case SyncOperation.playbackStopped:
        final p = _decode(row.payloadJson);
        await client.reportPlaybackStopped(
          itemId: row.itemId,
          playSessionId: p['playSessionId'] as String? ?? row.itemId,
          mediaSourceId: p['mediaSourceId'] as String? ?? row.itemId,
          positionTicks: (p['positionTicks'] as num?)?.toInt() ?? 0,
        );
      case SyncOperation.markPlayed:
        await client.markPlayed(row.itemId);
      case SyncOperation.markUnplayed:
        await client.markUnplayed(row.itemId);
      case SyncOperation.addFavorite:
        await client.markFavorite(row.itemId);
      case SyncOperation.removeFavorite:
        await client.unmarkFavorite(row.itemId);
    }
  }

  static Map<String, dynamic> _decode(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) return decoded;
    } on Object {
      // fall through
    }
    return const {};
  }

  void dispose() {
    _sub?.close();
    _events.close();
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final svc = SyncService(ref);
  ref.onDispose(svc.dispose);
  return svc;
});

/// Convenience helper used from widgets: enqueues an offline op with a
/// JSON-encoded payload. Returns the new row's id. The row is stamped with
/// the currently-active account so the right session picks it up on flush.
Future<int> enqueueSync(
  WidgetRef ref, {
  required String itemId,
  required SyncOperation operation,
  Map<String, dynamic> payload = const {},
}) async {
  final db = ref.read(appDatabaseProvider);
  final session = ref.read(authControllerProvider).valueOrNull?.session;
  return db.enqueueSync(
    accountKey: accountKeyForSession(session),
    itemId: itemId,
    operation: operation,
    payloadJson: payload.isEmpty ? '{}' : jsonEncode(payload),
  );
}
