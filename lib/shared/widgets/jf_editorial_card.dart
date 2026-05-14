import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Magazine-style card. Backdrop image with the title rendered in Fraunces
/// directly on top of the lower half, with a thin colored accent line under
/// it. Used to break the rhythm of poster rows on Home — gives a "curated
/// editorial" feel for sections like "Hidden gems".
class JfEditorialCard extends StatelessWidget {
  const JfEditorialCard({
    required this.title,
    this.imageUrl,
    this.tagline,
    this.width = 240,
    this.aspectRatio = 3 / 4,
    this.onTap,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final String? tagline;
  final double width;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = BorderRadius.circular(AppRadius.md);

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape,
        child: ClipRRect(
          borderRadius: shape,
          child: AspectRatio(
            aspectRatio: aspectRatio,
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

                // Layered scrim: subtle top vignette + strong bottom fade.
                // The bottom needs to be dense enough to carry white Fraunces
                // text at any poster luminance.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x44000000),
                        Color(0x00000000),
                        Color(0xBB000000),
                        Color(0xEE000000),
                      ],
                      stops: [0.0, 0.35, 0.7, 1.0],
                    ),
                  ),
                ),

                // Bottom: Fraunces title + accent rule + optional tagline.
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tagline != null) ...[
                        Text(
                          tagline!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 21,
                          weight: FontWeight.w600,
                          height: 1.05,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
