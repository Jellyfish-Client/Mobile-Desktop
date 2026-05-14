import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/auth/accounts_repository.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/saved_account.dart';
import '../../../core/jellyfin/jellyfin_client.dart';

/// Current user fetched from `/Users/Me`. Profile screen mutations invalidate
/// this provider to refresh the displayed name and avatar tag.
final currentUserProvider = FutureProvider.autoDispose<UserDto>((ref) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getUserApi().getCurrentUser();
  return res.data!;
});

/// SavedAccount entry for the active session, used to feed AccountAvatar so it
/// has a real `primaryImageTag` to query. Re-fetched when the auth state
/// changes (rename/avatar update), and bypasses copyWith?? null pitfalls by
/// reading directly from the persistent store.
final activeSavedAccountProvider =
    FutureProvider.autoDispose<SavedAccount?>((ref) async {
  // Rebuild when sessions change (rename, account switch, …).
  final session = ref.watch(
    authControllerProvider.select((s) => s.valueOrNull?.session),
  );
  if (session == null) return null;
  final repo = ref.read(accountsRepositoryProvider);
  final accounts = await repo.readAll();
  for (final a in accounts) {
    if (a.serverId == session.serverId && a.userId == session.userId) {
      return a;
    }
  }
  return null;
});
