import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import '../../settings/widgets/settings_section.dart';
import '../libraries/libraries_providers.dart';
import 'users_providers.dart';

class AdminUserEditScreen extends ConsumerWidget {
  const AdminUserEditScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminUserByIdProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminUserEditTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(context.l10n.adminErrorPrefix(e.toString())),
          ),
        ),
        data: (user) => _UserEditForm(user: user),
      ),
    );
  }
}

class _UserEditForm extends ConsumerStatefulWidget {
  const _UserEditForm({required this.user});

  final UserDto user;

  @override
  ConsumerState<_UserEditForm> createState() => _UserEditFormState();
}

class _UserEditFormState extends ConsumerState<_UserEditForm> {
  late bool _isAdmin;
  late bool _isDisabled;
  late bool _enableAllFolders;
  late Set<String> _enabledFolderIds;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.user.policy;
    _isAdmin = p?.isAdministrator ?? false;
    _isDisabled = p?.isDisabled ?? false;
    _enableAllFolders = p?.enableAllFolders ?? true;
    _enabledFolderIds = {...?p?.enabledFolders};
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final activeUserId =
        ref.watch(authControllerProvider).valueOrNull?.session?.userId;
    final isSelf = user.id == activeUserId;
    final librariesAsync = ref.watch(adminLibrariesProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        SettingsSection(
          label: context.l10n.adminUserEditIdentitySection,
          tiles: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(user.name ?? '—'),
              subtitle: Text(user.id ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(context.l10n.adminUserEditLastLogin),
              subtitle: Text(user.lastLoginDate?.toLocal().toString() ?? '—'),
            ),
          ],
        ),
        SettingsSection(
          label: context.l10n.adminUserEditRightsSection,
          tiles: [
            SwitchListTile(
              secondary: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(context.l10n.adminUserEditIsAdmin),
              subtitle: isSelf
                  ? Text(context.l10n.adminUserEditIsAdminSelfHint)
                  : null,
              value: _isAdmin,
              onChanged: isSelf
                  ? null
                  : (v) => setState(() => _isAdmin = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.block),
              title: Text(context.l10n.adminUserEditIsDisabled),
              subtitle: isSelf
                  ? Text(context.l10n.adminUserEditIsDisabledSelfHint)
                  : null,
              value: _isDisabled,
              onChanged: isSelf
                  ? null
                  : (v) => setState(() => _isDisabled = v),
            ),
          ],
        ),
        SettingsSection(
          label: context.l10n.adminUserEditLibrariesSection,
          tiles: [
            SwitchListTile(
              secondary: const Icon(Icons.folder_copy_outlined),
              title: Text(context.l10n.adminUserEditAllFolders),
              value: _enableAllFolders,
              onChanged: (v) => setState(() => _enableAllFolders = v),
            ),
            if (!_enableAllFolders)
              librariesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(context.l10n.adminErrorPrefix(e.toString())),
                ),
                data: (folders) => Column(
                  children: [
                    for (final f in folders)
                      CheckboxListTile(
                        title: Text(f.name ?? '—'),
                        value: _enabledFolderIds.contains(f.itemId),
                        onChanged: f.itemId == null
                            ? null
                            : (checked) => setState(() {
                                  if (checked ?? false) {
                                    _enabledFolderIds.add(f.itemId!);
                                  } else {
                                    _enabledFolderIds.remove(f.itemId);
                                  }
                                }),
                      ),
                  ],
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(context.l10n.adminUserEditSaveButton),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: OutlinedButton.icon(
            onPressed: _resetPassword,
            icon: const Icon(Icons.lock_reset),
            label: Text(context.l10n.adminUserEditResetPassword),
          ),
        ),
        if (!isSelf)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(context.l10n.adminUserEditDeleteButton),
            ),
          ),
      ],
    );
  }

  Future<void> _save() async {
    final user = widget.user;
    if (user.id == null) return;
    setState(() => _saving = true);
    try {
      final base = (user.policy?.toBuilder() ?? UserPolicyBuilder())
        ..isAdministrator = _isAdmin
        ..isDisabled = _isDisabled
        ..enableAllFolders = _enableAllFolders
        ..enabledFolders.replace(
          _enableAllFolders ? const <String>[] : _enabledFolderIds.toList(),
        );
      await ref
          .read(adminUsersProvider.notifier)
          .updatePolicy(user.id!, base.build());
      // Refresh the single-user provider so other consumers see the change.
      ref.invalidate(adminUserByIdProvider(user.id!));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminUserEditSaveSnack)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetPassword() async {
    final controller = TextEditingController();
    final String? newPwd;
    try {
      newPwd = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.adminUserEditNewPasswordTitle),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              hintText: context.l10n.adminUserEditNewPasswordHint,
            ),
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.adminUserEditResetPasswordCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: Text(context.l10n.adminUserEditResetPasswordConfirm),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    if (!mounted) return;
    if (newPwd == null || newPwd.isEmpty) return;
    try {
      await ref.read(adminUsersProvider.notifier).resetPassword(
            userId: widget.user.id!,
            newPassword: newPwd,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminUserEditResetPasswordSnack)),
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

  Future<void> _delete() async {
    final ok = await showJfConfirm(
      context,
      title: context.l10n.adminUserEditDeleteTitle(widget.user.name ?? '—'),
      message: context.l10n.adminUserEditDeleteMessage,
      confirmLabel: context.l10n.adminUserEditDeleteConfirm,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(adminUsersProvider.notifier).delete(widget.user.id!);
      if (!mounted) return;
      context.pop();
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
