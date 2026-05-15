import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_async_scaffold.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import 'api_keys_providers.dart';

// i18n keys consumed (added in Phase B):
//   adminApiKeys, adminApiKeysSubtitle, adminApiKeysEmpty,
//   adminApiKeysCreate, adminApiKeysCreateDialogTitle,
//   adminApiKeysAppNameLabel, adminApiKeysAppNameHelper,
//   adminApiKeysAppNameRequired, adminApiKeysCreateButton,
//   adminApiKeysCreateSuccess, adminApiKeysCopy, adminApiKeysCopied,
//   adminApiKeysRevoke, adminApiKeysRevokeConfirmTitle,
//   adminApiKeysRevokeConfirmMessage, adminApiKeysRevokeConfirmLabel,
//   adminApiKeysCreatedAt, adminApiKeysCancel,
//   adminFailurePrefix, adminErrorPrefix.

class AdminApiKeysScreen extends ConsumerWidget {
  const AdminApiKeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminApiKeysProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminApiKeys)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.adminApiKeysCreate),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminApiKeysProvider.notifier).refresh(),
        child: JfAsyncScaffold(
          value: async,
          maxWidth: double.infinity,
          padding: EdgeInsets.zero,
          error: (e, _) => ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(context.l10n.adminErrorPrefix(e.toString())),
                ),
              ),
            ],
          ),
          isEmpty: (keys) => keys.isEmpty,
          empty: ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Text(
                    context.l10n.adminApiKeysEmpty,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          data: (keys) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            itemCount: keys.length,
            itemBuilder: (_, i) => _ApiKeyCard(entry: keys[i]),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l = context.l10n;

    final submitted = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.adminApiKeysCreateDialogTitle),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.adminApiKeysAppNameLabel,
                helperText: l.adminApiKeysAppNameHelper,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.adminApiKeysAppNameRequired
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.adminApiKeysCancel),
            ),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(ctx).pop(controller.text.trim());
              },
              icon: const Icon(Icons.vpn_key_outlined),
              label: Text(l.adminApiKeysCreateButton),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (submitted == null || submitted.isEmpty) return;
    if (!context.mounted) return;
    try {
      await ref.read(adminApiKeysProvider.notifier).create(submitted);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminApiKeysCreateSuccess)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminFailurePrefix(e.toString()))),
      );
    }
  }
}

class _ApiKeyCard extends ConsumerWidget {
  const _ApiKeyCard({required this.entry});

  final AuthenticationInfo entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final token = entry.accessToken;
    final masked = _mask(token);

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
                        entry.appName ?? '—',
                        style: theme.textTheme.titleMedium,
                      ),
                      if ((entry.deviceName ?? '').isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          entry.deviceName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (entry.dateCreated != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l.adminApiKeysCreatedAt(_fmtDate(entry.dateCreated!)),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (token != null && token.isNotEmpty)
              GestureDetector(
                onLongPress: () => _copyToken(context, token),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          masked,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l.adminApiKeysCopy,
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () => _copyToken(context, token),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                onPressed: token == null || token.isEmpty
                    ? null
                    : () => _onRevoke(context, ref, token: token),
                icon: const Icon(Icons.delete_outline),
                label: Text(l.adminApiKeysRevoke),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mask(String? token) {
    if (token == null || token.isEmpty) return '—';
    if (token.length <= 12) return token;
    final head = token.substring(0, 4);
    final tail = token.substring(token.length - 4);
    return '$head${'•' * 8}$tail';
  }

  String _fmtDate(DateTime when) {
    final local = when.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _copyToken(BuildContext context, String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.adminApiKeysCopied)));
  }

  Future<void> _onRevoke(
    BuildContext context,
    WidgetRef ref, {
    required String token,
  }) async {
    final l = context.l10n;
    final confirmed = await showJfConfirm(
      context,
      title: l.adminApiKeysRevokeConfirmTitle,
      message: l.adminApiKeysRevokeConfirmMessage(entry.appName ?? '—'),
      confirmLabel: l.adminApiKeysRevokeConfirmLabel,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    try {
      await ref.read(adminApiKeysProvider.notifier).revoke(token);
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminFailurePrefix(e.toString()))),
      );
    }
  }
}
