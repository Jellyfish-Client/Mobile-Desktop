import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../auth/account_key.dart';
import '../auth/auth_controller.dart';
import '../jellyfin/jellyfin_client.dart';
import '../network/connectivity_provider.dart';
import '../storage/app_database.dart';
import '../storage/app_database_provider.dart';

class SyncFlushEvent {
  const SyncFlushEvent({required this.flushedCount, required this.failedCount});

  final int flushedCount;
  final int failedCount;
}

/// Drains the offline `SyncQueue` against Jellyfin whenever connectivity is
/// restored. Holds a stream of completion events so UI surfaces can show a
/// toast after a successful flush.
class SyncService {
  SyncService(this._ref) {
    _start();
  }

  final Ref _ref;
  static final _log = Logger('SyncService');
  static const _maxAttempts = 5;

  final StreamController<SyncFlushEvent> _events =
      StreamController<SyncFlushEvent>.broadcast();
  ProviderSubscription<AsyncValue<bool>>? _sub;
  bool _flushing = false;
  bool _wasOnline = false;

  Stream<SyncFlushEvent> get events => _events.stream;

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
        final batch = await db.pendingSyncBatch(accountKey, limit: limit);
        if (batch.isEmpty) break;
        var progressedThisBatch = 0;
        for (final row in batch) {
          if (row.attempts >= _maxAttempts) continue;
          try {
            await _apply(client, row);
            await db.deleteSyncRow(row.id);
            flushed++;
            progressedThisBatch++;
          } on Object catch (e, s) {
            _log.warning(
              'Sync op ${row.operation} for ${row.itemId} failed',
              e,
              s,
            );
            await db.incrementSyncAttempts(row.id, e.toString());
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

  Future<void> _apply(JellyfinClient client, SyncQueueRow row) async {
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

  Map<String, dynamic> _decode(String json) {
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
