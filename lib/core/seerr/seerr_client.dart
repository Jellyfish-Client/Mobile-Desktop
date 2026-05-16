import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bridge/bridge_dio_provider.dart';
import '../bridge/bridge_services.dart';
import 'models.dart';

const _prefix = 'jellyfish/jellyseerr/';

final seerrClientProvider = Provider<SeerrClient>((ref) {
  final dio = ref.watch(bridgeDioProvider);
  final services =
      ref.watch(bridgeServicesProvider).valueOrNull ??
      BridgeServices.unavailable;
  return SeerrClient(dio, jellyseerrAvailable: services.jellyseerrAvailable);
});

/// Thin wrapper over the Jellyfish.Bridge plugin's Jellyseerr passthrough
/// endpoints. Same public surface as the previous direct-to-Seerr client —
/// callers haven't moved. The transport is now `<jellyfin>/jellyfish/jellyseerr/…`
/// authenticated with the user's Jellyfin token; there is no separate Seerr
/// session anymore. Body shapes are still Seerr's JSON (passthrough) so the
/// JSON mappers are unchanged.
class SeerrClient {
  SeerrClient(this._dio, {required bool jellyseerrAvailable})
    : _jellyseerrAvailable = jellyseerrAvailable;

  final Dio _dio;
  final bool _jellyseerrAvailable;

  // Keyed by "<type>:<tmdbId>" (e.g. "movie:550"). Lives for the lifetime of
  // this client instance. Avoids re-fetching TMDB detail on every refresh.
  final Map<String, SeerrRequest> _enrichCache = {};

  /// True iff the Jellyfish.Bridge plugin reports Jellyseerr as configured
  /// and reachable. False during the brief window before `bridgeServicesProvider`
  /// resolves on first launch; the provider's rebuild will flip this once the
  /// services discovery completes.
  bool get isLinked => _jellyseerrAvailable;

  // -- Discover ------------------------------------------------------------

  Future<List<SeerrMedia>> trending({int page = 1}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}trending',
      queryParameters: {'page': page},
    );
    return _mapResultsJson(res.data?['results']);
  }

  Future<List<SeerrMedia>> popularMovies({int page = 1}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}discover/movies',
      queryParameters: {'page': page},
    );
    return _mapResultsJson(res.data?['results']);
  }

  Future<List<SeerrMedia>> popularSeries({int page = 1}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}discover/tv',
      queryParameters: {'page': page},
    );
    return _mapResultsJson(res.data?['results']);
  }

  Future<List<SeerrMedia>> discoverMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}discover/movies',
      queryParameters: {'genre': genreId.toString(), 'page': page},
    );
    return _mapResultsJson(res.data?['results']);
  }

  /// Generic `/discover/movies` passthrough exposing the TMDB params that
  /// matter to the home "mood" rails. Genre ids are joined with `|` (TMDB's
  /// OR semantics): a film matching any of the listed genres is eligible.
  /// Using `,` (AND) would intersect the lists and produce near-empty results
  /// for the multi-genre moods. Empty / null fields are omitted from the
  /// query string so they don't override Seerr's defaults.
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
      '${_prefix}discover/movies',
      queryParameters: params,
    );
    return _mapResultsJson(res.data?['results']);
  }

  Future<List<SeerrMedia>> discoverTvByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}discover/tv',
      queryParameters: {'genre': genreId.toString(), 'page': page},
    );
    return _mapResultsJson(res.data?['results']);
  }

  /// Items the linked Plex/Seerr user added to their watchlist.
  ///
  /// Bridge passthrough of Seerr's `/discover/watchlist`, which returns sparse
  /// entries (tmdbId + mediaType only). We enrich each result via a detail
  /// round-trip in parallel, capped at [enrichLimit] — the watchlist can be
  /// large but the home rail only displays a handful.
  Future<List<SeerrMedia>> watchlist({
    int page = 1,
    int enrichLimit = 10,
  }) async {
    if (!isLinked) return const [];
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}discover/watchlist',
      queryParameters: {'page': page},
    );
    final raw = (res.data?['results'] as List?) ?? const [];

    final futures = <Future<SeerrMedia?>>[];
    for (final entry in raw.take(enrichLimit)) {
      if (entry is! Map) continue;
      final json = Map<String, dynamic>.from(entry);
      final tmdbId = (json['tmdbId'] as num?)?.toInt();
      final type = json['mediaType'] as String?;
      if (tmdbId == null || (type != 'movie' && type != 'tv')) continue;
      futures.add(() async {
        try {
          final detail = await _dio.get<Map<String, dynamic>>(
            type == 'movie'
                ? '${_prefix}movie/$tmdbId'
                : '${_prefix}tv/$tmdbId',
          );
          final data = detail.data;
          if (data == null) return null;
          return type == 'movie'
              ? _mapMovieJson({...data, 'mediaType': 'movie'})
              : _mapTvJson({...data, 'mediaType': 'tv'});
        } on Object {
          return null;
        }
      }());
    }
    final settled = await Future.wait(futures);
    return settled.whereType<SeerrMedia>().toList();
  }

  Future<List<SeerrGenreSlide>> genreSliderMovies() =>
      _fetchGenreSlider('${_prefix}discover/genreslider/movie');

  Future<List<SeerrGenreSlide>> genreSliderTv() =>
      _fetchGenreSlider('${_prefix}discover/genreslider/tv');

  Future<List<SeerrWatchProvider>> watchProvidersMovies({
    String region = 'FR',
  }) => _fetchWatchProviders('${_prefix}watchproviders/movies', region);

  Future<List<SeerrWatchProvider>> watchProvidersTv({String region = 'FR'}) =>
      _fetchWatchProviders('${_prefix}watchproviders/tv', region);

  Future<List<SeerrWatchProvider>> _fetchWatchProviders(
    String path,
    String region,
  ) async {
    if (!isLinked) return const [];
    try {
      final res = await _dio.get<List<dynamic>>(
        path,
        queryParameters: {'watchRegion': region},
      );
      final raw = res.data ?? const [];
      final out = <SeerrWatchProvider>[];
      for (final entry in raw) {
        if (entry is! Map) continue;
        final json = Map<String, dynamic>.from(entry);
        final id = (json['id'] as num?)?.toInt();
        final name = json['name'] as String?;
        if (id == null || name == null) continue;
        out.add(
          SeerrWatchProvider(
            id: id,
            name: name,
            logoPath: json['logoPath'] as String?,
          ),
        );
      }
      return out;
    } on Object {
      return const [];
    }
  }

  Future<List<SeerrMedia>> discoverMoviesByProvider(
    int providerId, {
    String region = 'FR',
    int page = 1,
  }) async {
    if (!isLinked) return const [];
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}discover/movies',
      queryParameters: {
        'watchRegion': region,
        'watchProviders': providerId.toString(),
        'page': page,
      },
    );
    return _mapResultsJson(res.data?['results']);
  }

  Future<List<SeerrMedia>> discoverTvByProvider(
    int providerId, {
    String region = 'FR',
    int page = 1,
  }) async {
    if (!isLinked) return const [];
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}discover/tv',
      queryParameters: {
        'watchRegion': region,
        'watchProviders': providerId.toString(),
        'page': page,
      },
    );
    return _mapResultsJson(res.data?['results']);
  }

  Future<List<SeerrGenreSlide>> _fetchGenreSlider(String path) async {
    if (!isLinked) return const [];
    try {
      final res = await _dio.get<List<dynamic>>(path);
      final raw = res.data ?? const [];
      final out = <SeerrGenreSlide>[];
      for (final entry in raw) {
        if (entry is! Map) continue;
        final json = Map<String, dynamic>.from(entry);
        final id = (json['id'] as num?)?.toInt();
        final name = json['name'] as String?;
        if (id == null || name == null) continue;
        final backdrops =
            (json['backdrops'] as List?)?.whereType<String>().toList() ??
            const <String>[];
        out.add(SeerrGenreSlide(id: id, name: name, backdrops: backdrops));
      }
      return out;
    } on Object {
      return const [];
    }
  }

  /// Searches via Bridge passthrough of Seerr's `/search`. Returns the media
  /// results plus the collections derived from the top movie hits (Seerr's
  /// `/search` itself only returns Movie/Tv/Person, so we look up the top
  /// movies to find their owning collection).
  Future<({List<SeerrMedia> media, List<SeerrCollection> collections})> search(
    String query, {
    int page = 1,
    int movieDetailLookupLimit = 6,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}search',
      queryParameters: {'query': query, 'page': page},
    );
    final raw = (res.data?['results'] as List?) ?? const [];

    final media = <SeerrMedia>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final json = Map<String, dynamic>.from(entry);
      switch (json['mediaType']) {
        case 'movie':
          final m = _mapMovieJson(json);
          if (m != null) media.add(m);
        case 'tv':
          final t = _mapTvJson(json);
          if (t != null) media.add(t);
      }
    }

    final collections = await _collectionsFromTopMovies(
      media,
      limit: movieDetailLookupLimit,
    );
    return (media: media, collections: collections);
  }

  Future<List<SeerrCollection>> _collectionsFromTopMovies(
    List<SeerrMedia> media, {
    required int limit,
  }) async {
    final topMovies = media
        .where((m) => m.type == SeerrMediaType.movie)
        .take(limit)
        .toList();
    if (topMovies.isEmpty) return const [];

    final stubs = await Future.wait(
      topMovies.map((m) async {
        try {
          final res = await _dio.get<Map<String, dynamic>>(
            '${_prefix}movie/${m.tmdbId}',
          );
          final c = res.data?['collection'];
          if (c is! Map) return null;
          final json = Map<String, dynamic>.from(c);
          return _mapCollectionStub(json);
        } on Object {
          return null;
        }
      }),
    );

    final seen = <int>{};
    final out = <SeerrCollection>[];
    for (final c in stubs) {
      if (c == null) continue;
      if (seen.add(c.tmdbId)) out.add(c);
    }
    return out;
  }

  Future<SeerrMedia?> movieDetails(int tmdbId) async {
    if (!isLinked) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '${_prefix}movie/$tmdbId',
      );
      final data = res.data;
      if (data == null) return null;
      return _mapMovieJson({...data, 'mediaType': 'movie'});
    } on Object {
      return null;
    }
  }

  Future<int?> movieCollectionId(int tmdbId) async {
    if (!isLinked) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '${_prefix}movie/$tmdbId',
      );
      final c = res.data?['collection'];
      if (c is! Map) return null;
      final id = c['id'];
      if (id is num) return id.toInt();
      return null;
    } on Object {
      return null;
    }
  }

  Future<SeerrCollection?> collection(int tmdbId) async {
    if (!isLinked) return null;
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}collection/$tmdbId',
    );
    final data = res.data;
    if (data == null) return null;

    final parts = <SeerrMedia>[];
    for (final entry in (data['parts'] as List?) ?? const []) {
      if (entry is! Map) continue;
      final json = Map<String, dynamic>.from(entry);
      // Collection parts come from TMDB without a mediaType; force movie.
      json['mediaType'] = 'movie';
      final m = _mapMovieJson(json);
      if (m != null) parts.add(m);
    }

    final id = (data['id'] as num?)?.toInt();
    final name = data['name'] as String?;
    if (id == null || name == null) return null;
    return SeerrCollection(
      tmdbId: id,
      name: name,
      overview: data['overview'] as String?,
      posterPath: data['posterPath'] as String?,
      backdropPath: data['backdropPath'] as String?,
      parts: parts,
    );
  }

  Future<List<SeerrMedia>> similarMovies(int tmdbId, {int page = 1}) async {
    if (!isLinked) return const [];
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}movie/$tmdbId/similar',
      queryParameters: {'page': page},
    );
    return _mapResultsJson(res.data?['results']);
  }

  Future<List<SeerrMedia>> similarTv(int tmdbId, {int page = 1}) async {
    if (!isLinked) return const [];
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}tv/$tmdbId/similar',
      queryParameters: {'page': page},
    );
    return _mapResultsJson(res.data?['results']);
  }

  /// Lists the seasons of a TV show. Parses Seerr's raw `/tv/{id}` payload
  /// to extract `seasons[]` and the per-season availability from `mediaInfo`.
  Future<List<SeerrTvSeason>> tvSeasons(int tmdbId) async {
    if (!isLinked) return const [];
    try {
      final res = await _dio.get<Map<String, dynamic>>('${_prefix}tv/$tmdbId');
      final raw = (res.data?['seasons'] as List?) ?? const [];
      final statusBySeason = <int, SeerrAvailability>{};
      final info = res.data?['mediaInfo'];
      if (info is Map) {
        final infoSeasons = info['seasons'];
        if (infoSeasons is List) {
          for (final s in infoSeasons) {
            if (s is! Map) continue;
            final seasonNum = (s['seasonNumber'] as num?)?.toInt();
            if (seasonNum == null) continue;
            statusBySeason[seasonNum] = SeerrAvailability.fromCode(
              s['status'] as num?,
            );
          }
        }
      }
      final out = <SeerrTvSeason>[];
      for (final s in raw) {
        if (s is! Map) continue;
        final rawSeasonNumber = s['seasonNumber'];
        final seasonNumber = rawSeasonNumber is num
            ? rawSeasonNumber.toInt()
            : int.tryParse('$rawSeasonNumber');
        if (seasonNumber == null) continue;
        out.add(
          SeerrTvSeason(
            seasonNumber: seasonNumber,
            name: s['name'] as String?,
            episodeCount: (s['episodeCount'] as num?)?.toInt(),
            posterPath: s['posterPath'] as String?,
            availability:
                statusBySeason[seasonNumber] ?? SeerrAvailability.unknown,
          ),
        );
      }
      // Surface specials last so the picker reads naturally (S1, S2, …, Specials).
      out.sort((a, b) {
        if (a.isSpecials && !b.isSpecials) return 1;
        if (!a.isSpecials && b.isSpecials) return -1;
        return a.seasonNumber.compareTo(b.seasonNumber);
      });
      return out;
    } on Object catch (_) {
      return const [];
    }
  }

  // -- Person -------------------------------------------------------------

  /// Bridge passthrough of Seerr's `/person/{id}`. Returns `null` when Seerr
  /// isn't linked or the server can't resolve the id — callers fall back to
  /// the Jellyfin metadata (which may already carry the biography).
  Future<SeerrPersonDetail?> personDetails(int tmdbPersonId) async {
    if (!isLinked) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '${_prefix}person/$tmdbPersonId',
      );
      final data = res.data;
      if (data == null) return null;
      final name = data['name'] as String?;
      if (name == null) return null;
      return SeerrPersonDetail(
        tmdbId: tmdbPersonId,
        name: name,
        biography: data['biography'] as String?,
        profilePath: data['profilePath'] as String?,
        knownForDepartment: data['knownForDepartment'] as String?,
        birthday: data['birthday'] as String?,
        placeOfBirth: data['placeOfBirth'] as String?,
      );
    } on Object {
      return null;
    }
  }

  /// Bridge passthrough of Seerr's `/person/{id}/combined_credits`. Flattens
  /// the `cast` array into [SeerrMedia] entries, deduplicated by `(type, tmdbId)`
  /// (Seerr lists a title once per role: same actor in two seasons of a series
  /// would otherwise appear twice). Crew entries are ignored — this is for an
  /// actor filmography view, not a director's.
  Future<List<SeerrMedia>> personCombinedCredits(int tmdbPersonId) async {
    if (!isLinked) return const [];
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '${_prefix}person/$tmdbPersonId/combined_credits',
      );
      final raw = (res.data?['cast'] as List?) ?? const [];
      final seen = <String>{};
      final out = <SeerrMedia>[];
      for (final entry in raw) {
        if (entry is! Map) continue;
        final json = Map<String, dynamic>.from(entry);
        final mediaType = json['mediaType'] as String?;
        final SeerrMedia? media;
        switch (mediaType) {
          case 'movie':
            media = _mapMovieJson(json);
          case 'tv':
            media = _mapTvJson(json);
          default:
            media = null;
        }
        if (media == null) continue;
        final key = '${media.type.name}:${media.tmdbId}';
        if (seen.add(key)) out.add(media);
      }
      return out;
    } on Object catch (e) {
      debugPrint('SeerrClient.personCombinedCredits($tmdbPersonId) failed: $e');
      return const [];
    }
  }

  /// TMDB person profile image. Returns `null` when the person has no photo —
  /// the UI falls back to initials in that case.
  String? personProfileUrl(SeerrPersonDetail person, {String size = 'w300'}) {
    final p = person.profilePath;
    if (p == null || p.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$p';
  }

  // -- Requests ------------------------------------------------------------

  /// Creates a Seerr request for [tmdbId].
  ///
  /// For TV requests:
  /// - Pass `seasons: null` to request every numbered season (specials
  ///   excluded) — Seerr accepts the literal `"all"` value for this.
  /// - Pass a list of season numbers (e.g. `[0, 1, 2]`) to scope the request.
  ///   Use `0` to include Specials.
  ///
  /// The plugin injects `userId` server-side from the Jellyfin token, so the
  /// request is attributed to the correct Seerr user. We must NOT send a
  /// `userId` field here — Bridge overwrites it.
  Future<void> createRequest({
    required SeerrMediaType type,
    required int tmdbId,
    List<int>? seasons,
  }) async {
    final body = <String, dynamic>{
      'mediaType': type == SeerrMediaType.movie ? 'movie' : 'tv',
      'mediaId': tmdbId,
      if (type == SeerrMediaType.tv) 'seasons': seasons ?? 'all',
    };
    await _dio.post<Map<String, dynamic>>('${_prefix}request', data: body);
  }

  Future<List<SeerrRequest>> myRequests({int take = 50}) async {
    // Bridge's `/jellyfish/jellyseerr/request` already scopes results to the
    // caller (it injects `requestedBy` matching the mapped Seerr user), so
    // we don't pass `requestedBy` ourselves.
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}request',
      queryParameters: {
        'take': take,
        'skip': 0,
        'filter': 'all',
        'sort': 'added',
        'sortDirection': 'desc',
      },
    );
    final raw = (res.data?['results'] as List?) ?? const [];

    final stubs = raw
        .map((e) => _mapRequestJson(e as Map<String, dynamic>))
        .whereType<SeerrRequest>()
        .toList();

    // Enrich each stub in parallel — fetch title + posterPath from the
    // movie/tv detail endpoint. Individual failures are silently swallowed
    // so one bad request never crashes the entire list.
    final enriched = await Future.wait(stubs.map(_enrichRequest));
    return enriched;
  }

  SeerrRequest? _mapRequestJson(Map<String, dynamic> r) {
    final media = r['media'] as Map<String, dynamic>?;
    if (media == null) return null;
    final tmdbId = (media['tmdbId'] as num?)?.toInt() ?? 0;
    if (tmdbId == 0) return null;
    final mediaType = media['mediaType'] as String?;
    final type = mediaType == 'tv' ? SeerrMediaType.tv : SeerrMediaType.movie;
    return SeerrRequest(
      id: (r['id'] as num?)?.toInt() ?? 0,
      tmdbId: tmdbId,
      type: type,
      availability: SeerrAvailability.fromCode(media['status'] as num?),
      createdAt: DateTime.tryParse(r['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(r['updatedAt'] as String? ?? ''),
    );
  }

  Future<SeerrRequest> _enrichRequest(SeerrRequest stub) async {
    final cacheKey =
        '${stub.type == SeerrMediaType.movie ? 'movie' : 'tv'}:${stub.tmdbId}';

    final cached = _enrichCache[cacheKey];
    if (cached != null) {
      // Availability may have changed on the server; keep the latest value from
      // the request list while reusing the expensive TMDB metadata.
      return SeerrRequest(
        id: stub.id,
        tmdbId: stub.tmdbId,
        type: stub.type,
        title: cached.title,
        posterPath: cached.posterPath,
        year: cached.year,
        availability: stub.availability,
        createdAt: stub.createdAt,
        updatedAt: stub.updatedAt,
      );
    }

    try {
      final path = stub.type == SeerrMediaType.movie
          ? '${_prefix}movie/${stub.tmdbId}'
          : '${_prefix}tv/${stub.tmdbId}';
      final res = await _dio.get<Map<String, dynamic>>(path);
      final d = res.data;
      if (d == null) return _stubWithFallback(stub);

      final title = stub.type == SeerrMediaType.movie
          ? (d['title'] as String?) ?? (d['originalTitle'] as String?)
          : (d['name'] as String?) ?? (d['originalName'] as String?);
      final posterPath = d['posterPath'] as String?;
      final dateStr = stub.type == SeerrMediaType.movie
          ? d['releaseDate'] as String?
          : d['firstAirDate'] as String?;

      final enriched = SeerrRequest(
        id: stub.id,
        tmdbId: stub.tmdbId,
        type: stub.type,
        title: (title != null && title.isNotEmpty) ? title : '#${stub.tmdbId}',
        posterPath: posterPath,
        year: _yearFrom(dateStr),
        availability: stub.availability,
        createdAt: stub.createdAt,
        updatedAt: stub.updatedAt,
      );
      _enrichCache[cacheKey] = enriched;
      return enriched;
    } on Object catch (_) {
      return _stubWithFallback(stub);
    }
  }

  /// Clears the per-tmdbId enrichment cache. Useful when the user explicitly
  /// wants fresh TMDB metadata (e.g. after changing language preferences).
  void clearEnrichCache() => _enrichCache.clear();

  SeerrRequest _stubWithFallback(SeerrRequest stub) => SeerrRequest(
    id: stub.id,
    tmdbId: stub.tmdbId,
    type: stub.type,
    title: stub.title ?? '#${stub.tmdbId}',
    availability: stub.availability,
    createdAt: stub.createdAt,
    updatedAt: stub.updatedAt,
  );

  // -- User settings -------------------------------------------------------

  /// Updates the Jellyseerr user locale preference via the bridge passthrough.
  ///
  /// Two-step: `GET /auth/me` to resolve the current Seerr user id (the bridge
  /// maps the Jellyfin token to a Seerr account), then `POST /user/{id}/settings/main`
  /// with the new locale. No-op when Jellyseerr isn't linked or when the
  /// bridge can't resolve a user id. Callers may swallow exceptions — this is
  /// fire-and-forget at the app-locale layer.
  Future<void> updateLocale(String locale) async {
    if (!isLinked) return;
    final meRes = await _dio.get<Map<String, dynamic>>('${_prefix}auth/me');
    final userId = (meRes.data?['id'] as num?)?.toInt();
    if (userId == null) return;
    await _dio.post<void>(
      '${_prefix}user/$userId/settings/main',
      data: {'locale': locale},
    );
  }

  // -- Image URL helpers ---------------------------------------------------

  /// Seerr proxies TMDB images at `/imageproxy/...`. We hit the public TMDB
  /// CDN directly — saves a server round-trip and works without auth.
  String? posterUrl(SeerrMedia m, {String size = 'w500'}) {
    final p = m.posterPath;
    if (p == null || p.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$p';
  }

  String? backdropUrl(SeerrMedia m, {String size = 'w1280'}) {
    final p = m.backdropPath;
    if (p == null || p.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$p';
  }

  String? genreBackdropUrl(SeerrGenreSlide g, {String size = 'w780'}) {
    for (final p in g.backdrops) {
      if (p.isNotEmpty) return 'https://image.tmdb.org/t/p/$size$p';
    }
    return null;
  }

  String? providerLogoUrl(SeerrWatchProvider p, {String size = 'w92'}) {
    final path = p.logoPath;
    if (path == null || path.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  String? seasonPosterUrl(SeerrTvSeason season, {String size = 'w500'}) {
    final p = season.posterPath;
    if (p == null || p.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$p';
  }

  String? requestPosterUrl(SeerrRequest request, {String size = 'w500'}) {
    final p = request.posterPath;
    if (p == null || p.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$p';
  }

  String? collectionImageUrl(
    SeerrCollection c, {
    String backdropSize = 'w780',
    String posterSize = 'w500',
  }) {
    final b = c.backdropPath;
    if (b != null && b.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/$backdropSize$b';
    }
    final p = c.posterPath;
    if (p != null && p.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/$posterSize$p';
    }
    return null;
  }

  // -- Mapping helpers -----------------------------------------------------

  /// Parses a Seerr-shaped `results[]` array (movies + tv + person) into a
  /// list of [SeerrMedia], skipping Person and unknown entries. Used by
  /// every endpoint that returns a paginated list of mixed results.
  List<SeerrMedia> _mapResultsJson(Object? results) {
    if (results is! List) return const [];
    final out = <SeerrMedia>[];
    for (final entry in results) {
      if (entry is! Map) continue;
      final json = Map<String, dynamic>.from(entry);
      switch (json['mediaType']) {
        case 'movie':
          final m = _mapMovieJson(json);
          if (m != null) out.add(m);
        case 'tv':
          final t = _mapTvJson(json);
          if (t != null) out.add(t);
        // Person and unknown types are skipped silently.
      }
    }
    return out;
  }

  int? _yearFrom(String? date) {
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }

  SeerrMedia? _mapMovieJson(Map<String, dynamic> j) {
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

  SeerrMedia? _mapTvJson(Map<String, dynamic> j) {
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

  SeerrCollection? _mapCollectionStub(Map<String, dynamic> j) {
    final id = (j['id'] as num?)?.toInt();
    final name = j['name'] as String?;
    if (id == null || name == null) return null;
    return SeerrCollection(
      tmdbId: id,
      name: name,
      overview: j['overview'] as String?,
      posterPath: j['posterPath'] as String?,
      backdropPath: j['backdropPath'] as String?,
    );
  }
}
