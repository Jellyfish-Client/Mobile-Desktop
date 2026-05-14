import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// Horizontal episode row: 16:9 still on the left, title/number/runtime on the
/// right. Optional progress bar and "watched" badge surface playback state.
class JfEpisodeTile extends StatelessWidget {
  const JfEpisodeTile({
    required this.title,
    required this.episodeNumber,
    this.imageUrl,
    this.runtime,
    this.overview,
    this.progress,
    this.watched = false,
    this.onTap,
    super.key,
  });

  final String title;
  final int? episodeNumber;
  final String? imageUrl;
  final String? runtime;
  final String? overview;
  final double? progress;
  final bool watched;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = BorderRadius.circular(AppRadius.sm);

    final heading = [
      if (episodeNumber != null)
        TextSpan(
          text: '$episodeNumber · ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      TextSpan(
        text: title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: shape,
              child: SizedBox(
                width: 128,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
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

                      if (watched)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),

                      if (progress != null && progress! > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LinearProgressIndicator(
                            value: progress!.clamp(0, 1),
                            minHeight: 3,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            valueColor: AlwaysStoppedAnimation(scheme.primary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(children: heading),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (runtime != null && runtime!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      runtime!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (overview != null && overview!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      overview!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
