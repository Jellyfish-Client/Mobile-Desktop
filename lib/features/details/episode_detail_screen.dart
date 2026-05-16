import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '../downloads/widgets/download_button.dart';
import '_format.dart';
import 'detail_providers.dart';
import 'widgets/cast_row.dart';
import 'widgets/studios_row.dart';

class EpisodeDetailView extends ConsumerWidget {
  const EpisodeDetailView({required this.item, super.key});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);

    final stillUrl = urls.landscapeUrl(item, maxWidth: 1080);
    final logoUrl = urls.logoUrl(item, maxWidth: 600);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
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
                backdropUrl: stillUrl,
                logoUrl: logoUrl,
                title: item.seriesName ?? item.name ?? '',
                height: 240,
                logoMaxHeight: 80,
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
                child: _EpisodeBody(item: item),
              ),
              const SizedBox(height: AppSpacing.lg),
              JfReadingPanel(maxWidth: 1100, child: CastRow(item: item)),
              const SizedBox(height: AppSpacing.xxxl),
            ]),
          ),
        ],
      ),
    );
  }
}

class _EpisodeBody extends StatelessWidget {
  const _EpisodeBody({required this.item});

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
                  SizedBox(width: 360, child: _EpisodeActions(item: item)),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: _EpisodeMetadata(item: item)),
                ],
              ),
            ),
          );
        }
        return JfReadingPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EpisodeMetadata(item: item),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: _EpisodeActions(item: item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EpisodeMetadata extends StatelessWidget {
  const _EpisodeMetadata({required this.item});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final code = formatEpisodeCode(item);
    final runtime = formatRuntime(item.runTimeTicks);
    final air = formatAirDate(item.premiereDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.seriesName != null && item.seriesId != null)
          InkWell(
            onTap: () => context.push('/items/${item.seriesId}'),
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 14,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.seriesName!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          code.isEmpty ? (item.name ?? '') : '$code — ${item.name ?? ''}',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (runtime.isNotEmpty) JfChip(label: runtime),
            if (air.isNotEmpty) JfChip(label: air),
            if (item.communityRating != null)
              JfChip(
                icon: Icons.star_rounded,
                label: item.communityRating!.toStringAsFixed(1),
                tone: JfChipTone.warning,
              ),
            if (item.played ?? false)
              JfChip(
                icon: Icons.check_rounded,
                label: context.l10n.detailsWatched,
                tone: JfChipTone.success,
              ),
          ],
        ),
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
        if (item.studios.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StudiosRow(item: item),
        ],
      ],
    );
  }
}

class _EpisodeActions extends StatelessWidget {
  const _EpisodeActions({required this.item});

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
        if (item.seriesId != null && item.seasonId != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _EpisodeNavRow(
            seriesId: item.seriesId!,
            seasonId: item.seasonId!,
            currentId: item.id,
          ),
        ],
      ],
    );
  }
}

class _EpisodeNavRow extends ConsumerWidget {
  const _EpisodeNavRow({
    required this.seriesId,
    required this.seasonId,
    required this.currentId,
  });

  final String seriesId;
  final String seasonId;
  final String currentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(
      episodesProvider((seriesId: seriesId, seasonId: seasonId)),
    );
    return episodesAsync.maybeWhen(
      data: (episodes) {
        if (episodes.isEmpty) {
          return const SizedBox.shrink();
        }
        final idx = episodes.indexWhere((e) => e.id == currentId);
        if (idx < 0) return const SizedBox.shrink();
        final prev = idx > 0 ? episodes[idx - 1] : null;
        final next = idx < episodes.length - 1 ? episodes[idx + 1] : null;

        return Row(
          children: [
            Expanded(
              child: JfButton.secondary(
                label: context.l10n.detailsPreviousEpisode,
                icon: Icons.skip_previous_rounded,
                fullWidth: true,
                onPressed: prev == null
                    ? null
                    : () => context.replace('/items/${prev.id}'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: JfButton.secondary(
                label: context.l10n.detailsNextEpisode,
                icon: Icons.skip_next_rounded,
                fullWidth: true,
                onPressed: next == null
                    ? null
                    : () => context.replace('/items/${next.id}'),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
