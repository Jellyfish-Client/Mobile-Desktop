import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'jellyfin_client.dart';
import 'mappers/base_item_dto_mapper.dart';
import 'models/jellyfin_item.dart';

/// User libraries (a.k.a. "views"). Session-scoped Jellyfin primitive shared
/// by Library, Search and Home — kept non-autoDispose so reopening any of
/// those screens reuses the cached payload instead of refetching.
final userViewsProvider = FutureProvider<List<JellyfinItem>>((ref) async {
  final dtos = await ref.read(jellyfinClientProvider).userViews();
  return dtos.toDomainList();
});
