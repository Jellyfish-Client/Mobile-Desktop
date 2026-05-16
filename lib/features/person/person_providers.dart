import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../core/jellyfin/jellyfin_client.dart';
import '../../core/jellyfin/mappers/base_item_dto_mapper.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';

/// The person as a domain item — name, biography (from `overview`), image
/// tags, and TMDB provider id. Sourced from the same `/Users/{userId}/Items/{id}`
/// endpoint as any other item, which conveniently exposes `providerIds`.
final personProvider = FutureProvider.autoDispose.family<JellyfinItem, String>((
  ref,
  personId,
) async {
  final dto = await ref.watch(jellyfinClientProvider).item(personId);
  final domain = dto.toDomain();
  if (domain == null) {
    throw StateError('Jellyfin person $personId has no id');
  }
  return domain;
});

/// Movies and series in which the person is credited, sourced from the local
/// Jellyfin library. Sorted by production year descending (server-side).
final personFilmographyProvider = FutureProvider.autoDispose
    .family<List<JellyfinItem>, String>((ref, personId) async {
      final dtos = await ref
          .watch(jellyfinClientProvider)
          .itemsByPerson(
            personId,
            includeItemTypes: const [BaseItemKind.movie, BaseItemKind.series],
          );
      return dtos.toDomainList();
    });

/// Seerr biography / extra metadata fallback for the person. Returns null
/// when Seerr isn't linked or the lookup fails. Callers use it only to fill
/// holes left by the Jellyfin metadata (no biography, no portrait).
final personSeerrDetailProvider = FutureProvider.autoDispose
    .family<SeerrPersonDetail?, int>((ref, tmdbPersonId) async {
      final client = ref.watch(seerrClientProvider);
      if (!client.isLinked) return null;
      return client.personDetails(tmdbPersonId);
    });

/// Key for `personSeerrMissingCreditsProvider`: pairs the TMDB person id used
/// to query Seerr with the Jellyfin id used to query the local filmography
/// (needed to subtract titles already in the library).
typedef PersonSeerrCreditsKey = ({int tmdbPersonId, String jellyfinPersonId});

/// Seerr combined credits for the TMDB person id, filtered to titles that are:
/// - NOT already in the Jellyfin filmography (TMDB-id-based dedup), and
/// - NOT marked available on Seerr (those would just duplicate the library).
/// Returns an empty list when Seerr isn't linked.
final personSeerrMissingCreditsProvider = FutureProvider.autoDispose
    .family<List<SeerrMedia>, PersonSeerrCreditsKey>((ref, key) async {
      final client = ref.watch(seerrClientProvider);
      if (!client.isLinked) return const [];
      final filmography = await ref.watch(
        personFilmographyProvider(key.jellyfinPersonId).future,
      );
      final present = <int>{
        for (final i in filmography)
          if (i.tmdbId != null) i.tmdbId!,
      };
      final credits = await client.personCombinedCredits(key.tmdbPersonId);
      return [
        for (final m in credits)
          if (!present.contains(m.tmdbId) &&
              m.availability != SeerrAvailability.available)
            m,
      ];
    });

enum PersonFilter { all, movies, series }

/// Per-person filter state for the Tout / Films / Séries chips. Scoped by
/// person id so navigating between two actor pages doesn't leak selection.
final personFilterProvider = StateProvider.autoDispose
    .family<PersonFilter, String>((ref, _) => PersonFilter.all);
