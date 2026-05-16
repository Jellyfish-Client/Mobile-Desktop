import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
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
import 'widgets/jellyfin_similar_row.dart';
import 'widgets/missing_poster_card.dart';
import 'widgets/seerr_recommendations_row.dart';
import 'widgets/seerr_request_sheet.dart';
import 'widgets/studios_row.dart';

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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            stretch: true,
            actions: [
              const SyncPlayButton(color: Colors.white),
              CastButton(itemId: item.id, color: Colors.white),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: _SeriesBody(item: item),
              ),

              const SizedBox(height: AppSpacing.lg),
              JfReadingPanel(maxWidth: 1100, child: CastRow(item: item)),

              const SizedBox(height: AppSpacing.lg),
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

/// Vertical on phone, two-column actions+text layout on desktop. Mirrors
/// `_MovieBody` so the look stays consistent across detail screens.
class _SeriesBody extends StatelessWidget {
  const _SeriesBody({required this.item});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= 900) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 360, child: _NextUpCta(seriesId: item.id)),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: _SeriesMetadata(item: item)),
                ],
              ),
            ),
          );
        }
        return JfReadingPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SeriesMetadata(item: item),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: _NextUpCta(seriesId: item.id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeriesMetadata extends StatelessWidget {
  const _SeriesMetadata({required this.item});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (item.productionYear != null)
              JfChip(label: '${item.productionYear}'),
            if (item.officialRating != null && item.officialRating!.isNotEmpty)
              JfChip(label: item.officialRating!),
            if (item.communityRating != null)
              JfChip(
                icon: Icons.star_rounded,
                label: item.communityRating!.toStringAsFixed(1),
                tone: JfChipTone.warning,
              ),
          ],
        ),
        if (item.genres.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final g in item.genres)
                JfChip(label: g, tone: JfChipTone.info),
            ],
          ),
        ],
        if (item.studios.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          StudiosRow(item: item),
        ],
        if (item.overview != null && item.overview!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            item.overview!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Smart Play/Resume CTA driven by `seriesNextUpProvider`. Falls back to a
/// generic "Play" label while the next-up query is pending so the page never
/// renders without a primary action.
class _NextUpCta extends ConsumerWidget {
  const _NextUpCta({required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final nextUpAsync = ref.watch(seriesNextUpProvider(seriesId));

    final l = context.l10n;
    return nextUpAsync.when(
      loading: () => JfButton.primary(
        label: l.detailsPlay,
        icon: Icons.play_arrow,
        fullWidth: true,
        size: JfButtonSize.lg,
        loading: true,
        onPressed: null,
      ),
      error: (_, __) => JfButton.primary(
        label: l.detailsPlay,
        icon: Icons.play_arrow,
        fullWidth: true,
        size: JfButtonSize.lg,
        onPressed: null,
      ),
      data: (ep) {
        if (ep == null) {
          return JfButton.primary(
            label: l.detailsNoEpisodes,
            icon: Icons.play_arrow,
            fullWidth: true,
            size: JfButtonSize.lg,
            onPressed: null,
          );
        }
        final code = formatEpisodeCode(ep);
        final isResume = ep.hasResumePosition;
        final verb = isResume ? l.detailsResume : l.detailsPlay;
        final label = code.isEmpty
            ? '$verb — ${ep.name ?? ''}'
            : '$verb $code — ${ep.name ?? ''}';
        final progress = ep.resumeProgress;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JfButton.primary(
              label: label,
              icon: Icons.play_arrow,
              fullWidth: true,
              size: JfButtonSize.lg,
              onPressed: () => context.push('/play/${ep.id}'),
            ),
            if (progress != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: scheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(scheme.primary),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.detailsResumeFrom(formatRuntime(ep.playbackPositionTicks)),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Renders the season pill row and the episode list for the currently-
/// selected season. Defaults the selection to the season of the next-up
/// episode, falling back to the first season.
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
        // Seed selection: prefer the next-up's season, else the first one.
        // Wait until next-up has resolved (data or error) so we don't flash
        // S1 when the user actually has a resume position in a later season.
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
            JfSectionTitle(
              title: context.l10n.detailsEpisodes,
              action: IconButton(
                icon: const Icon(Icons.download_outlined),
                tooltip: context.l10n.detailsDownloadSeason,
                onPressed: () => ref
                    .read(downloadManagerProvider)
                    .enqueueSeason(seriesId: seriesId, seasonId: selected),
              ),
            ),
            _SeasonPills(
              seasons: seasons,
              selectedId: selected,
              onSelect: (id) =>
                  ref.read(selectedSeasonProvider(seriesId).notifier).state =
                      id,
            ),
            const SizedBox(height: AppSpacing.sm),
            _EpisodesList(seriesId: seriesId, seasonId: selected),
          ],
        );
      },
    );
  }
}

class _SeasonPills extends StatelessWidget {
  const _SeasonPills({
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

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: seasons.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final season = seasons[i];
          final id = season.id;
          final isSelected = id == selectedId;
          final bg = isSelected ? scheme.primary : scheme.surfaceContainerHigh;
          final fg = isSelected ? scheme.onPrimary : scheme.onSurfaceVariant;
          final shape = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          );
          return Material(
            color: bg,
            shape: shape,
            child: InkWell(
              onTap: () => onSelect(id),
              customBorder: shape,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                child: Center(
                  child: Text(
                    season.name ??
                        context.l10n.detailsSeason(season.indexNumber ?? 0),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EpisodesList extends ConsumerWidget {
  const _EpisodesList({required this.seriesId, required this.seasonId});

  final String seriesId;
  final String seasonId;

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
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: episodes.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: scheme.outlineVariant,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
          itemBuilder: (context, index) {
            final ep = episodes[index];
            return JfEpisodeTile(
              title: ep.name ?? '',
              episodeNumber: ep.indexNumber,
              imageUrl: urls.landscapeUrl(ep, maxWidth: 320),
              runtime: formatRuntime(ep.runTimeTicks),
              overview: ep.overview,
              progress: ep.resumeProgress,
              watched: ep.played ?? false,
              onTap: () => context.push('/items/${ep.id}'),
            );
          },
        );
      },
    );
  }
}

/// Horizontal row of poster cards for seasons present on TMDB but absent
/// from the user's Jellyfin library. Tap a poster to request the season via
/// Seerr. The row is hidden when there's nothing missing (or Seerr isn't
/// linked), so the section costs no vertical space in the happy path.
class _MissingSeasonsRow extends ConsumerWidget {
  const _MissingSeasonsRow({
    required this.seriesId,
    required this.tmdbId,
    required this.seriesItem,
  });

  final String seriesId;
  final int tmdbId;
  final JellyfinItem seriesItem;

  /// Builds a SeerrMedia stub from the Jellyfin series item so the existing
  /// request sheet (poster + synopsis + season picker) can be opened.
  ///
  /// The series itself is typically `partiallyAvailable` (some seasons in,
  /// some missing) — passing that verbatim would disable the submit button.
  /// We override availability to `unknown` for the requestable case, but
  /// preserve `pending`/`processing` when the tapped season is already in
  /// flight so the sheet shows "Already requested" and blocks a duplicate.
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
