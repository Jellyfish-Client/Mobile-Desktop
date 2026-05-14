import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import 'users_providers.dart';

class AdminUserCreateScreen extends ConsumerStatefulWidget {
  const AdminUserCreateScreen({super.key});

  @override
  ConsumerState<AdminUserCreateScreen> createState() =>
      _AdminUserCreateScreenState();
}

class _AdminUserCreateScreenState extends ConsumerState<AdminUserCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _password = TextEditingController();
  bool _isAdmin = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.adminUserCreateTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.adminUserCreateName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.adminUserCreateRequired : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l.adminUserCreatePassword,
                helperText: l.adminUserCreatePasswordHelper,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: Text(l.adminUserCreateIsAdmin),
              subtitle: Text(l.adminUserCreateIsAdminSubtitle),
              value: _isAdmin,
              onChanged: (v) => setState(() => _isAdmin = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_1),
              label: Text(l.adminUserCreateButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminUsersProvider.notifier).create(
            username: _name.text.trim(),
            password: _password.text,
            isAdmin: _isAdmin,
          );
      if (!mounted) return;
      context.pop();
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
}
