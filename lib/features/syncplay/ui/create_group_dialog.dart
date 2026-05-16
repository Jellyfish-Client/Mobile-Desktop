import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/sync_play_providers.dart';

/// Ouvre un dialog de création de groupe SyncPlay.
/// Retourne `true` si le groupe a été créé avec succès.
Future<bool> showCreateGroupDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const _CreateGroupDialog(),
  );
  return result ?? false;
}

class _CreateGroupDialog extends ConsumerStatefulWidget {
  const _CreateGroupDialog();

  @override
  ConsumerState<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<_CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.syncPlayCreateDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JfTextField(
              controller: _nameController,
              label: l10n.syncPlayCreateGroupNameLabel,
              hint: l10n.syncPlayCreateGroupNameHint,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) {
                final trimmed = (v ?? '').trim();
                if (trimmed.isEmpty || trimmed.length > 50) {
                  return l10n.syncPlayCreateGroupNameRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        JfButton.ghost(
          label: MaterialLocalizations.of(context).cancelButtonLabel,
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
        ),
        JfButton.primary(
          label: l10n.syncPlayCreateButton,
          loading: _isLoading,
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Capture les éléments dépendants du contexte avant tout gap async.
    // On utilise this.context (getter State) — validé par le check mounted.
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    setState(() => _isLoading = true);

    try {
      await ref.read(syncPlaySessionProvider.notifier).create(name: name);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.syncPlayCreateError)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
