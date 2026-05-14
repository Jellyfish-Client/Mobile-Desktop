import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// Vertical poster + metadata block, used in browse rows / search results.
/// Pass a null [imageUrl] to render a placeholder.
class JfPosterCard extends StatelessWidget {
  const JfPosterCard({
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.aspectRatio = 2 / 3,
    this.width,
    this.progress,
    this.overlay,
    this.dimmed = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final String? subtitle;
  final double aspectRatio;

  /// Explicit width. When null, the card fills the parent's available width
  /// (use inside grids or LayoutBuilder-driven rows).
  final double? width;

  /// Resume / continue-watching progress in [0, 1]. Null hides the bar.
  final double? progress;

  /// Optional widget pinned to the top-right of the poster image — used to
  /// mark items as missing/requestable. Non-interactive (wrap in IgnorePointer
  /// upstream if needed; the card's [onTap] still catches the gesture).
  final Widget? overlay;

  /// Desaturates and slightly fades the poster image to signal that the
  /// content isn't in the user's library yet. Title/subtitle stay full-colour.
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _maybeDim(
                    dimmed: dimmed,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: scheme.surfaceContainerHigh),
                            errorWidget: (_, __, ___) =>
                                _Placeholder(scheme: scheme),
                          )
                        : _Placeholder(scheme: scheme),
                  ),
                  if (progress != null && progress! > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progress!.clamp(0, 1),
                        minHeight: 3,
                        backgroundColor: scheme.surface.withValues(alpha: 0.4),
                        valueColor: AlwaysStoppedAnimation(scheme.primary),
                      ),
                    ),
                  // Subtle vignette at the bottom — preserves poster readability
                  // even when the artwork has a bright lower edge.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 36,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0x00000000),
                            Colors.black.withValues(alpha: 0.28),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (overlay case final o?)
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: IgnorePointer(child: o),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}

/// Greyscale matrix (BT.709 luma coefficients) + alpha-preserving identity row.
const _greyscaleMatrix = <double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

Widget _maybeDim({required bool dimmed, required Widget child}) {
  if (!dimmed) return child;
  return Opacity(
    opacity: 0.55,
    child: ColorFiltered(
      colorFilter: const ColorFilter.matrix(_greyscaleMatrix),
      child: child,
    ),
  );
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
