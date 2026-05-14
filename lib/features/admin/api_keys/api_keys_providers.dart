import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Lists the API keys minted on the server. Keys are sorted by `dateCreated`
/// descending so the freshest entries come first — that's the one the user
/// just created and is most likely to copy. The notifier exposes
/// create/revoke instance methods so callers can `await
/// ref.read(adminApiKeysProvider.notifier).create(appName)` and let the
/// refreshed list pull in the freshly-minted token.
///
/// Note: Jellyfin's `createKey` endpoint returns void — the new key is only
/// retrievable via a follow-up `getKeys` call, which is why every mutator
/// here ends with `refresh()` instead of returning a value directly.
class AdminApiKeysNotifier
    extends AutoDisposeAsyncNotifier<List<AuthenticationInfo>> {
  @override
  Future<List<AuthenticationInfo>> build() => _fetch();

  Future<List<AuthenticationInfo>> _fetch() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getApiKeyApi().getKeys();
    // Newest-first by creation date — tokens with no date sink to the
    // bottom so they don't bury the entry the admin just created.
    final list =
        (res.data?.items?.toList() ?? <AuthenticationInfo>[])
          ..sort((a, b) {
            final ad = a.dateCreated;
            final bd = b.dateCreated;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad);
          });
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Mints a new API key for the given app name. The endpoint takes `app`
  /// (not `appName`) and returns void; the resulting token shows up in the
  /// next `getKeys` payload.
  Future<void> create(String appName) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getApiKeyApi().createKey(app: appName);
    await refresh();
  }

  /// Revokes a key by its access token (not its database id — that's what
  /// the DELETE `/Auth/Keys/{key}` endpoint expects).
  Future<void> revoke(String accessToken) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getApiKeyApi().revokeKey(key: accessToken);
    await refresh();
  }
}

final adminApiKeysProvider = AutoDisposeAsyncNotifierProvider<
    AdminApiKeysNotifier, List<AuthenticationInfo>>(
  AdminApiKeysNotifier.new,
);
