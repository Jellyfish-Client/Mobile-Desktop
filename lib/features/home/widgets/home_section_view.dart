import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/breakpoints.dart';
import '../../../core/jellyfin/jellyfin_url_service.dart';
import '../../../core/jellyfin/mappers/base_item_dto_mapper.dart';
import '../../../core/jellyfin/models/jellyfin_item.dart';
import '../../../core/recommender/recommendation_rail.dart';
import '../../../core/seerr/models.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../shared/widgets/widgets.dart';
import '../home_providers.dart';
import '../home_section.dart';
import 'home_section_header.dart';
import 'jellyfin_rail.dart';
import 'jf_spotlight_insert.dart';
import 'seerr_genre_slider_rail.dart';
import 'seerr_rail.dart';
import 'seerr_watch_providers_rail.dart';
import 'upcoming_rail.dart';

class HomeSectionView extends ConsumerWidget {
  const HomeSectionView({required this.section, super.key});

  final HomeSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (section) {
      HomeJellyfinRail() => _JellyfinRailSection(
        section: section as HomeJellyfinRail,
      ),
      HomeLibraryRail() => _LibraryRailSection(
        section: section as HomeLibraryRail,
      ),
      HomeSeerRail() => _buildSeerRail(section as HomeSeerRail),
      HomeMiniHero() => _MiniHeroSection(section: section as HomeMiniHero),
      HomeSpotlightInsert() => _buildSpotlightInsert(
        section as HomeSpotlightInsert,
      ),
      HomeSectionHeader() => HomeSectionHeaderWidget(
        section: section as HomeSectionHeader,
      ),
      HomeSeerGenreSlider() => SeerrGenreSliderRail(
        section: section as HomeSeerGenreSlider,
      ),
      HomeSeerWatchProviders() => SeerrWatchProvidersRail(
        section: section as HomeSeerWatchProviders,
      ),
      HomeUpcomingRail() => UpcomingRail(section: section as HomeUpcomingRail),
    };
  }

  Widget _buildSeerRail(HomeSeerRail s) {
    return SeerRail(
      id: s.id,
      title: s.title,
      subtitle: s.subtitle,
      eyebrow: s.eyebrow,
      source: s.source,
    );
  }

  Widget _buildSpotlightInsert(HomeSpotlightInsert s) {
    return JfSpotlightInsert(source: s.source, index: s.index);
  }
}

class _JellyfinRailSection extends ConsumerWidget {
  const _JellyfinRailSection({required this.section});

  final HomeJellyfinRail section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);
    // Resume / Next Up / Nouveautés bypass the recommender: they have
    // dedicated SWR providers that paint instantly from the Drift cache at
    // cold start, instead of gating on `recentlyPlayed → tasteProfile → rails`.
    if (section.id == 'continue') {
      return _SwrRail(
        section: section,
        async: ref.watch(resumeItemsProvider),
        urls: urls,
        showProgress: true,
      );
    }
    if (section.id == 'next_up') {
      return _SwrRail(
        section: section,
        async: ref.watch(nextUpItemsProvider),
        urls: urls,
      );
    }
    if (section.id == 'latest') {
      return _SwrRail(
        section: section,
        async: ref.watch(latestItemsProvider),
        urls: urls,
      );
    }
    final railsAsync = ref.watch(recommendationRailsProvider);
    return railsAsync.when(
      loading: () => const SkeletonRail(),
      error: (_, __) => const SizedBox.shrink(),
      data: (rails) {
        final rail = _findRail(rails, section.id);
        if (rail == null) return const SizedBox.shrink();
        // Map DTOs at the boundary: the recommender (core/) returns
        // [BaseItemDto] for SDK fidelity; rail widgets consume [JellyfinItem].
        // Keep `null` entries — the rail widgets render them as placeholder
        // cards. Don't use `_dtosToDomain` here: it filters nulls out.
        final items = [for (final dto in rail.items) dto.toDomain()];
        // For "Parce que vous avez aimé X" the recommender resolves the
        // source's name at fetch time and bakes it into `rail.title` — use
        // it as-is instead of the catalog's generic placeholder title.
        final renderSection = section.id == 'because_'
            ? HomeJellyfinRail(
                id: section.id,
                title: rail.title,
                style: section.style,
                subtitle: section.subtitle,
              )
            : section;
        return RailShellFromSection(
          section: renderSection,
          items: items,
          urls: urls,
          subtitle: rail.reason?.label ?? rail.subtitle,
          showProgress: rail.showProgress,
        );
      },
    );
  }

  RecommendationRail? _findRail(
    List<RecommendationRail> rails,
    String sectionId,
  ) {
    if (sectionId == 'because_') {
      return rails.where((r) => r.id.startsWith('because_')).firstOrNull;
    }
    return rails.where((r) => r.id == sectionId).firstOrNull;
  }
}

/// Renders a Jellyfin rail directly from an SWR provider snapshot. Used for
/// `continue` and `next_up` so the rail paints from disk cache without
/// waiting on the recommender chain.
class _SwrRail extends StatelessWidget {
  const _SwrRail({
    required this.section,
    required this.async,
    required this.urls,
    this.showProgress = false,
  });

  final HomeJellyfinRail section;
  final AsyncValue<List<JellyfinItem>> async;
  final JellyfinUrlService urls;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const SkeletonRail(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return RailShellFromSection(
          section: section,
          items: [for (final i in items) i],
          urls: urls,
          showProgress: showProgress,
        );
      },
    );
  }
}

class _LibraryRailSection extends ConsumerWidget {
  const _LibraryRailSection({required this.section});

  final HomeLibraryRail section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final async = ref.watch(
      latestByLibraryProvider((parentId: section.parentId, kind: section.kind)),
    );
    return async.when(
      loading: () => const SkeletonRail(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        // Library provider already returns domain items — pass through.
        // RailShellFromSection takes a HomeJellyfinRail; the library section
        // and the rail share visual shape, so we re-emit a HomeJellyfinRail
        // from the HomeLibraryRail's display fields. Adding new visual
        // fields to either type means updating this mapping too.
        return RailShellFromSection(
          section: HomeJellyfinRail(
            id: section.id,
            title: section.title,
            style: section.style,
            subtitle: section.subtitle,
          ),
          items: [for (final i in items) i],
          urls: urls,
        );
      },
    );
  }
}

class _MiniHeroSection extends ConsumerWidget {
  const _MiniHeroSection({required this.section});

  final HomeMiniHero section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(seerrClientProvider);
    final async = _watchProvider(ref, section.source);

    return async.when(
      loading: () => const _MiniHeroSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final slides = items
            .take(section.slideCount.clamp(1, 4))
            .map(
              (m) => JfHeroSlide(
                id: m.tmdbId.toString(),
                title: m.title,
                subtitle: m.overview,
                imageUrl: client.backdropUrl(m),
              ),
            )
            .toList();
        return JfMiniHeroCarousel(
          slides: slides,
          slideCount: section.slideCount,
          onSlideTap: (_) {},
        );
      },
    );
  }

  AsyncValue<List<SeerrMedia>> _watchProvider(
    WidgetRef ref,
    SeerSource source,
  ) {
    return switch (source) {
      SeerTrending() => ref.watch(seerrTrendingProvider),
      SeerPopularMovies() => ref.watch(seerrPopularMoviesProvider),
      SeerPopularSeries() => ref.watch(seerrPopularSeriesProvider),
      SeerWatchlist() => ref.watch(seerrWatchlistProvider),
      SeerSimilarToSeed(:final tmdbId, :final type) => ref.watch(
        seerrSimilarBySeedProvider((tmdbId: tmdbId, type: type)),
      ),
      SeerMood(:final id) => ref.watch(seerMoodProvider(id)),
    };
  }
}

class _MiniHeroSkeleton extends StatelessWidget {
  const _MiniHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: Breakpoints.miniHeroHeight(constraints.maxWidth),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
    );
  }
}
