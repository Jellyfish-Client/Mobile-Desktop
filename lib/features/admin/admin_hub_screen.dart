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
            ],
          ),
        ],
      ),
    );
  }
}
