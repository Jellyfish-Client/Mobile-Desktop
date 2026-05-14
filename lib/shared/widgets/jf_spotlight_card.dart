import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'jf_button.dart';

/// Big featured card — used as the first item in a "Spotlight" rail to give
/// that rail a distinct opening beat. 16:9 landscape, ~85% screen width on
/// mobile, with a Fraunces title, metadata chips, and a Play CTA overlaid on
/// the backdrop.
class JfSpotlightCard extends StatelessWidget {
  const JfSpotlightCard({
    required this.title,
    required this.imageUrl,
    this.year,
    this.runtimeMinutes,
    this.tagline,
    this.width = 320,
    this.aspectRatio = 16 / 10,
    this.onTap,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final int? year;
  final int? runtimeMinutes;
  final String? tagline;
  final double width;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = BorderRadius.circular(AppRadius.lg);

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

                // Two-layer gradient: a top vignette that fades into
                // transparency, then a bottom scrim that kicks in at 45% to
                // carry all the text overlays. Avoids the diagonal tint that
                // read as a colour cast on cold-toned backdrops.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x66000000),
                        Color(0x00000000),
                        Color(0x88000000),
                        Color(0xEE000000),
                      ],
                      stops: [0.0, 0.22, 0.52, 1.0],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eyebrow row: label left, accent line right
                      Row(
                        children: [
                          Text(
                            'FEATURED',
                            style: AppTypography.eyebrow(
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondary.withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Bottom block: title + meta + CTA
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.display(
                              size: 26,
                              weight: FontWeight.w700,
                              height: 1.02,
                              color: Colors.white,
                            ).copyWith(
                              shadows: const [
                                Shadow(
                                  color: Color(0xCC000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          if (tagline != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              tagline!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (year != null)
                                Text(
                                  year.toString(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (year != null && runtimeMinutes != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  child: Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              if (runtimeMinutes != null)
                                Text(
                                  '${runtimeMinutes}min',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const Spacer(),
                              JfButton.primary(
                                label: 'Play',
                                onPressed: onTap,
                                size: JfButtonSize.sm,
                                icon: Icons.play_arrow,
                              ),
                            ],
                          ),
                        ],
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
