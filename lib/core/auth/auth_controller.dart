import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_database_provider.dart';
import 'account_key.dart';
import 'accounts_repository.dart';
import 'saved_account.dart';
import 'session.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, SessionState>(AuthController.new);

class AuthController extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    final repo = ref.read(accountsRepositoryProvider);
    final accounts = await repo.readAll();
    if (accounts.isEmpty) return SessionState.empty;
    return SessionState(session: _sessionFrom(accounts.first));
  }

  /// Returns the full list of known accounts, ordered by last-used desc.
  Future<List<SavedAccount>> listAccounts() {
    return ref.read(accountsRepositoryProvider).readAll();
  }

  /// Persists a freshly authenticated account and makes it active.
  ///
  /// Since persisted state (SWR cache, downloads, sync queue) is now
  /// account-scoped, switching does NOT wipe anything globally — the new
  /// account simply starts from its own (possibly empty) scope.
  Future<void> addAccount(SavedAccount account) async {
    final repo = ref.read(accountsRepositoryProvider);
    final stamped = account.copyWith(lastUsedAt: DateTime.now().toUtc());
    await repo.upsert(stamped);
    state = AsyncData(SessionState(session: _sessionFrom(stamped)));
  }

  /// Switches the active session to an already-persisted account. No network
  /// call — the stored token is reused. If it's stale, the auth interceptor
  /// will trigger a re-auth prompt on the next request. Each account keeps
  /// its own scoped SWR cache so the home screen paints from disk instantly.
  Future<void> switchTo({
    required String serverId,
    required String userId,
  }) async {
    final repo = ref.read(accountsRepositoryProvider);
    final updated = await repo.markUsed(serverId, userId);
    if (updated == null) return;
    state = AsyncData(SessionState(session: _sessionFrom(updated)));
  }

  /// Removes an account from the persistent store. If it was the active one,
  /// falls back to the next most-recently-used account, or to the empty state
  /// if no other accounts remain. Also drops the removed account's SWR cache
  /// to avoid orphan rows piling up in Drift.
  Future<void> removeAccount({
    required String serverId,
    required String userId,
  }) async {
    final repo = ref.read(accountsRepositoryProvider);
    final wasActive =
        state.valueOrNull?.session?.serverId == serverId &&
        state.valueOrNull?.session?.userId == userId;
    await _wipeAccountCache(serverId: serverId, userId: userId);
    await repo.remove(serverId, userId);
    if (!wasActive) return;
    final remaining = await repo.readAll();
    if (remaining.isEmpty) {
      state = const AsyncData(SessionState.empty);
    } else {
      state = AsyncData(SessionState(session: _sessionFrom(remaining.first)));
    }
  }

  /// Removes every account tied to [serverId] in a single batch. If the active
  /// session was on that server, it falls back to the next account or to the
  /// empty state. Cheaper than calling [removeAccount] in a loop because the
  /// underlying store is rewritten once.
  Future<void> removeServer(String serverId) async {
    final repo = ref.read(accountsRepositoryProvider);
    final activeOnServer = state.valueOrNull?.session?.serverId == serverId;
    final affected = await repo.readAll();
    // Wipe each removed account's cache before mutating the store, so we
    // don't accumulate orphan rows.
    for (final a in affected.where((a) => a.serverId == serverId)) {
      await _wipeAccountCache(serverId: a.serverId, userId: a.userId);
    }
    final removed = await repo.removeServer(serverId);
    if (removed == 0 || !activeOnServer) return;
    final remaining = await repo.readAll();
    if (remaining.isEmpty) {
      state = const AsyncData(SessionState.empty);
    } else {
      state = AsyncData(SessionState(session: _sessionFrom(remaining.first)));
    }
  }

  /// Logs out of the active account: removes it from the store and falls back
  /// to the next account (or onboarding if it was the last one).
  Future<void> clear() async {
    final active = state.valueOrNull?.session;
    if (active == null) return;
    await removeAccount(serverId: active.serverId, userId: active.userId);
  }

  /// Drops the SWR cache rows belonging to the given (server, user). Downloads
  /// and pending sync rows are intentionally NOT cleared here — those carry
  /// local files / unsent ops we don't want to silently drop. A future
  /// `purgeAccountStorage(accountKey)` flow can wipe them once we also delete
  /// the on-disk media (out of scope for this PR).
  Future<void> _wipeAccountCache({
    required String serverId,
    required String userId,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final key = accountKeyForSession(
      Session(
        serverUrl: '',
        serverId: serverId,
        userId: userId,
        userName: '',
        accessToken: '',
      ),
    );
    await db.clearCachedResponsesFor(key);
  }

  /// Updates the active session's admin flag and persists it back to the
  /// account store. Used by the boot-time refresh that calls `/Users/Me` so
  /// accounts persisted before the flag existed (or whose server-side policy
  /// changed) get the right value without forcing a re-login.
  Future<void> refreshAdminFlag({required bool isAdmin}) async {
    final active = state.valueOrNull?.session;
    if (active == null || active.isAdmin == isAdmin) return;
    final repo = ref.read(accountsRepositoryProvider);
    final accounts = await repo.readAll();
    final match = accounts.firstWhere(
      (a) => a.serverId == active.serverId && a.userId == active.userId,
      orElse: () => throw StateError('Active account not found in repository'),
    );
    await repo.upsert(match.copyWith(isAdmin: isAdmin));
    state = AsyncData(
      SessionState(session: active.copyWith(isAdmin: isAdmin)),
    );
  }

  /// Renames the active account (after a successful `UserApi.updateUser`).
  /// Keeps the persisted SavedAccount and the in-memory Session in sync so the
  /// Settings tile, AccountAvatar fallback initial and account switcher all
  /// reflect the new name without forcing a re-login.
  Future<void> refreshUserName(String userName) async {
    final active = state.valueOrNull?.session;
    if (active == null || active.userName == userName) return;
    final repo = ref.read(accountsRepositoryProvider);
    final accounts = await repo.readAll();
    final match = accounts.firstWhere(
      (a) => a.serverId == active.serverId && a.userId == active.userId,
      orElse: () => throw StateError('Active account not found in repository'),
    );
    await repo.upsert(match.copyWith(userName: userName));
    state = AsyncData(
      SessionState(session: active.copyWith(userName: userName)),
    );
  }

  /// Refreshes the cached avatar tag for the active account. `tag` is the
  /// server's image cache key (`UserDto.primaryImageTag`) — pass null after a
  /// `deleteUserImage` to fall back to the colourised initial. We don't carry
  /// the tag on Session: AccountAvatar reads SavedAccount directly, so we only
  /// touch the persistent store here. The SavedAccount is rebuilt explicitly
  /// rather than via copyWith because copyWith's `??` semantics swallow null
  /// arguments and we genuinely need to clear the tag on delete.
  Future<void> refreshAvatarTag(String? tag) async {
    final active = state.valueOrNull?.session;
    if (active == null) return;
    final repo = ref.read(accountsRepositoryProvider);
    final accounts = await repo.readAll();
    final match = accounts.firstWhere(
      (a) => a.serverId == active.serverId && a.userId == active.userId,
      orElse: () => throw StateError('Active account not found in repository'),
    );
    if (match.primaryImageTag == tag) return;
    await repo.upsert(
      SavedAccount(
        serverId: match.serverId,
        serverUrl: match.serverUrl,
        serverName: match.serverName,
        userId: match.userId,
        userName: match.userName,
        accessToken: match.accessToken,
        proxyAuth: match.proxyAuth,
        primaryImageTag: tag,
        isAdmin: match.isAdmin,
        lastUsedAt: match.lastUsedAt,
      ),
    );
  }

  Session _sessionFrom(SavedAccount a) => Session(
    serverUrl: a.serverUrl,
    serverId: a.serverId,
    userId: a.userId,
    userName: a.userName,
    accessToken: a.accessToken,
    proxyAuth: a.proxyAuth,
    isAdmin: a.isAdmin,
  );
}
