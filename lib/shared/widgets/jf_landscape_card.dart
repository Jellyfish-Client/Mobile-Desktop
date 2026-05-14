import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// Landscape 16:9 card with a backdrop image, dark bottom-gradient, and
/// title + optional progress overlaid. Used on the Home for "Continue
/// Watching" — the partial-play state reads better at landscape than at
/// poster portrait.
class JfLandscapeCard extends StatelessWidget {
  const JfLandscapeCard({
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.progress,
    this.width,
    this.aspectRatio = 16 / 9,
    this.onTap,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final String? subtitle;
  final double? progress;

  /// Explicit width. When null, the card fills the parent's available width
  /// (use inside grids or LayoutBuilder-driven rows).
  final double? width;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = BorderRadius.circular(AppRadius.md);

    final card = InkWell(
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

              // Layered gradient: a gentle top vignette + stronger bottom dim.
              // The top vignette prevents the image from "bleeding" into the
              // screen background; the bottom scrim protects the title text.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x33000000),
                      Color(0x00000000),
                      Color(0x44000000),
                      Color(0xDD000000),
                    ],
                    stops: [0.0, 0.25, 0.55, 1.0],
                  ),
                ),
              ),

              // Title + subtitle, bottom-left.
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: progress != null && progress! > 0
                    ? AppSpacing.md + 6
                    : AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (subtitle != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        shadows: const [
                          Shadow(
                            color: Color(0xBB000000),
                            blurRadius: 16,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar (resume).
              if (progress != null && progress! > 0)
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.sm,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: progress!.clamp(0, 1),
                      minHeight: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation(scheme.primary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}
