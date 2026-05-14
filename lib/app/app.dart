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

    // App-level locale: empty `languageCode` means "follow the device" — pass
    // `null` to MaterialApp in that case so Flutter resolves the best match
    // from `supportedLocales`. Until the controller finishes its first load
    // we use the defaults (= device locale), which matches how a fresh
    // install behaves before the user ever opens Settings.
    final localeAsync = ref.watch(appLocaleSettingsProvider);
    final localeSettings =
        localeAsync.valueOrNull ?? AppLocaleSettings.defaults;
    final locale = localeSettings.languageCode.isEmpty
        ? null
        : Locale(localeSettings.languageCode);

    return MaterialApp.router(
      title: 'Jellyfish',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fr')],
    );
  }
}
