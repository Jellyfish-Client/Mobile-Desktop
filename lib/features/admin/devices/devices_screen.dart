import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import 'devices_providers.dart';

class AdminDevicesScreen extends ConsumerWidget {
  const AdminDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminDevicesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminDevices)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminDevicesProvider.notifier).refresh(),
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
          data: (devices) {
            if (devices.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 96),
                  Center(child: Text(context.l10n.adminDevicesEmpty)),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              itemCount: devices.length,
              itemBuilder: (_, i) => _DeviceTile(device: devices[i]),
            );
          },
        ),
      ),
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  const _DeviceTile({required this.device});

  final DeviceInfoDto device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = context.l10n;
    final displayName =
        (device.customName ?? '').isNotEmpty ? device.customName! : device.name;
    final subtitleParts = <String>[
      if ((device.appName ?? '').isNotEmpty)
        device.appName! +
            ((device.appVersion ?? '').isNotEmpty
                ? ' ${device.appVersion}'
                : ''),
      if ((device.lastUserName ?? '').isNotEmpty) device.lastUserName!,
      if (device.dateLastActivity != null)
        DateFormat.yMd().add_Hm().format(device.dateLastActivity!.toLocal()),
    ];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: const Icon(Icons.devices_other),
      ),
      title: Text(displayName ?? '—', overflow: TextOverflow.ellipsis),
      subtitle: subtitleParts.isEmpty
          ? null
          : Text(
              subtitleParts.join(' • '),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'rename') {
            await _promptAndRename(context, ref);
          } else if (value == 'delete') {
            await _confirmAndDelete(context, ref);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem<String>(
            value: 'rename',
            child: Row(
              children: [
                const Icon(Icons.edit_outlined),
                const SizedBox(width: AppSpacing.sm),
                Text(l.adminDevicesRename),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: scheme.error),
                const SizedBox(width: AppSpacing.sm),
                Text(l.adminDevicesDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _promptAndRename(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final id = device.id;
    if (id == null) return;
    final controller = TextEditingController(
      text: (device.customName ?? '').isNotEmpty
          ? device.customName
          : device.name,
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l.adminDevicesRenameDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l.adminDevicesRenameDialogLabel,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l.cancelButton),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(l.adminDevicesRenameDialogSave),
            ),
          ],
        );
      },
    );
    if (newName == null || !context.mounted) return;
    try {
      await ref.read(adminDevicesProvider.notifier).rename(
            id: id,
            customName: newName,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminDevicesRenameSnack)),
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

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final id = device.id;
    if (id == null) return;
    final ok = await showJfConfirm(
      context,
      title: l.adminDevicesDeleteConfirmTitle,
      message: l.adminDevicesDeleteConfirmMessage,
      confirmLabel: l.adminDevicesDelete,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(adminDevicesProvider.notifier).delete(id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminDevicesDeleteSnack)),
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
