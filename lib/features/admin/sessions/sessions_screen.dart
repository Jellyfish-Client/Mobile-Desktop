import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import 'sessions_providers.dart';

class AdminSessionsScreen extends ConsumerWidget {
  const AdminSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminSessions)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminSessionsProvider.notifier).refresh(),
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
          data: (sessions) {
            if (sessions.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 96),
                  Center(child: Text(context.l10n.adminSessionsEmpty)),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              itemCount: sessions.length,
              itemBuilder: (_, i) => _SessionTile(session: sessions[i]),
            );
          },
        ),
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session});

  final SessionInfoDto session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = context.l10n;
    final user = session.userName ?? '—';
    final initial = user.characters.isEmpty
        ? '?'
        : user.characters.first.toUpperCase();
    final isPlaying = session.nowPlayingItem != null;
    final isActive = session.isActive ?? false;
    final clientLine = [
      if ((session.client ?? '').isNotEmpty) session.client,
      if ((session.deviceName ?? '').isNotEmpty) session.deviceName,
    ].whereType<String>().join(' • ');
    final nowPlaying = isPlaying
        ? l.adminSessionsPlaying(session.nowPlayingItem!.name ?? '—')
        : l.adminSessionsIdle;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPlaying ? scheme.primary : scheme.primaryContainer,
        foregroundColor:
            isPlaying ? scheme.onPrimary : scheme.onPrimaryContainer,
        child: Text(initial),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(user, overflow: TextOverflow.ellipsis),
          ),
          if (isActive) ...[
            const SizedBox(width: AppSpacing.sm),
            _Badge(
              label: l.adminSessionsBadgeActive,
              color: scheme.primaryContainer,
              foreground: scheme.onPrimaryContainer,
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (clientLine.isNotEmpty) Text(clientLine),
          Text(nowPlaying),
        ],
      ),
      isThreeLine: clientLine.isNotEmpty,
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'message') {
            await _promptAndSendMessage(context, ref);
          } else if (value == 'stop') {
            await _confirmAndStopPlayback(context, ref);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem<String>(
            value: 'message',
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline),
                const SizedBox(width: AppSpacing.sm),
                Text(l.adminSessionsSendMessage),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'stop',
            enabled: isPlaying,
            child: Row(
              children: [
                const Icon(Icons.stop_circle_outlined),
                const SizedBox(width: AppSpacing.sm),
                Text(l.adminSessionsStopPlayback),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _promptAndSendMessage(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l = context.l10n;
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l.adminSessionsMessageDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l.adminSessionsMessageDialogLabel,
              hintText: l.adminSessionsMessageDialogHint,
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l.cancelButton),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(l.adminSessionsMessageDialogSend),
            ),
          ],
        );
      },
    );
    if (text == null || text.isEmpty || !context.mounted) return;
    final sessionId = session.id;
    if (sessionId == null) return;
    try {
      await ref.read(adminSessionsProvider.notifier).sendMessage(
            sessionId: sessionId,
            text: text,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminSessionsMessageSent)),
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

  Future<void> _confirmAndStopPlayback(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l = context.l10n;
    final ok = await showJfConfirm(
      context,
      title: l.adminSessionsStopConfirmTitle,
      message: l.adminSessionsStopConfirmMessage,
      confirmLabel: l.adminSessionsStopPlayback,
      destructive: true,
      confirmIcon: Icons.stop_circle_outlined,
    );
    if (!ok || !context.mounted) return;
    final sessionId = session.id;
    if (sessionId == null) return;
    try {
      await ref.read(adminSessionsProvider.notifier).stopPlayback(sessionId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminSessionsStopSnack)),
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
