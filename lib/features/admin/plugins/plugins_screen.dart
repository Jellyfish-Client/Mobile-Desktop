import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import 'plugins_providers.dart';

// i18n keys consumed (added in Phase B):
//   adminPlugins, adminPluginsSubtitle, adminPluginsEmpty,
//   adminPluginsUninstall, adminPluginsUninstallConfirmTitle,
//   adminPluginsUninstallConfirmMessage, adminPluginsUninstallConfirmLabel,
//   adminPluginsStatusActive, adminPluginsStatusDisabled,
//   adminPluginsStatusRestart, adminPluginsStatusMalfunctioned,
//   adminPluginsStatusNotSupported, adminPluginsStatusDeleted,
//   adminPluginsStatusSuperseded, adminPluginsVersionLabel,
//   adminPluginsEnableTooltip, adminPluginsDisableTooltip,
//   adminFailurePrefix, adminErrorPrefix.

class AdminPluginsScreen extends ConsumerWidget {
  const AdminPluginsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminPluginsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminPlugins)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminPluginsProvider.notifier).refresh(),
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
          data: (plugins) {
            if (plugins.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        context.l10n.adminPluginsEmpty,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              itemCount: plugins.length,
              itemBuilder: (_, i) => _PluginCard(plugin: plugins[i]),
            );
          },
        ),
      ),
    );
  }
}

class _PluginCard extends ConsumerWidget {
  const _PluginCard({required this.plugin});

  final PluginInfo plugin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final status = plugin.status;
    final isActive = status == PluginStatus.active;
    final canUninstall = plugin.canUninstall ?? true;
    final pluginId = plugin.id;
    final version = plugin.version;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plugin.name ?? '—',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (version != null && version.isNotEmpty)
                            Text(
                              l.adminPluginsVersionLabel(version),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          if (version != null && version.isNotEmpty)
                            const SizedBox(width: AppSpacing.sm),
                          _StatusChip(status: status),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (pluginId == null || version == null)
                      ? null
                      : (next) => _onToggle(
                            context,
                            ref,
                            pluginId: pluginId,
                            version: version,
                            value: next,
                          ),
                ),
                PopupMenuButton<_PluginAction>(
                  tooltip: '',
                  onSelected: (action) {
                    if (action == _PluginAction.uninstall && pluginId != null) {
                      _onUninstall(context, ref, pluginId: pluginId);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _PluginAction.uninstall,
                      enabled: canUninstall && pluginId != null,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: scheme.error),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l.adminPluginsUninstall),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if ((plugin.description ?? '').isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                plugin.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onToggle(
    BuildContext context,
    WidgetRef ref, {
    required String pluginId,
    required String version,
    required bool value,
  }) async {
    try {
      await ref.read(adminPluginsProvider.notifier).setEnabled(
            pluginId,
            version,
            value: value,
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

  Future<void> _onUninstall(
    BuildContext context,
    WidgetRef ref, {
    required String pluginId,
  }) async {
    final l = context.l10n;
    final confirmed = await showJfConfirm(
      context,
      title: l.adminPluginsUninstallConfirmTitle,
      message: l.adminPluginsUninstallConfirmMessage(plugin.name ?? '—'),
      confirmLabel: l.adminPluginsUninstallConfirmLabel,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    try {
      await ref.read(adminPluginsProvider.notifier).uninstall(pluginId);
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

enum _PluginAction { uninstall }

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PluginStatus? status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = context.l10n;

    final (label, fg, bg) = switch (status) {
      PluginStatus.active => (
          l.adminPluginsStatusActive,
          scheme.onPrimaryContainer,
          scheme.primaryContainer,
        ),
      PluginStatus.disabled => (
          l.adminPluginsStatusDisabled,
          scheme.onSurfaceVariant,
          scheme.surfaceContainerHighest,
        ),
      PluginStatus.restart => (
          l.adminPluginsStatusRestart,
          scheme.onTertiaryContainer,
          scheme.tertiaryContainer,
        ),
      PluginStatus.malfunctioned => (
          l.adminPluginsStatusMalfunctioned,
          scheme.onErrorContainer,
          scheme.errorContainer,
        ),
      PluginStatus.notSupported => (
          l.adminPluginsStatusNotSupported,
          scheme.onErrorContainer,
          scheme.errorContainer,
        ),
      PluginStatus.deleted => (
          l.adminPluginsStatusDeleted,
          scheme.onErrorContainer,
          scheme.errorContainer,
        ),
      PluginStatus.superseded || PluginStatus.superceded => (
          l.adminPluginsStatusSuperseded,
          scheme.onSurfaceVariant,
          scheme.surfaceContainerHighest,
        ),
      _ => (
          '—',
          scheme.onSurfaceVariant,
          scheme.surfaceContainerHighest,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
