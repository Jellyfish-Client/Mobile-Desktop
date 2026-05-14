import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/jellyfin/jellyfin_client.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import '../../settings/widgets/settings_section.dart';
import 'dashboard_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminSystemInfoProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminDashboard)),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminSystemInfoProvider.future),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 96),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(context.l10n.adminErrorPrefix(e.toString())),
                ),
              ),
            ],
          ),
          data: (info) {
            final l = context.l10n;
            final tiles = <Widget>[
              _InfoTile(label: l.adminServerName, value: info.serverName),
              _InfoTile(label: l.adminVersion, value: info.version),
              _InfoTile(label: l.adminProduct, value: info.productName),
              _InfoTile(label: l.adminServerId, value: info.id),
              if (info.localAddress != null && info.localAddress!.isNotEmpty)
                _InfoTile(label: l.adminLocalAddress, value: info.localAddress),
              if (info.hasPendingRestart ?? false)
                ListTile(
                  leading: Icon(Icons.warning_amber, color: scheme.error),
                  title: Text(l.adminRestartPending),
                  subtitle: Text(l.adminRestartPendingMessage),
                ),
              if (info.isShuttingDown ?? false)
                ListTile(
                  leading: Icon(Icons.power_off_outlined, color: scheme.error),
                  title: Text(l.adminShuttingDown),
                ),
            ];

            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                SettingsSection(label: l.adminInfoSection, tiles: tiles),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xs,
                  ),
                  child: FilledButton.tonalIcon(
                    onPressed: () => _confirmAndRestart(context, ref),
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l.adminRestartButton),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.xs,
                  ),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    ),
                    onPressed: () => _confirmAndShutdown(context, ref),
                    icon: const Icon(Icons.power_settings_new),
                    label: Text(l.adminShutdownButton),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmAndRestart(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showJfConfirm(
      context,
      title: l.adminRestartConfirmTitle,
      message: l.adminRestartConfirmMessage,
      confirmLabel: l.adminRestartConfirmLabel,
      destructive: true,
      confirmIcon: Icons.restart_alt,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(jellyfinApiProvider).getSystemApi().restartApplication();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminRestartSnack)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    }
  }

  Future<void> _confirmAndShutdown(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showJfConfirm(
      context,
      title: l.adminShutdownConfirmTitle,
      message: l.adminShutdownConfirmMessage,
      confirmLabel: l.adminShutdownConfirmLabel,
      destructive: true,
      confirmIcon: Icons.power_settings_new,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(jellyfinApiProvider).getSystemApi().shutdownApplication();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminShutdownSnack)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        (value == null || value!.isEmpty) ? '—' : value!,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
