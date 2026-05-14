import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/app_settings/app_locale_settings.dart';
import '../../core/auth/accounts_repository.dart';
import '../../core/auth/auth_controller.dart';
import '../../l10n/l10n_extension.dart';
import '../admin/admin_providers.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull?.session;
    final isAdmin = ref.watch(isAdminProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final currentLocale =
        ref.watch(appLocaleSettingsProvider).valueOrNull?.languageCode ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          SettingsSection(
            label: l10n.settingsAccount,
            tiles: [
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(l10n.settingsMyProfile),
                subtitle: Text(l10n.settingsMyProfileSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/profile'),
              ),
              ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: Text(l10n.settingsServer),
                subtitle: Text(session?.serverUrl ?? '—'),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.settingsUser),
                subtitle: Text(session?.userName ?? '—'),
              ),
              _AccountSwitcherTile(onTap: () => context.push('/accounts')),
              ListTile(
                leading: Icon(Icons.logout, color: scheme.error),
                title: Text(
                  l10n.settingsLogout,
                  style: TextStyle(color: scheme.error),
                ),
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).clear();
                  if (!context.mounted) return;
                  // The auth controller falls back to the next account or to
                  // the empty state on its own; the router redirect picks the
                  // right destination from there.
                  final nextSession = ref
                      .read(authControllerProvider)
                      .valueOrNull
                      ?.session;
                  context.go(
                    nextSession == null ? '/onboarding/server' : '/home',
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            label: l10n.settingsDownloads,
            tiles: [
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(l10n.settingsDownloadsTitle),
                subtitle: Text(l10n.settingsDownloadsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/downloads'),
              ),
            ],
          ),
          SettingsSection(
            label: l10n.settingsDiscovery,
            tiles: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text(l10n.settingsRequests),
                subtitle: Text(l10n.settingsRequestsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/requests'),
              ),
            ],
          ),
          SettingsSection(
            label: l10n.settingsPlayback,
            tiles: [
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(l10n.settingsPlaybackTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/playback'),
              ),
            ],
          ),
          if (isAdmin)
            SettingsSection(
              label: l10n.settingsAdmin,
              tiles: [
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: Text(l10n.settingsAdminTitle),
                  subtitle: Text(l10n.settingsAdminSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/admin'),
                ),
              ],
            ),
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
          SettingsSection(
            label: l10n.settingsAbout,
            tiles: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsAboutTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountSwitcherTile extends ConsumerWidget {
  const _AccountSwitcherTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(_accountsCountProvider);
    final count = accountsAsync.valueOrNull ?? 0;
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.switch_account_outlined),
      title: Text(l10n.settingsSwitchAccount),
      subtitle: Text(
        count <= 1
            ? l10n.settingsSwitchAccountSubtitleSingle
            : l10n.settingsSwitchAccountSubtitleMultiple(count),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

final _accountsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  // Rebuild when sessions change.
  ref.watch(authControllerProvider);
  final list = await ref.read(accountsRepositoryProvider).readAll();
  return list.length;
});
