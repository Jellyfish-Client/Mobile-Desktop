import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/breakpoints.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/seerr/models.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '_format.dart';
import 'widgets/cast_row.dart';
import 'widgets/detail_chrome.dart';
import 'widgets/jellyfin_similar_row.dart';
import 'widgets/seerr_recommendations_row.dart';

class MovieDetailView extends ConsumerWidget {
  const MovieDetailView({required this.item, super.key});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);

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
                  runtime: formatRuntime(item.runTimeTicks),
                  officialRating: item.officialRating,
                  communityRating: item.communityRating,
                  genres: item.genres,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              JfReadingPanel(
                maxWidth: 700,
                child: _MovieActions(item: item),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (item.overview != null && item.overview!.isNotEmpty) ...[
                JfReadingPanel(
                  maxWidth: 700,
                  child: SynopsisExpander(text: item.overview!),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              JfReadingPanel(maxWidth: 700, child: _MovieFacts(item: item)),
              const SizedBox(height: AppSpacing.xxl),
              JfReadingPanel(maxWidth: 1100, child: CastRow(item: item)),
              const SizedBox(height: AppSpacing.lg),
              JfReadingPanel(
                maxWidth: 1100,
                child: JellyfinSimilarRow(itemId: item.id),
              ),
              if (tmdb != null) ...[
                const SizedBox(height: AppSpacing.lg),
                JfReadingPanel(
                  maxWidth: 1100,
                  child: SeerrRecommendationsRow(
                    tmdbId: tmdb,
                    type: SeerrMediaType.movie,
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

class _MovieActions extends ConsumerWidget {
  const _MovieActions({required this.item});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hasResume = item.hasResumePosition;
    final playLabel = hasResume ? l.detailsResume : l.detailsPlay;
    final resumeCaption = hasResume
        ? l.detailsResumeFrom(formatRuntime(item.playbackPositionTicks))
        : null;
    return ActionCluster(
      primaryLabel: playLabel,
      primaryIcon: Icons.play_arrow_rounded,
      onPrimary: () => context.push('/play/${item.id}'),
      progress: item.resumeProgress,
      resumeCaption: resumeCaption,
      secondaries: [
        ActionChipSpec(
          icon: Icons.add_rounded,
          label: l.detailsAddToList,
          onTap: () {},
        ),
        ActionChipSpec.custom(
          builder: (_) => DownloadIconButton(itemId: item.id),
          label: l.downloadButtonDownload,
        ),
        ActionChipSpec(
          icon: (item.played ?? false)
              ? Icons.check_circle_rounded
              : Icons.check_rounded,
          label: l.detailsWatched,
          active: item.played ?? false,
          onTap: () {},
        ),
      ],
    );
  }
}

class _MovieFacts extends StatelessWidget {
  const _MovieFacts({required this.item});

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
