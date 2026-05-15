import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/breakpoints.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/seerr/models.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '../downloads/widgets/download_button.dart';
import '_format.dart';
import 'widgets/cast_row.dart';
import 'widgets/jellyfin_similar_row.dart';
import 'widgets/seerr_recommendations_row.dart';
import 'widgets/studios_row.dart';

class MovieDetailView extends ConsumerWidget {
  const MovieDetailView({required this.item, super.key});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);

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
            actions: [CastButton(itemId: item.id, color: Colors.white)],
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
                child: _MovieBody(item: item),
              ),
              const SizedBox(height: AppSpacing.lg),
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

/// Vertical layout on phone, two-column poster+text layout on desktop.
class _MovieBody extends ConsumerWidget {
  const _MovieBody({required this.item});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= 900) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: _Actions(item: item)),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: _Metadata(item: item)),
                ],
              ),
            ),
          );
        }
        return JfReadingPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Metadata(item: item),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: _Actions(item: item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.item});

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
            if (item.runTimeTicks != null && item.runTimeTicks! > 0)
              JfChip(label: formatRuntime(item.runTimeTicks)),
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

class _Actions extends StatelessWidget {
  const _Actions({required this.item});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = item.resumeProgress;
    final l = context.l10n;
    final playLabel = item.hasResumePosition
        ? '${l.detailsResume} — ${formatRuntime(item.playbackPositionTicks)}'
        : l.detailsPlay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JfButton.primary(
          label: playLabel,
          icon: Icons.play_arrow,
          fullWidth: true,
          size: JfButtonSize.lg,
          onPressed: () => context.push('/play/${item.id}'),
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
        ],
        const SizedBox(height: AppSpacing.sm),
        DownloadButton(itemId: item.id, fullWidth: true),
      ],
    );
  }
}
