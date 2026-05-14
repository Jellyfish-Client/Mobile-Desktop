import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/downloads/download_manager.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_button.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';

/// State-aware "Download" CTA shown on detail screens. Reads the current
/// download status for the item and dispatches the right action on tap.
class DownloadButton extends ConsumerWidget {
  const DownloadButton({
    required this.itemId,
    this.fullWidth = false,
    this.size = JfButtonSize.lg,
    super.key,
  });

  final String itemId;
  final bool fullWidth;
  final JfButtonSize size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(itemDownloadStatusProvider(itemId));
    final mgr = ref.read(downloadManagerProvider);

    final l = context.l10n;
    switch (status.state) {
      case ItemDownloadState.notDownloaded:
      case ItemDownloadState.failed:
      case ItemDownloadState.cancelled:
        return JfButton.secondary(
          label: l.downloadButtonDownload,
          icon: Icons.download_outlined,
          fullWidth: fullWidth,
          size: size,
          onPressed: () => _enqueueOrSnack(context, mgr),
        );
      case ItemDownloadState.queued:
        return JfButton.secondary(
          label: l.downloadButtonQueued,
          icon: Icons.schedule,
          fullWidth: fullWidth,
          size: size,
          onPressed: () => mgr.cancel(itemId),
        );
      case ItemDownloadState.running:
        final pct = (status.progress * 100).clamp(0, 100).toStringAsFixed(0);
        return JfButton.secondary(
          label: l.downloadButtonDownloading(pct),
          icon: Icons.pause_circle_outline,
          fullWidth: fullWidth,
          size: size,
          onPressed: () => mgr.pause(itemId),
        );
      case ItemDownloadState.paused:
        final pct = (status.progress * 100).clamp(0, 100).toStringAsFixed(0);
        return JfButton.secondary(
          label: l.downloadButtonPaused(pct),
          icon: Icons.play_arrow,
          fullWidth: fullWidth,
          size: size,
          onPressed: () => mgr.resume(itemId),
        );
      case ItemDownloadState.completed:
        return GestureDetector(
          onLongPress: () => _confirmDelete(context, mgr, itemId),
          child: JfButton.secondary(
            label: l.downloadButtonDownloaded,
            icon: Icons.check_circle,
            fullWidth: fullWidth,
            size: size,
            onPressed: () => _confirmDelete(context, mgr, itemId),
          ),
        );
    }
  }

  /// Wraps [DownloadManager.enqueueItemById] in error reporting — the call
  /// fetches the DTO over the network so a server outage or 404 must not
  /// disappear silently into a fire-and-forget Future.
  Future<void> _enqueueOrSnack(
    BuildContext context,
    DownloadManager mgr,
  ) async {
    try {
      await mgr.enqueueItemById(itemId);
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.downloadButtonFailedSnack(e.toString())),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DownloadManager mgr,
    String itemId,
  ) async {
    final l = context.l10n;
    final ok = await showJfConfirm(
      context,
      title: l.downloadButtonDeleteTitle,
      message: l.downloadButtonDeleteMessage,
      confirmLabel: l.downloadButtonDeleteConfirm,
      cancelLabel: l.downloadButtonDeleteCancel,
      destructive: true,
    );
    if (!context.mounted) return;
    if (ok) {
      try {
        await mgr.deleteDownload(itemId);
      } on Object catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.downloadButtonDeleteFailedSnack(e.toString()),
            ),
          ),
        );
      }
    }
  }
}
