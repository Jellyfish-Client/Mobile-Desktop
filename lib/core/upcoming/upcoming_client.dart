import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bridge/bridge_dio_provider.dart';
import 'models.dart';

final upcomingClientProvider = Provider<UpcomingClient>((ref) {
  return UpcomingClient(ref.watch(bridgeDioProvider));
});

/// Reads the aggregated upcoming-releases feed from Jellyfish.Bridge.
/// `GET /jellyfish/upcoming` merges Radarr and Sonarr into a single chronological
/// list, sorted by release date ascending.
class UpcomingClient {
  UpcomingClient(this._dio);

  final Dio _dio;

  Future<List<UpcomingItem>> get({
    int days = 30,
    Set<UpcomingKind> kinds = const {
      UpcomingKind.movies,
      UpcomingKind.episodes,
    },
    bool onlyMissing = true,
    int limit = 50,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'jellyfish/upcoming',
      queryParameters: {
        'days': days,
        'kinds': kinds.map((k) => k.wire).join(','),
        'onlyMissing': onlyMissing,
        'limit': limit,
      },
    );
    final raw = (res.data?['items'] as List?) ?? const [];
    final out = <UpcomingItem>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final json = Map<String, dynamic>.from(entry);
      final item = _parseItem(json);
      if (item != null) out.add(item);
    }
    return out;
  }

  static UpcomingItem? _parseItem(Map<String, dynamic> json) {
    final date = _parseDate(json['releaseDate']);
    if (date == null) return null;
    return switch (json['kind']) {
      'movie' => UpcomingMovie(
        releaseDate: date,
        title: (json['title'] as String?) ?? '',
        overview: (json['overview'] as String?) ?? '',
        posterUrl: (json['posterUrl'] as String?) ?? '',
        hasFile: json['hasFile'] == true,
        sourceId: (json['sourceId'] as num?)?.toInt() ?? 0,
        year: (json['year'] as num?)?.toInt(),
      ),
      'episode' => UpcomingEpisode(
        releaseDate: date,
        title: (json['title'] as String?) ?? '',
        overview: (json['overview'] as String?) ?? '',
        posterUrl: (json['posterUrl'] as String?) ?? '',
        hasFile: json['hasFile'] == true,
        sourceId: (json['sourceId'] as num?)?.toInt() ?? 0,
        seriesTitle: (json['seriesTitle'] as String?) ?? '',
        seasonNumber: (json['seasonNumber'] as num?)?.toInt() ?? 0,
        episodeNumber: (json['episodeNumber'] as num?)?.toInt() ?? 0,
      ),
      _ => null,
    };
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }
}
