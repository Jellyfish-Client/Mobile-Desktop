import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/breakpoints.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../shared/widgets/widgets.dart';
import '../home_providers.dart';
import '../home_section.dart';
import 'jellyfin_rail.dart';

/// Genre-as-tiles rail backed by `/discover/genreslider/{movie|tv}`. Each
/// tile shows the genre name layered over a TMDB backdrop pulled from the
/// slider payload. Tapping a tile drills into `discoverMoviesByGenre` /
/// `discoverTvByGenre` (handled by go_router elsewhere).
class SeerrGenreSliderRail extends ConsumerWidget {
  const SeerrGenreSliderRail({required this.section, super.key});

  final HomeSeerGenreSlider section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = section.kind == HomeSeerGenreSliderKind.movies
        ? ref.watch(seerrGenreSliderMoviesProvider)
        : ref.watch(seerrGenreSliderTvProvider);
    final client = ref.watch(seerrClientProvider);

    return async.when(
      loading: () => const SkeletonRail(),
      error: (_, __) => const SizedBox.shrink(),
      data: (slides) {
        if (slides.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JfRailHeader(eyebrow: section.eyebrow, title: section.title),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final cardWidth = Breakpoints.landscapeCardWidth(width);
                final rowHeight = cardWidth * 9 / 16;
                return SizedBox(
                  height: rowHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: slides.length,
                    itemBuilder: (context, i) {
                      final g = slides[i];
                      final url = client.genreBackdropUrl(g);
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: _GenreTile(
                          name: g.name,
                          imageUrl: url,
                          width: cardWidth,
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
}

class _GenreTile extends StatelessWidget {
  const _GenreTile({
    required this.name,
    required this.imageUrl,
    required this.width,
  });

  final String name;
  final String? imageUrl;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: scheme.surfaceContainerHigh),
                errorWidget: (_, __, ___) =>
                    Container(color: scheme.surfaceContainerHigh),
              )
            else
              Container(color: scheme.surfaceContainerHigh),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.display(
                    size: 22,
                    weight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
