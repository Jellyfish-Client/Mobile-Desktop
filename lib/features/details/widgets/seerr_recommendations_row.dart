import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/seerr/models.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';
import '../detail_providers.dart';
import 'seerr_request_sheet.dart';

/// "Available on Seerr — request it" rail. Filters out items already
/// available locally (status Available) so we only surface things the user
/// can actually act on. Hides itself when Seerr isn't linked, no TMDB id
/// is known, or the API returns nothing.
class SeerrRecommendationsRow extends ConsumerWidget {
  const SeerrRecommendationsRow({
    required this.tmdbId,
    required this.type,
    super.key,
  });

  /// TMDB id of the *source* item used to seed Seerr's similar lookup.
  final int tmdbId;
  final SeerrMediaType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(seerrClientProvider);
    if (!client.isLinked) return const SizedBox.shrink();

    final async = ref.watch(seerrSimilarProvider((tmdbId: tmdbId, type: type)));

    return async.when(
      loading: () => const SizedBox(height: 300, child: JfLoading()),
      error: (_, __) => const SizedBox.shrink(),
      data: (raw) {
        // Drop items already in the Jellyfin library — they'd just be a
        // round-trip to "Already available", which adds noise to the rail.
        final items = raw
            .where((m) => m.availability != SeerrAvailability.available)
            .toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JfSectionTitle(
              title: context.l10n.seerrDiscoverTitle,
              subtitle: context.l10n.seerrDiscoverSubtitle,
            ),
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, i) {
                  final m = items[i];
                  return _SeerrPosterCard(
                    media: m,
                    posterUrl: client.posterUrl(m),
                    onTap: () => showSeerrRequestSheet(context, media: m),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Poster card variant for Seerr items: poster + title + year, with a
/// "Seerr" badge in the top-right and an availability hint at the bottom-left
/// when the item is already in flight (pending / processing).
class _SeerrPosterCard extends StatelessWidget {
  const _SeerrPosterCard({
    required this.media,
    required this.posterUrl,
    required this.onTap,
  });

  final SeerrMedia media;
  final String? posterUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtitle = media.year == null ? null : '${media.year}';

    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (posterUrl != null)
                      CachedNetworkImage(
                        imageUrl: posterUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: scheme.surfaceContainerHigh),
                        errorWidget: (_, __, ___) =>
                            _Placeholder(scheme: scheme),
                      )
                    else
                      _Placeholder(scheme: scheme),
                    const Positioned(top: 6, right: 6, child: _SeerrBadge()),
                    if (_inFlightLabel(context, media.availability) != null)
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: JfChip(
                          icon: Icons.hourglass_top_rounded,
                          label: _inFlightLabel(context, media.availability)!,
                          tone: JfChipTone.warning,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              media.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String? _inFlightLabel(BuildContext context, SeerrAvailability a) {
    final l = context.l10n;
    switch (a) {
      case SeerrAvailability.pending:
        return l.seerrPendingLabel;
      case SeerrAvailability.processing:
        return l.seerrProcessingLabel;
      case SeerrAvailability.partiallyAvailable:
        return l.seerrPartialLabel;
      case SeerrAvailability.available:
      case SeerrAvailability.unknown:
        return null;
    }
  }
}

class _SeerrBadge extends StatelessWidget {
  const _SeerrBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_download_outlined, size: 12, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            'Seerr',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
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
