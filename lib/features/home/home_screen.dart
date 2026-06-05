import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/bridge/bridge_error_bus.dart';
import '../../core/bridge/bridge_errors.dart';
import '../../core/bridge/bridge_services.dart';
import '../../core/jellyfin/user_views_provider.dart';
import '../../core/network/offline_mode_provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../main.dart' show appStartStopwatch;
import '../../shared/widgets/widgets.dart';
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
    // `select` keeps this screen from rebuilding on every bridgeServices
    // state transition — only the pluginInstalled flag matters here.
    final pluginMissing = ref.watch(
      bridgeServicesProvider.select(
        (a) => a.valueOrNull?.pluginInstalled == false,
      ),
    );
    final sectionsAsync = ref.watch(homeSectionsControllerProvider);
    if (!_homePaintLogged && sectionsAsync.hasValue) {
      _homePaintLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint(
          '[perf] home_painted: ${appStartStopwatch.elapsedMilliseconds}ms',
        );
      });
    }

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
                // Status-bar inset + room for the floating search/syncplay
                // cluster (48px touch target below `topInset + sm`). The
                // full-bleed hero used to absorb the notch; this spacer
                // replaces it now that the first rail leads the scroll view.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: topInset + AppSpacing.sm + 48 + AppSpacing.md,
                  ),
                ),
                if (pluginMissing)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: _PluginMissingBanner(),
                    ),
                  ),

                // ── Sections ────────────────────────────────────────────────
                // No global loading skeleton — each rail manages its own
                // placeholder. Showing one full-width skeleton here while we
                // wait for the (lightweight) catalog/userViews resolution
                // produces a visible "loading screen" feel; an empty body is
                // better since the first rail typically lands within 100ms.
                //
                // SliverList + builder delegate so sections are built (and
                // their providers watched, hence their network fetches
                // started) lazily as they approach the viewport — a
                // SliverToBoxAdapter per section used to mount every Seerr
                // rail at the first frame and fire ~25 below-the-fold
                // requests during cold start.
                // skipLoadingOnReload: the catalog re-emits once when the
                // reco seeds land (and on pull-to-refresh) — without it the
                // transient AsyncLoading would blank the whole section list
                // for a frame before repainting.
                ...sectionsAsync.when(
                  skipLoadingOnReload: true,
                  loading: () => const <Widget>[],
                  error: (_, __) => const <Widget>[],
                  data: (state) => [
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == state.visible.length) {
                          return _ExhaustedFooter();
                        }
                        final section = state.visible[index];
                        return KeyedSubtree(
                          key: ValueKey(section.id),
                          child: HomeSectionView(section: section),
                        );
                      }, childCount: state.visible.length + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subtle film-grain overlay.
          const Positioned.fill(child: JfGrainOverlay(opacity: 0.035)),

          // Floating top-right cluster — SyncPlay (desktop only) + Search.
          // Both buttons share the same translucent-black background so they
          // read as a coherent action group over the scrolling content.
          Positioned(
            top: topInset + AppSpacing.sm,
            right: AppSpacing.lg,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: const SyncPlayButton(color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.xs),
                Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    tooltip: context.l10n.homeSearch,
                    onPressed: () => context.go('/search'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
