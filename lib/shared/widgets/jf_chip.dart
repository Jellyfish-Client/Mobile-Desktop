import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

enum JfChipTone { neutral, brand, success, warning, error, info }

/// Compact label / metadata chip. Used for genres, ratings, status badges.
class JfChip extends StatelessWidget {
  const JfChip({
    required this.label,
    this.icon,
    this.tone = JfChipTone.neutral,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final IconData? icon;
  final JfChipTone tone;
  final VoidCallback? onTap;

  /// Accessibility label announced by screen readers. Falls back to [label].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (bg, fg) = switch (tone) {
      JfChipTone.neutral => (
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      ),
      JfChipTone.brand => (scheme.primaryContainer, scheme.onPrimaryContainer),
      JfChipTone.success => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      JfChipTone.warning => (const Color(0xFF2C1F0E), const Color(0xFFFFB559)),
      JfChipTone.error => (scheme.errorContainer, scheme.onErrorContainer),
      JfChipTone.info => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
    };

    final inner = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
    );

    if (onTap == null) {
      return Material(color: bg, shape: shape, child: inner);
    }
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: Material(
        color: bg,
        shape: shape,
        child: InkWell(onTap: onTap, customBorder: shape, child: inner),
      ),
    );
  }
}
