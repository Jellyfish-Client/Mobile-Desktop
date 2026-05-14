import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/auth/account_key.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/app_database_provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/empty_state.dart';

/// Offline view of a series: lists every downloaded episode grouped by
/// season. Tapping an episode opens its standard `/items/:id` route which,
/// while offline, lands on `OfflineDetailScreen`.
class OfflineSeriesScreen extends ConsumerWidget {
  const OfflineSeriesScreen({
    required this.seriesId,
    required this.seriesName,
    super.key,
  });

  final String seriesId;
  final String seriesName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final accountKey = ref.watch(
      authControllerProvider.select(
        (s) => accountKeyForSession(s.valueOrNull?.session),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(seriesName)),
      body: FutureBuilder<List<DownloadRow>>(
        future: db.bySeries(accountKey, seriesId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final episodes =
              (snap.data ?? const <DownloadRow>[])
                  .where((r) => r.status == DownloadStatus.completed)
                  .toList()
                ..sort((a, b) {
                  final s = (a.seasonNumber ?? 0).compareTo(
                    b.seasonNumber ?? 0,
                  );
                  if (s != 0) return s;
                  return (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0);
                });
          if (episodes.isEmpty) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: context.l10n.offlineSeriesNoEpisodesTitle,
              message: context.l10n.offlineSeriesNoEpisodesMessage,
            );
          }
          final bySeason = <int, List<DownloadRow>>{};
          for (final r in episodes) {
            bySeason.putIfAbsent(r.seasonNumber ?? 0, () => []).add(r);
          }
          return ListView(
            children: [
              for (final season in bySeason.keys.toList()..sort()) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    season == 0
                        ? context.l10n.offlineSeasonUnknown
                        : context.l10n.offlineSeasonLabel(season),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (final ep in bySeason[season]!) _EpisodeTile(row: ep),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.row});
  final DownloadRow row;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final poster = row.imagePath ?? row.seriesImagePath;
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: 64,
          height: 36,
          child: poster == null
              ? _Placeholder(scheme: scheme)
              : Image.file(
                  File(poster),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _Placeholder(scheme: scheme),
                ),
        ),
      ),
      title: Text('E${row.episodeNumber ?? '?'} — ${row.name}'),
      subtitle: row.overview != null
          ? Text(row.overview!, maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
      onTap: () => context.push('/items/${row.itemId}'),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.scheme});
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: scheme.surfaceContainerHigh,
    child: Icon(Icons.tv_outlined, color: scheme.onSurfaceVariant, size: 18),
  );
}
