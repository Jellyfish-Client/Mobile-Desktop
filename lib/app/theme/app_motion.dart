import 'package:flutter/animation.dart';

/// Centralised motion tokens — durations and curves used by transitions,
/// hover states, snackbars, etc.
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);

  /// Material 3 standard easing.
  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve decelerated = Curves.easeOutCubic;
}
