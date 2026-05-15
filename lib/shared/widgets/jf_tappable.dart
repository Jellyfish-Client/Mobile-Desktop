import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Haptic feedback intensity emitted by [JfTappable] before invoking
/// `onTap`/`onLongPress`. Kept narrow on purpose — three discrete steps cover
/// the existing usage in the app and stay easy to reason about.
enum HapticFeedbackType {
  /// No haptic feedback.
  none,

  /// [HapticFeedback.selectionClick] — neutral selection.
  selection,

  /// [HapticFeedback.lightImpact] — confirmation of a benign action.
  light,

  /// [HapticFeedback.mediumImpact] — emphasised action (e.g. destructive).
  medium,
}

/// Standardised tappable wrapper that enforces accessibility (`semanticLabel`
/// is required) and emits a consistent haptic feedback before delegating to
/// `onTap`.
///
/// Use this instead of bare `InkWell` / `GestureDetector` whenever a tap
/// target is built — it prevents a11y regressions and guarantees the same
/// look-and-feel across the app.
class JfTappable extends StatelessWidget {
  const JfTappable({
    required this.semanticLabel,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticHint,
    this.excludeFromSemantics = false,
    this.borderRadius,
    this.haptic = HapticFeedbackType.selection,
    super.key,
  });

  /// Accessible label announced by screen readers. Required to prevent
  /// unlabelled tap targets from shipping.
  final String semanticLabel;

  /// The widget below the gesture detector.
  final Widget child;

  /// Tap callback. When `null` the widget is rendered as a static surface
  /// (`enabled: false` on the [Semantics] node).
  final VoidCallback? onTap;

  /// Long-press callback.
  final VoidCallback? onLongPress;

  /// Optional hint announced after the label by screen readers.
  final String? semanticHint;

  /// When `true`, the widget is removed from the accessibility tree entirely
  /// (use for purely decorative tap targets that have a sibling label).
  final bool excludeFromSemantics;

  /// Border radius applied to the [InkWell] ink splash.
  final BorderRadius? borderRadius;

  /// Haptic feedback to emit before invoking [onTap].
  final HapticFeedbackType haptic;

  Future<void> _emitHaptic() async {
    switch (haptic) {
      case HapticFeedbackType.none:
        return;
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
    }
  }

  void _handleTap() {
    unawaited(_emitHaptic());
    onTap!();
  }

  void _handleLongPress() {
    unawaited(_emitHaptic());
    onLongPress!();
  }

  @override
  Widget build(BuildContext context) {
    final hasGesture = onTap != null || onLongPress != null;
    final inkWell = Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap == null ? null : _handleTap,
        onLongPress: onLongPress == null ? null : _handleLongPress,
        child: child,
      ),
    );

    if (excludeFromSemantics) {
      return ExcludeSemantics(child: inkWell);
    }

    return Semantics(
      button: true,
      enabled: hasGesture,
      label: semanticLabel,
      hint: semanticHint,
      onTap: onTap == null ? null : _handleTap,
      onLongPress: onLongPress == null ? null : _handleLongPress,
      excludeSemantics: true,
      child: inkWell,
    );
  }
}
