import 'package:flutter/material.dart';

enum WindowSizeClass { compact, medium, expanded, large, extraLarge }

enum NavigationMode { burgerFab, railCompact, railExtended, drawerPermanent }

class Breakpoints {
  const Breakpoints._();

  static const double phoneMax = 600;
  static const double tabletMax = 1200;

  static bool isPhone(double width) => width < phoneMax;
  static bool isTablet(double width) => width >= phoneMax && width < tabletMax;
  static bool isDesktop(double width) => width >= tabletMax;

  static double posterCardWidth(double width) {
    if (width < 360) return 104;
    if (width < phoneMax) return 128;
    if (width < tabletMax) return 152;
    return 176;
  }

  static double landscapeCardWidth(double width) {
    if (width < 360) return 200;
    if (width < phoneMax) return 240;
    if (width < tabletMax) return 300;
    return 360;
  }

  static double posterCardTotalHeight(double cardWidth, TextTheme text) {
    final imageHeight = cardWidth * 3 / 2;
    // Defaults aligned with Material 3 (bodyMedium height 1.43, bodySmall
    // 1.33). Using 1.25 here under-counted the trailing line by ~5px and
    // clipped the subtitle on poster rails.
    final bodyMediumHeight =
        (text.bodyMedium?.fontSize ?? 14) *
        (text.bodyMedium?.height ?? 1.43) *
        2;
    final bodySmallHeight =
        (text.bodySmall?.fontSize ?? 12) * (text.bodySmall?.height ?? 1.33);
    const spacing = 8.0 + 2.0;
    return imageHeight + spacing + bodyMediumHeight + 2 + bodySmallHeight + 8;
  }

  static double posterRowHeight(double width, TextTheme text) {
    return posterCardTotalHeight(posterCardWidth(width), text);
  }

  static double landscapeRowHeight(double width) {
    return landscapeCardWidth(width) * 9 / 16;
  }

  static double spotlightRowHeight(double width, TextTheme text) {
    return posterRowHeight(width, text);
  }

  static double editorialRowHeight(double width, TextTheme text) {
    final cardWidth = posterCardWidth(width);
    final imageHeight = cardWidth * 3 / 2;
    final titleHeight =
        (text.titleSmall?.fontSize ?? 14) *
        (text.titleSmall?.height ?? 1.43) *
        2;
    return imageHeight + 8 + titleHeight + 20;
  }

  static double miniHeroHeight(double width) {
    if (width < phoneMax) return (width * 9 / 16).clamp(180, 280);
    if (width < tabletMax) return (width * 9 / 22).clamp(220, 360);
    return (width * 9 / 28).clamp(280, 440);
  }

  static double detailHeroHeight(Size screen) {
    if (isDesktop(screen.width)) {
      return (screen.height * 0.35).clamp(280.0, 380.0);
    }
    final fraction = isTablet(screen.width) ? 0.50 : 0.45;
    return (screen.height * fraction).clamp(280.0, 520.0);
  }

  static double gridMaxCrossAxisExtent(double width) {
    if (width < 360) return 150;
    if (width < phoneMax) return 170;
    if (width < tabletMax) return 200;
    return 220;
  }

  /// Effective cell width inside a [SliverGridDelegateWithMaxCrossAxisExtent]
  /// — the delegate fits N columns where each cell is at most [maxExtent],
  /// the rest goes to spacing. We mirror that math so we can derive a
  /// matching aspect ratio.
  static double gridCellWidth({
    required double crossAxisExtent,
    required double maxExtent,
    required double crossAxisSpacing,
  }) {
    final usableWidth = crossAxisExtent + crossAxisSpacing;
    final perChild = maxExtent + crossAxisSpacing;
    final count = (usableWidth / perChild).ceil().clamp(1, 1 << 16);
    return usableWidth / count - crossAxisSpacing;
  }

  /// Aspect ratio that exactly accommodates a poster card
  /// (image 2:3 + 2 lines of body + 1 line subtitle) for the given cell
  /// width. Prevents grid overflow because text height is constant while
  /// cell width shrinks on narrow screens.
  static double posterGridAspectRatio(double cellWidth, TextTheme text) {
    final total = posterCardTotalHeight(cellWidth, text);
    return cellWidth / total;
  }

  static double bottomSheetMaxWidth(double width) {
    if (width < phoneMax) return double.infinity;
    if (width < tabletMax) return 560;
    return 640;
  }

  /// Determines the [WindowSizeClass] for the given width.
  /// Thresholds align with Material 3 Window Size Classes:
  /// - compact: < 600
  /// - medium: 600 - 904
  /// - expanded: 905 - 1199
  /// - large: 1200 - 1599
  /// - extraLarge: >= 1600
  static WindowSizeClass windowSizeClassFromWidth(double width) {
    if (width < 600) return WindowSizeClass.compact;
    if (width < 905) return WindowSizeClass.medium;
    if (width < 1200) return WindowSizeClass.expanded;
    if (width < 1600) return WindowSizeClass.large;
    return WindowSizeClass.extraLarge;
  }

  /// Returns the default [NavigationMode] for the given [WindowSizeClass].
  /// Follows the rule:
  /// - compact -> [NavigationMode.burgerFab]
  /// - medium -> [NavigationMode.railCompact]
  /// - expanded -> [NavigationMode.railExtended]
  /// - large / extraLarge -> [NavigationMode.drawerPermanent]
  static NavigationMode navigationModeForWindowSize(WindowSizeClass sizeClass) {
    return switch (sizeClass) {
      WindowSizeClass.compact => NavigationMode.burgerFab,
      WindowSizeClass.medium => NavigationMode.railCompact,
      WindowSizeClass.expanded => NavigationMode.railExtended,
      WindowSizeClass.large ||
      WindowSizeClass.extraLarge => NavigationMode.drawerPermanent,
    };
  }
}

extension BreakpointsContext on BuildContext {
  Size get _screen => MediaQuery.sizeOf(this);
  double get bpWidth => _screen.width;
  bool get isPhone => Breakpoints.isPhone(bpWidth);
  bool get isTablet => Breakpoints.isTablet(bpWidth);
  bool get isDesktop => Breakpoints.isDesktop(bpWidth);

  /// Returns the [WindowSizeClass] for the current screen width.
  WindowSizeClass get windowSizeClass =>
      Breakpoints.windowSizeClassFromWidth(bpWidth);

  /// Returns the default [NavigationMode] for the current screen size.
  NavigationMode get defaultNavigationMode =>
      Breakpoints.navigationModeForWindowSize(windowSizeClass);
}
