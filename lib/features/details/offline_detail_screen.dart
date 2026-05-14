import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/auth/account_key.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/downloads/download_manager.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/app_database_provider.dart';
import '../../core/sync/sync_service.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/jf_button.dart';
import '../../shared/widgets/jf_chip.dart';
import '../../shared/widgets/jf_confirm_dialog.dart';
import '_format.dart';

/// Offline page de détail bâtie à partir d'un `DownloadRow` Drift.
///
/// La route `/items/:id` y bascule automatiquement quand `offlineModeProvider`
/// est vrai. Si l'item n'a pas de download, on affiche un état "indisponible
/// hors ligne".
class OfflineDetailEntry extends ConsumerWidget {
  const OfflineDetailEntry({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final accountKey = ref.watch(
      authControllerProvider.select(
        (s) => accountKeyForSession(s.valueOrNull?.session),
      ),
    );
    return StreamBuilder<DownloadRow?>(
      stream: db.watchByItemId(accountKey, itemId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final row = snap.data;
        if (row == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.cloud_off,
              title: context.l10n.offlineUnavailableTitle,
              message: context.l10n.offlineUnavailableMessage,
            ),
          );
        }
        return OfflineDetailScreen(row: row);
      },
    );
  }
}

class OfflineDetailScreen extends ConsumerWidget {
  const OfflineDetailScreen({required this.row, super.key});

  final DownloadRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final backdropHeight = size.width * 9 / 16;

    final isEpisode = row.itemType == 'Episode';
    final title = isEpisode ? (row.seriesName ?? row.name) : row.name;
    final subtitle = isEpisode ? row.name : null;
    final genres = _parseGenres(row.genres);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: backdropHeight,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _Backdrop(
                backdropPath: row.backdropImagePath,
                posterPath: row.imagePath ?? row.seriesImagePath,
                scheme: scheme,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'S${row.seasonNumber ?? '?'} · E${row.episodeNumber ?? '?'} — $subtitle',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  _MetaRow(row: row),
                  if (genres.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final g in genres)
                          JfChip(label: g, tone: JfChipTone.neutral),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: JfButton.primary(
                          label: context.l10n.offlinePlay,
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => context.push('/play/${row.itemId}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.check),
                          label: Text(context.l10n.offlineMarkPlayed),
                          onPressed: () => _markPlayed(context, ref),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.favorite_outline),
                          label: Text(context.l10n.offlineAddFavorite),
                          onPressed: () => _addFavorite(context, ref),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: Text(context.l10n.offlineDeleteDownload),
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                  if (row.overview != null && row.overview!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      context.l10n.offlineSynopsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(row.overview!, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markPlayed(BuildContext context, WidgetRef ref) async {
    await enqueueSync(
      ref,
      itemId: row.itemId,
      operation: SyncOperation.markPlayed,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.offlineMarkPlayedSnack)),
    );
  }

  // Note: offline only supports adding the favorite — we don't know whether
  // the item is already favorited on the server, and there's no local
  // mirror of that flag yet. Removal stays a server-side action.
  Future<void> _addFavorite(BuildContext context, WidgetRef ref) async {
    await enqueueSync(
      ref,
      itemId: row.itemId,
      operation: SyncOperation.addFavorite,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.offlineAddFavoriteSnack)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showJfConfirm(
      context,
      title: context.l10n.offlineDeleteTitle,
      message: context.l10n.offlineDeleteMessage,
      confirmLabel: context.l10n.offlineDeleteConfirm,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(downloadManagerProvider).deleteDownload(row.itemId);
    if (!context.mounted) return;
    context.pop();
  }

  List<String> _parseGenres(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } on Object {
      // ignore malformed json
    }
    return const [];
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({
    required this.backdropPath,
    required this.posterPath,
    required this.scheme,
  });

  final String? backdropPath;
  final String? posterPath;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final path = backdropPath ?? posterPath;
    if (path == null) {
      return ColoredBox(color: scheme.surfaceContainerHigh);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              ColoredBox(color: scheme.surfaceContainerHigh),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                scheme.surface.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.row});

  final DownloadRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final parts = <Widget>[];

    if (row.productionYear != null) {
      parts.add(_chipText('${row.productionYear}'));
    }
    final runtime = formatRuntime(row.runtimeTicks);
    if (runtime.isNotEmpty) parts.add(_chipText(runtime));
    if (row.officialRating != null && row.officialRating!.isNotEmpty) {
      parts.add(_chipText(row.officialRating!));
    }
    if (row.communityRating != null) {
      parts.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 16, color: Color(0xFFFFD54F)),
            const SizedBox(width: 2),
            Text(
              row.communityRating!.toStringAsFixed(1),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    if (parts.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final p in parts)
          DefaultTextStyle(
            style: theme.textTheme.bodySmall!.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            child: p,
          ),
      ],
    );
  }

  Widget _chipText(String text) => Text(text);
}
