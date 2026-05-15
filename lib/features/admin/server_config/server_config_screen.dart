import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_async_scaffold.dart';
import '../../settings/widgets/settings_section.dart';

import 'server_config_providers.dart';

class AdminServerConfigScreen extends ConsumerWidget {
  const AdminServerConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminServerConfigProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminServerConfig)),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminServerConfigProvider.future),
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
          data: (config) => _ServerConfigForm(initial: config),
        ),
      ),
    );
  }
}

class _ServerConfigForm extends ConsumerStatefulWidget {
  const _ServerConfigForm({required this.initial});

  final ServerConfiguration initial;

  @override
  ConsumerState<_ServerConfigForm> createState() => _ServerConfigFormState();
}

class _ServerConfigFormState extends ConsumerState<_ServerConfigForm> {
  late TextEditingController _serverName;
  late TextEditingController _uiCulture;
  late TextEditingController _logRetention;
  late TextEditingController _slowThreshold;

  late bool _enableMetrics;
  late bool _enableNormalizedItemByNameIds;
  late bool _quickConnectAvailable;
  late bool _enableSlowResponseWarning;
  late List<String> _corsHosts;

  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _serverName = TextEditingController(text: c.serverName ?? '');
    _uiCulture = TextEditingController(text: c.uICulture ?? '');
    _logRetention = TextEditingController(
      text: (c.logFileRetentionDays ?? 0).toString(),
    );
    _slowThreshold = TextEditingController(
      text: (c.slowResponseThresholdMs ?? 0).toString(),
    );
    _enableMetrics = c.enableMetrics ?? false;
    _enableNormalizedItemByNameIds = c.enableNormalizedItemByNameIds ?? false;
    _quickConnectAvailable = c.quickConnectAvailable ?? false;
    _enableSlowResponseWarning = c.enableSlowResponseWarning ?? false;
    _corsHosts = c.corsHosts?.toList() ?? <String>[];

    for (final controller in [
      _serverName,
      _uiCulture,
      _logRetention,
      _slowThreshold,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _serverName.dispose();
    _uiCulture.dispose();
    _logRetention.dispose();
    _slowThreshold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final initial = widget.initial;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        SettingsSection(
          label: l.adminServerConfigIdentitySection,
          tiles: [
            _TextFieldTile(
              icon: Icons.dns_outlined,
              label: l.adminServerConfigServerName,
              controller: _serverName,
            ),
            _TextFieldTile(
              icon: Icons.language,
              label: l.adminServerConfigUiCulture,
              hint: 'en, fr, de, …',
              controller: _uiCulture,
            ),
          ],
        ),
        SettingsSection(
          label: l.adminServerConfigPathsSection,
          tiles: [
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(l.adminServerConfigCachePath),
              subtitle: Text(
                (initial.cachePath == null || initial.cachePath!.isEmpty)
                    ? '—'
                    : initial.cachePath!,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder_special_outlined),
              title: Text(l.adminServerConfigMetadataPath),
              subtitle: Text(
                (initial.metadataPath == null || initial.metadataPath!.isEmpty)
                    ? '—'
                    : initial.metadataPath!,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l.adminServerConfigStartupWizard),
              subtitle: Text(
                (initial.isStartupWizardCompleted ?? false)
                    ? l.adminServerConfigStartupWizardDone
                    : l.adminServerConfigStartupWizardPending,
              ),
            ),
          ],
        ),
        SettingsSection(
          label: l.adminServerConfigBehaviorSection,
          tiles: [
            SwitchListTile(
              secondary: const Icon(Icons.bolt_outlined),
              title: Text(l.adminServerConfigQuickConnect),
              value: _quickConnectAvailable,
              onChanged: (v) => setState(() {
                _quickConnectAvailable = v;
                _dirty = true;
              }),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.insights_outlined),
              title: Text(l.adminServerConfigEnableMetrics),
              subtitle: Text(l.adminServerConfigEnableMetricsHint),
              value: _enableMetrics,
              onChanged: (v) => setState(() {
                _enableMetrics = v;
                _dirty = true;
              }),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: Text(l.adminServerConfigNormalizedIds),
              subtitle: Text(l.adminServerConfigNormalizedIdsHint),
              value: _enableNormalizedItemByNameIds,
              onChanged: (v) => setState(() {
                _enableNormalizedItemByNameIds = v;
                _dirty = true;
              }),
            ),
          ],
        ),
        SettingsSection(
          label: l.adminServerConfigDiagnosticsSection,
          tiles: [
            _TextFieldTile(
              icon: Icons.history,
              label: l.adminServerConfigLogRetention,
              hint: '7',
              controller: _logRetention,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SwitchListTile(
              secondary: const Icon(Icons.speed_outlined),
              title: Text(l.adminServerConfigSlowResponse),
              value: _enableSlowResponseWarning,
              onChanged: (v) => setState(() {
                _enableSlowResponseWarning = v;
                _dirty = true;
              }),
            ),
            if (_enableSlowResponseWarning)
              _TextFieldTile(
                icon: Icons.timer_outlined,
                label: l.adminServerConfigSlowResponseThreshold,
                hint: '500',
                controller: _slowThreshold,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
          ],
        ),
        _CorsHostsSection(
          hosts: _corsHosts,
          onAdd: _addCorsHost,
          onRemove: _removeCorsHost,
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
            label: Text(l.adminServerConfigSaveButton),
          ),
        ),
      ],
    );
  }

  Future<void> _addCorsHost() async {
    final controller = TextEditingController();
    final String? host;
    try {
      host = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.adminServerConfigCorsAddTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: context.l10n.adminServerConfigCorsAddHint,
            ),
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.adminServerConfigCorsAddCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: Text(context.l10n.adminServerConfigCorsAddConfirm),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    if (!mounted) return;
    final trimmed = host?.trim() ?? '';
    if (trimmed.isEmpty) return;
    setState(() {
      _corsHosts = [..._corsHosts, trimmed];
      _dirty = true;
    });
  }

  void _removeCorsHost(String host) {
    setState(() {
      _corsHosts = _corsHosts.where((h) => h != host).toList();
      _dirty = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final logRetention =
          int.tryParse(_logRetention.text.trim()) ??
              widget.initial.logFileRetentionDays ??
              0;
      final slowThreshold =
          int.tryParse(_slowThreshold.text.trim()) ??
              widget.initial.slowResponseThresholdMs ??
              0;
      final next = widget.initial.rebuild((b) => b
        ..serverName = _serverName.text.trim().isEmpty
            ? null
            : _serverName.text.trim()
        ..uICulture = _uiCulture.text.trim().isEmpty
            ? null
            : _uiCulture.text.trim()
        ..logFileRetentionDays = logRetention
        ..enableMetrics = _enableMetrics
        ..enableNormalizedItemByNameIds = _enableNormalizedItemByNameIds
        ..quickConnectAvailable = _quickConnectAvailable
        ..enableSlowResponseWarning = _enableSlowResponseWarning
        ..slowResponseThresholdMs = slowThreshold
        ..corsHosts.replace(_corsHosts));
      await ref.read(adminServerConfigControllerProvider).save(next);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminServerConfigSaveSnack)),
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

class _TextFieldTile extends StatelessWidget {
  const _TextFieldTile({
    required this.icon,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
  });

  final IconData icon;
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Icon(icon),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CorsHostsSection extends StatelessWidget {
  const _CorsHostsSection({
    required this.hosts,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> hosts;
  final VoidCallback onAdd;
  final void Function(String host) onRemove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SettingsSection(
      label: l.adminServerConfigCorsSection,
      tiles: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.adminServerConfigCorsHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (hosts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    l.adminServerConfigCorsEmpty,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final host in hosts)
                      InputChip(
                        label: Text(host),
                        onDeleted: () => onRemove(host),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(l.adminServerConfigCorsAdd),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
