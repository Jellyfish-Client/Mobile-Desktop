import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// Section grouping for Settings-style screens: a small caps label followed by
/// a card-like list of tiles separated by thin top/bottom borders. Used in
/// the main Settings screen and the Admin hub.
class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.label, required this.tiles, super.key});

  final String label;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xs,
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.3),
                ),
                bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              color: scheme.surfaceContainerLow,
            ),
            child: Column(children: tiles),
          ),
        ],
      ),
    );
  }
}
