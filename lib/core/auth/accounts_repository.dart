import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_database.dart';
import '../storage/app_database_provider.dart';
import '../storage/secure_kv.dart';
import 'saved_account.dart';
import 'session.dart';

const _accountsKey = 'accounts_v1';
const _legacySessionKey = 'session_v1';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(
    ref.watch(secureKvProvider),
    legacyClaimDb: ref.watch(appDatabaseProvider),
  );
});

/// Stores the list of known (server, user) accounts in secure key-value
/// storage. The active session is whichever entry has the most recent
/// [SavedAccount.lastUsedAt].
class AccountsRepository {
  AccountsRepository(this._storage, {AppDatabase? legacyClaimDb})
    : _legacyClaimDb = legacyClaimDb;

  final SecureKv _storage;
  // Optional so tests can omit Drift. When provided, the legacy-session
  // migration also claims Drift rows for the migrated account so existing
  // downloads / cache survive the schema upgrade with their owner attached.
  final AppDatabase? _legacyClaimDb;

  /// Memoised migration future. Coalesces concurrent first-read attempts
  /// (e.g. AuthController.build() racing against the accounts list provider)
  /// so we never run the legacy migration twice. Reset by [clearAll] so a
  /// future replay of a legacy blob can still trigger a fresh migration.
  Future<List<SavedAccount>>? _migrationOnce;

  /// Tracks whether we've already attempted to re-stamp legacy Drift rows
  /// (`accountKey = ''`) for the current process. One claim per cold start is
  /// enough — the underlying SQL UPDATE is idempotent. Without this flag the
  /// claim would only run during the `session_v1 → accounts_v1` migration,
  /// silently skipping every user who upgraded from a pre-scoping version
  /// that already had `accounts_v1` populated.
  bool _legacyDriftClaimDone = false;

  /// Returns all known accounts sorted by [SavedAccount.lastUsedAt] desc.
  /// Performs a one-shot migration from the legacy single-session key
  /// (`session_v1`) on first read, and once per process also re-stamps any
  /// orphan Drift rows that may still carry the empty-string [legacyAccountKey].
  Future<List<SavedAccount>> readAll() async {
    final raw = await _storage.read(_accountsKey);
    if (raw != null) {
      try {
        final accounts = _decode(raw);
        // Reclaim legacy Drift rows even when accounts_v1 already exists.
        // This is the recovery path for users who upgraded from a version
        // that introduced multi-account but did NOT yet scope Drift tables —
        // without this their downloads/cache/sync would stay orphaned forever.
        await _claimLegacyDriftRowsOnce(accounts);
        return accounts;
      } on FormatException {
        await _storage.delete(_accountsKey);
      }
    }
    // No `accounts_v1` yet — try migrating the legacy single session. The
    // cached future ensures parallel callers share a single migration pass.
    return _migrationOnce ??= _runMigrationOnce();
  }

  Future<void> _claimLegacyDriftRowsOnce(List<SavedAccount> accounts) async {
    if (_legacyDriftClaimDone || accounts.isEmpty) return;
    _legacyDriftClaimDone = true;
    await _legacyClaimDb?.claimLegacyRowsFor(accounts.first.key);
  }

  Future<List<SavedAccount>> _runMigrationOnce() async {
    final migrated = await _migrateFromLegacy();
    if (migrated.isNotEmpty) {
      await _writeAll(migrated);
      // Re-stamp any legacy Drift rows (schema v3 and below stored everything
      // with an empty accountKey) onto the migrated account so the user's
      // downloads/cache/sync queue aren't silently orphaned after the upgrade.
      await _legacyClaimDb?.claimLegacyRowsFor(migrated.first.key);
    }
    return migrated;
  }

  Future<void> upsert(SavedAccount account) async {
    final list = await readAll();
    final idx = list.indexWhere((a) => a.key == account.key);
    if (idx >= 0) {
      list[idx] = account;
    } else {
      list.add(account);
    }
    await _writeAll(list);
  }

  Future<void> remove(String serverId, String userId) async {
    final list = await readAll();
    list.removeWhere((a) => a.serverId == serverId && a.userId == userId);
    await _writeAll(list);
  }

  /// Atomic batch removal of every account on a given server. One read + one
  /// write instead of N sequential readAll/writeAll cycles.
  Future<int> removeServer(String serverId) async {
    final list = await readAll();
    final before = list.length;
    list.removeWhere((a) => a.serverId == serverId);
    final removed = before - list.length;
    if (removed > 0) await _writeAll(list);
    return removed;
  }

  /// Bumps [SavedAccount.lastUsedAt] to now. Returns the updated account, or
  /// null if the (server, user) pair is unknown.
  Future<SavedAccount?> markUsed(String serverId, String userId) async {
    final list = await readAll();
    final idx = list.indexWhere(
      (a) => a.serverId == serverId && a.userId == userId,
    );
    if (idx < 0) return null;
    final updated = list[idx].copyWith(lastUsedAt: DateTime.now().toUtc());
    list[idx] = updated;
    await _writeAll(list);
    return updated;
  }

  Future<void> clearAll() async {
    // Wipe the legacy key too — otherwise a subsequent readAll() would
    // re-migrate the old session and resurrect the account we just cleared.
    await _storage.delete(_accountsKey);
    await _storage.delete(_legacySessionKey);
    // Allow a fresh migration attempt if a legacy blob ever reappears.
    _migrationOnce = null;
    _legacyDriftClaimDone = false;
  }

  Future<void> _writeAll(List<SavedAccount> accounts) {
    final sorted = [...accounts]
      ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    final payload = sorted.map((a) => a.toJson()).toList(growable: false);
    return _storage.write(_accountsKey, jsonEncode(payload));
  }

  List<SavedAccount> _decode(String raw) {
    final parsed = jsonDecode(raw);
    if (parsed is! List) throw const FormatException('expected JSON array');
    return parsed
        .cast<Map<String, dynamic>>()
        .map(SavedAccount.fromJson)
        .toList(growable: true)
      ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
  }

  Future<List<SavedAccount>> _migrateFromLegacy() async {
    final raw = await _storage.read(_legacySessionKey);
    if (raw == null) return [];
    try {
      final legacy = Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final account = SavedAccount(
        serverId: legacy.serverId,
        serverUrl: legacy.serverUrl,
        serverName: 'Jellyfin', // legacy session never carried a server name
        userId: legacy.userId,
        userName: legacy.userName,
        accessToken: legacy.accessToken,
        proxyAuth: legacy.proxyAuth,
        primaryImageTag: null,
        lastUsedAt: DateTime.now().toUtc(),
      );
      // Drop the legacy key so the two stores can't diverge.
      await _storage.delete(_legacySessionKey);
      return [account];
    } on Object {
      // Legacy blob is unreadable — wipe it and start fresh.
      await _storage.delete(_legacySessionKey);
      return [];
    }
  }
}
