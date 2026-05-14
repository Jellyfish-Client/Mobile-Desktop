import 'package:flutter/material.dart';

/// Brand and semantic colour tokens for Jellyfish.
///
/// Monochrome palette inspired by Vercel/Zed — pure black backgrounds,
/// white primary, stepped grey surfaces. Status semantics preserved with
/// slightly desaturated hues.
class AppColors {
  const AppColors._();

  // ---- Brand (white-on-black, Vercel-style) --------------------------------
  static const Color primary = Color(0xFFFFFFFF);
  static const Color primaryHover = Color(0xFFFAFAFA);
  static const Color primaryPressed = Color(0xFFD4D4D4);
  static const Color primarySoft = Color(0xFF1A1A1A);
  static const Color onPrimary = Color(0xFF000000);

  static const Color secondary = Color(0xFFA3A3A3);
  static const Color secondaryHover = Color(0xFFB8B8B8);
  static const Color secondaryPressed = Color(0xFF8A8A8A);
  static const Color secondarySoft = Color(0xFF1A1A1A);
  static const Color onSecondary = Color(0xFF000000);

  // ---- Surfaces (stepped greys) -------------------------------------------
  static const Color bg = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceContainer = Color(0xFF111111);
  static const Color surfaceContainerHigh = Color(0xFF171717);
  static const Color surfaceContainerHighest = Color(0xFF1F1F1F);
  static const Color surfaceInverse = Color(0xFFFAFAFA);

  // ---- Foreground / text on surfaces --------------------------------------
  static const Color onSurface = Color(0xFFFAFAFA);
  static const Color onSurfaceMuted = Color(0xFFA3A3A3);
  static const Color onSurfaceSubtle = Color(0xFF525252);
  static const Color onSurfaceInverse = Color(0xFF0A0A0A);

  // ---- Borders / dividers --------------------------------------------------
  static const Color outline = Color(0xFF262626);
  static const Color outlineSubtle = Color(0xFF1A1A1A);

  // ---- Semantic states -----------------------------------------------------
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFF0A1F14);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFF1F1408);
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFF1F0A0A);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color info = Color(0xFFFAFAFA);
  static const Color infoSoft = Color(0xFF1A1A1A);
  static const Color onInfo = Color(0xFF000000);
}
