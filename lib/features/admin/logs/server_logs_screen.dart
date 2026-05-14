import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import 'logs_providers.dart';

class AdminServerLogsScreen extends ConsumerWidget {
  const AdminServerLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminServerLogsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminServerLogs)),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminServerLogsProvider.future),
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
          data: (files) {
            if (files.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 96),
                  Center(child: Text(context.l10n.adminServerLogsEmpty)),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              itemCount: files.length,
              itemBuilder: (_, i) => _LogFileTile(file: files[i]),
            );
          },
        ),
      ),
    );
  }
}

class _LogFileTile extends StatelessWidget {
  const _LogFileTile({required this.file});

  final LogFile file;

  @override
  Widget build(BuildContext context) {
    final name = file.name ?? '—';
    final subtitleParts = <String>[
      if (file.dateModified != null)
        DateFormat.yMd().add_Hm().format(file.dateModified!.toLocal()),
      if (file.size != null) _formatSize(file.size!),
    ];

    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(name, overflow: TextOverflow.ellipsis),
      subtitle:
          subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
      trailing: const Icon(Icons.chevron_right),
      onTap: file.name == null
          ? null
          : () => context.push(
                '/settings/admin/logs/${Uri.encodeComponent(file.name!)}',
              ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
