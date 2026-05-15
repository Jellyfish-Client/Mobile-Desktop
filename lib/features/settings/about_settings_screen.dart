import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/updates/update_controller.dart';
import '../../core/updates/update_models.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>((_) async {
  return PackageInfo.fromPlatform();
});

class AboutSettingsScreen extends ConsumerWidget {
  const AboutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pkgAsync = ref.watch(_packageInfoProvider);
    final versionText = pkgAsync.maybeWhen(
      data: (pkg) => '${pkg.version} (build ${pkg.buildNumber})',
      orElse: () => '…',
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAboutTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.movie_filter_outlined),
            title: Text(l10n.aboutAppName),
            subtitle: Text(l10n.aboutAppSubtitle),
          ),
          ListTile(
            leading: const Icon(Icons.tag),
            title: Text(l10n.aboutVersion),
            subtitle: Text(versionText),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.aboutLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.aboutAppName,
              applicationVersion: pkgAsync.maybeWhen(
                data: (pkg) => pkg.version,
                orElse: () => '',
              ),
            ),
          ),
          if (updatesSupportedHere) ...[
            const Divider(height: 32),
            _UpdatesSection(),
          ],
        ],
      ),
    );
  }
}

class _UpdatesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stateAsync = ref.watch(updateControllerProvider);

    final state = stateAsync.valueOrNull;
    if (state == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.aboutUpdateSectionTitle.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.autorenew),
          title: Text(l10n.aboutUpdateAutoToggle),
          subtitle: Text(l10n.aboutUpdateAutoToggleSubtitle),
          value: state.autoCheckEnabled,
          onChanged: (v) async {
            await ref
                .read(updateControllerProvider.notifier)
                .setAutoCheck(enabled: v);
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: KeyedSubtree(
              key: ValueKey(state.phase.runtimeType),
              child: _PhaseTile(state: state),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhaseTile extends ConsumerWidget {
  const _PhaseTile({required this.state});

  final UpdateState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final phase = state.phase;

    return switch (phase) {
      UpdateIdle() || UpdateUpToDate() => ListTile(
        leading: Icon(
          phase is UpdateUpToDate
              ? Icons.check_circle_outline
              : Icons.refresh,
          color: phase is UpdateUpToDate
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        title: Text(l10n.aboutUpdateCheckNow),
        subtitle: phase is UpdateUpToDate
            ? Text(l10n.aboutUpdateUpToDate)
            : null,
        onTap: () => _checkNow(context, ref),
      ),
      UpdateChecking() => ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(l10n.aboutUpdateChecking),
      ),
      UpdateDownloading(:final info, :final progress) => ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress < 0 ? null : progress.clamp(0.0, 1.0),
          ),
        ),
        title: Text(l10n.aboutUpdateDownloading(info.version)),
        subtitle: progress >= 0
            ? Text('${(progress * 100).round()}%')
            : null,
      ),
      UpdateReady(:final info) => _ReadyCard(info: info),
      UpdateInstalling() => ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(l10n.aboutUpdateInstalling),
      ),
      UpdateFailed(:final reason) => ListTile(
        leading: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(_failureMessage(l10n, reason)),
        trailing: TextButton(
          onPressed: () => _checkNow(context, ref),
          child: Text(l10n.aboutUpdateCheckNow),
        ),
      ),
    };
  }

  Future<void> _checkNow(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref
        .read(updateControllerProvider.notifier)
        .checkNow();
    if (!context.mounted) return;
    // Only surface terminal outcomes that the lifecycle doesn't already
    // render in the list (Downloading/Ready paint themselves).
    final msg = switch (outcome) {
      UpdateCheckOutcome.upToDate => l10n.aboutUpdateUpToDate,
      UpdateCheckOutcome.failed => l10n.aboutUpdateCheckFailed,
      UpdateCheckOutcome.unsupportedPlatform =>
        l10n.aboutUpdateUnsupportedPlatform,
      UpdateCheckOutcome.available => null,
    };
    if (msg != null) {
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  String _failureMessage(AppLocalizations l10n, String reason) {
    return switch (reason) {
      'check_failed' => l10n.aboutUpdateCheckFailed,
      'download_failed' => l10n.aboutUpdateDownloadFailed,
      'install_failed' => l10n.aboutUpdateInstallFailed,
      _ => l10n.aboutUpdateCheckFailed,
    };
  }
}

Future<void> _confirmAndInstall(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.aboutUpdateInstall),
      content: Text(l10n.aboutUpdateReadyBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.aboutUpdateInstall),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;
  await ref.read(updateControllerProvider.notifier).installNow();
}

class _ReadyCard extends ConsumerWidget {
  const _ReadyCard({required this.info});

  final UpdateInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Card(
        color: scheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.system_update_alt,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.aboutUpdateReadyTitle(info.version),
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.aboutUpdateReadyBody,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: 16),
              // Wrap (not Row) so long localized strings on narrow windows
              // flow onto two lines instead of overflowing.
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => launchUrl(
                      Uri.parse(info.releaseNotesUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(l10n.aboutUpdateReleaseNotes),
                  ),
                  FilledButton.icon(
                    onPressed: () => _confirmAndInstall(context, ref),
                    icon: const Icon(Icons.download_done),
                    label: Text(l10n.aboutUpdateInstall),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
