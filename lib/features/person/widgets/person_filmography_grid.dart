import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/breakpoints.dart';
import '../../../core/jellyfin/jellyfin_url_service.dart';
import '../../../core/jellyfin/models/jellyfin_item.dart';
import '../../../core/seerr/models.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';
import '../../details/widgets/missing_poster_card.dart';
import '../../details/widgets/seerr_request_sheet.dart';
import '../person_providers.dart';

/// Sliver-grid filmography for a person page.
///
/// Merges Jellyfin items (real local titles) with Seerr "missing credits"
/// (TMDB credits the user can request). The two sets are interleaved by
/// production year descending — the dimmed `MissingPosterCard` overlay is a
/// strong enough signal that we don't need a separate "missing" section.
///
/// When [tmdbPersonId] is null (the Jellyfin person has no TMDB provider id)
/// Seerr lookups are skipped entirely — no spinner, no error.
class PersonFilmographyGrid extends ConsumerWidget {
  const PersonFilmographyGrid({
    required this.jellyfinPersonId,
    required this.tmdbPersonId,
    super.key,
  });

  final String jellyfinPersonId;
  final int? tmdbPersonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmography = ref.watch(personFilmographyProvider(jellyfinPersonId));

    final seerrMissing = tmdbPersonId == null
        ? const AsyncValue<List<SeerrMedia>>.data([])
        : ref.watch(
            personSeerrMissingCreditsProvider((
              tmdbPersonId: tmdbPersonId!,
              jellyfinPersonId: jellyfinPersonId,
            )),
          );

    final filter = ref.watch(personFilterProvider(jellyfinPersonId));

    return filmography.when(
      loading: () => const _Skeleton(),
      error: (e, _) => SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.error_outline,
          title: context.l10n.personFilmographyEmptyTitle,
          message: '$e',
        ),
      ),
      data: (jellyItems) {
        final missing = seerrMissing.maybeWhen(
          data: (m) => m,
          orElse: () => const <SeerrMedia>[],
        );
        final entries = _buildEntries(jellyItems, missing, filter);
        if (entries.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.movie_creation_outlined,
              title: context.l10n.personFilmographyEmptyTitle,
              message: context.l10n.personFilmographyEmpty,
            ),
          );
        }
        return _Grid(
          entries: entries,
          jellyfinPersonId: jellyfinPersonId,
          tmdbPersonId: tmdbPersonId,
        );
      },
    );
  }

  static List<_Entry> _buildEntries(
    List<JellyfinItem> jelly,
    List<SeerrMedia> missing,
    PersonFilter filter,
  ) {
    final out = <_Entry>[];
    for (final item in jelly) {
      if (!_matchesJellyfin(item, filter)) continue;
      out.add(_Entry.jellyfin(item));
    }
    for (final m in missing) {
      if (!_matchesSeerr(m, filter)) continue;
      out.add(_Entry.seerr(m));
    }
    out.sort((a, b) {
      final ay = a.year ?? -1;
      final by = b.year ?? -1;
      return by.compareTo(ay);
    });
    return out;
  }

  static bool _matchesJellyfin(JellyfinItem item, PersonFilter filter) {
    return switch (filter) {
      PersonFilter.all => true,
      PersonFilter.movies => item.type == BaseItemKind.movie,
      PersonFilter.series => item.type == BaseItemKind.series,
    };
  }

  static bool _matchesSeerr(SeerrMedia m, PersonFilter filter) {
    return switch (filter) {
      PersonFilter.all => true,
      PersonFilter.movies => m.type == SeerrMediaType.movie,
      PersonFilter.series => m.type == SeerrMediaType.tv,
    };
  }
}

/// Internal union: either a Jellyfin item (in the library) or a Seerr missing
/// item (requestable). Carries just enough data for sort + render.
class _Entry {
  _Entry.jellyfin(JellyfinItem this.item)
    : seerr = null,
      year = item.productionYear;
  _Entry.seerr(SeerrMedia this.seerr) : item = null, year = seerr.year;

  final JellyfinItem? item;
  final SeerrMedia? seerr;
  final int? year;

  bool get isJellyfin => item != null;
}

class _Grid extends ConsumerWidget {
  const _Grid({
    required this.entries,
    required this.jellyfinPersonId,
    required this.tmdbPersonId,
  });

  final List<_Entry> entries;
  final String jellyfinPersonId;
  final int? tmdbPersonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final seerr = ref.watch(seerrClientProvider);
    final theme = Theme.of(context);
    final gridExtent = Breakpoints.gridMaxCrossAxisExtent(context.bpWidth);

    return SliverLayoutBuilder(
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
            final entry = entries[index];
            if (entry.isJellyfin) {
              final item = entry.item!;
              return JfPosterCard(
                title: item.name ?? '',
                imageUrl: urls.imageUrl(item, maxWidth: 300),
                subtitle: _jellyfinSubtitle(item),
                onTap: () => context.push('/items/${item.id}'),
              );
            }
            final m = entry.seerr!;
            return MissingPosterCard(
              title: m.title,
              imageUrl: seerr.posterUrl(m),
              subtitle: m.year?.toString(),
              availability: m.availability,
              onTap: () async {
                await showSeerrRequestSheet(context, media: m);
                if (!context.mounted) return;
                if (tmdbPersonId != null) {
                  ref.invalidate(
                    personSeerrMissingCreditsProvider((
                      tmdbPersonId: tmdbPersonId!,
                      jellyfinPersonId: jellyfinPersonId,
                    )),
                  );
                }
              },
            );
          }, childCount: entries.length),
        );
      },
    );
  }

  static String? _jellyfinSubtitle(JellyfinItem item) {
    final year = item.productionYear?.toString();
    if (year == null) return null;
    return year;
  }
}

/// Lightweight skeleton: 9 static placeholder tiles matching the same grid
/// math as the real grid. Avoids the shimmer dependency for V1.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final gridExtent = Breakpoints.gridMaxCrossAxisExtent(context.bpWidth);
    return SliverLayoutBuilder(
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
          delegate: SliverChildBuilderDelegate(
            (_, __) => DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            childCount: 9,
          ),
        );
      },
    );
  }
}
