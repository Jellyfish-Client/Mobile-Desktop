import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../settings/widgets/settings_section.dart';

import 'server_config_providers.dart';

class AdminBrandingScreen extends ConsumerWidget {
  const AdminBrandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminBrandingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminBranding)),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminBrandingProvider.future),
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
          data: (branding) => _BrandingForm(initial: branding),
        ),
      ),
    );
  }
}

class _BrandingForm extends ConsumerStatefulWidget {
  const _BrandingForm({required this.initial});

  final BrandingOptionsDto initial;

  @override
  ConsumerState<_BrandingForm> createState() => _BrandingFormState();
}

class _BrandingFormState extends ConsumerState<_BrandingForm> {
  late TextEditingController _loginDisclaimer;
  late TextEditingController _customCss;
  late bool _splashscreenEnabled;

  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _loginDisclaimer =
        TextEditingController(text: widget.initial.loginDisclaimer ?? '');
    _customCss = TextEditingController(text: widget.initial.customCss ?? '');
    _splashscreenEnabled = widget.initial.splashscreenEnabled ?? false;
    _loginDisclaimer.addListener(_markDirty);
    _customCss.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _loginDisclaimer.dispose();
    _customCss.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        SettingsSection(
          label: l.adminBrandingMessagesSection,
          tiles: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: TextField(
                controller: _loginDisclaimer,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l.adminBrandingLoginDisclaimer,
                  helperText: l.adminBrandingLoginDisclaimerHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        SettingsSection(
          label: l.adminBrandingAppearanceSection,
          tiles: [
            SwitchListTile(
              secondary: const Icon(Icons.image_outlined),
              title: Text(l.adminBrandingSplashscreenEnabled),
              subtitle: Text(l.adminBrandingSplashscreenEnabledHint),
              value: _splashscreenEnabled,
              onChanged: (v) => setState(() {
                _splashscreenEnabled = v;
                _dirty = true;
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: TextField(
                controller: _customCss,
                minLines: 6,
                maxLines: 12,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: l.adminBrandingCustomCss,
                  helperText: l.adminBrandingCustomCssHint,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
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
            onPressed: (_saving || !_dirty) ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(l.adminBrandingSaveButton),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final disclaimer = _loginDisclaimer.text;
      final css = _customCss.text;
      await ref.read(adminServerConfigControllerProvider).saveBranding(
            loginDisclaimer: disclaimer.isEmpty ? null : disclaimer,
            customCss: css.isEmpty ? null : css,
            splashscreenEnabled: _splashscreenEnabled,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminBrandingSaveSnack)),
      );
      setState(() => _dirty = false);
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
