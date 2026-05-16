import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../auth/auth_controller.dart';
import '../auth/session.dart';
import '../network/dio_provider.dart';

final jellyfinApiProvider = Provider<JellyfinApi>((ref) {
  final dio = ref.watch(jellyfinDioProvider);
  // Don't add the SDK's default OAuth/Basic/Bearer/ApiKey interceptors —
  // we already inject the proper Jellyfin `Authorization: MediaBrowser …`
  // header via _JellyfinAuthInterceptor in dio_provider.dart.
  return JellyfinApi(dio: dio, interceptors: const []);
});

final jellyfinClientProvider = Provider<JellyfinClient>((ref) {
  final dio = ref.watch(jellyfinDioProvider);
  final session = ref.watch(authControllerProvider).valueOrNull?.session;
  final api = ref.watch(jellyfinApiProvider);
  return JellyfinClient(dio, session, api);
});

/// High-level wrapper over the generated Jellyfin SDK.
///
/// Adds Jellyfish-specific concerns on top of the raw SDK:
/// - Onboarding probe / login that target a temporary base URL before any
///   session is persisted.
/// - URL helpers for direct-stream playback and image rendering.
/// - Light fetchers that hide the full SDK signatures.
class JellyfinClient {
  JellyfinClient(this._dio, this._session, this._api);

  final Dio _dio;
  final Session? _session;
  final JellyfinApi _api;

  String get _userId {
    final s = _session;
    if (s == null) {
      throw StateError('JellyfinClient: no active session');
    }
    return s.userId;
  }

  // -- Onboarding (no session yet) -----------------------------------------

  /// Build an SDK facade pointed at an arbitrary URL, sharing our auth
  /// interceptor so the proxy Basic Auth / MediaBrowser identity headers are
  /// applied. Used by `systemInfoPublic` / `authenticateByName` during onboarding.
  JellyfinApi _apiAt(String baseUrl, {String? proxyAuth}) {
    final scopedDio = Dio(
      BaseOptions(
        baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    // Reuse the parent dio's interceptors — these are our auth + log
    // interceptors, configured around the (possibly absent) session.
    scopedDio.interceptors.addAll(_dio.interceptors);
    final perCallHeaders = proxyAuth == null
        ? null
        : Options(headers: {'Authorization': proxyAuth});
    return JellyfinApi(dio: scopedDio, interceptors: const [])
      ..dio.options.headers.addAll(perCallHeaders?.headers ?? const {});
  }

  /// Reachable without auth — used during onboarding to validate a server URL.
  /// Pass [proxyAuth] (a `Basic …` header value) if the server is behind a
  /// reverse-proxy Basic Auth gate.
  Future<PublicSystemInfo> systemInfoPublic({
    String? overrideBaseUrl,
    String? proxyAuth,
  }) async {
    final api = overrideBaseUrl != null
        ? _apiAt(overrideBaseUrl, proxyAuth: proxyAuth)
        : _api;
    final res = await api.getSystemApi().getPublicSystemInfo();
    return res.data!;
  }

  /// Reads `BrandingOptions` from the Jellyfin server. The `customCss` field
  /// can carry Jellyfish app config markers (e.g. the Seerr URL) parsed by
  /// `SeerrConfig.parse`. Returns null on any error so callers don't have to
  /// guard around it.
  Future<BrandingOptionsDto?> branding() async {
    try {
      final res = await _api.getBrandingApi().getBrandingOptions();
      return res.data;
    } on Object catch (_) {
      return null;
    }
  }

  Future<AuthenticationResult> authenticateByName({
    required String username,
    required String password,
    String? overrideBaseUrl,
    String? proxyAuth,
  }) async {
    final api = overrideBaseUrl != null
        ? _apiAt(overrideBaseUrl, proxyAuth: proxyAuth)
        : _api;
    final body = AuthenticateUserByName(
      (b) => b
        ..username = username
        ..pw = password,
    );
    final res = await api.getUserApi().authenticateUserByName(
      authenticateUserByName: body,
    );
    return res.data!;
  }

  // -- Quick Connect (no session yet) --------------------------------------

  /// Returns true when the server has the Quick Connect feature enabled.
  /// Returns false on any error (network, 404 on old servers) so callers can
  /// just hide the entry-point UI in that case.
  Future<bool> isQuickConnectEnabled({
    required String serverUrl,
    String? proxyAuth,
  }) async {
    final api = _apiAt(serverUrl, proxyAuth: proxyAuth);
    try {
      final res = await api.getQuickConnectApi().getQuickConnectEnabled();
      return res.data ?? false;
    } on Object catch (_) {
      return false;
    }
  }

  /// Asks the server to mint a new Quick Connect request. The returned secret
  /// is used to poll for approval; the code is what the user types into
  /// another logged-in Jellyfin client to approve this device.
  Future<QuickConnectResult> initiateQuickConnect({
    required String serverUrl,
    String? proxyAuth,
  }) async {
    final api = _apiAt(serverUrl, proxyAuth: proxyAuth);
    final res = await api.getQuickConnectApi().initiateQuickConnect();
    return res.data!;
  }

  /// Polls the Quick Connect state for a pending request. Once
  /// [QuickConnectResult.authenticated] flips to true, callers should hand the
  /// secret off to [authenticateWithQuickConnect] to get a real session token.
  Future<QuickConnectResult> pollQuickConnect({
    required String serverUrl,
    required String secret,
    String? proxyAuth,
    CancelToken? cancelToken,
  }) async {
    final api = _apiAt(serverUrl, proxyAuth: proxyAuth);
    final res = await api.getQuickConnectApi().getQuickConnectState(
      secret: secret,
      cancelToken: cancelToken,
    );
    return res.data!;
  }

  /// Exchanges an approved Quick Connect secret for a real
  /// [AuthenticationResult] (token + user).
  Future<AuthenticationResult> authenticateWithQuickConnect({
    required String serverUrl,
    required String secret,
    String? proxyAuth,
  }) async {
    final api = _apiAt(serverUrl, proxyAuth: proxyAuth);
    final body = QuickConnectDto((b) => b..secret = secret);
    final res = await api.getUserApi().authenticateWithQuickConnect(
      quickConnectDto: body,
    );
    return res.data!;
  }

  // -- Home -----------------------------------------------------------------

  /// Resume = items the user paused mid-playback. By default we restrict to
  /// movies — partly-watched TV episodes also live here, but "À finir" /
  /// `nextUp` already surfaces what's next per series, and showing both lists
  /// side by side produces near-duplicate posters on the home screen. Callers
  /// who need the full resume payload (e.g. an "everything in progress" view)
  /// can pass `kinds: null` to opt out of the filter.
  Future<List<BaseItemDto>> resumeItems({
    int limit = 12,
    List<BaseItemKind>? kinds = const [BaseItemKind.movie],
  }) async {
    final res = await _api.getItemsApi().getResumeItems(
      userId: _userId,
      limit: limit,
      mediaTypes: BuiltList<MediaType>.of(<MediaType>[MediaType.video]),
      includeItemTypes: kinds == null
          ? null
          : BuiltList<BaseItemKind>.of(kinds),
      fields: BuiltList<ItemFields>.of(<ItemFields>[ItemFields.overview]),
    );
    return res.data?.items?.toList() ?? const [];
  }

  Future<List<BaseItemDto>> latestItems({
    int limit = 24,
    String? parentId,
    List<BaseItemKind>? includeItemTypes,
    List<ItemFields> extraFields = const [],
  }) async {
    final fields = [ItemFields.overview, ...extraFields];
    final res = await _api.getUserLibraryApi().getLatestMedia(
      userId: _userId,
      limit: limit,
      parentId: parentId,
      includeItemTypes: includeItemTypes == null
          ? null
          : BuiltList<BaseItemKind>.of(includeItemTypes),
      fields: BuiltList<ItemFields>.of(fields),
    );
    return res.data?.toList() ?? const [];
  }

  /// Random unwatched Movies/Series that carry both a Logo and a Backdrop,
  /// plus an overview. Mirrors the query the
  /// `IAmParadox27/jellyfin-plugin-media-bar` plugin issues to fill its
  /// featured slideshow, so the home hero ends up sampling the same pool
  /// (everything you own with proper artwork, randomised, never anything you
  /// already finished). The result is then client-side shuffled and consumed
  /// by `featuredPoolProvider`.
  Future<List<BaseItemDto>> featuredItems({int limit = 60}) async {
    final res = await _api.getItemsApi().getItems(
      userId: _userId,
      includeItemTypes: BuiltList<BaseItemKind>.of(<BaseItemKind>[
        BaseItemKind.movie,
        BaseItemKind.series,
      ]),
      recursive: true,
      hasOverview: true,
      imageTypes: BuiltList<ImageType>.of(<ImageType>[
        ImageType.logo,
        ImageType.backdrop,
      ]),
      sortBy: BuiltList<ItemSortBy>.of(<ItemSortBy>[ItemSortBy.random]),
      isPlayed: false,
      enableUserData: true,
      limit: limit,
      fields: BuiltList<ItemFields>.of(<ItemFields>[
        ItemFields.overview,
        ItemFields.genres,
      ]),
    );
    return res.data?.items?.toList() ?? const [];
  }

  Future<List<BaseItemDto>> nextUp({int limit = 24}) async {
    final res = await _api.getTvShowsApi().getNextUp(
      userId: _userId,
      limit: limit,
      fields: BuiltList<ItemFields>.of(<ItemFields>[ItemFields.overview]),
    );
    return res.data?.items?.toList() ?? const [];
  }

  // -- Recommender helpers --------------------------------------------------

  /// Fetches up to [limit] recently-played items sorted by date played
  /// (descending). Includes Genres, People, Studios, ProviderIds and UserData
  /// so the taste-profile builder (`TasteProfile.fromHistory`) and the
  /// Seerr-seeds extractor (`_seedsFromHistory`) have enough signal.
  ///
  /// `overview` is intentionally NOT requested — it's not used by either
  /// consumer and accounts for the bulk of the payload. With limit=100 and
  /// a slimmed field set this endpoint typically returns ~30–60 KB instead
  /// of 200–500 KB, which shaves a measurable chunk off cold start.
  Future<List<BaseItemDto>> recentlyPlayed({int limit = 100}) async {
    final res = await _api.getItemsApi().getItems(
      userId: _userId,
      sortBy: BuiltList<ItemSortBy>.of(<ItemSortBy>[ItemSortBy.datePlayed]),
      sortOrder: BuiltList<SortOrder>.of(<SortOrder>[SortOrder.descending]),
      recursive: true,
      isPlayed: true,
      limit: limit,
      fields: BuiltList<ItemFields>.of(<ItemFields>[
        ItemFields.genres,
        ItemFields.people,
        ItemFields.studios,
        ItemFields.providerIds,
      ]),
      enableUserData: true,
    );
    return res.data?.items?.toList() ?? const [];
  }

  /// Fetches items similar to [itemId] from the server's similarity index.
  /// Includes Genres, People, Studios, Overview for scoring purposes.
  Future<List<BaseItemDto>> similar(String itemId, {int limit = 24}) async {
    final res = await _api.getLibraryApi().getSimilarItems(
      itemId: itemId,
      userId: _userId,
      limit: limit,
      fields: BuiltList<ItemFields>.of(<ItemFields>[
        ItemFields.genres,
        ItemFields.people,
        ItemFields.studios,
        ItemFields.overview,
      ]),
    );
    return res.data?.items?.toList() ?? const [];
  }

  // -- Library --------------------------------------------------------------

  Future<List<BaseItemDto>> userViews() async {
    final res = await _api.getUserViewsApi().getUserViews(userId: _userId);
    return res.data?.items?.toList() ?? const [];
  }

  Future<BaseItemDtoQueryResult> queryItems({
    String? parentId,
    String? searchTerm,
    List<BaseItemKind>? includeItemTypes,
    int startIndex = 0,
    int limit = 50,
    String sortBy = 'SortName',
    String sortOrder = 'Ascending',
  }) async {
    final res = await _api.getItemsApi().getItems(
      userId: _userId,
      parentId: parentId,
      searchTerm: searchTerm,
      includeItemTypes: includeItemTypes == null
          ? null
          : BuiltList<BaseItemKind>.of(includeItemTypes),
      startIndex: startIndex,
      limit: limit,
      recursive: true,
      fields: BuiltList<ItemFields>.of(<ItemFields>[
        ItemFields.overview,
        // ProviderIds is required to match BoxSet children against TMDB so
        // that missingCollectionMoviesProvider can resolve the collection
        // (Jellyfin omits ProviderIds from getItems by default).
        ItemFields.providerIds,
      ]),
    );
    return res.data!;
  }

  Future<BaseItemDto> item(String id) async {
    final res = await _api.getUserLibraryApi().getItem(
      userId: _userId,
      itemId: id,
    );
    return res.data!;
  }

  /// Items (movies + series + …) in which [personId] is credited. Used by the
  /// person detail screen to build the local filmography. The Items endpoint
  /// supports `personIds`, which scopes the result server-side; `recursive`
  /// makes the search span the whole library tree.
  Future<List<BaseItemDto>> itemsByPerson(
    String personId, {
    List<BaseItemKind>? includeItemTypes,
    int limit = 200,
  }) async {
    final res = await _api.getItemsApi().getItems(
      userId: _userId,
      personIds: BuiltList<String>.of(<String>[personId]),
      includeItemTypes: includeItemTypes == null
          ? null
          : BuiltList<BaseItemKind>.of(includeItemTypes),
      recursive: true,
      sortBy: BuiltList<ItemSortBy>.of(<ItemSortBy>[
        ItemSortBy.productionYear,
        ItemSortBy.premiereDate,
      ]),
      sortOrder: BuiltList<SortOrder>.of(<SortOrder>[SortOrder.descending]),
      limit: limit,
      fields: BuiltList<ItemFields>.of(<ItemFields>[
        ItemFields.overview,
        ItemFields.providerIds,
      ]),
    );
    return res.data?.items?.toList() ?? const [];
  }

  /// Person-only search used by the global search screen to surface actors
  /// as a separate section. Returns lightweight BaseItemDto entries (id, name,
  /// imageTags) sourced from the Jellyfin `/Persons` endpoint.
  Future<List<BaseItemDto>> searchPersons(String query, {int limit = 8}) async {
    if (query.trim().isEmpty) return const [];
    final res = await _api.getPersonsApi().getPersons(
      userId: _userId,
      searchTerm: query,
      limit: limit,
    );
    return res.data?.items?.toList() ?? const [];
  }

  Future<List<BaseItemDto>> seasons(String seriesId) async {
    final res = await _api.getTvShowsApi().getSeasons(
      seriesId: seriesId,
      userId: _userId,
    );
    return res.data?.items?.toList() ?? const [];
  }

  Future<List<BaseItemDto>> episodes(
    String seriesId, {
    String? seasonId,
  }) async {
    final res = await _api.getTvShowsApi().getEpisodes(
      seriesId: seriesId,
      userId: _userId,
      seasonId: seasonId,
      fields: BuiltList<ItemFields>.of(<ItemFields>[ItemFields.overview]),
    );
    return res.data?.items?.toList() ?? const [];
  }

  /// Next episode to play for a series: a resumable episode if one is in
  /// progress, otherwise the first unwatched episode, otherwise null.
  Future<BaseItemDto?> seriesNextUp(String seriesId) async {
    final res = await _api.getTvShowsApi().getNextUp(
      userId: _userId,
      seriesId: seriesId,
      limit: 1,
      enableUserData: true,
      fields: BuiltList<ItemFields>.of(<ItemFields>[ItemFields.overview]),
    );
    final items = res.data?.items?.toList() ?? const [];
    return items.isEmpty ? null : items.first;
  }

  // -- Playback -------------------------------------------------------------

  Future<PlaybackInfoResponse> playbackInfo(
    String itemId, {
    DeviceProfile? deviceProfile,
    int? maxStreamingBitrate,
    int? audioStreamIndex,
    int? subtitleStreamIndex,
    int? startTimeTicks,
    String? mediaSourceId,
  }) async {
    final res = await _api.getMediaInfoApi().getPostedPlaybackInfo(
      itemId: itemId,
      playbackInfoDto: PlaybackInfoDto((b) {
        b.userId = _userId;
        if (deviceProfile != null) b.deviceProfile.replace(deviceProfile);
        if (maxStreamingBitrate != null) {
          b.maxStreamingBitrate = maxStreamingBitrate;
        }
        if (audioStreamIndex != null) {
          b.audioStreamIndex = audioStreamIndex;
        }
        if (subtitleStreamIndex != null) {
          b.subtitleStreamIndex = subtitleStreamIndex;
        }
        if (startTimeTicks != null) b.startTimeTicks = startTimeTicks;
        if (mediaSourceId != null) b.mediaSourceId = mediaSourceId;
        if (deviceProfile != null) {
          // When a profile is sent, the client is asking the server to
          // pick the best playable source — let it auto-open live streams
          // and decide direct/transcode itself.
          b
            ..autoOpenLiveStream = true
            ..enableDirectPlay = true
            ..enableDirectStream = true
            ..enableTranscoding = true;
        }
      }),
    );
    return res.data!;
  }

  Future<void> reportPlaybackStart({
    required String itemId,
    required String playSessionId,
    required String mediaSourceId,
    required int positionTicks,
  }) async {
    await _api.getPlaystateApi().reportPlaybackStart(
      playbackStartInfo: PlaybackStartInfo(
        (b) => b
          ..itemId = itemId
          ..playSessionId = playSessionId
          ..mediaSourceId = mediaSourceId
          ..positionTicks = positionTicks,
      ),
    );
  }

  Future<void> reportPlaybackProgress({
    required String itemId,
    required String playSessionId,
    required String mediaSourceId,
    required int positionTicks,
    required bool isPaused,
  }) async {
    await _api.getPlaystateApi().reportPlaybackProgress(
      playbackProgressInfo: PlaybackProgressInfo(
        (b) => b
          ..itemId = itemId
          ..playSessionId = playSessionId
          ..mediaSourceId = mediaSourceId
          ..positionTicks = positionTicks
          ..isPaused = isPaused,
      ),
    );
  }

  Future<void> reportPlaybackStopped({
    required String itemId,
    required String playSessionId,
    required String mediaSourceId,
    required int positionTicks,
  }) async {
    await _api.getPlaystateApi().reportPlaybackStopped(
      playbackStopInfo: PlaybackStopInfo(
        (b) => b
          ..itemId = itemId
          ..playSessionId = playSessionId
          ..mediaSourceId = mediaSourceId
          ..positionTicks = positionTicks,
      ),
    );
  }

  // -- User-data toggles ----------------------------------------------------

  Future<void> markPlayed(String itemId) async {
    await _api.getPlaystateApi().markPlayedItem(
      userId: _userId,
      itemId: itemId,
    );
  }

  Future<void> markUnplayed(String itemId) async {
    await _api.getPlaystateApi().markUnplayedItem(
      userId: _userId,
      itemId: itemId,
    );
  }

  Future<void> markFavorite(String itemId) async {
    await _api.getUserLibraryApi().markFavoriteItem(
      userId: _userId,
      itemId: itemId,
    );
  }

  Future<void> unmarkFavorite(String itemId) async {
    await _api.getUserLibraryApi().unmarkFavoriteItem(
      userId: _userId,
      itemId: itemId,
    );
  }

  // -- URL helpers ----------------------------------------------------------
  //
  // Only `imageUrl(BaseItemDto)` remains: `core/downloads/download_manager.dart`
  // reads images from a DTO it already owns and avoiding a domain round-trip
  // here is the lesser evil. UI code must use `JellyfinUrlService` instead.

  String _joinUrl(String relative) {
    final base = _dio.options.baseUrl;
    final left = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final right = relative.startsWith('/') ? relative.substring(1) : relative;
    return '$left/$right';
  }

  /// Convenience builder for an image URL — `imageType` like Primary/Backdrop/Logo.
  /// Returns `null` when no tag exists for the requested type — a tag-less
  /// Jellyfin image URL just 404s on the server.
  ///
  /// For Backdrops the Jellyfin response often omits `imageTags['Backdrop']`
  /// and only exposes the tag via the separate `backdropImageTags` list. We
  /// fall back to the first entry of that list so callers can request a
  /// backdrop URL the same way as Primary/Logo.
  String? imageUrl(
    BaseItemDto item, {
    String imageType = 'Primary',
    int? maxWidth,
    int? maxHeight,
  }) {
    if (item.id == null) return null;
    var tag = item.imageTags?[imageType];
    if (tag == null && imageType == 'Backdrop') {
      final list = item.backdropImageTags;
      if (list != null && list.isNotEmpty) tag = list.first;
    }
    if (tag == null) return null;
    return _buildImageUrl(
      item.id!,
      imageType,
      tag,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// Builds an image URL from raw fields — used by call sites that already
  /// have `(itemId, imageType, tag)` in hand and want to avoid recomputing
  /// them via [imageUrl]. Currently called from `download_manager.dart` for
  /// the series-poster fallback path on episodes.
  String imageUrlById(
    String itemId,
    String imageType,
    String tag, {
    int? maxWidth,
    int? maxHeight,
  }) {
    final qp = <String, String>{
      'tag': tag,
      if (maxWidth != null) 'maxWidth': '$maxWidth',
      if (maxHeight != null) 'maxHeight': '$maxHeight',
      'quality': '90',
    };
    final query = qp.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '${_joinUrl('Items/$itemId/Images/$imageType')}?$query';
  }

  String _buildImageUrl(
    String itemId,
    String imageType,
    String tag, {
    int? maxWidth,
    int? maxHeight,
  }) => imageUrlById(
    itemId,
    imageType,
    tag,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
  );

  /// Media segments (intro / outro / recap / commercial markers).
  /// Returns an empty list if the server has no segment plugin enabled.
  Future<List<MediaSegmentDto>> mediaSegments(
    String itemId, {
    BuiltList<MediaSegmentType>? types,
  }) async {
    final res = await _api.getMediaSegmentsApi().getItemSegments(
      itemId: itemId,
      includeSegmentTypes: types,
    );
    return res.data?.items?.toList(growable: false) ?? const [];
  }
}
