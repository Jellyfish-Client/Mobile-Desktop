import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/downloads/download_manager.dart';
import '../../core/storage/app_database.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/jf_section_title.dart';
import 'widgets/download_tile.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allDownloadsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.downloadsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.downloadsSettings,
            onPressed: () => context.push('/settings/downloads'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rows) {
          if (rows.isEmpty) {
            return EmptyState(
              icon: Icons.download_outlined,
              title: context.l10n.downloadsNoDownloads,
              message: context.l10n.downloadsNoDownloadsMessage,
            );
          }

          final inProgress = rows
              .where(
                (r) =>
                    r.status == DownloadStatus.queued ||
                    r.status == DownloadStatus.running ||
                    r.status == DownloadStatus.paused,
              )
              .toList();
          final completed = rows
              .where((r) => r.status == DownloadStatus.completed)
              .toList();
          final failed = rows
              .where(
                (r) =>
                    r.status == DownloadStatus.failed ||
                    r.status == DownloadStatus.cancelled,
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              if (inProgress.isNotEmpty) ...[
                _SectionHeader(title: context.l10n.downloadsInProgress),
                ...inProgress.map(
                  (row) => _DismissibleTile(
                    row: row,
                    ref: ref,
                    onSwiped: () =>
                        ref.read(downloadManagerProvider).cancel(row.itemId),
                  ),
                ),
              ],
              if (completed.isNotEmpty) ...[
                _SectionHeader(title: context.l10n.downloadsDownloaded),
                ..._groupedCompleted(context, completed, ref),
              ],
              if (failed.isNotEmpty) ...[
                _SectionHeader(title: context.l10n.downloadsFailedOrCancelled),
                ...failed.map(
                  (row) => _DismissibleTile(
                    row: row,
                    ref: ref,
                    onSwiped: () => ref
                        .read(downloadManagerProvider)
                        .deleteDownload(row.itemId),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Episodes are grouped under their series. Movies are listed flat at the end.
  List<Widget> _groupedCompleted(
    BuildContext context,
    List<DownloadRow> rows,
    WidgetRef ref,
  ) {
    final bySeries = <String, List<DownloadRow>>{};
    final movies = <DownloadRow>[];
    for (final r in rows) {
      if (r.itemType == 'Episode' && r.seriesId != null) {
        bySeries.putIfAbsent(r.seriesId!, () => []).add(r);
      } else {
        movies.add(r);
      }
    }

    final widgets = <Widget>[];
    bySeries.forEach((seriesId, eps) {
      eps.sort((a, b) {
        final s = (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0);
        if (s != 0) return s;
        return (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0);
      });
      widgets
        ..add(
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Text(
              eps.first.seriesName ?? context.l10n.downloadsSeriesName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        )
        ..addAll(
          eps.map(
            (row) => _DismissibleTile(
              row: row,
              ref: ref,
              onSwiped: () =>
                  ref.read(downloadManagerProvider).deleteDownload(row.itemId),
            ),
          ),
        );
    });

    widgets.addAll(
      movies.map(
        (row) => _DismissibleTile(
          row: row,
          ref: ref,
          onSwiped: () =>
              ref.read(downloadManagerProvider).deleteDownload(row.itemId),
        ),
      ),
    );

    return widgets;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: JfSectionTitle(title: title),
    );
  }
}

class _DismissibleTile extends StatefulWidget {
  const _DismissibleTile({
    required this.row,
    required this.ref,
    required this.onSwiped,
  });

  final DownloadRow row;
  final WidgetRef ref;
  final Future<void> Function() onSwiped;

  @override
  State<_DismissibleTile> createState() => _DismissibleTileState();
}

class _DismissibleTileState extends State<_DismissibleTile> {
  // The Drift stream takes a beat to emit the deletion and re-render without
  // the row. During that window a fast user could trigger onDismissed twice.
  // Scoped per-instance so disposal of the widget naturally clears it.
  bool _dismissing = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('download-${widget.row.itemId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error.withValues(alpha: 0.85),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Icon(Icons.delete, color: scheme.onError),
      ),
      onDismissed: (_) async {
        if (_dismissing) return;
        _dismissing = true;
        try {
          await widget.onSwiped();
        } finally {
          if (mounted) _dismissing = false;
        }
      },
      child: DownloadTile(
        row: widget.row,
        onPause: () =>
            widget.ref.read(downloadManagerProvider).pause(widget.row.itemId),
        onResume: () =>
            widget.ref.read(downloadManagerProvider).resume(widget.row.itemId),
        onCancel: () =>
            widget.ref.read(downloadManagerProvider).cancel(widget.row.itemId),
        onDelete: () => widget.ref
            .read(downloadManagerProvider)
            .deleteDownload(widget.row.itemId),
        onPlay: () => context.push('/play/${widget.row.itemId}'),
      ),
    );
  }
}
