import 'package:jellyfin_api/jellyfin_api.dart';

import 'jellyfin_external_url.dart';
import 'jellyfin_person.dart';
import 'jellyfin_studio.dart';

/// Domain model for a Jellyfin library item.
///
/// Mirrors the subset of [BaseItemDto] that the feature layer actually
/// consumes. Anything dealing with playback internals (media sources,
/// streams, trickplay grid) stays on the SDK type and lives in
/// `lib/core/playback/`.
///
/// Note on enums: [BaseItemKind] is reused from the SDK rather than redeclared.
/// The enum values are stable across the upstream OpenAPI schema and keep
/// pattern-matching ergonomic for callers.
class JellyfinItem {
  const JellyfinItem({
    required this.id,
    this.name,
    this.type,
    this.collectionType,
    this.overview,
    this.runTimeTicks,
    this.productionYear,
    this.communityRating,
    this.officialRating,
    this.genres = const [],
    this.parentIndexNumber,
    this.indexNumber,
    this.seriesName,
    this.seriesId,
    this.seasonId,
    this.premiereDate,
    this.providerIds = const {},
    this.studios = const [],
    this.people = const [],
    this.externalUrls = const [],
    this.imageTags = const {},
    this.backdropImageTags = const [],
    this.parentLogoItemId,
    this.parentLogoImageTag,
    this.parentBackdropItemId,
    this.parentBackdropImageTags = const [],
    this.parentThumbItemId,
    this.parentThumbImageTag,
    this.seriesPrimaryImageTag,
    this.playbackPositionTicks,
    this.played,
    this.isFavorite,
  });

  final String id;
  final String? name;
  final BaseItemKind? type;

  /// Only set on "view" items (root libraries) returned by `/Users/{userId}/Views`.
  /// Drives the kind-filtering applied to recursive `getItems` queries.
  ///
  /// Acceptance rule for adding new SDK-typed fields here: a field may live
  /// on [JellyfinItem] without a dedicated sub-type only when (a) it is
  /// already carried by [BaseItemDto], (b) it is nullable, and (c) at least
  /// one feature consumes it. Pure view-administration fields
  /// (childCount, displayPreferencesId, …) belong in a separate JellyfinView
  /// wrapper, not here.
  final CollectionType? collectionType;
  final String? overview;
  final int? runTimeTicks;
  final int? productionYear;
  final double? communityRating;
  final String? officialRating;
  final List<String> genres;
  final int? parentIndexNumber;
  final int? indexNumber;
  final String? seriesName;
  final String? seriesId;
  final String? seasonId;
  final DateTime? premiereDate;
  final Map<String, String> providerIds;
  final List<JellyfinStudio> studios;
  final List<JellyfinPerson> people;
  final List<JellyfinExternalUrl> externalUrls;
  final Map<String, String> imageTags;
  final List<String> backdropImageTags;
  final String? parentLogoItemId;
  final String? parentLogoImageTag;
  final String? parentBackdropItemId;
  final List<String> parentBackdropImageTags;
  final String? parentThumbItemId;
  final String? parentThumbImageTag;
  final String? seriesPrimaryImageTag;

  // userData fields flattened to keep call sites concise (`item.played`
  // vs `item.userData?.played`). Each is independently nullable because the
  // server may omit userData entirely for unauthenticated items.
  final int? playbackPositionTicks;
  final bool? played;
  final bool? isFavorite;

  /// Resume progress in [0, 1], or null when the inputs are missing or
  /// degenerate. Mirrors the legacy helper `resumeProgress` from
  /// `lib/features/details/_format.dart`.
  double? get resumeProgress {
    final r = runTimeTicks;
    final p = playbackPositionTicks;
    if (r == null || r <= 0 || p == null || p <= 0) return null;
    final ratio = p / r;
    return ratio.clamp(0.0, 1.0);
  }

  /// True when the user has a non-zero, non-completed resume position.
  bool get hasResumePosition {
    final p = playbackPositionTicks;
    if (p == null || p <= 0) return false;
    if (played ?? false) return false;
    return true;
  }

  /// Convenience accessor for the TMDB id — the only provider id we currently
  /// surface to Seerr / TMDB integration code paths.
  ///
  /// Lookup is case-insensitive: Jellyfin's canonical key is `Tmdb`, but
  /// some agents/imports surface `tmdb` or `TMDB`. Tolerating all variants
  /// keeps Seerr / collection matching stable across servers.
  int? get tmdbId {
    for (final entry in providerIds.entries) {
      if (entry.key.toLowerCase() == 'tmdb') return int.tryParse(entry.value);
    }
    return null;
  }
}
