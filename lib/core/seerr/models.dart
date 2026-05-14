// Lightweight DTOs surfaced by [SeerrClient]. Keeps callers free of
// the verbose generated `built_value` types.

enum SeerrMediaType { movie, tv, collection }

/// Maps directly to Seerr's `MediaStatus` integer enum.
enum SeerrAvailability {
  unknown,
  pending,
  processing,
  partiallyAvailable,
  available;

  static SeerrAvailability fromCode(num? code) {
    switch (code?.toInt()) {
      case 2:
        return SeerrAvailability.pending;
      case 3:
        return SeerrAvailability.processing;
      case 4:
        return SeerrAvailability.partiallyAvailable;
      case 5:
        return SeerrAvailability.available;
      case 1:
      default:
        return SeerrAvailability.unknown;
    }
  }
}

class SeerrMedia {
  const SeerrMedia({
    required this.tmdbId,
    required this.type,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.year,
    this.voteAverage,
    this.availability = SeerrAvailability.unknown,
  });

  final int tmdbId;
  final SeerrMediaType type;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final int? year;
  final double? voteAverage;
  final SeerrAvailability availability;
}

class SeerrRequest {
  const SeerrRequest({
    required this.id,
    required this.tmdbId,
    required this.type,
    this.title,
    this.posterPath,
    this.year,
    this.availability = SeerrAvailability.unknown,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int tmdbId;
  final SeerrMediaType type;
  final String? title;
  final String? posterPath;
  final int? year;
  final SeerrAvailability availability;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// A TMDB movie collection (e.g. "Saw Collection"). Surfaced both in search
/// results (as a stub with [parts] left empty) and via `/collection/{id}`
/// (fully populated with [parts] for the selection sheet).
class SeerrCollection {
  const SeerrCollection({
    required this.tmdbId,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.parts = const [],
  });

  final int tmdbId;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;

  /// Movies in the collection. Empty for the search-stub form; populated
  /// when the collection is fetched via `SeerrClient.collection`.
  final List<SeerrMedia> parts;
}

/// One season of a TV show, as returned by Seerr's `/tv/{tmdbId}` endpoint.
/// `seasonNumber == 0` is the Specials season.
class SeerrTvSeason {
  const SeerrTvSeason({
    required this.seasonNumber,
    this.name,
    this.episodeCount,
    this.posterPath,
    this.availability = SeerrAvailability.unknown,
  });

  final int seasonNumber;
  final String? name;
  final int? episodeCount;
  final String? posterPath;

  /// Server-side status of this season — `pending`/`processing` mean the
  /// user already filed a request and Seerr is working on it.
  final SeerrAvailability availability;

  bool get isSpecials => seasonNumber == 0;
}

/// A streaming/rental service surfaced by Seerr's `/watchproviders/{movies|tv}`
/// endpoint. The TMDB `id` is what `/discover/{movies|tv}?watchProviders=` accepts.
class SeerrWatchProvider {
  const SeerrWatchProvider({
    required this.id,
    required this.name,
    this.logoPath,
  });

  final int id;
  final String name;

  /// Raw TMDB path (prefixed with `/`). Use `SeerrClient.providerLogoUrl` to
  /// turn it into a usable image URL.
  final String? logoPath;
}

/// One genre slide from `/discover/genreslider/{movie|tv}`. Backdrops are
/// raw TMDB paths (prefixed with `/`), turned into URLs by `SeerrClient`.
class SeerrGenreSlide {
  const SeerrGenreSlide({
    required this.id,
    required this.name,
    this.backdrops = const [],
  });

  final int id;
  final String name;
  final List<String> backdrops;
}
