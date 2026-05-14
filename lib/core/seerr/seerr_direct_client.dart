import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../bridge/bridge_dio_provider.dart';
import 'models.dart';

/// Direct-to-Jellyseerr client used by the Home "mood" rails.
///
/// The regular `SeerrClient` talks through the Jellyfish.Bridge plugin's
/// `/jellyfish/jellyseerr/...` passthrough wrappers, which only forward a
/// small whitelist of query parameters (`page`, `genre`, `watchProviders`)
/// and silently drop the TMDB knobs the mood specs depend on (`sortBy`,
/// `voteCountGte`, `voteAverageGte`). This client bypasses the wrapper and
/// hits Jellyseerr's `/api/v1/discover/movies` endpoint directly with the
/// full TMDB query string.
///
/// Credentials (Jellyseerr URL + admin API key) are fetched once per session
/// from the Bridge plugin's `/jellyfish/jellyseerr/config` endpoint.

class SeerrDirectConfig {
  const SeerrDirectConfig({required this.url, required this.apiKey});

  final String url;
  final String apiKey;
}

/// Fetches the Jellyseerr URL + admin API key from the Bridge plugin once per
/// session. Returns null when the plugin isn't installed or Jellyseerr isn't
/// configured (Bridge replies 503) — callers fall back to the bridge-routed
/// `SeerrClient` in that case.
///
/// Account switches invalidate the cached config: watching the session
/// fingerprint forces a re-fetch against the new server's Bridge so we never
/// reuse the previous user's URL/key. `keepAlive` keeps the result across
/// transient unmounts (tab switch during cold start).
final seerrDirectConfigProvider =
    FutureProvider.autoDispose<SeerrDirectConfig?>((ref) async {
      final session = ref.watch(authControllerProvider).valueOrNull?.session;
      ref.keepAlive();
      if (session == null) return null;
      final dio = ref.watch(bridgeDioProvider);
      try {
        final res = await dio.get<Map<String, dynamic>>(
          'jellyfish/jellyseerr/config',
        );
        final data = res.data;
        if (data == null) return null;
        final url = (data['url'] as String?)?.trim();
        final apiKey = (data['apiKey'] as String?)?.trim();
        if (url == null || url.isEmpty || apiKey == null || apiKey.isEmpty) {
          return null;
        }
        return SeerrDirectConfig(url: url, apiKey: apiKey);
      } on DioException {
        return null;
      }
    });

/// Builds a `SeerrDirectClient` once the config future resolves. Returns null
/// when the plugin isn't installed / Jellyseerr isn't configured — callers
/// must guard against null and either skip the fetch or fall back to the
/// bridge-routed `SeerrClient`. The Dio is closed when the provider disposes
/// (account switch, app teardown).
final seerrDirectClientProvider =
    FutureProvider.autoDispose<SeerrDirectClient?>((ref) async {
      ref.keepAlive();
      final config = await ref.watch(seerrDirectConfigProvider.future);
      if (config == null) return null;
      final base = config.url.endsWith('/') ? config.url : '${config.url}/';
      final dio = Dio(
        BaseOptions(
          baseUrl: base,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
            'X-Api-Key': config.apiKey,
          },
        ),
      );
      if (kDebugMode) {
        dio.interceptors.add(
          LogInterceptor(requestBody: false, responseBody: false),
        );
      }
      ref.onDispose(dio.close);
      return SeerrDirectClient(dio);
    });

class SeerrDirectClient {
  SeerrDirectClient(this._dio);

  final Dio _dio;

  /// Hits Jellyseerr's `/api/v1/discover/movies` directly. Genre ids are
  /// joined with `|` (TMDB's OR semantics) so a movie matching any of the
  /// listed genres is eligible. Empty / null fields are omitted from the
  /// query string so they don't override Jellyseerr's defaults.
  Future<List<SeerrMedia>> discoverMovies({
    int page = 1,
    List<int> genres = const [],
    String? sortBy,
    int? voteCountGte,
    double? voteAverageGte,
    String? primaryReleaseDateGte,
    String? primaryReleaseDateLte,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (genres.isNotEmpty) params['genre'] = genres.join('|');
    if (sortBy != null) params['sortBy'] = sortBy;
    if (voteCountGte != null) params['voteCountGte'] = voteCountGte;
    if (voteAverageGte != null) params['voteAverageGte'] = voteAverageGte;
    if (primaryReleaseDateGte != null) {
      params['primaryReleaseDateGte'] = primaryReleaseDateGte;
    }
    if (primaryReleaseDateLte != null) {
      params['primaryReleaseDateLte'] = primaryReleaseDateLte;
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'api/v1/discover/movies',
      queryParameters: params,
    );
    return _mapResults(res.data?['results']);
  }

  List<SeerrMedia> _mapResults(Object? results) {
    if (results is! List) return const [];
    final out = <SeerrMedia>[];
    for (final entry in results) {
      if (entry is! Map) continue;
      final json = Map<String, dynamic>.from(entry);
      switch (json['mediaType']) {
        case 'movie':
          final m = _mapMovie(json);
          if (m != null) out.add(m);
        case 'tv':
          final t = _mapTv(json);
          if (t != null) out.add(t);
      }
    }
    return out;
  }

  SeerrMedia? _mapMovie(Map<String, dynamic> j) {
    final id = (j['id'] as num?)?.toInt();
    final title = j['title'] as String?;
    if (id == null || title == null) return null;
    final mediaInfo = j['mediaInfo'] as Map?;
    return SeerrMedia(
      tmdbId: id,
      type: SeerrMediaType.movie,
      title: title,
      overview: j['overview'] as String?,
      posterPath: j['posterPath'] as String?,
      backdropPath: j['backdropPath'] as String?,
      year: _yearFrom(j['releaseDate'] as String?),
      voteAverage: (j['voteAverage'] as num?)?.toDouble(),
      availability: SeerrAvailability.fromCode(mediaInfo?['status'] as num?),
    );
  }

  SeerrMedia? _mapTv(Map<String, dynamic> j) {
    final id = (j['id'] as num?)?.toInt();
    final name = j['name'] as String?;
    if (id == null || name == null) return null;
    final mediaInfo = j['mediaInfo'] as Map?;
    return SeerrMedia(
      tmdbId: id,
      type: SeerrMediaType.tv,
      title: name,
      overview: j['overview'] as String?,
      posterPath: j['posterPath'] as String?,
      backdropPath: j['backdropPath'] as String?,
      year: _yearFrom(j['firstAirDate'] as String?),
      voteAverage: (j['voteAverage'] as num?)?.toDouble(),
      availability: SeerrAvailability.fromCode(mediaInfo?['status'] as num?),
    );
  }

  int? _yearFrom(String? date) {
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }
}
