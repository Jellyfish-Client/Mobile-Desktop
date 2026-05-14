import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/breakpoints.dart';
import '../../../core/jellyfin/jellyfin_url_service.dart';
import '../../../shared/widgets/widgets.dart';
import '../detail_providers.dart';

/// "More like this" rail powered by Jellyfin's `/Items/{id}/Similar` index.
/// Hides itself on empty / error so we don't show a dead section.
class JellyfinSimilarRow extends ConsumerWidget {
  const JellyfinSimilarRow({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarAsync = ref.watch(similarItemsProvider(itemId));
    final urls = ref.watch(jellyfinUrlServiceProvider);

    return similarAsync.when(
      loading: () => const SizedBox(height: 260, child: JfLoading()),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const JfSectionTitle(title: 'More like this'),
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
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final it = items[i];
                      final subtitle = it.productionYear == null
                          ? null
                          : '${it.productionYear}';
                      return JfPosterCard(
                        title: it.name ?? '',
                        subtitle: subtitle,
                        imageUrl: urls.imageUrl(it, maxWidth: 280),
                        width: cardWidth,
                        onTap: () => context.push('/items/${it.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
