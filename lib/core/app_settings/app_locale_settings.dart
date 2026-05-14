import 'dart:async';

import 'package:flutter/widgets.dart' show Locale, WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../jellyfin/jellyfin_client.dart';
import '../seerr/seerr_client.dart';

/// User-selected app language. An empty [languageCode] means "follow the device
/// locale" — that's the default for fresh installs so the app picks up the
/// system language without any user intervention.
class AppLocaleSettings {
  const AppLocaleSettings({required this.languageCode});

  /// ISO 639-1 code ('fr', 'en'). Empty string means "device locale".
  final String languageCode;

  static const defaults = AppLocaleSettings(languageCode: '');

  AppLocaleSettings copyWith({String? languageCode}) =>
      AppLocaleSettings(languageCode: languageCode ?? this.languageCode);

  /// Resolves the effective [Locale] to feed `MaterialApp.router`. When the
  /// user has forced a language, that wins. Otherwise we walk the OS locale
  /// list and return the first supported language-code match, falling back to
  /// the first supported locale. This is the exact algorithm Flutter applies
  /// by default — re-implementing it here lets us always pass a concrete,
  /// non-null `Locale` to `MaterialApp`, which is the only configuration that
  /// reliably propagates locale changes through `MaterialApp.router` +
  /// `go_router` (passing `null` and letting Flutter resolve internally has
  /// been observed to skip rebuilds of `Localizations` descendants).
  Locale resolve(List<Locale> deviceLocales, List<Locale> supported) {
    if (languageCode.isNotEmpty) return Locale(languageCode);
    for (final dl in deviceLocales) {
      for (final s in supported) {
        if (s.languageCode == dl.languageCode) return s;
      }
    }
    return supported.first;
  }
}

/// Persists the locale preference in SharedPreferences and best-effort syncs
/// the change to Jellyfin (`UserConfiguration.audioLanguagePreference` /
/// `subtitleLanguagePreference`) and Jellyseerr (user settings `locale`).
///
/// Both remote syncs are fire-and-forget: they run after the local state is
/// updated and any failure (offline, missing session, server rejection) is
/// swallowed so it never blocks the UI or surfaces an error to the caller.
class AppLocaleSettingsController extends AsyncNotifier<AppLocaleSettings> {
  static const _kLocale = 'app.locale';

  late SharedPreferences _prefs;

  @override
  Future<AppLocaleSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    return AppLocaleSettings(
      languageCode:
          _prefs.getString(_kLocale) ?? AppLocaleSettings.defaults.languageCode,
    );
  }

  /// Updates the app locale preference. Pass an empty string to revert to
  /// the device locale; pass `'fr'` / `'en'` to force one of the supported
  /// languages. Remote syncs are kicked off in the background and never
  /// propagate errors back to the caller.
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_kLocale, languageCode);
    state = AsyncData(state.requireValue.copyWith(languageCode: languageCode));
    // Skip remote syncs when the user wants the device locale: we don't have
    // a single language code to push, and re-aligning the server every launch
    // would be noisy.
    if (languageCode.isEmpty) return;
    unawaited(_syncJellyfin(languageCode));
    unawaited(_syncSeerr(languageCode));
  }

  /// Pushes the new language to Jellyfin's `UserConfiguration`. Both audio and
  /// subtitle language preferences are aligned with the app language because
  /// users rarely want them to drift. The Jellyfin server expects ISO 639-2/T
  /// codes ('fra', 'eng') in those fields, so we translate from our 639-1
  /// app code on the way out.
  Future<void> _syncJellyfin(String languageCode) async {
    try {
      final session = ref.read(authControllerProvider).valueOrNull?.session;
      if (session == null) return;
      final iso6392 = _toIso6392(languageCode);
      if (iso6392 == null) return;
      final api = ref.read(jellyfinApiProvider);
      final me = await api.getUserApi().getCurrentUser();
      final current = me.data?.configuration;
      if (current == null) return;
      final next = current.rebuild(
        (b) => b
          ..audioLanguagePreference = iso6392
          ..subtitleLanguagePreference = iso6392,
      );
      await api.getUserApi().updateUserConfiguration(
        userId: session.userId,
        userConfiguration: next,
      );
    } on Object catch (_) {
      // Fire-and-forget: never bubble up.
    }
  }

  /// Pushes the new language to Jellyseerr via the bridge passthrough. Silent
  /// on failure (no Seerr linked, network error, …) so a broken Seerr setup
  /// never prevents the app locale from changing.
  Future<void> _syncSeerr(String languageCode) async {
    try {
      await ref.read(seerrClientProvider).updateLocale(languageCode);
    } on Object catch (_) {
      // Fire-and-forget: never bubble up.
    }
  }

  /// Maps an ISO 639-1 code (what we store locally and what Flutter uses for
  /// `Locale`) to the ISO 639-2/T code Jellyfin expects in its user
  /// configuration. Returns null for codes we don't know about so the caller
  /// can skip the sync instead of pushing garbage.
  String? _toIso6392(String code) {
    switch (code) {
      case 'fr':
        return 'fra';
      case 'en':
        return 'eng';
      default:
        return null;
    }
  }
}

final appLocaleSettingsProvider =
    AsyncNotifierProvider<AppLocaleSettingsController, AppLocaleSettings>(
      AppLocaleSettingsController.new,
    );

/// `AppLocalizations` instance for the currently effective app locale.
///
/// Read this from Riverpod providers that need to produce translated strings
/// outside of a `BuildContext` (e.g. building the Home rail catalog inside a
/// FutureProvider). It watches [appLocaleSettingsProvider] so any switch in
/// the Settings screen invalidates the downstream providers and forces them
/// to rebuild their string output for the new language.
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  const supported = <Locale>[Locale('en'), Locale('fr')];
  final settings =
      ref.watch(appLocaleSettingsProvider).valueOrNull ??
      AppLocaleSettings.defaults;
  final deviceLocales = WidgetsBinding.instance.platformDispatcher.locales;
  final locale = settings.resolve(deviceLocales, supported);
  return lookupAppLocalizations(locale);
});
