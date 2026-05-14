import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// Generic surface container — use for grouping content (e.g. a settings
/// section, a poster row block, an info panel).
class JfCard extends StatelessWidget {
  const JfCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );

    final inner = Padding(padding: padding, child: child);

    if (onTap != null) {
      return Material(
        color: color ?? scheme.surfaceContainer,
        shape: shape,
        child: InkWell(onTap: onTap, customBorder: shape, child: inner),
      );
    }
    return Material(
      color: color ?? scheme.surfaceContainer,
      shape: shape,
      child: inner,
    );
  }
}
