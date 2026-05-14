import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Backdrop hero used by the detail pages. Renders the backdrop full-bleed
/// with a vertical gradient for legibility, and overlays the item's official
/// logo image at the bottom-left. When the logo is unavailable (or its URL
/// errors out) it falls back to a stylized title — matches the look of the
/// home hero carousel so the two surfaces feel coherent.
class JfDetailHero extends StatelessWidget {
  const JfDetailHero({
    required this.backdropUrl,
    required this.title,
    this.logoUrl,
    this.height = 360,
    this.logoMaxHeight = 110,
    this.logoMaxWidth = 280,
    super.key,
  });

  final String? backdropUrl;
  final String? logoUrl;
  final String title;
  final double height;
  final double logoMaxHeight;
  final double logoMaxWidth;

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

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000),
                      Color(0x00000000),
                      Color(0xCC07060C),
                      Color(0xFF07060C),
                    ],
                    stops: [0.0, 0.4, 0.85, 1.0],
                  ),
                ),
              ),

              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: Align(
                  alignment: alignment,
                  child: logoUrl != null
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
                                _titleFallback(theme, title, centered: isWide),
                          ),
                        )
                      : _titleFallback(theme, title, centered: isWide),
                ),
              ),
            ],
          );
        },
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
