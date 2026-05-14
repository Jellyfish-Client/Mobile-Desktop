import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/app_database.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/jf_section_title.dart';
import 'offline_home_providers.dart';

class OfflineHomeScreen extends ConsumerWidget {
  const OfflineHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(offlineMoviesProvider).valueOrNull ?? const [];
    final series =
        ref.watch(offlineSeriesGroupsProvider).valueOrNull ?? const [];

    final empty = movies.isEmpty && series.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.homeOffline),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: empty
          ? EmptyState(
              icon: Icons.cloud_off,
              title: context.l10n.homeOfflineNoDownloads,
              message: context.l10n.homeOfflineNoDownloadsMessage,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                const _OfflineBanner(),
                if (series.isNotEmpty) ...[
                  _SectionTitle(title: context.l10n.homeOfflineSeriesDownloaded),
                  _SeriesRail(series: series),
                ],
                if (movies.isNotEmpty) ...[
                  _SectionTitle(title: context.l10n.homeOfflineMoviesDownloaded),
                  _MoviesGrid(movies: movies),
                ],
              ],
            ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              context.l10n.homeOfflineBanner,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: JfSectionTitle(title: title),
    );
  }
}

class _SeriesRail extends StatelessWidget {
  const _SeriesRail({required this.series});

  final List<OfflineSeriesGroup> series;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemBuilder: (_, i) {
          final g = series[i];
          return _LocalPosterCard(
            title: g.seriesName,
            subtitle: context.l10n.homeOfflineEpisodeCount(g.episodeCount),
            posterPath: g.posterPath ?? g.episodes.first.imagePath,
            width: 130,
            onTap: () => context.push(
              '/offline/series/${g.seriesId}?name=${Uri.encodeComponent(g.seriesName)}',
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemCount: series.length,
      ),
    );
  }
}

class _MoviesGrid extends StatelessWidget {
  const _MoviesGrid({required this.movies});

  final List<DownloadRow> movies;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 2 / 3.4,
      ),
      itemCount: movies.length,
      itemBuilder: (_, i) {
        final m = movies[i];
        return _LocalPosterCard(
          title: m.name,
          subtitle: m.productionYear?.toString(),
          posterPath: m.imagePath,
          onTap: () => context.push('/items/${m.itemId}'),
        );
      },
    );
  }
}

/// Poster card backed by a local image file (not a network URL).
class _LocalPosterCard extends StatelessWidget {
  const _LocalPosterCard({
    required this.title,
    required this.posterPath,
    this.subtitle,
    this.width,
    this.onTap,
  });

  final String title;
  final String? posterPath;
  final String? subtitle;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(aspectRatio: 2 / 3, child: _posterImage(scheme)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }

  Widget _posterImage(ColorScheme scheme) {
    final path = posterPath;
    if (path != null) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(scheme),
      );
    }
    return _placeholder(scheme);
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_outlined,
        color: scheme.onSurfaceVariant,
        size: 32,
      ),
    );
  }
}
