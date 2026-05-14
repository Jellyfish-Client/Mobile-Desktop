import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography pairs:
///   • [display]  — Fraunces variable serif, used for editorial section titles.
///   • body / labels — Inter (handled in AppTheme via `interTextTheme`).
///
/// Fraunces is chosen for its strong character at large optical sizes — it
/// looks like a film poster headline, not a generic UI font.
class AppTypography {
  const AppTypography._();

  static TextStyle display({
    double size = 48,
    FontWeight weight = FontWeight.w600,
    double? height,
    Color? color,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      height: height ?? 0.95,
      letterSpacing: -size * 0.02,
      color: color,
      fontFeatures: const [FontFeature.enable('opsz')],
    );
  }

  /// Eyebrow / overline — small monospaced uppercase used above section titles.
  static TextStyle eyebrow({Color? color}) {
    return GoogleFonts.firaCode(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.6,
      height: 1,
      color: color,
    );
  }

  static TextTheme applyTo(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
