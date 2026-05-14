import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../core/jellyfin/jellyfin_client.dart';

/// Active user's `UserConfiguration` fetched from `/Users/Me`. The playback
/// settings screen watches this and writes back via `updateUserConfiguration`.
/// AutoDispose because we only need it while the screen is mounted.
final playbackConfigProvider = FutureProvider.autoDispose<UserConfiguration>((
  ref,
) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getUserApi().getCurrentUser();
  final user = res.data!;
  // The server always sends a Configuration block, but be defensive — fall
  // back to a fresh builder so the screen never crashes on a corner-case
  // missing field.
  return user.configuration ?? UserConfiguration();
});

/// Cached list of language cultures known to the server. Used by the audio /
/// subtitle language pickers in the playback screen. Kept on a long-lived
/// provider (no autoDispose) so flipping between the two pickers, or
/// reopening the screen, doesn't refetch the 200+ entry list every time.
final culturesProvider = FutureProvider<List<CultureDto>>((ref) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getLocalizationApi().getCultures();
  final list = (res.data?.toList() ?? <CultureDto>[])
    ..sort(
      (a, b) => (a.displayName ?? '').toLowerCase().compareTo(
        (b.displayName ?? '').toLowerCase(),
      ),
    );
  return list;
});
