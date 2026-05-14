import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/account_key.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/app_database_provider.dart';

String _watchAccountKey(Ref ref) => ref.watch(
  authControllerProvider.select(
    (s) => accountKeyForSession(s.valueOrNull?.session),
  ),
);

/// Films téléchargés et terminés.
final offlineMoviesProvider = StreamProvider.autoDispose<List<DownloadRow>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .watchCompleted(_watchAccountKey(ref))
      .map((rows) => rows.where((r) => r.itemType != 'Episode').toList());
});

class OfflineSeriesGroup {
  const OfflineSeriesGroup({
    required this.seriesId,
    required this.seriesName,
    required this.posterPath,
    required this.episodes,
  });

  final String seriesId;
  final String seriesName;
  final String? posterPath;
  final List<DownloadRow> episodes;

  int get episodeCount => episodes.length;
}

/// Séries téléchargées : épisodes regroupés par série, triés par
/// (saison, épisode).
final offlineSeriesGroupsProvider =
    StreamProvider.autoDispose<List<OfflineSeriesGroup>>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return db.watchCompleted(_watchAccountKey(ref)).map((rows) {
        final episodes = rows.where(
          (r) => r.itemType == 'Episode' && r.seriesId != null,
        );
        final bySeries = <String, List<DownloadRow>>{};
        for (final r in episodes) {
          bySeries.putIfAbsent(r.seriesId!, () => []).add(r);
        }
        final groups = <OfflineSeriesGroup>[];
        bySeries.forEach((seriesId, eps) {
          eps.sort((a, b) {
            final s = (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0);
            if (s != 0) return s;
            return (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0);
          });
          groups.add(
            OfflineSeriesGroup(
              seriesId: seriesId,
              seriesName: eps.first.seriesName ?? 'Série',
              // Take the series poster from the first episode that has one;
              // each episode row carries its own copy of the series poster path.
              posterPath: eps
                  .map((e) => e.seriesImagePath)
                  .firstWhere((p) => p != null, orElse: () => null),
              episodes: eps,
            ),
          );
        });
        groups.sort((a, b) => a.seriesName.compareTo(b.seriesName));
        return groups;
      });
    });
