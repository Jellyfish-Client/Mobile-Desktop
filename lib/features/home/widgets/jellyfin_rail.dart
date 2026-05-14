import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/breakpoints.dart';
import '../../../core/jellyfin/jellyfin_url_service.dart';
import '../../../core/jellyfin/mappers/base_item_dto_mapper.dart';
import '../../../core/jellyfin/models/jellyfin_item.dart';
import '../../../core/recommender/recommendation_rail.dart';
import '../../../shared/widgets/widgets.dart';
import '../home_section.dart';

/// Maps a list of DTOs coming out of the recommender (which still lives on
/// the SDK type) into the domain model consumed by the rail widgets. Items
/// without an id become `null` so the existing placeholder-aware layouts
/// keep working unchanged.
List<JellyfinItem?> _toDomainItems(List<BaseItemDto> dtos) {
  return [for (final dto in dtos) dto.toDomain()];
}

/// Dispatches to the correct row widget based on rail id/style.
class RailShell extends StatelessWidget {
  const RailShell({
    required this.index,
    required this.rail,
    required this.urls,
    super.key,
  });

  final int index;
  final RecommendationRail rail;
  final JellyfinUrlService urls;

  @override
  Widget build(BuildContext context) {
    final eyebrow = (index + 1).toString().padLeft(2, '0');
    final items = _toDomainItems(rail.items);
    final body = switch (rail.id) {
      'continue' || 'next_up' => LandscapeRow(items: items, urls: urls),
      'pour_vous' => SpotlightRow(items: items, urls: urls),
      'pepites' => EditorialRow(items: items, urls: urls),
      'vite_vu' => PosterRow(
        items: items,
        urls: urls,
        showProgress: false,
        dense: true,
      ),
      _ => PosterRow(items: items, urls: urls, showProgress: rail.showProgress),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JfRailHeader(
          eyebrow: eyebrow,
          title: rail.title,
          subtitle: rail.reason?.label ?? rail.subtitle,
        ),
        body,
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Dispatches to the correct row widget based on a [HomeJellyfinRail] style.
///
/// Accepts items as the already-mapped domain list so callers (recommender
/// rails on DTOs, library rails already on domain) can both feed the same
/// shell without going through a [RecommendationRail] wrapper.
class RailShellFromSection extends StatelessWidget {
  const RailShellFromSection({
    required this.section,
    required this.items,
    required this.urls,
    this.subtitle,
    this.showProgress = false,
    super.key,
  });

  final HomeJellyfinRail section;
  final List<JellyfinItem?> items;
  final JellyfinUrlService urls;

  /// Pre-resolved subtitle from the source rail (e.g.
  /// `rail.reason?.label ?? rail.subtitle`). `section.subtitle` still wins
  /// when set.
  final String? subtitle;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final body = switch (section.style) {
      RailStyle.landscape => LandscapeRow(items: items, urls: urls),
      RailStyle.spotlightRow => SpotlightRow(items: items, urls: urls),
      RailStyle.editorial => EditorialRow(items: items, urls: urls),
      RailStyle.posterDense => PosterRow(
        items: items,
        urls: urls,
        showProgress: false,
        dense: true,
      ),
      RailStyle.posterStandard => PosterRow(
        items: items,
        urls: urls,
        showProgress: showProgress,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JfRailHeader(
          title: section.title,
          subtitle: section.subtitle ?? subtitle,
        ),
        body,
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class SpotlightRow extends StatelessWidget {
  const SpotlightRow({required this.items, required this.urls, super.key});

  final List<JellyfinItem?> items;
  final JellyfinUrlService urls;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardWidth = Breakpoints.posterCardWidth(width);
        final spotlightWidth = (width * 0.78).clamp(260.0, 520.0);
        final spotlightHeight = spotlightWidth * 10 / 16;
        final rowHeight = [
          Breakpoints.posterCardTotalHeight(cardWidth, text),
          spotlightHeight,
        ].reduce((a, b) => a > b ? a : b);
        return SizedBox(
          height: rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              if (item == null) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: JfPosterCard(
                      title: '',
                      imageUrl: null,
                      width: cardWidth,
                    ),
                  ),
                );
              }
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: JfSpotlightCard(
                      title: item.name ?? '',
                      tagline: item.overview,
                      year: item.productionYear,
                      runtimeMinutes: item.runTimeTicks == null
                          ? null
                          : (item.runTimeTicks! ~/ 600000000),
                      imageUrl: urls.landscapeUrl(item, maxWidth: 720),
                      width: spotlightWidth,
                      onTap: () => context.push('/items/${item.id}'),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: JfPosterCard(
                    title: item.name ?? '',
                    imageUrl: urls.imageUrl(item, maxWidth: 240),
                    subtitle: item.productionYear?.toString(),
                    width: cardWidth,
                    onTap: () => context.push('/items/${item.id}'),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class EditorialRow extends StatelessWidget {
  const EditorialRow({required this.items, required this.urls, super.key});

  final List<JellyfinItem?> items;
  final JellyfinUrlService urls;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardWidth = Breakpoints.posterCardWidth(width);
        final rowHeight = Breakpoints.editorialRowHeight(width, text);
        return SizedBox(
          height: rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              if (item == null) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: JfEditorialCard(
                    title: '',
                    imageUrl: null,
                    width: cardWidth,
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: JfEditorialCard(
                  title: item.name ?? '',
                  tagline: item.communityRating == null
                      ? null
                      : '★ ${item.communityRating!.toStringAsFixed(1)}',
                  imageUrl: urls.imageUrl(item, maxWidth: 360),
                  width: cardWidth,
                  onTap: () => context.push('/items/${item.id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class LandscapeRow extends StatelessWidget {
  const LandscapeRow({required this.items, required this.urls, super.key});

  final List<JellyfinItem?> items;
  final JellyfinUrlService urls;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardWidth = Breakpoints.landscapeCardWidth(width);
        final rowHeight = cardWidth * 9 / 16;
        return SizedBox(
          height: rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              if (item == null) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: JfLandscapeCard(
                    title: '',
                    imageUrl: null,
                    width: cardWidth,
                  ),
                );
              }
              final progress = item.resumeProgress ?? 0.0;
              final url = urls.landscapeUrl(item, maxWidth: 600);
              final subtitle = item.seriesName != null
                  ? 'S${item.parentIndexNumber ?? 0} · E${item.indexNumber ?? 0}'
                        .toUpperCase()
                  : null;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: JfLandscapeCard(
                  title: item.seriesName ?? item.name ?? '',
                  subtitle: subtitle,
                  imageUrl: url,
                  progress: progress,
                  width: cardWidth,
                  onTap: () => context.push('/items/${item.id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class PosterRow extends StatelessWidget {
  const PosterRow({
    required this.items,
    required this.urls,
    required this.showProgress,
    this.dense = false,
    super.key,
  });

  final List<JellyfinItem?> items;
  final JellyfinUrlService urls;
  final bool showProgress;

  /// Renders denser/smaller posters — used for "vite_vu" style rails.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final base = Breakpoints.posterCardWidth(width);
        final cardWidth = dense ? (base * 0.78).clamp(88.0, 128.0) : base;
        final rowHeight = Breakpoints.posterCardTotalHeight(cardWidth, text);
        return SizedBox(
          height: rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item == null) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: JfPosterCard(title: '', width: cardWidth),
                );
              }

              final progress = showProgress
                  ? (item.resumeProgress ?? 0.0)
                  : null;

              final url = urls.imageUrl(item, maxWidth: 300);

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: JfPosterCard(
                  title: item.name ?? '',
                  imageUrl: url,
                  subtitle: item.productionYear?.toString(),
                  progress: progress,
                  width: cardWidth,
                  onTap: () => context.push('/items/${item.id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SkeletonRail extends StatelessWidget {
  const SkeletonRail({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const JfRailHeader(title: ''),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = Breakpoints.posterCardWidth(width);
            final rowHeight = Breakpoints.posterCardTotalHeight(
              cardWidth,
              text,
            );
            return SizedBox(
              height: rowHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: 6,
                itemBuilder: (context, _) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: JfPosterCard(title: '', width: cardWidth),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
