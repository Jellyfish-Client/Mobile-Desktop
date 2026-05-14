import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/storage/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';

class DownloadTile extends StatelessWidget {
  const DownloadTile({
    required this.row,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onDelete,
    this.onPlay,
    super.key,
  });

  final DownloadRow row;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isCompleted = row.status == DownloadStatus.completed;
    final isFailed = row.status == DownloadStatus.failed;
    final isPaused = row.status == DownloadStatus.paused;
    final isRunning =
        row.status == DownloadStatus.running ||
        row.status == DownloadStatus.queued;

    return InkWell(
      onTap: isCompleted ? onPlay : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                isCompleted
                    ? Icons.check_circle
                    : isFailed
                    ? Icons.error_outline
                    : isPaused
                    ? Icons.pause_circle_outline
                    : Icons.downloading,
                color: isCompleted
                    ? scheme.primary
                    : isFailed
                    ? scheme.error
                    : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isCompleted && !isFailed) ...[
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: row.progress.clamp(0, 1),
                      minHeight: 4,
                      backgroundColor: scheme.surfaceContainerHigh,
                    ),
                  ],
                  if (isFailed && row.errorMessage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      row.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _trailing(
              context,
              isCompleted: isCompleted,
              isRunning: isRunning,
              isPaused: isPaused,
              l10n: context.l10n,
            ),
          ],
        ),
      ),
    );
  }

  String _title() {
    if (row.itemType == 'Episode' && row.seriesName != null) {
      final s = row.seasonNumber;
      final e = row.episodeNumber;
      final tag = (s != null && e != null)
          ? ' · S${s.toString().padLeft(2, '0')}E${e.toString().padLeft(2, '0')}'
          : '';
      return '${row.seriesName!}$tag — ${row.name}';
    }
    return row.name;
  }

  String _subtitle(BuildContext context) {
    final l = context.l10n;
    final parts = <String>[];
    switch (row.status) {
      case DownloadStatus.queued:
        parts.add(l.downloadTileQueued);
      case DownloadStatus.running:
        parts.add('${(row.progress * 100).toStringAsFixed(0)}%');
      case DownloadStatus.paused:
        parts.add(
          '${l.downloadTilePaused} · ${(row.progress * 100).toStringAsFixed(0)}%',
        );
      case DownloadStatus.completed:
        parts.add(l.downloadTileDownloaded);
      case DownloadStatus.failed:
        parts.add(l.downloadTileFailed);
      case DownloadStatus.cancelled:
        parts.add(l.downloadTileCancelled);
    }
    if (row.sizeBytes != null) parts.add(_formatBytes(row.sizeBytes!));
    if (row.container != null) parts.add(row.container!.toUpperCase());
    return parts.join(' · ');
  }

  Widget _trailing(
    BuildContext context, {
    required bool isCompleted,
    required bool isRunning,
    required bool isPaused,
    required AppLocalizations l10n,
  }) {
    if (isCompleted) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: l10n.downloadTileTooltipDelete,
        onPressed: onDelete,
      );
    }
    if (isPaused) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: l10n.downloadTileTooltipResume,
            onPressed: onResume,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.downloadTileTooltipCancel,
            onPressed: onCancel,
          ),
        ],
      );
    }
    if (isRunning) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.pause),
            tooltip: l10n.downloadTileTooltipPause,
            onPressed: onPause,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.downloadTileTooltipCancel,
            onPressed: onCancel,
          ),
        ],
      );
    }
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: l10n.downloadTileTooltipRemove,
      onPressed: onDelete,
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
