import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/breakpoints.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import 'detail_providers.dart';
import 'widgets/missing_poster_card.dart';
import 'widgets/seerr_request_sheet.dart';

class BoxSetDetailView extends ConsumerWidget {
  const BoxSetDetailView({required this.item, super.key});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final boxSetId = item.id;

    final childrenAsync = ref.watch(boxSetItemsProvider(boxSetId));
    final missingAsync = ref.watch(missingCollectionMoviesProvider(boxSetId));
    final missing = missingAsync.maybeWhen(
      data: (m) => m,
      orElse: () => const <SeerrMedia>[],
    );
    final seerr = ref.watch(seerrClientProvider);
    final backdropUrl = urls.imageUrl(item, type: 'Backdrop', maxWidth: 1080);
    final heroHeight = Breakpoints.detailHeroHeight(MediaQuery.sizeOf(context));
    final gridExtent = Breakpoints.gridMaxCrossAxisExtent(
      MediaQuery.sizeOf(context).width,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            stretch: true,
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
                child: JfReadingPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.genres.isNotEmpty)
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final g in item.genres)
                              JfChip(label: g, tone: JfChipTone.info),
                          ],
                        ),
                      if (item.overview != null &&
                          item.overview!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          item.overview!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          childrenAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: JfLoading(),
              ),
            ),
            error: (e, __) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: context.l10n.detailsBoxSetFailedToLoad,
                  message: e.toString(),
                  actionLabel: context.l10n.detailsRetry,
                  onAction: () => ref.invalidate(boxSetItemsProvider(boxSetId)),
                ),
              ),
            ),
            data: (children) {
              // Wait for the missing-movies provider before declaring the
              // collection empty — otherwise an empty Jellyfin BoxSet linked
              // to a TMDB collection flashes "Empty" while Seerr loads.
              if (children.isEmpty &&
                  missing.isEmpty &&
                  !missingAsync.isLoading) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: EmptyState(
                      icon: Icons.movie_outlined,
                      title: context.l10n.detailsBoxSetEmpty,
                      message: context.l10n.detailsBoxSetEmptyMessage,
                    ),
                  ),
                );
              }
              if (children.isEmpty && missing.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: JfLoading(),
                  ),
                );
              }
              final totalCount = children.length + missing.length;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final cellWidth = Breakpoints.gridCellWidth(
                      crossAxisExtent: constraints.crossAxisExtent,
                      maxExtent: gridExtent,
                      crossAxisSpacing: AppSpacing.sm,
                    );
                    final ratio = Breakpoints.posterGridAspectRatio(
                      cellWidth,
                      theme.textTheme,
                    );
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: gridExtent,
                        childAspectRatio: ratio,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index < children.length) {
                          final child = children[index];
                          return JfPosterCard(
                            title: child.name ?? '',
                            imageUrl: urls.imageUrl(child, maxWidth: 300),
                            subtitle: child.productionYear?.toString(),
                            onTap: () => context.push('/items/${child.id}'),
                          );
                        }
                        final m = missing[index - children.length];
                        return MissingPosterCard(
                          title: m.title,
                          imageUrl: seerr.posterUrl(m),
                          subtitle: m.year?.toString(),
                          availability: m.availability,
                          onTap: () async {
                            // Collection.parts often comes back with a thin
                            // overview / no mediaInfo. Upgrade the stub via
                            // /movie/{id} so the sheet renders the same
                            // details as it does from the home rail.
                            final detailed =
                                await seerr.movieDetails(m.tmdbId) ?? m;
                            if (!context.mounted) return;
                            await showSeerrRequestSheet(
                              context,
                              media: detailed,
                            );
                            ref.invalidate(
                              missingCollectionMoviesProvider(boxSetId),
                            );
                          },
                        );
                      }, childCount: totalCount),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
