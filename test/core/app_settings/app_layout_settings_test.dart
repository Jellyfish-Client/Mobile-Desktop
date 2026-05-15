import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/app_settings/app_layout_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLayoutSettings', () {
    test('initial values are correct', () {
      const settings = AppLayoutSettings.initial;
      expect(settings.desktopNavMode, DesktopNavMode.collapsed);
      expect(settings.railExtendedOnExpanded, false);
    });

    test('copyWith updates fields correctly', () {
      const original = AppLayoutSettings.initial;
      final updated = original.copyWith(
        desktopNavMode: DesktopNavMode.expanded,
        railExtendedOnExpanded: true,
      );
      expect(updated.desktopNavMode, DesktopNavMode.expanded);
      expect(updated.railExtendedOnExpanded, true);
    });

    test('copyWith preserves unspecified fields', () {
      final original = AppLayoutSettings.initial.copyWith(
        desktopNavMode: DesktopNavMode.expanded,
        railExtendedOnExpanded: true,
      );
      final partial = original.copyWith(
        desktopNavMode: DesktopNavMode.collapsed,
      );
      expect(partial.desktopNavMode, DesktopNavMode.collapsed);
      expect(partial.railExtendedOnExpanded, true);
    });

    test('equality works correctly', () {
      const a = AppLayoutSettings.initial;
      const b = AppLayoutSettings.initial;
      final c = AppLayoutSettings.initial.copyWith(
        desktopNavMode: DesktopNavMode.expanded,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent', () {
      const settings = AppLayoutSettings.initial;
      expect(settings.hashCode, settings.hashCode);
    });

    test('toString produces readable output', () {
      const settings = AppLayoutSettings(
        desktopNavMode: DesktopNavMode.expanded,
        railExtendedOnExpanded: true,
      );
      final str = settings.toString();
      expect(str, contains('AppLayoutSettings'));
      expect(str, contains('expanded'));
      expect(str, contains('true'));
    });
  });

  group('AppLayoutSettingsController', () {
    test('build returns initial values on first run', () async {
      final container = ProviderContainer();
      final settings = await container.read(appLayoutSettingsProvider.future);
      expect(settings.desktopNavMode, DesktopNavMode.collapsed);
      expect(settings.railExtendedOnExpanded, false);
    });

    test('setDesktopNavMode persists to SharedPreferences', () async {
      final container = ProviderContainer();
      // Wait for initial build to complete
      await container.read(appLayoutSettingsProvider.future);

      await container
          .read(appLayoutSettingsProvider.notifier)
          .setDesktopNavMode(DesktopNavMode.expanded);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_layout.desktop_nav_mode'), 'expanded');
    });

    test('setDesktopNavMode updates state optimistically', () async {
      final container = ProviderContainer();
      // Wait for initial build to complete
      await container.read(appLayoutSettingsProvider.future);

      await container
          .read(appLayoutSettingsProvider.notifier)
          .setDesktopNavMode(DesktopNavMode.expanded);

      final settings = container.read(appLayoutSettingsProvider).requireValue;
      expect(settings.desktopNavMode, DesktopNavMode.expanded);
    });

    test('setRailExtendedOnExpanded persists to SharedPreferences', () async {
      final container = ProviderContainer();
      // Wait for initial build to complete
      await container.read(appLayoutSettingsProvider.future);

      await container
          .read(appLayoutSettingsProvider.notifier)
          .setRailExtendedOnExpanded(value: true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('app_layout.rail_extended_on_expanded'), true);
    });

    test('setRailExtendedOnExpanded updates state optimistically', () async {
      final container = ProviderContainer();
      // Wait for initial build to complete
      await container.read(appLayoutSettingsProvider.future);

      await container
          .read(appLayoutSettingsProvider.notifier)
          .setRailExtendedOnExpanded(value: true);

      final settings = container.read(appLayoutSettingsProvider).requireValue;
      expect(settings.railExtendedOnExpanded, true);
    });

    test(
      'toggleDesktopNav cycles collapsed -> expanded -> collapsed',
      () async {
        final container = ProviderContainer();
        // Wait for initial build to complete
        var settings = await container.read(appLayoutSettingsProvider.future);
        expect(settings.desktopNavMode, DesktopNavMode.collapsed);

        // Toggle to expanded
        await container
            .read(appLayoutSettingsProvider.notifier)
            .toggleDesktopNav();
        settings = container.read(appLayoutSettingsProvider).requireValue;
        expect(settings.desktopNavMode, DesktopNavMode.expanded);

        // Toggle back to collapsed
        await container
            .read(appLayoutSettingsProvider.notifier)
            .toggleDesktopNav();
        settings = container.read(appLayoutSettingsProvider).requireValue;
        expect(settings.desktopNavMode, DesktopNavMode.collapsed);
      },
    );

    test('build retrieves persisted values on reinit', () async {
      // First session: set values
      var container = ProviderContainer();
      await container.read(appLayoutSettingsProvider.future);
      await container
          .read(appLayoutSettingsProvider.notifier)
          .setDesktopNavMode(DesktopNavMode.expanded);
      await container
          .read(appLayoutSettingsProvider.notifier)
          .setRailExtendedOnExpanded(value: true);

      // Second session: new container should restore from prefs
      container = ProviderContainer();
      final settings = await container.read(appLayoutSettingsProvider.future);
      expect(settings.desktopNavMode, DesktopNavMode.expanded);
      expect(settings.railExtendedOnExpanded, true);
    });

    test('build handles invalid enum name gracefully', () async {
      // Pre-populate prefs with invalid enum value
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_layout.desktop_nav_mode', 'invalid_value');

      final container = ProviderContainer();
      // Should throw ArgumentError when parsing invalid enum with byName
      expect(
        () => container.read(appLayoutSettingsProvider.future),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
