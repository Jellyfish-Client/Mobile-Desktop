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

// ---------------------------------------------------------------------------
// Sealed class — représente un élément aplati de la liste virtualisée.
// Un header de section (En cours, Téléchargés, Échecs) ou un header de série
// ou une tuile téléchargeable.
// ---------------------------------------------------------------------------

sealed class _ListItem {
  const _ListItem();
}

final class _SectionItem extends _ListItem {
  const _SectionItem(this.title);
  final String title;
}

final class _SeriesHeaderItem extends _ListItem {
  const _SeriesHeaderItem(this.name);
  final String name;
}

final class _TileItem extends _ListItem {
  const _TileItem(this.row, this.kind);
  final DownloadRow row;
  final _TileKind kind;
}

enum _TileKind { inProgress, completed, failed }

// ---------------------------------------------------------------------------
// Fonction pure — construit la liste aplatie depuis les données brutes.
// Appelée une seule fois par build ; aucun widget n'est alloué ici.
// ---------------------------------------------------------------------------

List<_ListItem> _buildFlatList({
  required List<DownloadRow> inProgress,
  required List<DownloadRow> completed,
  required List<DownloadRow> failed,
  required String inProgressLabel,
  required String downloadedLabel,
  required String failedLabel,
}) {
  final items = <_ListItem>[];

  if (inProgress.isNotEmpty) {
    items.add(_SectionItem(inProgressLabel));
    for (final row in inProgress) {
      items.add(_TileItem(row, _TileKind.inProgress));
    }
  }

  if (completed.isNotEmpty) {
    items.add(_SectionItem(downloadedLabel));
    _addGroupedCompleted(items, completed);
  }

  if (failed.isNotEmpty) {
    items.add(_SectionItem(failedLabel));
    for (final row in failed) {
      items.add(_TileItem(row, _TileKind.failed));
    }
  }

  return items;
}

/// Ajoute les éléments "complétés" dans [items], groupés par série.
/// Les films (non-épisodes) sont ajoutés à la fin, sans header.
void _addGroupedCompleted(List<_ListItem> items, List<DownloadRow> rows) {
  final bySeries = <String, List<DownloadRow>>{};
  final movies = <DownloadRow>[];

  for (final r in rows) {
    if (r.itemType == 'Episode' && r.seriesId != null) {
      bySeries.putIfAbsent(r.seriesId!, () => []).add(r);
    } else {
      movies.add(r);
    }
  }

  bySeries.forEach((_, eps) {
    eps.sort((a, b) {
      final s = (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0);
      if (s != 0) return s;
      return (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0);
    });
    items.add(_SeriesHeaderItem(eps.first.seriesName ?? ''));
    for (final row in eps) {
      items.add(_TileItem(row, _TileKind.completed));
    }
  });

  for (final row in movies) {
    items.add(_TileItem(row, _TileKind.completed));
  }
}

// ---------------------------------------------------------------------------
// Écran principal
// ---------------------------------------------------------------------------

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allDownloadsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.downloadsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.downloadsSettings,
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
              title: l10n.downloadsNoDownloads,
              message: l10n.downloadsNoDownloadsMessage,
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

          // Liste aplatie — pure data, aucun widget alloué.
          final flatItems = _buildFlatList(
            inProgress: inProgress,
            completed: completed,
            failed: failed,
            inProgressLabel: l10n.downloadsInProgress,
            downloadedLabel: l10n.downloadsDownloaded,
            failedLabel: l10n.downloadsFailedOrCancelled,
          );

          return CustomScrollView(
            slivers: [
              // Padding haut via SliverPadding pour ne pas sortir du sliver world.
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildItem(context, ref, flatItems[index]),
                    childCount: flatItems.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, WidgetRef ref, _ListItem item) {
    return switch (item) {
      _SectionItem(:final title) => _SectionHeader(title: title),
      _SeriesHeaderItem(:final name) => _SeriesHeader(
        name: name.isNotEmpty ? name : context.l10n.downloadsSeriesName,
      ),
      _TileItem(:final row, :final kind) => _DismissibleTile(
        row: row,
        ref: ref,
        onSwiped: () => switch (kind) {
          _TileKind.inProgress =>
            ref.read(downloadManagerProvider).cancel(row.itemId),
          _TileKind.completed ||
          _TileKind.failed =>
            ref.read(downloadManagerProvider).deleteDownload(row.itemId),
        },
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Widgets statiques de présentation
// ---------------------------------------------------------------------------

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

class _SeriesHeader extends StatelessWidget {
  const _SeriesHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        name,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tuile avec geste swipe-to-dismiss
// ---------------------------------------------------------------------------

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
  // Le stream Drift prend un court instant pour propager la suppression.
  // Ce booléen par instance empêche un double-dismiss pendant cette fenêtre.
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
