import 'dart:convert';

import '../seerr/models.dart';

/// Hand-rolled JSON for [SeerrMedia] — these DTOs aren't generated via
/// built_value, so we serialise the fields the Home rails actually display.
/// The on-disk payload is versioned by the cache key suffix; bump `_v1` to
/// invalidate persisted blobs after a field-shape change.
String encodeSeerrMediaList(List<SeerrMedia> items) {
  return jsonEncode([for (final m in items) _encode(m)]);
}

List<SeerrMedia>? tryDecodeSeerrMediaList(String payload) {
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! List) return null;
    return [
      for (final raw in decoded)
        if (raw is Map<String, dynamic>) _decode(raw),
    ];
  } on Object {
    return null;
  }
}

Map<String, dynamic> encodeSeerrMediaJson(SeerrMedia m) => _encode(m);

SeerrMedia? tryDecodeSeerrMediaJson(Map<String, dynamic> raw) {
  try {
    return _decode(raw);
  } on Object {
    return null;
  }
}

Map<String, dynamic> _encode(SeerrMedia m) => {
  'tmdbId': m.tmdbId,
  'type': m.type.name,
  'title': m.title,
  'overview': m.overview,
  'posterPath': m.posterPath,
  'backdropPath': m.backdropPath,
  'year': m.year,
  'voteAverage': m.voteAverage,
  'availability': m.availability.name,
};

SeerrMedia _decode(Map<String, dynamic> raw) {
  return SeerrMedia(
    tmdbId: raw['tmdbId'] as int,
    type: SeerrMediaType.values.byName(raw['type'] as String),
    title: raw['title'] as String,
    overview: raw['overview'] as String?,
    posterPath: raw['posterPath'] as String?,
    backdropPath: raw['backdropPath'] as String?,
    year: raw['year'] as int?,
    voteAverage: (raw['voteAverage'] as num?)?.toDouble(),
    availability: SeerrAvailability.values.byName(
      raw['availability'] as String,
    ),
  );
}

String encodeSeerrWatchProviderList(List<SeerrWatchProvider> items) {
  return jsonEncode([
    for (final p in items) {'id': p.id, 'name': p.name, 'logoPath': p.logoPath},
  ]);
}

List<SeerrWatchProvider>? tryDecodeSeerrWatchProviderList(String payload) {
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! List) return null;
    return [
      for (final raw in decoded)
        if (raw is Map<String, dynamic>)
          SeerrWatchProvider(
            id: (raw['id'] as num).toInt(),
            name: raw['name'] as String,
            logoPath: raw['logoPath'] as String?,
          ),
    ];
  } on Object {
    return null;
  }
}

String encodeSeerrGenreSlideList(List<SeerrGenreSlide> items) {
  return jsonEncode([
    for (final g in items)
      {'id': g.id, 'name': g.name, 'backdrops': g.backdrops},
  ]);
}

List<SeerrGenreSlide>? tryDecodeSeerrGenreSlideList(String payload) {
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! List) return null;
    return [
      for (final raw in decoded)
        if (raw is Map<String, dynamic>)
          SeerrGenreSlide(
            id: (raw['id'] as num).toInt(),
            name: raw['name'] as String,
            backdrops:
                (raw['backdrops'] as List?)?.whereType<String>().toList() ??
                const [],
          ),
    ];
  } on Object {
    return null;
  }
}
