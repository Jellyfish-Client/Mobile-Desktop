import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/seerr/models.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../shared/widgets/widgets.dart';
import '../../details/widgets/seerr_request_sheet.dart';
import '../home_providers.dart';
import '../home_section.dart';

class JfSpotlightInsert extends ConsumerWidget {
  const JfSpotlightInsert({required this.source, this.index = 0, super.key});

  final SeerSource source;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = _watchProvider(ref);
    final client = ref.watch(seerrClientProvider);

    return async.when(
      loading: () => const _SkeletonSpotlight(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty || index >= items.length) {
          return const SizedBox.shrink();
        }
        final m = items[index];
        final backdropUrl = client.backdropUrl(m);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: JfSpotlightCard(
            title: m.title,
            imageUrl: backdropUrl,
            year: m.year,
            tagline: m.overview,
            width: double.infinity,
            onTap: () => showSeerrRequestSheet(context, media: m),
          ),
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
}

class _SkeletonSpotlight extends StatelessWidget {
  const _SkeletonSpotlight();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }
}
