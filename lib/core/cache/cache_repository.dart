import '../storage/app_database.dart';

/// Thin wrapper around the [CachedResponses] table. Holds the only knowledge
/// of how SWR payloads land on disk so providers can stay oblivious to Drift.
///
/// Account-scoped: every read/write is filtered by [accountKey] so different
/// users on the same device never see each other's rails. The [accountKey] is
/// resolved from the active session by `cacheRepositoryProvider` and rotates
/// automatically on `switchTo` / `addAccount`.
class CacheRepository {
  CacheRepository(this._db, {required this.accountKey});

  final AppDatabase _db;
  final String accountKey;

  Future<String?> read(String key) async {
    final row = await _db.readCachedResponse(accountKey, key);
    return row?.payload;
  }

  Future<void> write(String key, String payload) =>
      _db.writeCachedResponse(accountKey, key, payload);

  /// Drops SWR entries for the current account only. Other accounts keep
  /// their warm cache so we don't penalise unrelated sessions on logout.
  Future<void> clearAll() => _db.clearCachedResponsesFor(accountKey);
}
