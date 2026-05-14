import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/saved_account.dart';
import '../../../core/jellyfin/jellyfin_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../l10n/l10n_extension.dart';
import '../../accounts/widgets/account_avatar.dart';
import '../widgets/settings_section.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final accountAsync = ref.watch(activeSavedAccountProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileDisplayName)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(currentUserProvider)
            ..invalidate(activeSavedAccountProvider);
          await ref.read(currentUserProvider.future);
        },
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 96),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(l10n.errorFailed('$e')),
                ),
              ),
            ],
          ),
          data: (user) => ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            children: [
              _AvatarHeader(
                user: user,
                account: accountAsync.valueOrNull,
              ),
              SettingsSection(
                label: l10n.settingsAccount,
                tiles: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(l10n.profileDisplayName),
                    subtitle: Text(user.name ?? '—'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editDisplayName(context, ref, user),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(l10n.profileChangePassword),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _changePassword(context, ref, user),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    UserDto user,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DisplayNameSheet(initial: user.name ?? ''),
    );
    if (result == null || result.isEmpty || result == user.name) return;
    if (!context.mounted) return;
    try {
      final updated = user.rebuild((b) => b..name = result);
      await ref.read(jellyfinApiProvider).getUserApi().updateUser(
            userId: user.id,
            userDto: updated,
          );
      await ref.read(authControllerProvider.notifier).refreshUserName(result);
      ref
        ..invalidate(currentUserProvider)
        ..invalidate(activeSavedAccountProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileDisplayNameUpdated)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorFailed('$e'))),
      );
    }
  }

  Future<void> _changePassword(
    BuildContext context,
    WidgetRef ref,
    UserDto user,
  ) async {
    final result = await showModalBottomSheet<({String current, String next})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ChangePasswordSheet(),
    );
    if (result == null) return;
    if (!context.mounted) return;
    try {
      await ref.read(jellyfinApiProvider).getUserApi().updateUserPassword(
            userId: user.id,
            updateUserPassword: UpdateUserPassword(
              (b) => b
                ..currentPw = result.current
                ..newPw = result.next,
            ),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profilePasswordChanged)),
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      final isAuthError =
          e.response?.statusCode == 401 || e.response?.statusCode == 403;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAuthError
                ? context.l10n.profilePasswordIncorrect
                : context.l10n.errorFailed('${e.message ?? e}'),
          ),
        ),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorFailed('$e'))),
      );
    }
  }
}

class _AvatarHeader extends ConsumerWidget {
  const _AvatarHeader({required this.user, required this.account});

  final UserDto user;
  final SavedAccount? account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = account;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          if (acc != null)
            AccountAvatar(account: acc, size: 96)
          else
            const SizedBox(width: 96, height: 96),
          const SizedBox(height: AppSpacing.md),
          Text(
            user.name ?? '—',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickAndUpload(context, ref, user),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.profileChangePhoto),
              ),
              if (user.primaryImageTag != null)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                  onPressed: () => _deleteAvatar(context, ref, user),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.profileDeletePhoto),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref,
    UserDto user,
  ) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorFailed('$e'))),
      );
      return;
    }
    if (picked == null || !context.mounted) return;
    try {
      final bytes = await picked.readAsBytes();
      // Jellyfin's POST /UserImage doesn't accept a raw binary body despite
      // what the generated SDK suggests: the server reads the body as a
      // string and base64-decodes it. Sending raw bytes gets rejected with
      // "Incorrect ContentType" (misleading name — it really means "not a
      // base64 string"). We bypass the SDK wrapper and POST through Dio
      // directly with the base64 payload and a concrete image/* MIME so the
      // server can pick the right decoder.
      final mime = _mimeFor(picked);
      final dio = ref.read(jellyfinDioProvider);
      await dio.post<void>(
        'UserImage',
        data: base64Encode(bytes),
        queryParameters: {if (user.id != null) 'userId': user.id},
        options: Options(contentType: mime),
      );
      // Refresh the UserDto so we get the new primaryImageTag from the
      // server, then mirror it onto the SavedAccount so AccountAvatar's
      // CachedNetworkImage cache key changes and forces a fresh fetch.
      final fresh = await ref
          .read(jellyfinApiProvider)
          .getUserApi()
          .getCurrentUser();
      await ref
          .read(authControllerProvider.notifier)
          .refreshAvatarTag(fresh.data?.primaryImageTag);
      ref
        ..invalidate(currentUserProvider)
        ..invalidate(activeSavedAccountProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profilePhotoUpdated)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorFailed('$e'))),
      );
    }
  }

  /// Best-effort MIME inference for the picked image. ImagePicker normalises
  /// most pictures to JPEG, but PNG/WebP pass through unchanged on Android.
  /// Falls back to image/jpeg, the safe default.
  String _mimeFor(XFile picked) {
    final declared = picked.mimeType;
    if (declared != null && declared.startsWith('image/')) return declared;
    final lower = picked.name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _deleteAvatar(
    BuildContext context,
    WidgetRef ref,
    UserDto user,
  ) async {
    try {
      await ref.read(jellyfinApiProvider).getImageApi().deleteUserImage(
            userId: user.id,
          );
      await ref.read(authControllerProvider.notifier).refreshAvatarTag(null);
      ref
        ..invalidate(currentUserProvider)
        ..invalidate(activeSavedAccountProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profilePhotoDeleted)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorFailed('$e'))),
      );
    }
  }
}

class _DisplayNameSheet extends StatefulWidget {
  const _DisplayNameSheet({required this.initial});

  final String initial;

  @override
  State<_DisplayNameSheet> createState() => _DisplayNameSheetState();
}

class _DisplayNameSheetState extends State<_DisplayNameSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl + viewInsets,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileDisplayNameTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancelButton),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(_controller.text.trim()),
                child: Text(l10n.successSaved),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl + viewInsets,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profileChangePasswordTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _current,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.profileCurrentPassword,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.profileRequired : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _next,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.profileNewPassword,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.profileRequired : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.profileConfirmPassword,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.profileRequired;
                if (v != _next.text) return l10n.profilePasswordsDoNotMatch;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancelButton),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    Navigator.of(context).pop(
                      (current: _current.text, next: _next.text),
                    );
                  },
                  child: Text(l10n.successSaved),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
