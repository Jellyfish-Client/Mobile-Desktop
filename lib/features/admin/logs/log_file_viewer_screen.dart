import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import 'logs_providers.dart';

class LogFileViewerScreen extends ConsumerWidget {
  const LogFileViewerScreen({required this.name, super.key});

  /// Server-side file name (e.g. "log_20260514.log"). Already URL-decoded by
  /// go_router before reaching this constructor.
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminLogFileProvider(name));
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: l.adminLogViewerCopy,
            onPressed: async.maybeWhen(
              data: (content) => () async {
                await Clipboard.setData(ClipboardData(text: content));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.adminLogViewerCopied)),
                );
              },
              orElse: () => null,
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(context.l10n.adminErrorPrefix(e.toString())),
          ),
        ),
        data: (content) {
          if (content.isEmpty) {
            return Center(child: Text(l.adminLogViewerEmpty));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SelectableText(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: ['Menlo', 'Courier'],
                fontSize: 12,
                height: 1.35,
              ),
            ),
          );
        },
      ),
    );
  }
}
