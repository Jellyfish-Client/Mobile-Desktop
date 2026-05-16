import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/breakpoints.dart';
import '../../core/downloads/download_manager.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '_format.dart';
import 'detail_providers.dart';
import 'widgets/cast_row.dart';
import 'widgets/detail_chrome.dart';
import 'widgets/jellyfin_similar_row.dart';
import 'widgets/missing_poster_card.dart';
import 'widgets/seerr_recommendations_row.dart';
import 'widgets/seerr_request_sheet.dart';

class SeriesDetailView extends ConsumerWidget {
  const SeriesDetailView({required this.item, super.key});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final seriesId = item.id;

    final backdropUrl = urls.imageUrl(item, type: 'Backdrop', maxWidth: 1080);

    final tmdb = item.tmdbId;

    final heroHeight = Breakpoints.detailHeroHeight(MediaQuery.sizeOf(context));
    final hInset = detailAppBarInset(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            stretch: true,
            leading: hInset > 0
                ? Padding(
                    padding: EdgeInsets.only(left: hInset),
                    child: const BackButton(color: Colors.white),
                  )
                : null,
            leadingWidth: hInset > 0 ? hInset + 56 : null,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: hInset),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SyncPlayButton(color: Colors.white),
                    CastButton(itemId: item.id, color: Colors.white),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: JfDetailHero(
                backdropUrl: backdropUrl,
                logoUrl: urls.logoUrl(item, maxWidth: 600),
                title: item.name ?? '',
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.lg),
              JfReadingPanel(
                maxWidth: 900,
                child: MetadataStrip(
                  year: item.productionYear,
                  officialRating: item.officialRating,
                  communityRating: item.communityRating,
                  genres: item.genres,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              JfReadingPanel(
                maxWidth: 700,
                child: _SeriesActions(seriesId: seriesId, series: item),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (item.overview != null && item.overview!.isNotEmpty) ...[
                JfReadingPanel(
                  maxWidth: 700,
                  child: SynopsisExpander(text: item.overview!),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              JfReadingPanel(maxWidth: 700, child: _SeriesFacts(item: item)),
              const SizedBox(height: AppSpacing.xxl),
              JfReadingPanel(
                maxWidth: 1100,
                child: _SeasonsAndEpisodes(seriesId: seriesId),
              ),

              if (tmdb != null) ...[
                const SizedBox(height: AppSpacing.lg),
                JfReadingPanel(
                  maxWidth: 1100,
                  child: _MissingSeasonsRow(
                    seriesId: seriesId,
                    tmdbId: tmdb,
                    seriesItem: item,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),
              JfReadingPanel(maxWidth: 1100, child: CastRow(item: item)),

              const SizedBox(height: AppSpacing.lg),
              JfReadingPanel(
                maxWidth: 1100,
                child: JellyfinSimilarRow(itemId: seriesId),
              ),
              if (tmdb != null) ...[
                const SizedBox(height: AppSpacing.lg),
                JfReadingPanel(
                  maxWidth: 1100,
                  child: SeerrRecommendationsRow(
                    tmdbId: tmdb,
                    type: SeerrMediaType.tv,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxxl),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Smart Play/Resume cluster for the series page. The pill resolves to the
/// next-up episode (resumable or first unwatched) and falls back to a
/// disabled "No episodes" pill while loading or when the series is empty.
class _SeriesActions extends ConsumerWidget {
  const _SeriesActions({required this.seriesId, required this.series});

  final String seriesId;
  final JellyfinItem series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextUpAsync = ref.watch(seriesNextUpProvider(seriesId));
    final l = context.l10n;

    return nextUpAsync.when(
      loading: () => ActionCluster(
        primaryLabel: l.detailsPlay,
        primaryIcon: Icons.play_arrow_rounded,
        onPrimary: null,
        secondaries: _secondaries(context, ref),
      ),
      error: (_, __) => ActionCluster(
        primaryLabel: l.detailsPlay,
        primaryIcon: Icons.play_arrow_rounded,
        onPrimary: null,
        secondaries: _secondaries(context, ref),
      ),
      data: (ep) {
        if (ep == null) {
          return ActionCluster(
            primaryLabel: l.detailsNoEpisodes,
            primaryIcon: Icons.play_arrow_rounded,
            onPrimary: null,
            secondaries: _secondaries(context, ref),
          );
        }
        final code = formatEpisodeCode(ep);
        final isResume = ep.hasResumePosition;
        final verb = isResume ? l.detailsResume : l.detailsPlay;
        final caption = code.isEmpty
            ? (ep.name ?? '')
            : '$code — ${ep.name ?? ''}';
        return ActionCluster(
          primaryLabel: verb,
          primaryIcon: Icons.play_arrow_rounded,
          onPrimary: () => context.push('/play/${ep.id}'),
          progress: ep.resumeProgress,
          resumeCaption: caption,
          secondaries: _secondaries(context, ref),
        );
      },
    );
  }

  List<ActionChipSpec> _secondaries(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return [
      ActionChipSpec(
        icon: Icons.add_rounded,
        label: l.detailsAddToList,
        onTap: () {},
      ),
      ActionChipSpec.custom(
        builder: (_) => DownloadIconButton(itemId: series.id),
        label: l.downloadButtonDownload,
      ),
      ActionChipSpec(
        icon: (series.played ?? false)
            ? Icons.check_circle_rounded
            : Icons.check_rounded,
        label: l.detailsWatched,
        active: series.played ?? false,
        onTap: () {},
      ),
    ];
  }
}

class _SeriesFacts extends StatelessWidget {
  const _SeriesFacts({required this.item});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = <(String, String)>[
      if (item.studios.isNotEmpty)
        (
          l.detailsStudios,
          [
            for (final s in item.studios)
              if (s.name != null && s.name!.isNotEmpty) s.name!,
          ].join(' · '),
        ),
      if (item.premiereDate != null)
        (l.detailsReleaseDate, formatAirDate(item.premiereDate)),
      if (item.officialRating != null && item.officialRating!.isNotEmpty)
        (l.detailsOfficialRating, item.officialRating!),
      if (item.genres.isNotEmpty) (l.detailsGenres, item.genres.join(' · ')),
    ];
    return FactList(rows: rows);
  }
}

/// Season selector + episode list. Switches between a pill row (≤5 seasons)
/// and a dropdown menu (6+) to keep the header compact for long-running
/// shows.
class _SeasonsAndEpisodes extends ConsumerWidget {
  const _SeasonsAndEpisodes({required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsProvider(seriesId));
    final nextUpAsync = ref.watch(seriesNextUpProvider(seriesId));

    return seasonsAsync.when(
      loading: () => const SizedBox(height: 220, child: JfLoading()),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        if (seasons.isEmpty) return const SizedBox.shrink();

        final selected = ref.watch(selectedSeasonProvider(seriesId));
        if (selected == null) {
          if (nextUpAsync.isLoading) {
            return const SizedBox(height: 220, child: JfLoading());
          }
          final defaultId =
              nextUpAsync.valueOrNull?.seasonId ?? seasons.first.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            ref.read(selectedSeasonProvider(seriesId).notifier).state =
                defaultId;
          });
          return const SizedBox(height: 220, child: JfLoading());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    context.l10n.detailsEpisodes.toUpperCase(),
                    style: AppTypography.eyebrow(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  _SeasonControl(
                    seasons: seasons,
                    selectedId: selected,
                    onSelect: (id) => ref
                        .read(selectedSeasonProvider(seriesId).notifier)
                        .state = id,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.download_outlined),
                    tooltip: context.l10n.detailsDownloadSeason,
                    onPressed: () => ref
                        .read(downloadManagerProvider)
                        .enqueueSeason(seriesId: seriesId, seasonId: selected),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _EpisodesList(
              seriesId: seriesId,
              seasonId: selected,
              nextUpId: nextUpAsync.valueOrNull?.id,
            ),
          ],
        );
      },
    );
  }
}

class _SeasonControl extends StatelessWidget {
  const _SeasonControl({
    required this.seasons,
    required this.selectedId,
    required this.onSelect,
  });

  final List<JellyfinItem> seasons;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (seasons.length <= 5) {
      return _SeasonPillRow(
        seasons: seasons,
        selectedId: selectedId,
        onSelect: onSelect,
      );
    }
    return _SeasonDropdown(
      seasons: seasons,
      selectedId: selectedId,
      onSelect: onSelect,
    );
  }
}

class _SeasonPillRow extends StatelessWidget {
  const _SeasonPillRow({
    required this.seasons,
    required this.selectedId,
    required this.onSelect,
  });

  final List<JellyfinItem> seasons;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: seasons.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, i) {
            final season = seasons[i];
            final id = season.id;
            final isSelected = id == selectedId;
            final shape = RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              side: BorderSide(
                color: isSelected
                    ? scheme.onSurface
                    : scheme.outline.withValues(alpha: 0.6),
              ),
            );
            return AnimatedContainer(
              duration: AppMotion.fast,
              decoration: ShapeDecoration(
                shape: shape,
                color: isSelected ? scheme.onSurface : Colors.transparent,
              ),
              child: Material(
                color: Colors.transparent,
                shape: shape,
                child: InkWell(
                  onTap: () => onSelect(id),
                  customBorder: shape,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md + 2,
                      vertical: AppSpacing.xs + 2,
                    ),
                    child: Center(
                      child: Text(
                        _shortName(context, season),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? scheme.surface
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _shortName(BuildContext context, JellyfinItem season) {
    final n = season.indexNumber;
    if (n != null) return 'S$n';
    return season.name ?? '?';
  }
}

class _SeasonDropdown extends StatelessWidget {
  const _SeasonDropdown({
    required this.seasons,
    required this.selectedId,
    required this.onSelect,
  });

  final List<JellyfinItem> seasons;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = seasons.firstWhere(
      (s) => s.id == selectedId,
      orElse: () => seasons.first,
    );
    return PopupMenuButton<String>(
      tooltip: '',
      initialValue: selectedId,
      onSelected: onSelect,
      offset: const Offset(0, 40),
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
      ),
      itemBuilder: (context) => [
        for (final s in seasons)
          PopupMenuItem<String>(
            value: s.id,
            child: Text(
              s.name ?? context.l10n.detailsSeason(s.indexNumber ?? 0),
              style: theme.textTheme.bodyMedium,
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 2,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected.name ??
                  context.l10n.detailsSeason(selected.indexNumber ?? 0),
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodesList extends ConsumerWidget {
  const _EpisodesList({
    required this.seriesId,
    required this.seasonId,
    required this.nextUpId,
  });

  final String seriesId;
  final String seasonId;
  final String? nextUpId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(
      episodesProvider((seriesId: seriesId, seasonId: seasonId)),
    );
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return episodesAsync.when(
      loading: () => const SizedBox(height: 200, child: JfLoading()),
      error: (_, __) => const SizedBox.shrink(),
      data: (episodes) {
        if (episodes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Text(
              context.l10n.detailsNoEpisodesInSeason,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return AnimatedSwitcher(
          duration: AppMotion.medium,
          switchInCurve: AppMotion.standard,
          switchOutCurve: AppMotion.standard,
          child: ListView.separated(
            key: ValueKey(seasonId),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            itemCount: episodes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final ep = episodes[index];
              final isNextUp = ep.id == nextUpId;
              final continueLabel = ep.hasResumePosition
                  ? context.l10n.detailsContinue
                  : context.l10n.detailsNextUp;
              return JfEpisodeTile(
                title: ep.name ?? '',
                episodeNumber: ep.indexNumber,
                imageUrl: urls.landscapeUrl(ep, maxWidth: 320),
                runtime: formatRuntime(ep.runTimeTicks),
                overview: ep.overview,
                progress: ep.resumeProgress,
                watched: ep.played ?? false,
                nextUp: isNextUp,
                nextUpLabel: isNextUp ? continueLabel : null,
                onTap: () => context.push('/items/${ep.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _MissingSeasonsRow extends ConsumerWidget {
  const _MissingSeasonsRow({
    required this.seriesId,
    required this.tmdbId,
    required this.seriesItem,
  });

  final String seriesId;
  final int tmdbId;
  final JellyfinItem seriesItem;

  SeerrMedia _seriesAsSeerrMedia(SeerrAvailability seasonAvailability) {
    final passthrough =
        seasonAvailability == SeerrAvailability.pending ||
        seasonAvailability == SeerrAvailability.processing;
    return SeerrMedia(
      tmdbId: tmdbId,
      type: SeerrMediaType.tv,
      title: seriesItem.name ?? '',
      overview: seriesItem.overview,
      year: seriesItem.productionYear,
      availability: passthrough
          ? seasonAvailability
          : SeerrAvailability.unknown,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missingAsync = ref.watch(
      missingSeasonsProvider((seriesId: seriesId, tmdbId: tmdbId)),
    );
    return missingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (missing) {
        if (missing.isEmpty) return const SizedBox.shrink();
        final seerr = ref.read(seerrClientProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: JfSectionTitle(title: context.l10n.detailsMissingSeasons),
            ),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: missing.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final s = missing[i];
                  final label =
                      s.name ??
                      context.l10n.detailsMissingSeason(s.seasonNumber);
                  return SizedBox(
                    width: 120,
                    child: MissingPosterCard(
                      title: label,
                      imageUrl: seerr.seasonPosterUrl(s),
                      subtitle: s.episodeCount == null
                          ? null
                          : '${s.episodeCount} ép.',
                      availability: s.availability,
                      onTap: () async {
                        await showSeerrRequestSheet(
                          context,
                          media: _seriesAsSeerrMedia(s.availability),
                          initialSeasons: [s.seasonNumber],
                        );
                        ref.invalidate(
                          missingSeasonsProvider((
                            seriesId: seriesId,
                            tmdbId: tmdbId,
                          )),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
