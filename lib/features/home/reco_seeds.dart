import 'dart:math';

import 'package:jellyfin_api/jellyfin_api.dart';

import '../../core/seerr/models.dart';

/// One seed used to fuel a "Parce que vous avez regardé X" rail (or the
/// fallback "Comme X" variant when we pulled it from a popular catalogue
/// instead of the user's own play history).
class RecoSeed {
  const RecoSeed({
    required this.tmdbId,
    required this.type,
    required this.title,
    required this.fromHistory,
  });

  final int tmdbId;
  final SeerrMediaType type;
  final String title;

  /// True iff the seed was extracted from `recentlyPlayedItemsProvider`.
  /// When false, it came from the popular movies/series fallback — the rail
  /// renderer should label it accordingly ("Comme X" vs "Parce que vous avez
  /// regardé X").
  final bool fromHistory;
}

/// Up to [max] reco seeds, biased toward variety. Pure function so the seed
/// composition logic can be unit-tested without spinning Riverpod up.
///
/// Selection order:
///   1. If the history contains an "Anime"-tagged item, one of them is
///      randomly picked first — keeps the section from collapsing onto the
///      single genre the user happens to watch most.
///   2. The rest of the [max] slots are filled with a shuffled draw from
///      the remaining history items (dedup by tmdbId).
///   3. If history still leaves slots empty, [popularFallback] tops them
///      up with `fromHistory: false` so the rail title can downgrade to
///      "Comme X". Empty fallback → fewer rails, no padding with fakes.
List<RecoSeed> pickRecoSeeds(
  List<BaseItemDto> history,
  List<SeerrMedia> popularFallback, {
  int max = 3,
  Random? rng,
}) {
  final r = rng ?? Random();
  final hist = _historyCandidates(history);

  final picks = <RecoSeed>[];
  final usedIds = <int>{};

  void take(_HistoryCandidate c) {
    picks.add(
      RecoSeed(
        tmdbId: c.tmdbId,
        type: c.type,
        title: c.title,
        fromHistory: true,
      ),
    );
    usedIds.add(c.tmdbId);
  }

  // 1. Anime bias.
  final animes = hist.where((c) => c.isAnime).toList();
  if (animes.isNotEmpty && picks.length < max) {
    take(animes[r.nextInt(animes.length)]);
  }

  // 2. Fill from remaining history (shuffled — gives variety across sessions).
  final remaining = hist.where((c) => !usedIds.contains(c.tmdbId)).toList()
    ..shuffle(r);
  for (final c in remaining) {
    if (picks.length >= max) break;
    take(c);
  }

  // 3. Top up with popular fallback if history was thin.
  if (picks.length < max) {
    final fallback = popularFallback
        .where((m) => !usedIds.contains(m.tmdbId))
        .toList()
      ..shuffle(r);
    for (final m in fallback) {
      if (picks.length >= max) break;
      picks.add(
        RecoSeed(
          tmdbId: m.tmdbId,
          type: m.type,
          title: m.title,
          fromHistory: false,
        ),
      );
      usedIds.add(m.tmdbId);
    }
  }
  return picks;
}

/// Reduces [history] to (tmdbId, type, title, isAnime) candidates, keeping
/// only movies and series with a parsable TMDB id and a non-empty name.
/// Dedups by tmdbId so multiple plays of the same series don't fight for
/// distinct slots.
List<_HistoryCandidate> _historyCandidates(List<BaseItemDto> history) {
  final out = <_HistoryCandidate>[];
  final seen = <int>{};
  for (final item in history) {
    final tmdbId = _tmdbIdOf(item);
    if (tmdbId == null || !seen.add(tmdbId)) continue;
    final title = item.name;
    if (title == null || title.isEmpty) continue;
    final type = switch (item.type) {
      BaseItemKind.movie => SeerrMediaType.movie,
      BaseItemKind.series => SeerrMediaType.tv,
      _ => null,
    };
    if (type == null) continue;
    final genres = item.genres ?? const <String>[];
    // Sonarr / AniDB / TMDB all surface anime shows with the genre literal
    // "Anime". We deliberately don't accept "Animation" as a proxy — it
    // captures Western cartoons (Pixar, DreamWorks, …) too and would
    // hijack the anime-bias slot for users who only watch family animation.
    final isAnime = genres.any((g) => g.toLowerCase() == 'anime');
    out.add(_HistoryCandidate(tmdbId, type, title, isAnime: isAnime));
  }
  return out;
}

/// Case-insensitive TMDB id lookup on a [BaseItemDto]. Jellyfin normalises
/// to "Tmdb" but some agents/imports surface "tmdb" or "TMDB"; tolerate all.
int? _tmdbIdOf(BaseItemDto item) {
  final map = item.providerIds;
  if (map == null) return null;
  for (final entry in map.entries) {
    if (entry.key.toLowerCase() == 'tmdb') {
      final v = entry.value;
      return v == null ? null : int.tryParse(v);
    }
  }
  return null;
}

class _HistoryCandidate {
  const _HistoryCandidate(
    this.tmdbId,
    this.type,
    this.title, {
    required this.isAnime,
  });
  final int tmdbId;
  final SeerrMediaType type;
  final String title;
  final bool isAnime;
}
