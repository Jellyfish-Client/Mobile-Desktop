import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import '../../settings/widgets/settings_section.dart';

import 'backup_providers.dart';

class AdminBackupScreen extends ConsumerStatefulWidget {
  const AdminBackupScreen({super.key});

  @override
  ConsumerState<AdminBackupScreen> createState() => _AdminBackupScreenState();
}

class _AdminBackupScreenState extends ConsumerState<AdminBackupScreen> {
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final async = ref.watch(adminBackupProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.adminBackup)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminBackupProvider.notifier).refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 96),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(l.adminErrorPrefix(e.toString())),
                ),
              ),
            ],
          ),
          data: (backups) => ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            children: [
              _CreateBackupCard(
                isCreating: _isCreating,
                onCreate: _create,
              ),
              if (backups.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      l.adminBackupEmpty,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                SettingsSection(
                  label: l.adminBackupListSection,
                  tiles: [
                    for (final manifest in backups)
                      _BackupTile(
                        manifest: manifest,
                        onRestore: () => _confirmAndRestore(manifest),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);
    final messenger = ScaffoldMessenger.of(context)
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.adminBackupCreating)),
      );
    try {
      await ref.read(adminBackupProvider.notifier).create();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.adminBackupCreateSnack)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _confirmAndRestore(BackupManifestDto manifest) async {
    final l = context.l10n;
    final path = manifest.path ?? '';
    if (path.isEmpty) return;

    final first = await showJfConfirm(
      context,
      title: l.adminBackupRestoreConfirm1Title,
      message: l.adminBackupRestoreConfirm1Message,
      confirmLabel: l.adminBackupRestoreConfirm1Confirm,
      destructive: true,
      confirmIcon: Icons.restore,
    );
    if (!first || !mounted) return;

    final second = await showJfConfirm(
      context,
      title: l.adminBackupRestoreConfirm2Title,
      message: l.adminBackupRestoreConfirm2Message,
      confirmLabel: l.adminBackupRestoreConfirm2Confirm,
      destructive: true,
      confirmIcon: Icons.warning_amber,
    );
    if (!second || !mounted) return;

    try {
      await ref.read(adminBackupProvider.notifier).restore(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminBackupRestoreSnack)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    }
  }
}

class _CreateBackupCard extends StatelessWidget {
  const _CreateBackupCard({required this.isCreating, required this.onCreate});

  final bool isCreating;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.backup_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l.adminBackupCreateSectionTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.adminBackupCreateHint,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: isCreating ? null : onCreate,
                  icon: isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.backup),
                  label: Text(l.adminBackupCreate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackupTile extends StatelessWidget {
  const _BackupTile({required this.manifest, required this.onRestore});

  final BackupManifestDto manifest;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final path = manifest.path ?? '';
    final date = manifest.dateCreated?.toLocal();
    final version = manifest.serverVersion ?? '';
    final subtitleBits = <String>[
      if (date != null) date.toString(),
      if (version.isNotEmpty) l.adminBackupVersionPrefix(version),
    ];
    final options = manifest.options;
    final contents = <String>[
      if (options?.metadata ?? false) l.adminBackupContentMetadata,
      if (options?.database ?? false) l.adminBackupContentDatabase,
      if (options?.subtitles ?? false) l.adminBackupContentSubtitles,
      if (options?.trickplay ?? false) l.adminBackupContentTrickplay,
    ];

    return ListTile(
      leading: const Icon(Icons.archive_outlined),
      title: Text(
        path.isEmpty ? '—' : path,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitleBits.isNotEmpty) Text(subtitleBits.join(' • ')),
          if (contents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final label in contents)
                    Chip(
                      label: Text(label),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ),
        ],
      ),
      isThreeLine: contents.isNotEmpty,
      trailing: IconButton(
        icon: const Icon(Icons.restore),
        tooltip: l.adminBackupRestoreTooltip,
        onPressed: path.isEmpty ? null : onRestore,
      ),
    );
  }

}
