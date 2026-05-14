import 'dart:convert';

import '../upcoming/models.dart';

/// Hand-rolled JSON for [UpcomingItem]. The on-disk payload is versioned by
/// the cache-key suffix in the consuming provider (`bridge_upcoming_*_v1`);
/// bump that suffix when the wire shape changes.
String encodeUpcomingItemList(List<UpcomingItem> items) {
  return jsonEncode([for (final i in items) _encode(i)]);
}

List<UpcomingItem>? tryDecodeUpcomingItemList(String payload) {
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! List) return null;
    final out = <UpcomingItem>[];
    for (final raw in decoded) {
      if (raw is! Map<String, dynamic>) continue;
      final item = _decode(raw);
      if (item != null) out.add(item);
    }
    return out;
  } on Object {
    return null;
  }
}

Map<String, dynamic> _encode(UpcomingItem i) {
  final base = <String, dynamic>{
    'releaseDate': i.releaseDate.toIso8601String(),
    'title': i.title,
    'overview': i.overview,
    'posterUrl': i.posterUrl,
    'hasFile': i.hasFile,
    'sourceId': i.sourceId,
  };
  return switch (i) {
    UpcomingMovie(:final year) => {...base, 'kind': 'movie', 'year': year},
    UpcomingEpisode(
      :final seriesTitle,
      :final seasonNumber,
      :final episodeNumber,
    ) =>
      {
        ...base,
        'kind': 'episode',
        'seriesTitle': seriesTitle,
        'seasonNumber': seasonNumber,
        'episodeNumber': episodeNumber,
      },
  };
}

UpcomingItem? _decode(Map<String, dynamic> raw) {
  final date = DateTime.tryParse((raw['releaseDate'] as String?) ?? '');
  if (date == null) return null;
  return switch (raw['kind']) {
    'movie' => UpcomingMovie(
      releaseDate: date,
      title: (raw['title'] as String?) ?? '',
      overview: (raw['overview'] as String?) ?? '',
      posterUrl: (raw['posterUrl'] as String?) ?? '',
      hasFile: raw['hasFile'] == true,
      sourceId: (raw['sourceId'] as num?)?.toInt() ?? 0,
      year: (raw['year'] as num?)?.toInt(),
    ),
    'episode' => UpcomingEpisode(
      releaseDate: date,
      title: (raw['title'] as String?) ?? '',
      overview: (raw['overview'] as String?) ?? '',
      posterUrl: (raw['posterUrl'] as String?) ?? '',
      hasFile: raw['hasFile'] == true,
      sourceId: (raw['sourceId'] as num?)?.toInt() ?? 0,
      seriesTitle: (raw['seriesTitle'] as String?) ?? '',
      seasonNumber: (raw['seasonNumber'] as num?)?.toInt() ?? 0,
      episodeNumber: (raw['episodeNumber'] as num?)?.toInt() ?? 0,
    ),
    _ => null,
  };
}
