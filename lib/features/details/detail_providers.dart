import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../core/jellyfin/jellyfin_client.dart';
import '../../core/jellyfin/mappers/base_item_dto_mapper.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';

final itemProvider = FutureProvider.autoDispose.family<JellyfinItem, String>((
  ref,
  id,
) async {
  final dto = await ref.watch(jellyfinClientProvider).item(id);
  final domain = dto.toDomain();
  if (domain == null) {
    throw StateError('Jellyfin item $id has no id');
  }
  return domain;
});

final seasonsProvider = FutureProvider.autoDispose
    .family<List<JellyfinItem>, String>((ref, seriesId) async {
      final dtos = await ref.watch(jellyfinClientProvider).seasons(seriesId);
      return dtos.toDomainList();
    });

/// Items contained in a BoxSet (collection). Returned in server order so the
/// detail view can render them as a poster grid.
final boxSetItemsProvider = FutureProvider.autoDispose
    .family<List<JellyfinItem>, String>((ref, boxSetId) async {
      final res = await ref
          .watch(jellyfinClientProvider)
          .queryItems(parentId: boxSetId, limit: 200);
      return (res.items?.toList() ?? const <BaseItemDto>[]).toDomainList();
    });

final episodesProvider = FutureProvider.autoDispose
    .family<List<JellyfinItem>, ({String seriesId, String seasonId})>((
      ref,
      args,
    ) async {
      final dtos = await ref
          .watch(jellyfinClientProvider)
          .episodes(args.seriesId, seasonId: args.seasonId);
      return dtos.toDomainList();
    });

/// Resolves the next episode the user should play for a series — either a
/// resumable in-progress episode or the first unwatched one. Null when the
/// series has no episodes.
final seriesNextUpProvider = FutureProvider.autoDispose
    .family<JellyfinItem?, String>((ref, seriesId) async {
      final dto = await ref
          .watch(jellyfinClientProvider)
          .seriesNextUp(seriesId);
      return dto?.toDomain();
    });

/// Inline season selector for the Series detail page. Holds the currently
/// displayed `seasonId` per `seriesId`. `null` means "not initialised yet" —
/// the Series view seeds it from the next-up episode (or the first season)
/// the first time both providers resolve.
final selectedSeasonProvider = StateProvider.autoDispose
    .family<String?, String>((ref, seriesId) => null);

/// Items the Jellyfin server considers similar to `itemId`. Used by the
/// "Suggestions" rail on movie/series detail pages.
final similarItemsProvider = FutureProvider.autoDispose
    .family<List<JellyfinItem>, String>((ref, itemId) async {
      // keepAlive prevents re-fetching when the section scrolls off screen.
      ref.keepAlive();
      final dtos = await ref
          .watch(jellyfinClientProvider)
          .similar(itemId, limit: 24);
      return dtos.toDomainList();
    });

/// Seerr similar-items lookup keyed by `(tmdbId, mediaType)`. Returns an
/// empty list when Seerr isn't linked, when the item has no TMDB id, or
/// when the lookup fails so the rail can hide silently.
final seerrSimilarProvider = FutureProvider.autoDispose
    .family<List<SeerrMedia>, ({int tmdbId, SeerrMediaType type})>((
      ref,
      key,
    ) async {
      ref.keepAlive();
      final client = ref.watch(seerrClientProvider);
      if (!client.isLinked) return const [];
      try {
        return key.type == SeerrMediaType.movie
            ? await client.similarMovies(key.tmdbId)
            : await client.similarTv(key.tmdbId);
      } on Object catch (_) {
        return const [];
      }
    });

/// Seasons of a Seerr TV show keyed by TMDB id. Used by the request sheet
/// to populate the season picker. Returns an empty list on any failure so
/// callers can fall back to "request all" silently.
final seerrTvSeasonsProvider = FutureProvider.autoDispose
    .family<List<SeerrTvSeason>, int>((ref, tmdbId) async {
      final client = ref.watch(seerrClientProvider);
      if (!client.isLinked) return const [];
      return client.tvSeasons(tmdbId);
    });

/// Seasons that exist on TMDB (via Seerr) but aren't yet in the user's
/// Jellyfin library for the given series. Specials (season 0) are excluded —
/// they are rarely useful to mass-request. Empty when Seerr isn't linked.
final missingSeasonsProvider = FutureProvider.autoDispose
    .family<List<SeerrTvSeason>, ({String seriesId, int tmdbId})>((
      ref,
      key,
    ) async {
      final all = await ref.watch(seerrTvSeasonsProvider(key.tmdbId).future);
      final present = await ref.watch(seasonsProvider(key.seriesId).future);
      final presentNumbers = <int>{
        for (final s in present)
          if (s.indexNumber != null) s.indexNumber!,
      };
      // Filter rule: hide a season iff it is already entirely served. We
      // exclude `available` (Seerr considers it fully delivered) and keep
      // `partiallyAvailable`, `pending`, `processing` visible so the user
      // can still see progress / re-request the missing episodes.
      return [
        for (final s in all)
          if (!s.isSpecials &&
              !presentNumbers.contains(s.seasonNumber) &&
              s.availability != SeerrAvailability.available)
            s,
      ];
    });

/// Movies that exist in the TMDB collection matching this BoxSet (via Seerr)
/// but aren't yet in the user's library. Resolution strategy:
///   1. If the BoxSet itself carries a TMDB provider id (Jellyfin's TMDB
///      Box Sets plugin populates this), use it as the collection id.
///   2. Otherwise, walk the children and ask Seerr for the first movie's
///      `belongs_to_collection.id`. This covers user-created BoxSets that
///      have no TMDB id of their own but contain TMDB-matched movies.
/// Returns empty when Seerr isn't linked, no collection can be resolved, or
/// the collection has no missing parts.
final missingCollectionMoviesProvider = FutureProvider.autoDispose
    .family<List<SeerrMedia>, String>((ref, boxSetId) async {
      final client = ref.watch(seerrClientProvider);
      final children = await ref.watch(boxSetItemsProvider(boxSetId).future);
      final boxSetItem = await ref.watch(itemProvider(boxSetId).future);

      var collectionId = boxSetItem.tmdbId;
      collectionId ??= _collectionIdFromExternalUrls(boxSetItem);
      if (collectionId == null) {
        for (final c in children) {
          final movieId = c.tmdbId;
          if (movieId == null) continue;
          collectionId = await client.movieCollectionId(movieId);
          if (collectionId != null) break;
        }
      }
      if (collectionId == null) return const [];

      final collection = await client.collection(collectionId);
      if (collection == null) return const [];
      final presentTmdbIds = <int>{
        for (final c in children)
          if (c.tmdbId != null) c.tmdbId!,
      };
      final missing = [
        for (final m in collection.parts)
          if (!presentTmdbIds.contains(m.tmdbId) &&
              m.availability != SeerrAvailability.available)
            m,
      ];
      return missing;
    });

final _tmdbCollectionUrlRegex = RegExp(r'themoviedb\.org/collection/(\d+)');

/// Some Jellyfin BoxSets are linked to a TMDB collection only via their
/// `ExternalUrls` (the TMDB Box Sets plugin populates the URL but not always
/// `ProviderIds.Tmdb`). This pulls the collection id back out of that URL.
int? _collectionIdFromExternalUrls(JellyfinItem item) {
  for (final ext in item.externalUrls) {
    final url = ext.url;
    if (url == null) continue;
    final match = _tmdbCollectionUrlRegex.firstMatch(url);
    if (match != null) {
      final id = int.tryParse(match.group(1)!);
      if (id != null) return id;
    }
  }
  return null;
}
