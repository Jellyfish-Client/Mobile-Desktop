import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;

import '../../core/network/offline_mode_provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import 'box_set_detail_screen.dart';
import 'detail_providers.dart';
import 'episode_detail_screen.dart';
import 'movie_detail_screen.dart';
import 'offline_detail_screen.dart';
import 'series_detail_screen.dart';

/// Entry point for `/items/:id`. Fetches the item, then delegates to a
/// per-type view (movie / series / episode). Seasons redirect back to their
/// parent series — the series page handles season selection inline.
class DetailScreen extends ConsumerWidget {
  const DetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(offlineModeProvider)) {
      return OfflineDetailEntry(itemId: itemId);
    }
    final itemAsync = ref.watch(itemProvider(itemId));

    return itemAsync.when(
      // No spinner while the item resolves: the route push already produces a
      // navigation transition, and stacking a logo+spinner on top gave the
      // app a "loading page" feel between tap and content. The bare Scaffold
      // shows the theme background for the (usually sub-second) fetch.
      loading: () => const Scaffold(),
      error: (e, __) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.error_outline,
          title: context.l10n.detailsFailedToLoad,
          message: e is StateError
              ? context.l10n.detailsItemInvalid
              : e.toString(),
          actionLabel: context.l10n.detailsRetry,
          onAction: () => ref.invalidate(itemProvider(itemId)),
        ),
      ),
      data: (item) {
        final type = item.type;
        if (type == BaseItemKind.movie) return MovieDetailView(item: item);
        if (type == BaseItemKind.series) return SeriesDetailView(item: item);
        if (type == BaseItemKind.episode) return EpisodeDetailView(item: item);
        if (type == BaseItemKind.boxSet) return BoxSetDetailView(item: item);
        if (type == BaseItemKind.season) {
          final seriesId = item.seriesId;
          if (seriesId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.replace('/items/$seriesId');
            });
          }
          return const Scaffold();
        }
        return Scaffold(
          appBar: AppBar(),
          body: EmptyState(
            icon: Icons.help_outline,
            title: context.l10n.detailsUnsupportedItem,
            message: context.l10n.detailsUnsupportedItemMessage,
          ),
        );
      },
    );
  }
}
