import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/breakpoints.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '_format.dart';
import 'detail_providers.dart';
import 'widgets/cast_row.dart';
import 'widgets/detail_chrome.dart';

class EpisodeDetailView extends ConsumerWidget {
  const EpisodeDetailView({required this.item, super.key});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;

    final stillUrl = urls.landscapeUrl(item, maxWidth: 1280);
    final size = MediaQuery.sizeOf(context);
    // 16:9 still — cap by the page height so we don't push everything below
    // the fold on tall portrait phones.
    final heroHeight = (size.width * 9 / 16).clamp(220.0, size.height * 0.55);

    final epNumber = item.indexNumber;
    final overlineText = epNumber == null
        ? null
        : l.detailsEpisodeOverline(epNumber.toString().padLeft(2, '0'));
    final hasSeriesContext =
        item.seriesName != null && item.seriesId != null;
    final hInset = detailAppBarInset(context);
    // Push the hero breadcrumb to the right of the leading back arrow so the
    // two don't overlap in the top-left corner. 56dp is the default leading
    // width on Material 3 toolbars; we add a small gap on top.
    final breadcrumbInset = hInset + 56 + AppSpacing.xs;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
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
                backdropUrl: stillUrl,
                title: item.name ?? '',
                useTitleFallback: false,
                breadcrumbInset: breadcrumbInset,
                breadcrumb: hasSeriesContext
                    ? _BackBreadcrumb(
                        seriesId: item.seriesId!,
                        seriesName: item.seriesName!,
                      )
                    : null,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.lg),
              if (overlineText != null) ...[
                Center(
                  child: Text(
                    overlineText,
                    style: AppTypography.eyebrow(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              JfReadingPanel(
                maxWidth: 900,
                child: Text(
                  item.name ?? '',
                  textAlign: TextAlign.center,
                  style: AppTypography.display(
                    size: size.width < 600 ? 30 : 38,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              JfReadingPanel(
                maxWidth: 900,
                child: MetadataStrip(
                  episodeCode: formatEpisodeCode(item),
                  runtime: formatRuntime(item.runTimeTicks),
                  airDate: formatAirDate(item.premiereDate),
                  communityRating: item.communityRating,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              JfReadingPanel(
                maxWidth: 700,
                child: _EpisodeActions(item: item),
              ),
              if (item.seriesId != null && item.seasonId != null) ...[
                const SizedBox(height: AppSpacing.lg),
                JfReadingPanel(
                  maxWidth: 700,
                  child: _EpisodeNavRow(
                    seriesId: item.seriesId!,
                    seasonId: item.seasonId!,
                    currentId: item.id,
                    wide: Breakpoints.isDesktop(size.width) ||
                        Breakpoints.isTablet(size.width),
                  ),
                ),
              ],
              if (item.overview != null && item.overview!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                JfReadingPanel(
                  maxWidth: 700,
                  child: SynopsisExpander(text: item.overview!),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              JfReadingPanel(maxWidth: 1100, child: CastRow(item: item)),
              const SizedBox(height: AppSpacing.xxxl),
            ]),
          ),
        ],
      ),
    );
  }
}

class _BackBreadcrumb extends StatelessWidget {
  const _BackBreadcrumb({required this.seriesId, required this.seriesName});

  final String seriesId;
  final String seriesName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: () {
        // Prefer popping back to the series page if it's the previous route,
        // otherwise navigate fresh. Avoids piling identical pages onto the
        // stack when the user came in via "next episode".
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/items/$seriesId');
        }
      },
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_rounded, size: 14, color: scheme.onSurface),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              seriesName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeActions extends ConsumerWidget {
  const _EpisodeActions({required this.item});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hasResume = item.hasResumePosition;
    final label = hasResume ? l.detailsResume : l.detailsPlay;
    final caption = hasResume
        ? l.detailsResumeFrom(formatRuntime(item.playbackPositionTicks))
        : null;
    return ActionCluster(
      primaryLabel: label,
      primaryIcon: Icons.play_arrow_rounded,
      onPrimary: () => context.push('/play/${item.id}'),
      progress: item.resumeProgress,
      resumeCaption: caption,
      secondaries: [
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

class _EpisodeNavRow extends ConsumerWidget {
  const _EpisodeNavRow({
    required this.seriesId,
    required this.seasonId,
    required this.currentId,
    required this.wide,
  });

  final String seriesId;
  final String seasonId;
  final String currentId;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(
      episodesProvider((seriesId: seriesId, seasonId: seasonId)),
    );
    return episodesAsync.maybeWhen(
      data: (episodes) {
        if (episodes.isEmpty) return const SizedBox.shrink();
        final idx = episodes.indexWhere((e) => e.id == currentId);
        if (idx < 0) return const SizedBox.shrink();
        final prev = idx > 0 ? episodes[idx - 1] : null;
        final next = idx < episodes.length - 1 ? episodes[idx + 1] : null;

        if (wide) {
          return Row(
            children: [
              Expanded(
                child: _NavLink(
                  direction: _NavDirection.previous,
                  episode: prev,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _NavLink(
                  direction: _NavDirection.next,
                  episode: next,
                ),
              ),
            ],
          );
        }
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

enum _NavDirection { previous, next }

class _NavLink extends StatefulWidget {
  const _NavLink({required this.direction, required this.episode});

  final _NavDirection direction;
  final JellyfinItem? episode;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final enabled = widget.episode != null;
    final isPrev = widget.direction == _NavDirection.previous;
    final titleColor = enabled
        ? (_hovering ? scheme.onSurface : scheme.onSurfaceVariant)
        : scheme.onSurfaceVariant.withValues(alpha: 0.4);
    final caption = isPrev ? l.detailsPreviousEpisode : l.detailsNextEpisode;
    final title = widget.episode?.name ?? '—';

    final col = Column(
      crossAxisAlignment: isPrev
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPrev) ...[
              Icon(Icons.arrow_back_rounded, size: 14, color: titleColor),
              const SizedBox(width: 4),
            ],
            Text(
              caption.toUpperCase(),
              style: AppTypography.eyebrow(color: titleColor),
            ),
            if (!isPrev) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14, color: titleColor),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedDefaultTextStyle(
          duration: AppMotion.fast,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w600,
            decoration: enabled && _hovering
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: titleColor,
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isPrev ? TextAlign.start : TextAlign.end,
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) setState(() => _hovering = true);
      },
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: enabled
            ? () => context.replace('/items/${widget.episode!.id}')
            : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: col,
        ),
      ),
    );
  }
}
