import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import 'models/jellyfin_item.dart';
import 'user_views_provider.dart';

/// Maps the user's libraries to the set of top-level item kinds that should
/// appear when no library is selected. Excludes Season/Episode so series stay
/// grouped under their parent.
List<BaseItemKind> rootKindsForViews(List<JellyfinItem> views) {
  final kinds = <BaseItemKind>{};
  var sawUnknown = false;
  for (final v in views) {
    final type = v.collectionType;
    if (type == CollectionType.movies) {
      kinds.add(BaseItemKind.movie);
    } else if (type == CollectionType.tvshows) {
      kinds.add(BaseItemKind.series);
    } else if (type == CollectionType.boxsets) {
      kinds.add(BaseItemKind.boxSet);
    } else if (type == CollectionType.music) {
      kinds.add(BaseItemKind.musicAlbum);
    } else if (type == CollectionType.books) {
      kinds.add(BaseItemKind.book);
    } else if (type == CollectionType.homevideos) {
      kinds
        ..add(BaseItemKind.video)
        ..add(BaseItemKind.photo);
    } else if (type == CollectionType.musicvideos) {
      kinds.add(BaseItemKind.musicVideo);
    } else if (type == CollectionType.photos) {
      kinds.add(BaseItemKind.photo);
    } else if (type == CollectionType.trailers) {
      kinds.add(BaseItemKind.trailer);
    } else if (type == CollectionType.playlists) {
      kinds.add(BaseItemKind.playlist);
    } else {
      sawUnknown = true;
    }
  }
  if (sawUnknown || kinds.isEmpty) {
    kinds
      ..add(BaseItemKind.movie)
      ..add(BaseItemKind.series);
  }
  return kinds.toList();
}

/// Derived from [userViewsProvider] — the set of item kinds the Library and
/// Search screens use as their default scope (no specific view selected).
/// Non-autoDispose: shared by Library + Search, computed once per session.
final rootKindsProvider = FutureProvider<List<BaseItemKind>>((ref) async {
  final views = await ref.watch(userViewsProvider.future);
  return rootKindsForViews(views);
});
