import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// Backdrop hero used by the detail pages.
///
/// Renders the backdrop full-bleed with a multi-stop vertical gradient that
/// fades into the page background, and overlays the item's official logo (or
/// a stylized title fallback) anchored to the bottom. Optional [overline] and
/// [breadcrumb] slots support episode pages, where the still is a 16:9 frame
/// rather than a tall hero and we want a typographic context strip and a
/// glass back-link inside the hero itself.
class JfDetailHero extends StatelessWidget {
  const JfDetailHero({
    required this.backdropUrl,
    required this.title,
    this.logoUrl,
    this.height = 360,
    this.logoMaxHeight = 110,
    this.logoMaxWidth = 280,
    this.overline,
    this.breadcrumb,
    this.breadcrumbInset = 0,
    this.useTitleFallback = true,
    super.key,
  });

  final String? backdropUrl;
  final String? logoUrl;
  final String title;
  final double height;
  final double logoMaxHeight;
  final double logoMaxWidth;

  /// Small mono-spaced label rendered above the title in the bottom slot.
  /// Used by the episode hero to surface "EPISODE 02".
  final Widget? overline;

  /// Floating glass back-link rendered top-left inside the hero. Used by the
  /// episode hero to point back to the parent series.
  final Widget? breadcrumb;

  /// Extra left padding for the [breadcrumb], used on wide windows to keep it
  /// roughly in line with the centered content column instead of hugging the
  /// viewport edge.
  final double breadcrumbInset;

  /// When false, no logo and no title are rendered in the hero bottom slot.
  /// The overline / breadcrumb slots still render. Useful when the title is
  /// going to be rendered below the hero instead of over the image.
  final bool useTitleFallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final alignment = isWide
              ? Alignment.bottomCenter
              : Alignment.bottomLeft;
          final logoWidth = isWide ? 420.0 : logoMaxWidth;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (backdropUrl != null)
                CachedNetworkImage(
                  imageUrl: backdropUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.surface),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.surface),
                )
              else
                Container(color: AppColors.surface),

              // Multi-stop gradient — keeps the top edge legible for app-bar
              // icons, the middle nearly clean for the image, and the bottom
              // fully bleeds into the page background so content below feels
              // continuous with the hero rather than meeting a hard edge.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000),
                      Color(0x00000000),
                      Color(0x66000000),
                      Color(0xE6000000),
                      Color(0xFF000000),
                    ],
                    stops: [0.0, 0.35, 0.7, 0.92, 1.0],
                  ),
                ),
              ),

              if (breadcrumb != null)
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.lg + breadcrumbInset,
                  right: AppSpacing.lg + breadcrumbInset,
                  child: SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: _Glass(child: breadcrumb!),
                    ),
                  ),
                ),

              if (overline != null || useTitleFallback)
                Positioned(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xl,
                  child: Align(
                    alignment: alignment,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: logoWidth + 60),
                      child: Column(
                        crossAxisAlignment: isWide
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (overline != null) ...[
                            overline!,
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          if (useTitleFallback)
                            logoUrl != null
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: logoMaxHeight,
                                      maxWidth: logoWidth,
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: logoUrl!,
                                      fit: BoxFit.contain,
                                      alignment: alignment,
                                      errorWidget: (_, __, ___) =>
                                          _titleFallback(
                                            theme,
                                            title,
                                            centered: isWide,
                                          ),
                                    ),
                                  )
                                : _titleFallback(theme, title, centered: isWide),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x99000000),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

Widget _titleFallback(ThemeData theme, String title, {bool centered = false}) {
  return Text(
    title,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    textAlign: centered ? TextAlign.center : TextAlign.start,
    style: theme.textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.05,
      shadows: const [
        Shadow(color: Color(0x99000000), blurRadius: 22, offset: Offset(0, 3)),
      ],
    ),
  );
}
