import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/breakpoints.dart';
import '../../../core/upcoming/models.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';
import '../home_providers.dart';
import '../home_section.dart';

/// Rail rendering items from `/jellyfish/upcoming`. Pattern-matches on the
/// sealed [UpcomingItem] hierarchy so each variant (movie vs episode) gets a
/// dedicated subtitle (release date or `Sxx·Exx · date`).
class UpcomingRail extends ConsumerWidget {
  const UpcomingRail({required this.section, super.key});

  final HomeUpcomingRail section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = switch (section.kind) {
      HomeUpcomingKind.movies => ref.watch(bridgeUpcomingMoviesProvider),
      HomeUpcomingKind.episodes => ref.watch(bridgeUpcomingEpisodesProvider),
    };

    return async.when(
      loading: () =>
          _SkeletonRow(eyebrow: section.eyebrow, title: section.title),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JfRailHeader(
              eyebrow: section.eyebrow,
              title: section.title,
              subtitle: section.subtitle,
              action: TextButton(
                onPressed: () => context.go('/calendar'),
                child: Text(context.l10n.upcomingViewAll),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = Breakpoints.posterCardWidth(
                  constraints.maxWidth,
                );
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
                      final item = items[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: JfPosterCard(
                          title: _title(item),
                          subtitle: _subtitle(item),
                          imageUrl: item.posterUrl.isEmpty
                              ? null
                              : item.posterUrl,
                          width: cardWidth,
                          onTap: () => context.go('/calendar'),
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

  static String _title(UpcomingItem item) => switch (item) {
    UpcomingMovie(:final title) => title,
    UpcomingEpisode(:final seriesTitle) => seriesTitle,
  };

  static String _subtitle(UpcomingItem item) => switch (item) {
    UpcomingMovie(:final releaseDate) => _formatDate(releaseDate),
    UpcomingEpisode(
      :final seasonNumber,
      :final episodeNumber,
      :final releaseDate,
    ) =>
      'S${seasonNumber.toString().padLeft(2, '0')}E'
          '${episodeNumber.toString().padLeft(2, '0')} · '
          '${_formatDate(releaseDate)}',
  };

  static String _formatDate(DateTime d) {
    // Stand-alone month abbreviations in French — avoids pulling
    // `package:intl/date_symbol_data_local.dart` initialisation into the
    // app start path just for a one-line subtitle. Add more locales here
    // when we ship in another language.
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${d.day} ${months[d.month - 1]}';
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
            final cardWidth = Breakpoints.posterCardWidth(constraints.maxWidth);
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
