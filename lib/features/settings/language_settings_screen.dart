import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/app_settings/app_locale_settings.dart';
import '../../l10n/l10n_extension.dart';
import 'widgets/settings_section.dart';

/// Standalone Language picker. Sits behind a Settings tile rather than being
/// inlined on the root Settings screen so the page hierarchy stays consistent
/// with the other category sub-pages (Playback, Downloads, …).
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale =
        ref.watch(appLocaleSettingsProvider).valueOrNull?.languageCode ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsLanguage)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          SettingsSection(
            label: l10n.settingsLanguageSection,
            tiles: [
              RadioGroup<String>(
                groupValue: currentLocale,
                onChanged: (v) => ref
                    .read(appLocaleSettingsProvider.notifier)
                    .setLanguage(v ?? ''),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: '',
                      title: Text(l10n.settingsLanguageSystem),
                    ),
                    RadioListTile<String>(
                      value: 'fr',
                      title: Text(l10n.settingsLanguageFrench),
                    ),
                    RadioListTile<String>(
                      value: 'en',
                      title: Text(l10n.settingsLanguageEnglish),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
