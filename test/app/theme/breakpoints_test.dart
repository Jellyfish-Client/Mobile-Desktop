import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/app/theme/breakpoints.dart';

void main() {
  group('WindowSizeClass.fromWidth', () {
    test('returns compact for width < 600', () {
      expect(
        Breakpoints.windowSizeClassFromWidth(599),
        WindowSizeClass.compact,
      );
    });

    test('returns medium for width 600 to 904', () {
      expect(Breakpoints.windowSizeClassFromWidth(600), WindowSizeClass.medium);
      expect(Breakpoints.windowSizeClassFromWidth(904), WindowSizeClass.medium);
    });

    test('returns expanded for width 905 to 1199', () {
      expect(
        Breakpoints.windowSizeClassFromWidth(905),
        WindowSizeClass.expanded,
      );
      expect(
        Breakpoints.windowSizeClassFromWidth(1199),
        WindowSizeClass.expanded,
      );
    });

    test('returns large for width 1200 to 1599', () {
      expect(Breakpoints.windowSizeClassFromWidth(1200), WindowSizeClass.large);
      expect(Breakpoints.windowSizeClassFromWidth(1599), WindowSizeClass.large);
    });

    test('returns extraLarge for width >= 1600', () {
      expect(
        Breakpoints.windowSizeClassFromWidth(1600),
        WindowSizeClass.extraLarge,
      );
      expect(
        Breakpoints.windowSizeClassFromWidth(2560),
        WindowSizeClass.extraLarge,
      );
    });

    test('threshold boundaries are correct', () {
      // compact boundary
      expect(
        Breakpoints.windowSizeClassFromWidth(599),
        WindowSizeClass.compact,
      );
      expect(Breakpoints.windowSizeClassFromWidth(600), WindowSizeClass.medium);

      // medium boundary
      expect(Breakpoints.windowSizeClassFromWidth(904), WindowSizeClass.medium);
      expect(
        Breakpoints.windowSizeClassFromWidth(905),
        WindowSizeClass.expanded,
      );

      // expanded boundary
      expect(
        Breakpoints.windowSizeClassFromWidth(1199),
        WindowSizeClass.expanded,
      );
      expect(Breakpoints.windowSizeClassFromWidth(1200), WindowSizeClass.large);

      // large boundary
      expect(Breakpoints.windowSizeClassFromWidth(1599), WindowSizeClass.large);
      expect(
        Breakpoints.windowSizeClassFromWidth(1600),
        WindowSizeClass.extraLarge,
      );
    });
  });

  group('NavigationMode.defaultFor', () {
    test('compact -> burgerFab', () {
      expect(
        Breakpoints.navigationModeForWindowSize(WindowSizeClass.compact),
        NavigationMode.burgerFab,
      );
    });

    test('medium -> railCompact', () {
      expect(
        Breakpoints.navigationModeForWindowSize(WindowSizeClass.medium),
        NavigationMode.railCompact,
      );
    });

    test('expanded -> railExtended', () {
      expect(
        Breakpoints.navigationModeForWindowSize(WindowSizeClass.expanded),
        NavigationMode.railExtended,
      );
    });

    test('large -> drawerPermanent', () {
      expect(
        Breakpoints.navigationModeForWindowSize(WindowSizeClass.large),
        NavigationMode.drawerPermanent,
      );
    });

    test('extraLarge -> drawerPermanent', () {
      expect(
        Breakpoints.navigationModeForWindowSize(WindowSizeClass.extraLarge),
        NavigationMode.drawerPermanent,
      );
    });
  });
}
