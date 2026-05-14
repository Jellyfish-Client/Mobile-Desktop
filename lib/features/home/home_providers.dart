import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../core/app_settings/app_locale_settings.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/bridge/bridge_error_bus.dart';
import '../../core/bridge/bridge_errors.dart';
import '../../core/bridge/bridge_services.dart';
import '../../core/cache/cache_repository.dart';
import '../../core/cache/cache_repository_provider.dart';
import '../../core/cache/item_serialization.dart';
import '../../core/cache/seerr_serialization.dart';
import '../../core/cache/upcoming_serialization.dart';
import '../../core/jellyfin/jellyfin_client.dart';
import '../../core/jellyfin/mappers/base_item_dto_mapper.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/jellyfin/user_views_provider.dart';
import '../../core/recommender/recommendation_rail.dart';
import '../../core/recommender/recommender.dart';
import '../../core/recommender/taste_profile.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';
import '../../core/upcoming/models.dart';
import '../../core/upcoming/upcoming_client.dart';
import 'hero_featured.dart';
import 'home_catalog.dart';
import 'home_section.dart';
import 'reco_seeds.dart';
import 'seer_moods.dart';

// ---------------------------------------------------------------------------
// Generic stale-while-revalidate list notifier
// ---------------------------------------------------------------------------

/// Notifier that paints from the on-disk cache on the first frame and then
/// re-emits with the network result. The cache key is versioned (`_v1`) so
/// a future schema bump can invalidate persisted payloads by rolling the
/// suffix.
///
/// Two type parameters separate **what the UI consumes** ([TState]) from
/// **what lives on disk** ([TStorage]). Jellyfin rails fetch raw
/// [BaseItemDto] (full SDK fidelity for cache persistence) and emit
/// [JellyfinItem] to the UI; Seerr rails set both params to [SeerrMedia]
/// since no transform happens there.
class _CachedListNotifier<TState, TStorage>
    extends AutoDisposeAsyncNotifier<List<TState>> {
  _CachedListNotifier({
    required this.cacheKey,
    required this.fetch,
    required this.encode,
    required this.decode,
    required this.mapState,
  });

  final String cacheKey;
  final Future<List<TStorage>> Function(Ref ref) fetch;
  final String Function(List<TStorage>) encode;
  final List<TStorage>? Function(String) decode;
  final List<TState> Function(List<TStorage>) mapState;

  @override
  Future<List<TState>> build() async {
    // Invalidate this notifier whenever the active account changes — without
    // this watch the keepAlive() below would hold the previous user's rails in
    // memory forever and the UI would flash old data after switchTo.
    ref.watch(_activeAccountKeyProvider);
    // Keep alive *before* awaiting anything. Otherwise if the consuming widget
    // unmounts (tab switch) before the network call returns, the provider is
    // disposed and the in-flight fetch is thrown away.
    ref.keepAlive();
    final cache = ref.read(cacheRepositoryProvider);
    final cached = await _readCache(cache);
    if (cached != null) {
      // Paint the cached list synchronously so the UI doesn't flash a skeleton
      // on cold start. The network call below will re-emit when it lands.
      state = AsyncData(mapState(cached));
    }
    final fresh = await fetch(ref);
    // Await the write so a pull-to-refresh that re-creates the notifier can't
    // race against an in-flight write from the previous cycle and read a
    // stale payload from disk.
    await cache.write(cacheKey, encode(fresh));
    return mapState(fresh);
  }

  Future<List<TStorage>?> _readCache(CacheRepository cache) async {
    final raw = await cache.read(cacheKey);
    if (raw == null) return null;
    return decode(raw);
  }
}

/// Returns a stable string identifying the active (server, user) pair.
/// `_CachedListNotifier` watches this so it gets rebuilt on every account
/// switch instead of replaying the previous user's cached state.
final _activeAccountKeyProvider = Provider<String>((ref) {
  final session = ref.watch(authControllerProvider).valueOrNull?.session;
  return session == null ? '_' : '${session.serverId}|${session.userId}';
});

/// Family equivalent of [_CachedListNotifier]. Keyed on an arbitrary record so
/// e.g. (libraryId, itemKind) combinations share a single provider type.
class _CachedListFamilyNotifier<TState, TStorage, K>
    extends AutoDisposeFamilyAsyncNotifier<List<TState>, K> {
  _CachedListFamilyNotifier({
    required this.cacheKeyFor,
    required this.fetch,
    required this.encode,
    required this.decode,
    required this.mapState,
  });

  final String Function(K arg) cacheKeyFor;
  final Future<List<TStorage>> Function(Ref ref, K arg) fetch;
  final String Function(List<TStorage>) encode;
  final List<TStorage>? Function(String) decode;
  final List<TState> Function(List<TStorage>) mapState;

  @override
  Future<List<TState>> build(K arg) async {
    ref.watch(_activeAccountKeyProvider);
    ref.keepAlive();
    final cache = ref.read(cacheRepositoryProvider);
    final key = cacheKeyFor(arg);
    final raw = await cache.read(key);
    final cached = raw == null ? null : decode(raw);
    if (cached != null) state = AsyncData(mapState(cached));
    final fresh = await fetch(ref, arg);
    await cache.write(key, encode(fresh));
    return mapState(fresh);
  }
}

// ---------------------------------------------------------------------------
// Stale-while-revalidate rails (Jellyfin)
// ---------------------------------------------------------------------------

final resumeItemsProvider =
    AsyncNotifierProvider.autoDispose<
      _CachedListNotifier<JellyfinItem, BaseItemDto>,
      List<JellyfinItem>
    >(
      () => _CachedListNotifier<JellyfinItem, BaseItemDto>(
        cacheKey: 'resume_items_v1',
        fetch: (ref) => ref.read(jellyfinClientProvider).resumeItems(limit: 12),
        encode: encodeBaseItemList,
        decode: tryDecodeBaseItemList,
        mapState: (dtos) => dtos.toDomainList(),
      ),
    );

final latestItemsProvider =
    AsyncNotifierProvider.autoDispose<
      _CachedListNotifier<JellyfinItem, BaseItemDto>,
      List<JellyfinItem>
    >(
      () => _CachedListNotifier<JellyfinItem, BaseItemDto>(
        cacheKey: 'latest_items_v1',
        fetch: (ref) => ref.read(jellyfinClientProvider).latestItems(limit: 24),
        encode: encodeBaseItemList,
        decode: tryDecodeBaseItemList,
        mapState: (dtos) => dtos.toDomainList(),
      ),
    );

final nextUpItemsProvider =
    AsyncNotifierProvider.autoDispose<
      _CachedListNotifier<JellyfinItem, BaseItemDto>,
      List<JellyfinItem>
    >(
      () => _CachedListNotifier<JellyfinItem, BaseItemDto>(
        cacheKey: 'next_up_v1',
        fetch: (ref) => ref.read(jellyfinClientProvider).nextUp(limit: 24),
        encode: encodeBaseItemList,
        decode: tryDecodeBaseItemList,
        mapState: (dtos) => dtos.toDomainList(),
      ),
    );

/// Latest items scoped to a specific Jellyfin library and item kind.
///
/// One on-disk blob per (libraryId, kind) pair — orphan blobs (library
/// removed) remain on disk but are harmless. The library id is truncated to
/// 8 chars in the cache key just to keep filenames short; collisions are
/// astronomically unlikely for the handful of libraries a user has.
typedef LatestByLibraryArg = ({String parentId, BaseItemKind kind});

final latestByLibraryProvider = AsyncNotifierProvider.autoDispose
    .family<
      _CachedListFamilyNotifier<JellyfinItem, BaseItemDto, LatestByLibraryArg>,
      List<JellyfinItem>,
      LatestByLibraryArg
    >(
      () =>
          _CachedListFamilyNotifier<
            JellyfinItem,
            BaseItemDto,
            LatestByLibraryArg
          >(
            cacheKeyFor: (arg) {
              final short = arg.parentId.length > 8
                  ? arg.parentId.substring(0, 8)
                  : arg.parentId;
              return 'latest_lib_${short}_${arg.kind.name}_v1';
            },
            fetch: (ref, arg) => ref
                .read(jellyfinClientProvider)
                .latestItems(
                  parentId: arg.parentId,
                  includeItemTypes: [arg.kind],
                  limit: 24,
                ),
            encode: encodeBaseItemList,
            decode: tryDecodeBaseItemList,
            mapState: (dtos) => dtos.toDomainList(),
          ),
    );

/// Raw play history used to derive the taste profile. Cached on disk so the
/// `recentlyPlayed` round-trip doesn't gate the recommendations rail on cold
/// start — we paint a profile from the cache immediately, then refresh in
/// the background.
///
/// **Asymmetry warning.** Unlike the sibling Jellyfin home providers, this
/// one exposes [BaseItemDto] (not [JellyfinItem]) because the consumer
/// ([tasteProfileProvider] / [Recommender]) lives in `core/recommender/`
/// and operates on raw SDK types. A new UI consumer must map via
/// [BaseItemDtoMapper.toDomain] at the boundary.
final recentlyPlayedItemsProvider =
    AsyncNotifierProvider.autoDispose<
      _CachedListNotifier<BaseItemDto, BaseItemDto>,
      List<BaseItemDto>
    >(
      () => _CachedListNotifier<BaseItemDto, BaseItemDto>(
        cacheKey: 'recently_played_v1',
        fetch: (ref) => ref.read(jellyfinClientProvider).recentlyPlayed(),
        encode: encodeBaseItemList,
        decode: tryDecodeBaseItemList,
        mapState: (raw) => raw,
      ),
    );

/// SWR-cached pool of "hero-eligible" Jellyfin items.
///
/// Mirrors the query the `IAmParadox27/jellyfin-plugin-media-bar` plugin runs
/// (random unwatched Movies/Series with both Logo + Backdrop artwork). We
/// keep this list cached on disk so a cold start can paint a slide from
/// memory while the fresh shuffle lands in the background; the
/// shuffle-on-each-build over [featuredCarouselItemsProvider] gives session
/// variety without re-hitting the server.
final featuredPoolProvider =
    AsyncNotifierProvider.autoDispose<
      _CachedListNotifier<JellyfinItem, BaseItemDto>,
      List<JellyfinItem>
    >(
      () => _CachedListNotifier<JellyfinItem, BaseItemDto>(
        cacheKey: 'featured_pool_v1',
        fetch: (ref) => ref.read(jellyfinClientProvider).featuredItems(),
        encode: encodeBaseItemList,
        decode: tryDecodeBaseItemList,
        mapState: (dtos) => dtos.toDomainList(),
      ),
    );

/// Jellyfin-only items for the hero carousel. Up to 6 items with Logo+Backdrop
/// shuffled per session for variety. Seerr items are intentionally excluded —
/// the hero is reserved for content the user already has access to in their
/// library.
///
/// Defensive client-side Logo filter: even with `imageTypes=Logo,Backdrop`
/// the server occasionally returns items whose Logo tag is on the parent
/// (BoxSet / Series logo for an Episode). We need a real logo on the item
/// itself so the hero's logo box doesn't fall back to a text title that
/// contradicts the artwork.
final featuredCarouselItemsProvider =
    FutureProvider.autoDispose<List<HeroFeaturedItem>>((ref) async {
      ref.keepAlive();
      final pool = await ref.watch(featuredPoolProvider.future);
      final jfPool = pool.where((i) => i.imageTags.containsKey('Logo')).toList()
        ..shuffle();
      return jfPool.take(6).map(HeroJellyfinItem.new).toList();
    });

// ---------------------------------------------------------------------------
// Recommender providers
// ---------------------------------------------------------------------------

/// Provides the [Recommender] instance. AutoDispose so it is rebuilt when the
/// session changes.
final recommenderProvider = Provider.autoDispose<Recommender>((ref) {
  return Recommender(ref.watch(jellyfinClientProvider));
});

/// Builds a [TasteProfile] from the user's play history. Reads from the
/// SWR-cached [recentlyPlayedItemsProvider] so a cold start can compute a
/// (possibly stale) profile immediately from disk, while the fresh network
/// payload refreshes the same provider in the background.
final tasteProfileProvider = FutureProvider.autoDispose<TasteProfile>((
  ref,
) async {
  ref.keepAlive();
  final history = await ref.watch(recentlyPlayedItemsProvider.future);
  return TasteProfile.fromHistory(history);
});

/// Returns the ordered list of recommendation rails for the Home screen.
/// Depends on [tasteProfileProvider] — waits for the profile before computing
/// rails so scoring has full signal. Kept alive across navigation.
final recommendationRailsProvider =
    FutureProvider.autoDispose<List<RecommendationRail>>((ref) async {
      ref.keepAlive();
      final profile = await ref.watch(tasteProfileProvider.future);
      return ref.watch(recommenderProvider).rails(profile);
    });

// ---------------------------------------------------------------------------
// Seerr providers
// ---------------------------------------------------------------------------

/// Drops items Seerr flags as already requested, in-flight, or sitting in
/// the linked Jellyfin library — the Home rails are pure discovery, so
/// anything the user has already acted on (or that's available) is noise.
/// `unknown` is Seerr's "no media record at all" state, which is exactly
/// what we want to surface.
List<SeerrMedia> _hideAcquiredOrRequested(List<SeerrMedia> items) {
  return items
      .where((m) => m.availability == SeerrAvailability.unknown)
      .toList();
}

/// Builds a SWR-cached Seerr rail. Returns an empty list (and skips the
/// network/cache entirely) when Seerr is not linked, so the UI never shows a
/// "link your Seerr" CTA on Home and a later linking triggers a fresh fetch.
AutoDisposeAsyncNotifierProvider<
  _CachedListNotifier<SeerrMedia, SeerrMedia>,
  List<SeerrMedia>
>
_seerrRailProvider({
  required String cacheKey,
  required Future<List<SeerrMedia>> Function(SeerrClient client) fetch,
}) {
  return AsyncNotifierProvider.autoDispose<
    _CachedListNotifier<SeerrMedia, SeerrMedia>,
    List<SeerrMedia>
  >(
    () => _CachedListNotifier<SeerrMedia, SeerrMedia>(
      cacheKey: cacheKey,
      fetch: (ref) async {
        // Wait for the bridge services discovery before deciding to skip —
        // a synchronous read here would pick up the pre-resolution
        // `unavailable` state at cold start and silently overwrite the
        // on-disk cache with an empty list.
        final services = await ref.watch(bridgeServicesProvider.future);
        if (!services.jellyseerrAvailable) return const [];
        final client = ref.read(seerrClientProvider);
        try {
          return _hideAcquiredOrRequested(await fetch(client));
        } on DioException catch (e) {
          final mapped = mapBridgeError(e);
          if (mapped != null) {
            ref.read(bridgeErrorBusProvider.notifier).state = mapped;
          }
          return const <SeerrMedia>[];
        }
      },
      encode: encodeSeerrMediaList,
      decode: (raw) {
        final decoded = tryDecodeSeerrMediaList(raw);
        return decoded == null ? null : _hideAcquiredOrRequested(decoded);
      },
      mapState: (raw) => raw,
    ),
  );
}

final seerrTrendingProvider = _seerrRailProvider(
  cacheKey: 'seerr_trending_v1',
  fetch: (c) => c.trending(),
);

final seerrPopularMoviesProvider = _seerrRailProvider(
  cacheKey: 'seerr_popular_movies_v1',
  fetch: (c) => c.popularMovies(),
);

final seerrPopularSeriesProvider = _seerrRailProvider(
  cacheKey: 'seerr_popular_series_v1',
  fetch: (c) => c.popularSeries(),
);

final seerrWatchlistProvider = _seerrRailProvider(
  cacheKey: 'seerr_watchlist_v1',
  fetch: (c) => c.watchlist(),
);

/// Up to 3 "Parce que vous avez regardé X" seeds, picked at random per
/// session (autoDispose+keepAlive keeps the result stable until the user
/// switches account or kills the app). Logic lives in `pickRecoSeeds` so
/// it's unit-testable in isolation.
///
/// **Why we `await` the popular providers' `.future` instead of just reading
/// `valueOrNull`.** Watching the AsyncValue would trigger a rebuild on the
/// `loading → data` transition, and that rebuild would create a fresh
/// `Random()` and re-shuffle the seeds — visible to the user as the reco
/// rails reordering mid-scroll a few seconds after cold start. Awaiting the
/// future means we build exactly once (per session / account), seeds stay
/// stable, and the popular fallback is only consulted once it's available.
final recoSeedsProvider = FutureProvider.autoDispose<List<RecoSeed>>((
  ref,
) async {
  ref
    ..watch(_activeAccountKeyProvider)
    ..keepAlive();
  final history = await ref.watch(recentlyPlayedItemsProvider.future);
  List<SeerrMedia> popMovies;
  List<SeerrMedia> popSeries;
  try {
    popMovies = await ref.watch(seerrPopularMoviesProvider.future);
  } on Object {
    popMovies = const [];
  }
  try {
    popSeries = await ref.watch(seerrPopularSeriesProvider.future);
  } on Object {
    popSeries = const [];
  }
  return pickRecoSeeds(history, [...popMovies, ...popSeries]);
});

/// One "similar to X" rail per seed. Family keyed on `(tmdbId, type)` so a
/// rename of the seed title (or a swap from history-source to fallback-
/// source) reuses the same cached fetch.
typedef SimilarSeedKey = ({int tmdbId, SeerrMediaType type});

final seerrSimilarBySeedProvider = FutureProvider.autoDispose
    .family<List<SeerrMedia>, SimilarSeedKey>((ref, key) async {
      ref.keepAlive();
      final services = await ref.watch(bridgeServicesProvider.future);
      if (!services.jellyseerrAvailable) return const [];
      final client = ref.read(seerrClientProvider);
      try {
        final fresh = key.type == SeerrMediaType.movie
            ? await client.similarMovies(key.tmdbId)
            : await client.similarTv(key.tmdbId);
        return _hideAcquiredOrRequested(fresh);
      } on DioException catch (e) {
        final mapped = mapBridgeError(e);
        if (mapped != null) {
          ref.read(bridgeErrorBusProvider.notifier).state = mapped;
        }
        return const <SeerrMedia>[];
      }
    });

/// Per-mood raw discover results (SWR-cached as a single blob keyed by
/// account). Cross-mood / cross-rail dedup happens in [_seerMoodDedupedProvider]
/// at read time — caching the *pre-dedup* map keeps the on-disk shape
/// independent of which other Seer rails happen to be loaded.
class _SeerMoodAggregateNotifier
    extends AutoDisposeAsyncNotifier<Map<SeerMoodId, List<SeerrMedia>>> {
  // v2: switched genre joiner to `|` (OR) and TMDB-canonical sortBy values
  // (`vote_average.desc` over the camelCase). v1 blobs cached empty results
  // because of the old AND-semantics + invalid sort value — bump to force a
  // refetch on next launch.
  static const _cacheKey = 'seer_moods_v2';

  @override
  Future<Map<SeerMoodId, List<SeerrMedia>>> build() async {
    ref
      ..watch(_activeAccountKeyProvider)
      ..keepAlive();
    final cache = ref.read(cacheRepositoryProvider);
    final raw = await cache.read(_cacheKey);
    if (raw != null) {
      final decoded = tryDecodeSeerMoodMap(raw);
      if (decoded != null) state = AsyncData(decoded);
    }
    final services = await ref.watch(bridgeServicesProvider.future);
    if (!services.jellyseerrAvailable) return const {};
    final client = ref.read(seerrClientProvider);
    // Per-mood failures collapse to an empty list so one broken query never
    // blanks the whole rail group. `_hideAcquiredOrRequested` runs per-mood
    // for the same reason it runs on every other Seer rail — Home is pure
    // discovery, anything already on the library shouldn't appear here.
    final pairs = await Future.wait(
      SeerMoodId.values.map((id) => _fetchOne(client, id)),
    );
    final fresh = <SeerMoodId, List<SeerrMedia>>{
      for (final p in pairs) p.$1: p.$2,
    };
    await cache.write(_cacheKey, encodeSeerMoodMap(fresh));
    return fresh;
  }

  Future<(SeerMoodId, List<SeerrMedia>)> _fetchOne(
    SeerrClient client,
    SeerMoodId id,
  ) async {
    final s = moodSpec(id);
    try {
      final list = await client.discoverMovies(
        sortBy: s.sortBy,
        genres: s.genres,
        voteCountGte: s.voteCountGte,
        voteAverageGte: s.voteAverageGte,
      );
      return (id, _hideAcquiredOrRequested(list));
    } on DioException catch (e) {
      final mapped = mapBridgeError(e);
      if (mapped != null) {
        ref.read(bridgeErrorBusProvider.notifier).state = mapped;
      }
      return (id, const <SeerrMedia>[]);
    } on Object {
      return (id, const <SeerrMedia>[]);
    }
  }
}

final seerMoodAggregateProvider =
    AsyncNotifierProvider.autoDispose<
      _SeerMoodAggregateNotifier,
      Map<SeerMoodId, List<SeerrMedia>>
    >(_SeerMoodAggregateNotifier.new);

/// Snapshot of tmdbIds already shown by the *earlier* Seer rails on Home
/// (trending → popular movies → popular series → watchlist → reco). Best-
/// effort: if one of those rails hasn't resolved yet, its contribution is
/// just missing — the deduped mood rails will re-evaluate when it lands.
final _seerMoodSeenIdsProvider = Provider.autoDispose<Set<int>>((ref) {
  final ids = <int>{};
  void merge(List<SeerrMedia>? list) {
    if (list == null) return;
    for (final m in list) {
      ids.add(m.tmdbId);
    }
  }

  merge(ref.watch(seerrTrendingProvider).valueOrNull);
  merge(ref.watch(seerrPopularMoviesProvider).valueOrNull);
  merge(ref.watch(seerrPopularSeriesProvider).valueOrNull);
  merge(ref.watch(seerrWatchlistProvider).valueOrNull);
  final seeds = ref.watch(recoSeedsProvider).valueOrNull ?? const [];
  for (final s in seeds) {
    merge(
      ref
          .watch(seerrSimilarBySeedProvider((tmdbId: s.tmdbId, type: s.type)))
          .valueOrNull,
    );
  }
  return ids;
});

/// Applies cross-mood dedup (first mood in [SeerMoodId.values] wins) on top
/// of the earlier-rail "seen" set. Computed once and consumed by every per-
/// mood selector so all rails agree on the assignment.
final _seerMoodDedupedProvider =
    Provider.autoDispose<AsyncValue<Map<SeerMoodId, List<SeerrMedia>>>>((ref) {
      final aggregate = ref.watch(seerMoodAggregateProvider);
      final seen = ref.watch(_seerMoodSeenIdsProvider);
      return aggregate.whenData((map) {
        final used = {...seen};
        final out = <SeerMoodId, List<SeerrMedia>>{};
        for (final mood in SeerMoodId.values) {
          final src = map[mood] ?? const <SeerrMedia>[];
          final list = <SeerrMedia>[];
          for (final m in src) {
            if (!used.add(m.tmdbId)) continue;
            list.add(m);
          }
          out[mood] = list;
        }
        return out;
      });
    });

final seerMoodProvider = Provider.autoDispose
    .family<AsyncValue<List<SeerrMedia>>, SeerMoodId>((ref, id) {
      return ref
          .watch(_seerMoodDedupedProvider)
          .whenData((map) => map[id] ?? const <SeerrMedia>[]);
    });

/// SWR-cached genre slider (genres-as-tiles with backdrops). One provider per
/// kind (movies/tv) so caches stay independent.
class _GenreSliderNotifier
    extends AutoDisposeAsyncNotifier<List<SeerrGenreSlide>> {
  _GenreSliderNotifier(this.cacheKey, this.fetch);

  final String cacheKey;
  final Future<List<SeerrGenreSlide>> Function(SeerrClient client) fetch;

  @override
  Future<List<SeerrGenreSlide>> build() async {
    ref.keepAlive();
    final cache = ref.read(cacheRepositoryProvider);
    final raw = await cache.read(cacheKey);
    if (raw != null) {
      final decoded = tryDecodeSeerrGenreSlideList(raw);
      if (decoded != null) state = AsyncData(decoded);
    }
    final client = ref.read(seerrClientProvider);
    if (!client.isLinked) return const [];
    final fresh = await fetch(client);
    await cache.write(cacheKey, encodeSeerrGenreSlideList(fresh));
    return fresh;
  }
}

/// Watch providers (Netflix, Disney+, …) for the current region. Region is
/// hardcoded to FR for now; a future setting could surface this.
class _WatchProvidersNotifier
    extends AutoDisposeAsyncNotifier<List<SeerrWatchProvider>> {
  _WatchProvidersNotifier(this.cacheKey, this.fetch);

  final String cacheKey;
  final Future<List<SeerrWatchProvider>> Function(SeerrClient client) fetch;

  @override
  Future<List<SeerrWatchProvider>> build() async {
    ref.keepAlive();
    final cache = ref.read(cacheRepositoryProvider);
    final raw = await cache.read(cacheKey);
    if (raw != null) {
      final decoded = tryDecodeSeerrWatchProviderList(raw);
      if (decoded != null) state = AsyncData(decoded);
    }
    final client = ref.read(seerrClientProvider);
    if (!client.isLinked) return const [];
    final fresh = await fetch(client);
    await cache.write(cacheKey, encodeSeerrWatchProviderList(fresh));
    return fresh;
  }
}

final seerrWatchProvidersMoviesProvider =
    AsyncNotifierProvider.autoDispose<
      _WatchProvidersNotifier,
      List<SeerrWatchProvider>
    >(
      () => _WatchProvidersNotifier(
        'seerr_watch_providers_movies_v1',
        (c) => c.watchProvidersMovies(),
      ),
    );

final seerrWatchProvidersTvProvider =
    AsyncNotifierProvider.autoDispose<
      _WatchProvidersNotifier,
      List<SeerrWatchProvider>
    >(
      () => _WatchProvidersNotifier(
        'seerr_watch_providers_tv_v1',
        (c) => c.watchProvidersTv(),
      ),
    );

/// Movies/TV available on a given provider. Family is keyed by
/// `(providerId, isTv)` rather than by provider name — the TMDB id is
/// authoritative and survives renaming.
typedef WatchProviderArg = ({int providerId, bool isTv});

final seerrDiscoverByProviderProvider = FutureProvider.autoDispose
    .family<List<SeerrMedia>, WatchProviderArg>((ref, arg) async {
      ref.keepAlive();
      final client = ref.watch(seerrClientProvider);
      if (!client.isLinked) return const [];
      final fresh = arg.isTv
          ? await client.discoverTvByProvider(arg.providerId)
          : await client.discoverMoviesByProvider(arg.providerId);
      return _hideAcquiredOrRequested(fresh);
    });

final seerrGenreSliderMoviesProvider =
    AsyncNotifierProvider.autoDispose<
      _GenreSliderNotifier,
      List<SeerrGenreSlide>
    >(
      () => _GenreSliderNotifier(
        'seerr_genre_slider_movies_v1',
        (c) => c.genreSliderMovies(),
      ),
    );

final seerrGenreSliderTvProvider =
    AsyncNotifierProvider.autoDispose<
      _GenreSliderNotifier,
      List<SeerrGenreSlide>
    >(
      () => _GenreSliderNotifier(
        'seerr_genre_slider_tv_v1',
        (c) => c.genreSliderTv(),
      ),
    );

// ---------------------------------------------------------------------------
// Bridge — Upcoming rails (Radarr movies + Sonarr episodes)
// ---------------------------------------------------------------------------

/// Window for the home rails. The calendar page surfaces longer ranges
/// itself; this is just "coming soon" prominence on the home.
const _homeUpcomingDays = 30;
const _homeUpcomingLimit = 30;

AutoDisposeAsyncNotifierProvider<
  _CachedListNotifier<UpcomingItem, UpcomingItem>,
  List<UpcomingItem>
>
_bridgeUpcomingRailProvider({
  required String cacheKey,
  required UpcomingKind kind,
  required bool Function(BridgeServices) available,
}) {
  return AsyncNotifierProvider.autoDispose<
    _CachedListNotifier<UpcomingItem, UpcomingItem>,
    List<UpcomingItem>
  >(
    () => _CachedListNotifier<UpcomingItem, UpcomingItem>(
      cacheKey: cacheKey,
      fetch: (ref) async {
        final services = await ref.watch(bridgeServicesProvider.future);
        if (!available(services)) return const [];
        try {
          return await ref
              .read(upcomingClientProvider)
              .get(
                days: _homeUpcomingDays,
                kinds: {kind},
                limit: _homeUpcomingLimit,
              );
        } on DioException catch (e) {
          final mapped = mapBridgeError(e);
          if (mapped != null) {
            ref.read(bridgeErrorBusProvider.notifier).state = mapped;
          }
          return const <UpcomingItem>[];
        }
      },
      encode: encodeUpcomingItemList,
      decode: tryDecodeUpcomingItemList,
      mapState: (raw) => raw,
    ),
  );
}

final bridgeUpcomingMoviesProvider = _bridgeUpcomingRailProvider(
  cacheKey: 'bridge_upcoming_movies_v1',
  kind: UpcomingKind.movies,
  available: (s) => s.radarrAvailable,
);

final bridgeUpcomingEpisodesProvider = _bridgeUpcomingRailProvider(
  cacheKey: 'bridge_upcoming_episodes_v1',
  kind: UpcomingKind.episodes,
  available: (s) => s.sonarrAvailable,
);

// ---------------------------------------------------------------------------
// Home catalog (dynamic)
// ---------------------------------------------------------------------------

/// Builds the ordered list of Home sections from the user's libraries and
/// the bridge-services discovery. Replaces the static
/// `kHomeHead`/`kHomeQueue` constants so each library contributes its own
/// rails (per [CollectionType]).
final homeCatalogProvider = FutureProvider.autoDispose<List<HomeSection>>((
  ref,
) async {
  // keepAlive BEFORE awaiting — userViews fetch must survive transient
  // unmounts (tab switch during cold start).
  ref.keepAlive();
  final views = await ref.watch(userViewsProvider.future);
  // Wait for the services discovery to resolve before building the catalog.
  // A synchronous read here would observe the pre-resolution `unavailable`
  // state at cold start and drop every Seerr section.
  final services = await ref.watch(bridgeServicesProvider.future);
  // Reco seeds are only meaningful when Seerr is reachable. Awaiting before
  // building the catalog keeps the rail order stable — otherwise the reco
  // rails would pop in mid-scroll once the history finishes resolving.
  final recoSeeds = services.jellyseerrAvailable
      ? await ref.watch(recoSeedsProvider.future)
      : const <RecoSeed>[];
  // Watching the localizations provider here makes the catalog reactive to
  // language switches: changing the app locale invalidates this provider so
  // the rail titles ("Continue watching", "Pour vous", …) rebuild in the
  // new language without restarting the app.
  final l10n = ref.watch(appLocalizationsProvider);
  return buildHomeCatalog(
    views: views,
    isSeerLinked: services.jellyseerrAvailable,
    recoSeeds: recoSeeds,
    l10n: l10n,
  );
});
