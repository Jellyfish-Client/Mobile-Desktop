import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/auth/account_key.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/downloads/download_manager.dart';
import '../../core/downloads/download_settings.dart';
import '../../core/storage/app_database_provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/jf_confirm_dialog.dart';

final downloadsStorageProvider = FutureProvider.autoDispose<int>((ref) {
  // Refresh whenever the downloads table changes so the counter stays live.
  ref.watch(allDownloadsProvider);
  final accountKey = ref.watch(
    authControllerProvider.select(
      (s) => accountKeyForSession(s.valueOrNull?.session),
    ),
  );
  return ref.read(appDatabaseProvider).totalDownloadedBytes(accountKey);
});

class DownloadsSettingsScreen extends ConsumerWidget {
  const DownloadsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(downloadSettingsProvider).valueOrNull ??
        DownloadSettings.defaults;
    final controller = ref.read(downloadSettingsProvider.notifier);
    final storage = ref.watch(downloadsStorageProvider).valueOrNull ?? 0;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.downloadsSettingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(label: l10n.downloadsOptions),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_download_outlined),
            title: Text(l10n.downloadsBackgroundEnabled),
            subtitle: Text(l10n.downloadsBackgroundEnabledDescription),
            value: settings.backgroundEnabled,
            onChanged: (v) => controller.setBackgroundEnabled(value: v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: Text(l10n.downloadsWifiOnly),
            subtitle: Text(l10n.downloadsWifiOnlyDescription),
            value: settings.wifiOnly,
            onChanged: (v) => controller.setWifiOnly(value: v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_delete_outlined),
            title: Text(l10n.downloadsAutoDeleteWatched),
            subtitle: Text(l10n.downloadsAutoDeleteWatchedDescription),
            value: settings.autoDeleteWatched,
            onChanged: (v) => controller.setAutoDeleteWatched(value: v),
          ),
          const Divider(),
          _SectionHeader(label: l10n.downloadsStorage),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n.downloadsStorageUsed),
            subtitle: Text(_formatBytes(storage)),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_sweep_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.downloadsDeleteAll,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _confirmDeleteAll(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showJfConfirm(
      context,
      title: l10n.downloadsDeleteAllConfirm,
      message: l10n.downloadsDeleteAllConfirmMessage,
      confirmLabel: l10n.downloadsDeleteAll,
      destructive: true,
    );
    if (!confirmed) return;
    final db = ref.read(appDatabaseProvider);
    final manager = ref.read(downloadManagerProvider);
    final accountKey = accountKeyForSession(
      ref.read(authControllerProvider).valueOrNull?.session,
    );
    final rows = await db.watchAll(accountKey).first;
    for (final r in rows) {
      await manager.deleteDownload(r.itemId);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppTypography.eyebrow(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 Mo';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} Ko';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} Go';
}
