import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/app_settings/app_locale_settings.dart';
import 'package:jellyfish/core/auth/auth_controller.dart';
import 'package:jellyfish/core/auth/session.dart';
import 'package:jellyfish/core/bridge/bridge_dio_provider.dart';
import 'package:jellyfish/core/bridge/bridge_services.dart';
import 'package:jellyfish/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tiny app that mirrors the locale-resolution wiring of `JellyfishApp`
/// (without pulling in `go_router` / session state). Any regression in how
/// `AppLocaleSettings` resolves and propagates through `MaterialApp` should
/// surface here.
class _LocaleHarness extends ConsumerWidget {
  const _LocaleHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const supportedLocales = <Locale>[Locale('en'), Locale('fr')];
    final settings =
        ref.watch(appLocaleSettingsProvider).valueOrNull ??
        AppLocaleSettings.defaults;
    final deviceLocales = WidgetsBinding.instance.platformDispatcher.locales;
    final effective = settings.resolve(deviceLocales, supportedLocales);

    return MaterialApp(
      locale: effective,
      localeListResolutionCallback: (_, _) => effective,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(title: Text(l10n.settingsTitle)),
            body: Text(l10n.settingsLanguageSection),
          );
        },
      ),
    );
  }
}

/// Overrides that neutralise the fire-and-forget remote syncs `setLanguage`
/// kicks off. We're testing locale propagation, not Jellyfin/Seerr push.
List<Override> _silentSyncOverrides() => [
  // No session → `_syncJellyfin` short-circuits before any network call.
  authControllerProvider.overrideWith(_NoSessionAuth.new),
  // Jellyseerr unavailable → `SeerrClient.isLinked` is false →
  // `updateLocale` is a no-op.
  bridgeServicesProvider.overrideWith((_) => BridgeServices.unavailable),
  // SeerrClient still reads a Dio instance even when it never calls it;
  // give it an inert one so the provider graph resolves without touching
  // platform channels.
  bridgeDioProvider.overrideWithValue(Dio()),
];

class _NoSessionAuth extends AuthController {
  @override
  Future<SessionState> build() async => SessionState.empty;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpHarness(WidgetTester tester) async {
    final container = ProviderContainer(overrides: _silentSyncOverrides());
    addTearDown(container.dispose);
    // Mirror `main.dart`: settle the locale provider before the first frame.
    await container.read(appLocaleSettingsProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _LocaleHarness(),
      ),
    );
    return container;
  }

  testWidgets('defaults to device locale (en in test environment)', (
    tester,
  ) async {
    await pumpHarness(tester);
    // Test platform locale is en_US by default, so resolve() picks `en`.
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('LANGUAGE'), findsOneWidget);
  });

  testWidgets('setLanguage(fr) switches the entire UI to French', (
    tester,
  ) async {
    final container = await pumpHarness(tester);

    await container.read(appLocaleSettingsProvider.notifier).setLanguage('fr');
    await tester.pumpAndSettle();

    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('LANGUE'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('setLanguage(en) after fr switches the UI back to English', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app.locale': 'fr'});
    final container = await pumpHarness(tester);

    // Initial frame uses persisted 'fr'.
    expect(find.text('Paramètres'), findsOneWidget);

    await container.read(appLocaleSettingsProvider.notifier).setLanguage('en');
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Paramètres'), findsNothing);
  });

  testWidgets('setLanguage("") reverts to device locale', (tester) async {
    SharedPreferences.setMockInitialValues({'app.locale': 'fr'});
    final container = await pumpHarness(tester);

    expect(find.text('Paramètres'), findsOneWidget);

    await container.read(appLocaleSettingsProvider.notifier).setLanguage('');
    await tester.pumpAndSettle();

    // Device locale in tests is en_US → resolves to `en`.
    expect(find.text('Settings'), findsOneWidget);
  });
}
