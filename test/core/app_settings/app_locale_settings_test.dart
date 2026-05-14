import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/app_settings/app_locale_settings.dart';

void main() {
  const supported = <Locale>[Locale('en'), Locale('fr')];

  group('AppLocaleSettings.resolve', () {
    test('forced language wins over device list', () {
      const s = AppLocaleSettings(languageCode: 'en');
      expect(
        s.resolve(const [Locale('fr', 'FR')], supported),
        const Locale('en'),
      );
    });

    test('empty preference matches first device locale by languageCode', () {
      const s = AppLocaleSettings.defaults;
      expect(
        s.resolve(const [Locale('fr', 'FR'), Locale('en', 'US')], supported),
        const Locale('fr'),
      );
    });

    test('empty preference walks down device list until a match', () {
      const s = AppLocaleSettings.defaults;
      expect(
        s.resolve(const [Locale('es', 'ES'), Locale('en', 'US')], supported),
        const Locale('en'),
      );
    });

    test('empty preference falls back to first supported when no match', () {
      const s = AppLocaleSettings.defaults;
      expect(
        s.resolve(const [Locale('es'), Locale('de')], supported),
        const Locale('en'),
      );
    });

    test('empty preference with empty device list returns first supported', () {
      const s = AppLocaleSettings.defaults;
      expect(s.resolve(const [], supported), const Locale('en'));
    });
  });
}
