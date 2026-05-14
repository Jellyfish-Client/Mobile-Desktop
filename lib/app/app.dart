import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_settings/app_locale_settings.dart';
import '../features/admin/admin_providers.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class JellyfishApp extends ConsumerWidget {
  const JellyfishApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Mount the boot-time admin flag refresher: it watches the active session
    // and refetches `/Users/Me` so isAdmin stays in sync with the server even
    // for accounts persisted before the flag existed.
    ref.watch(currentUserAdminRefresherProvider);

    // App-level locale: empty `languageCode` means "follow the device". We
    // resolve the effective `Locale` ourselves (against the live OS locale
    // list) so we can always pass a concrete, non-null `Locale` to
    // `MaterialApp.router` AND back it with a `localeListResolutionCallback`
    // that re-imposes the same value on every resolution pass. This is what
    // forces `Localizations` to invalidate its descendants when the user
    // switches language at runtime — passing `null` and relying on Flutter's
    // default resolver does not consistently rebuild the Navigator subtree
    // under `MaterialApp.router`.
    const supportedLocales = <Locale>[Locale('en'), Locale('fr')];
    final localeSettings =
        ref.watch(appLocaleSettingsProvider).valueOrNull ??
        AppLocaleSettings.defaults;
    final deviceLocales = WidgetsBinding.instance.platformDispatcher.locales;
    final effectiveLocale = localeSettings.resolve(
      deviceLocales,
      supportedLocales,
    );

    return MaterialApp.router(
      title: 'Jellyfish',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
      locale: effectiveLocale,
      localeListResolutionCallback: (_, _) => effectiveLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
    );
  }
}
