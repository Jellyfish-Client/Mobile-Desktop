import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/bridge/bridge_error_bus.dart';
import '../../core/bridge/bridge_errors.dart';
import '../../core/bridge/bridge_services.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/user_views_provider.dart';
import '../../core/network/offline_mode_provider.dart';
import '../../core/seerr/seerr_client.dart';
import '../../l10n/l10n_extension.dart';
import '../../main.dart' show appStartStopwatch;
import '../../shared/widgets/widgets.dart';
import '../details/widgets/seerr_request_sheet.dart';
import 'hero_featured.dart';
import 'home_providers.dart';
import 'home_sections_controller.dart';
import 'offline_home_screen.dart';
import 'widgets/home_section_view.dart';

// Logged exactly once per process: the elapsed wall-clock between `main()`
// entry and the first frame where Home has section data to render. Compare
// against the engine's `timeToFirstFrame` (loading frame) to size the gap
// between "loading shown" and "home actually populated".
bool _homePaintLogged = false;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(offlineModeProvider)) {
      return const OfflineHomeScreen();
    }
    // Surface plugin-level errors (e.g. no_jellyseerr_account) as snackbars
    // even when the originating screen is gone. The bus is cleared right
    // after to avoid replaying the same error on a future rebuild.
    ref.listen<BridgeException?>(bridgeErrorBusProvider, (_, next) {
      if (next == null) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(content: Text(_bridgeErrorText(context, next))),
      );
      ref.read(bridgeErrorBusProvider.notifier).state = null;
    });
    final servicesAsync = ref.watch(bridgeServicesProvider);
    final pluginMissing = servicesAsync.valueOrNull?.pluginInstalled == false;
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final seerrClient = ref.watch(seerrClientProvider);
    final sectionsAsync = ref.watch(homeSectionsControllerProvider);
    if (!_homePaintLogged && sectionsAsync.hasValue) {
      _homePaintLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint(
          '[perf] home_painted: ${appStartStopwatch.elapsedMilliseconds}ms',
        );
      });
    }
    final featured =
        ref.watch(featuredCarouselItemsProvider).valueOrNull ?? const [];

    final heroSlides = <JfFullHeroSlide>[
      for (final fItem in featured)
        switch (fItem) {
          HeroJellyfinItem(:final item) => JfFullHeroSlide(
            id: 'jf_${item.id}',
            title: item.name ?? '',
            overview: item.overview,
            backdropUrl: urls.imageUrl(item, type: 'Backdrop', maxWidth: 1600),
            logoUrl: urls.imageUrl(item, type: 'Logo', maxWidth: 600),
            year: item.productionYear,
            rating: item.communityRating,
            ageRating: item.officialRating,
            runtimeMinutes: item.runTimeTicks == null
                ? null
                : item.runTimeTicks! ~/ 600000000,
            genres: item.genres,
            isFavorite: item.isFavorite,
          ),
          HeroSeerrItem(:final media) => JfFullHeroSlide(
            id: 'seer_${media.tmdbId}_${media.type.name}',
            title: media.title,
            overview: media.overview,
            backdropUrl: seerrClient.backdropUrl(media),
            year: media.year,
            primaryLabel: context.l10n.seerrRequest,
            primaryIcon: Icons.add_circle_outline,
          ),
        },
    ];

    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // Invalidate every Home provider — they all keepAlive themselves
              // after the first build, so without explicit invalidation a
              // pull-to-refresh would just re-emit the cached SWR payload.
              ref
                ..invalidate(resumeItemsProvider)
                ..invalidate(latestItemsProvider)
                ..invalidate(nextUpItemsProvider)
                ..invalidate(recentlyPlayedItemsProvider)
                ..invalidate(featuredPoolProvider)
                ..invalidate(featuredCarouselItemsProvider)
                ..invalidate(tasteProfileProvider)
                ..invalidate(recommendationRailsProvider)
                ..invalidate(userViewsProvider)
                ..invalidate(homeCatalogProvider)
                ..invalidate(latestByLibraryProvider)
                ..invalidate(seerrTrendingProvider)
                ..invalidate(seerrPopularMoviesProvider)
                ..invalidate(seerrPopularSeriesProvider)
                ..invalidate(bridgeUpcomingMoviesProvider)
                ..invalidate(bridgeUpcomingEpisodesProvider)
                ..invalidate(seerrWatchlistProvider)
                ..invalidate(recoSeedsProvider)
                ..invalidate(seerrSimilarBySeedProvider)
                ..invalidate(seerrGenreSliderMoviesProvider)
                ..invalidate(seerrGenreSliderTvProvider)
                ..invalidate(seerrWatchProvidersMoviesProvider)
                ..invalidate(seerrWatchProvidersTvProvider)
                ..invalidate(seerrDiscoverByProviderProvider)
                ..invalidate(seerMoodAggregateProvider)
                ..invalidate(homeSectionsControllerProvider);
            },
            child: CustomScrollView(
              slivers: [
                if (pluginMissing)
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          0,
                        ),
                        child: _PluginMissingBanner(),
                      ),
                    ),
                  ),
                // ── Hero plein écran ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: JfFullHero(
                    topPadding: topInset,
                    slides: heroSlides,
                    onPrimaryTap: (slide) =>
                        _onHeroAction(context, slide, featured),
                    onDetailTap: (slide) {
                      if (slide.id.startsWith('jf_')) {
                        final itemId = slide.id.substring(3);
                        if (itemId.isNotEmpty) {
                          context.push('/items/$itemId');
                        }
                      }
                    },
                  ),
                ),

                // ── Sections ────────────────────────────────────────────────
                // No global loading skeleton — each rail manages its own
                // placeholder. Showing one full-width skeleton here while we
                // wait for the (lightweight) catalog/userViews resolution
                // produces a visible "loading screen" feel; an empty body is
                // better since the first rail typically lands within 100ms.
                ...sectionsAsync.when(
                  loading: () => const <Widget>[],
                  error: (_, __) => const <Widget>[],
                  data: (state) => [
                    for (final section in state.visible)
                      SliverToBoxAdapter(
                        key: ValueKey(section.id),
                        child: HomeSectionView(section: section),
                      ),
                    SliverToBoxAdapter(child: _ExhaustedFooter()),
                  ],
                ),
              ],
            ),
          ),

          // Subtle film-grain overlay.
          const Positioned.fill(child: JfGrainOverlay(opacity: 0.035)),

          // Floating search entry — opens unified Jellyfin + Seerr search.
          Positioned(
            top: topInset + AppSpacing.sm,
            right: AppSpacing.lg,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                tooltip: context.l10n.homeSearch,
                onPressed: () => context.go('/search'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _onHeroAction(
  BuildContext context,
  JfFullHeroSlide slide,
  List<HeroFeaturedItem> featured,
) {
  // The slide id encodes the source so the primary CTA branches without
  // needing a second lookup table: `jf_<itemId>` plays/opens the Jellyfin
  // item, `seer_<tmdbId>_<type>` opens the Seerr request sheet.
  if (slide.id.startsWith('jf_')) {
    final itemId = slide.id.substring(3);
    if (itemId.isNotEmpty) context.push('/items/$itemId');
    return;
  }
  if (slide.id.startsWith('seer_')) {
    final match = featured
        .whereType<HeroSeerrItem>()
        .where((s) => s.id == slide.id)
        .firstOrNull;
    if (match != null) {
      showSeerrRequestSheet(context, media: match.media);
    }
  }
}

String _bridgeErrorText(BuildContext context, BridgeException e) {
  final l10n = context.l10n;
  return switch (e.kind) {
    BridgeErrorKind.noJellyseerrAccount => l10n.homeNoJellyseerrAccount,
    BridgeErrorKind.jellyseerrNotConfigured => l10n.homeJellyseerrNotConfigured,
    BridgeErrorKind.radarrNotConfigured => l10n.homeRadarrNotConfigured,
    BridgeErrorKind.sonarrNotConfigured => l10n.homeSonarrNotConfigured,
    BridgeErrorKind.upstreamUnreachable => l10n.homeUpstreamUnreachable,
    BridgeErrorKind.upstreamTimeout => l10n.homeUpstreamTimeout,
    BridgeErrorKind.pluginMissing => l10n.homePluginMissingError,
    BridgeErrorKind.other => l10n.homeOtherError(e.statusCode ?? 0),
  };
}

class _PluginMissingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: scheme.onErrorContainer),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              context.l10n.homePluginMissing,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExhaustedFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: Text(
            context.l10n.homeNoMoreContent,
            style: AppTypography.display(
              size: 14,
              weight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.5),
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
