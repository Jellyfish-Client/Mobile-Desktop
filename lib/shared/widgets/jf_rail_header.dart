import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Editorial rail header — eyebrow with index + thin separator + Fraunces
/// display title + optional sub-line. Replaces JfSectionTitle on Home for
/// a more cinematic feel.
///
///   01 ───── POUR VOUS
///   Discover something new.
///   *little subtitle, optional*
class JfRailHeader extends StatelessWidget {
  const JfRailHeader({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.lg,
      AppSpacing.md,
    ),
    super.key,
  });

  final String title;

  /// e.g. "01" or "01 ── EXTERNAL". Shown above the title in monospaced caps.
  final String? eyebrow;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Text(
                          eyebrow!,
                          style: AppTypography.eyebrow(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  title,
                  style: AppTypography.display(
                    size: 30,
                    weight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: action,
            ),
        ],
      ),
    );
  }
}
