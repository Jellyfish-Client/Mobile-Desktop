import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../home_section.dart';

/// Marks the boundary between two logical home blocks ("Vos contenus" /
/// "À découvrir"). Renders as eyebrow + display title + thin gradient rule;
/// no card, no padding around the edge so it spans the full width.
class HomeSectionHeaderWidget extends StatelessWidget {
  const HomeSectionHeaderWidget({required this.section, super.key});

  final HomeSectionHeader section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dividerColor = scheme.outlineVariant.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xxl,
        bottom: AppSpacing.xl,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.eyebrow != null) ...[
            Text(
              section.eyebrow!,
              style: AppTypography.eyebrow(
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            section.title,
            style: AppTypography.display(
              size: 28,
              weight: FontWeight.w400,
              color: scheme.onSurface,
            ),
          ),
          if (section.divider) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    dividerColor,
                    Colors.transparent,
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
