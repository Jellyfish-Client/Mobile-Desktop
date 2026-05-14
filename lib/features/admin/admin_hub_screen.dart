import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import '../settings/widgets/settings_section.dart';

class AdminHubScreen extends StatelessWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          SettingsSection(
            label: context.l10n.adminServer,
            tiles: [
              ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: Text(context.l10n.adminDashboard),
                subtitle: Text(context.l10n.adminDashboardSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/dashboard'),
              ),
              ListTile(
                leading: const Icon(Icons.tune_outlined),
                title: Text(context.l10n.adminServerConfig),
                subtitle: Text(context.l10n.adminServerConfigSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/server-config'),
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(context.l10n.adminBranding),
                subtitle: Text(context.l10n.adminBrandingSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/branding'),
              ),
              ListTile(
                leading: const Icon(Icons.history_outlined),
                title: Text(context.l10n.adminActivityLog),
                subtitle: Text(context.l10n.adminActivityLogSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/activity'),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(context.l10n.adminServerLogs),
                subtitle: Text(context.l10n.adminServerLogsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/logs'),
              ),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: Text(context.l10n.adminBackup),
                subtitle: Text(context.l10n.adminBackupSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/backup'),
              ),
            ],
          ),
          SettingsSection(
            label: context.l10n.adminContent,
            tiles: [
              ListTile(
                leading: const Icon(Icons.folder_copy_outlined),
                title: Text(context.l10n.adminLibraries),
                subtitle: Text(context.l10n.adminLibrariesSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/libraries'),
              ),
              ListTile(
                leading: const Icon(Icons.task_alt_outlined),
                title: Text(context.l10n.adminTasks),
                subtitle: Text(context.l10n.adminTasksSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/tasks'),
              ),
              ListTile(
                leading: const Icon(Icons.extension_outlined),
                title: Text(context.l10n.adminPlugins),
                subtitle: Text(context.l10n.adminPluginsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/plugins'),
              ),
            ],
          ),
          SettingsSection(
            label: context.l10n.adminAccounts,
            tiles: [
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(context.l10n.adminUsers),
                subtitle: Text(context.l10n.adminUsersSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/users'),
              ),
              ListTile(
                leading: const Icon(Icons.cast_outlined),
                title: Text(context.l10n.adminSessions),
                subtitle: Text(context.l10n.adminSessionsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/sessions'),
              ),
              ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: Text(context.l10n.adminDevices),
                subtitle: Text(context.l10n.adminDevicesSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/devices'),
              ),
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined),
                title: Text(context.l10n.adminApiKeys),
                subtitle: Text(context.l10n.adminApiKeysSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/admin/api-keys'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
