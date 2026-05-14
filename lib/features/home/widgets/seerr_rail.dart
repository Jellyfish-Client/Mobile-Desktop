import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/breakpoints.dart';
import '../../../core/seerr/models.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';
import '../../details/widgets/seerr_request_sheet.dart';
import '../home_providers.dart';
import '../home_section.dart';

class SeerRail extends ConsumerWidget {
  const SeerRail({
    required this.id,
    required this.title,
    required this.source,
    this.subtitle,
    this.eyebrow,
    super.key,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final SeerSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = _watchProvider(ref);
    final client = ref.watch(seerrClientProvider);

    return async.when(
      loading: () => _SkeletonRow(eyebrow: eyebrow, title: title),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JfRailHeader(eyebrow: eyebrow, title: title, subtitle: subtitle),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final cardWidth = Breakpoints.posterCardWidth(width);
                final rowHeight = Breakpoints.posterCardTotalHeight(
                  cardWidth,
                  Theme.of(context).textTheme,
                );
                return SizedBox(
                  height: rowHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final m = items[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: Stack(
                          children: [
                            JfPosterCard(
                              title: m.title,
                              imageUrl: client.posterUrl(m),
                              subtitle: m.year?.toString(),
                              width: cardWidth,
                              onTap: () =>
                                  showSeerrRequestSheet(context, media: m),
                            ),
                            if (m.availability != SeerrAvailability.unknown)
                              Positioned(
                                top: AppSpacing.sm,
                                left: AppSpacing.sm,
                                child: JfChip(
                                  label: _availabilityLabel(
                                    context,
                                    m.availability,
                                  ),
                                  tone: _availabilityTone(m.availability),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }

  AsyncValue<List<SeerrMedia>> _watchProvider(WidgetRef ref) {
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

  String _availabilityLabel(BuildContext context, SeerrAvailability availability) {
    final l = context.l10n;
    return switch (availability) {
      SeerrAvailability.available => l.seerrAvailabilityAvailable,
      SeerrAvailability.partiallyAvailable => l.seerrAvailabilityPartial,
      SeerrAvailability.processing => l.seerrAvailabilityProcessing,
      SeerrAvailability.pending => l.seerrAvailabilityPending,
      SeerrAvailability.unknown => '',
    };
  }

  JfChipTone _availabilityTone(SeerrAvailability availability) {
    return switch (availability) {
      SeerrAvailability.available => JfChipTone.success,
      SeerrAvailability.partiallyAvailable => JfChipTone.info,
      SeerrAvailability.processing ||
      SeerrAvailability.pending => JfChipTone.warning,
      SeerrAvailability.unknown => JfChipTone.neutral,
    };
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.title, this.eyebrow});

  final String? eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JfRailHeader(eyebrow: eyebrow, title: title),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = Breakpoints.posterCardWidth(width);
            final rowHeight = Breakpoints.posterCardTotalHeight(
              cardWidth,
              Theme.of(context).textTheme,
            );
            return SizedBox(
              height: rowHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: 6,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: JfPosterCard(title: '', width: cardWidth),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
