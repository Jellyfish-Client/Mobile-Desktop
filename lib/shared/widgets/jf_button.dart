import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

enum JfButtonVariant {
  /// Filled brand-coloured button — primary CTA.
  primary,

  /// Tonal / soft surface — secondary action.
  secondary,

  /// Borderless — tertiary action, "Cancel"-style.
  ghost,

  /// Filled with the error colour — dangerous actions.
  destructive,
}

enum JfButtonSize { sm, md, lg }

/// Standard Jellyfish button. Use [JfButton.primary], [JfButton.secondary],
/// [JfButton.ghost], or [JfButton.destructive] factories for the common
/// variants. Supports a leading [icon], a `loading` state and full-width.
class JfButton extends StatelessWidget {
  const JfButton({
    required this.label,
    required this.onPressed,
    this.variant = JfButtonVariant.primary,
    this.size = JfButtonSize.md,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.semanticLabel,
    super.key,
  });

  factory JfButton.primary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading = false,
    bool fullWidth = false,
    JfButtonSize size = JfButtonSize.md,
    String? semanticLabel,
    Key? key,
  }) => JfButton(
    key: key,
    label: label,
    onPressed: onPressed,
    icon: icon,
    loading: loading,
    fullWidth: fullWidth,
    size: size,
    semanticLabel: semanticLabel,
  );

  factory JfButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading = false,
    bool fullWidth = false,
    JfButtonSize size = JfButtonSize.md,
    String? semanticLabel,
    Key? key,
  }) => JfButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: JfButtonVariant.secondary,
    icon: icon,
    loading: loading,
    fullWidth: fullWidth,
    size: size,
    semanticLabel: semanticLabel,
  );

  factory JfButton.ghost({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    JfButtonSize size = JfButtonSize.md,
    String? semanticLabel,
    Key? key,
  }) => JfButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: JfButtonVariant.ghost,
    icon: icon,
    size: size,
    semanticLabel: semanticLabel,
  );

  factory JfButton.destructive({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading = false,
    JfButtonSize size = JfButtonSize.md,
    String? semanticLabel,
    Key? key,
  }) => JfButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: JfButtonVariant.destructive,
    icon: icon,
    loading: loading,
    size: size,
    semanticLabel: semanticLabel,
  );

  final String label;
  final VoidCallback? onPressed;
  final JfButtonVariant variant;
  final JfButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  /// Accessibility label announced by screen readers. Falls back to [label].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = onPressed == null || loading;

    final (bg, fg, overlay) = switch (variant) {
      JfButtonVariant.primary => (
        scheme.primary,
        scheme.onPrimary,
        scheme.onPrimary,
      ),
      JfButtonVariant.secondary => (
        scheme.surfaceContainerHigh,
        scheme.onSurface,
        scheme.onSurface,
      ),
      JfButtonVariant.ghost => (
        Colors.transparent,
        scheme.primary,
        scheme.primary,
      ),
      JfButtonVariant.destructive => (
        scheme.error,
        scheme.onError,
        scheme.onError,
      ),
    };

    final padding = switch (size) {
      JfButtonSize.sm => const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      JfButtonSize.md => const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      JfButtonSize.lg => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
    };

    final textStyle = switch (size) {
      JfButtonSize.sm => Theme.of(context).textTheme.labelMedium,
      JfButtonSize.md => Theme.of(context).textTheme.labelLarge,
      JfButtonSize.lg => Theme.of(context).textTheme.titleMedium,
    };

    final spinnerSize = switch (size) {
      JfButtonSize.sm => 14.0,
      JfButtonSize.md => 18.0,
      JfButtonSize.lg => 22.0,
    };

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: spinnerSize,
              height: spinnerSize,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: spinnerSize, color: fg),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textStyle?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    final btn = Material(
      color: disabled ? bg.withValues(alpha: 0.4) : bg,
      shape: shape,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        customBorder: shape,
        overlayColor: WidgetStatePropertyAll(overlay.withValues(alpha: 0.08)),
        child: Padding(
          padding: padding,
          child: Center(widthFactor: fullWidth ? null : 1.0, child: child),
        ),
      ),
    );

    final wrapped = Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: !disabled,
      child: fullWidth ? SizedBox(width: double.infinity, child: btn) : btn,
    );
    return wrapped;
  }
}
