import 'dart:math' as math;

import 'package:jellyfin_api/jellyfin_api.dart';

import '../jellyfin/jellyfin_client.dart';
import 'recommendation_rail.dart';
import 'taste_profile.dart';

/// Client-side recommendation engine.
///
/// [buildProfile] is async (hits the network once).
/// [score] is **pure and synchronous** — safe to call in tight loops and unit
/// tests without mocking anything.
/// [rails] orchestrates multiple fetches and returns display-ready sections.
class Recommender {
  Recommender(this._client);

  final JellyfinClient _client;

  // ---------------------------------------------------------------------------
  // Score weights — base signals sum to 0.95; boosts are additive on top.
  // ---------------------------------------------------------------------------
  //
  // Design rationale:
  //  • Genre is the strongest predictor of preference (0.40).
  //  • People (cast/directors) add a meaningful secondary signal (0.25).
  //  • Studio is useful for franchise/style matching (0.10).
  //  • Community rating acts as a quality floor/boost (0.10).
  //  • Year proximity tie-breaks peers of similar content (0.05).
  //  • Runtime proximity rewards content that fits the user's habit (0.05).
  //  • Boosts for in-progress series (+0.10) and favourites (+0.05) sit
  //    outside the base weights so they can push items above the genre signal
  //    without inflating it.

  static const double _wGenre = 0.40;
  static const double _wPeople = 0.25;
  static const double _wStudio = 0.10;
  static const double _wRating = 0.10;
  static const double _wYear = 0.05;
  static const double _wRuntime = 0.05;

  static const double _boostInProgressSeries = 0.10;
  static const double _boostFavourite = 0.05;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches the recently played items and builds a [TasteProfile].
  ///
  /// Never throws: returns [TasteProfile.empty] on any error so callers can
  /// degrade gracefully.
  Future<TasteProfile> buildProfile() async {
    try {
      final history = await _client.recentlyPlayed();
      return TasteProfile.fromHistory(history);
    } on Object catch (_) {
      // Catch-all (Exception + Error) — a malformed API response can throw
      // built_value `TypeError`s, and we still want the home screen to render.
      return TasteProfile.empty;
    }
  }

  /// Scores a candidate item against a [TasteProfile].
  ///
  /// Returns a value in [-1, ~1.15] where:
  ///   * `> 0`  — positive match
  ///   * `≈ 0`  — neutral / unknown
  ///   * `-1`   — excluded (already seen; callers of resume/nextUp rails
  ///              should not pass seen items into this method)
  ///
  /// This method is **pure** — no async, no side effects.
  double score(BaseItemDto item, TasteProfile profile) {
    // Hard exclusion for already-seen items.
    final id = item.id ?? '';
    if (profile.seenItemIds.contains(id)) return -1;

    var s = 0.0;

    // 1. Genre overlap — Jaccard-weighted with profile weights.
    s += _wGenre * _genreScore(item, profile);

    // 2. People overlap.
    s += _wPeople * _peopleScore(item, profile);

    // 3. Studio overlap.
    s += _wStudio * _studioScore(item, profile);

    // 4. Community rating bump (rating / 10, clamped to [0, 1]).
    final rating = item.communityRating ?? 0;
    s += _wRating * (rating / 10).clamp(0.0, 1.0);

    // 5. Production year proximity.
    s += _wYear * _yearScore(item, profile);

    // 6. Runtime proximity.
    s += _wRuntime * _runtimeScore(item, profile);

    // 7. In-progress series boost. The `seenItemIds` guard from earlier is
    // not re-checked here — the early `return -1` above already excludes
    // seen items from reaching this code path.
    final seriesId = item.seriesId;
    if (seriesId != null && profile.seriesIdsInProgress.contains(seriesId)) {
      s += _boostInProgressSeries;
    }

    // 8. Favourite boost.
    if (item.userData?.isFavorite ?? false) {
      s += _boostFavourite;
    }

    // Items with zero matching genres AND zero matching people will score near
    // zero: only rating/year/runtime fractions contribute (max ≈ 0.20), which
    // is correct — non-matches surface below genuine matches.

    return s;
  }

  /// Builds the set of *derived* display rails for the Home screen
  /// (Pour vous, Pépites, Vite vu, Parce que vous avez aimé…), in display
  /// order. Empty rails are skipped automatically.
  ///
  /// The "Continuer à regarder" and "À finir" rails are NOT produced here —
  /// they are rendered directly from `resumeItemsProvider` / `nextUpItemsProvider`
  /// so they can paint from the Drift SWR cache at cold start without gating
  /// on this method's recentlyPlayed → tasteProfile chain.
  Future<List<RecommendationRail>> rails(TasteProfile profile) async {
    // No play history → nothing meaningful to recommend. Return empty and
    // skip the expensive `latestItems(60)` fetch entirely. The home still
    // shows library rails (Derniers ajouts par bibliothèque) for fresh users.
    if (profile.sampleSize == 0) return const [];

    // Request genres, people and studios so the scoring functions have full
    // signal. Without these fields, _genreScore/_peopleScore/_studioScore all
    // return 0 and every item scores nearly identically — "Pour vous" and
    // "Pépites" then surface the same high-rated items in the same order.
    final latestItems = await _client.latestItems(
      limit: 60,
      extraFields: const [
        ItemFields.genres,
        ItemFields.people,
        ItemFields.studios,
      ],
    );

    // Compute derived rails (may involve additional network calls).
    final similarRailsList = await _similarRails(profile);
    final pourVousItems = await _pourVousItems(profile, latestItems);

    final result = <RecommendationRail>[];

    // Rail — Pour vous.
    if (pourVousItems.isNotEmpty) {
      result.add(
        RecommendationRail(
          id: 'pour_vous',
          title: 'Pour vous',
          items: pourVousItems,
        ),
      );
    }

    // Rails — "Parce que vous avez aimé X" (up to 2).
    result.addAll(similarRailsList);

    // Collect ids already assigned to "Pour vous" and the "Parce que" rails so
    // that Pépites and Vite vu never repeat the same items. Without this cross-
    // rail dedup, any high-rated item that tops "Pour vous" would also appear
    // first in "Pépites" — the two sections look identical to the user.
    final alreadyShownIds = {
      for (final item in pourVousItems) if (item.id != null) item.id!,
      for (final rail in similarRailsList)
        for (final item in rail.items) if (item.id != null) item.id!,
    };

    // Rail — Pépites cachées.
    final pepites = _pepitesItems(latestItems, profile, excludeIds: alreadyShownIds);
    if (pepites.isNotEmpty) {
      result.add(
        RecommendationRail(
          id: 'pepites',
          title: 'Pépites cachées',
          subtitle: 'Bien notés, peu connus',
          items: pepites,
        ),
      );
    }

    // Rail — Vite vu (≤ 95 minutes).
    final alreadyShownForViteVu = {
      ...alreadyShownIds,
      for (final item in pepites) if (item.id != null) item.id!,
    };
    final vitevuItems = _vitevuItems(latestItems, profile, excludeIds: alreadyShownForViteVu);
    if (vitevuItems.isNotEmpty) {
      result.add(
        RecommendationRail(
          id: 'vite_vu',
          title: 'Vite vu',
          subtitle: 'Moins de 95 minutes',
          items: vitevuItems,
        ),
      );
    }

    // Last resort: if everything is empty, fall back to Latest.
    if (result.isEmpty && latestItems.isNotEmpty) {
      result.add(
        RecommendationRail(
          id: 'latest_fallback',
          title: 'Derniers ajouts',
          items: latestItems.take(24).toList(),
        ),
      );
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Rail builders (private)
  // ---------------------------------------------------------------------------

  /// Pour vous: merge latest + similar(top played), score, dedup vs seenIds.
  Future<List<BaseItemDto>> _pourVousItems(
    TasteProfile profile,
    List<BaseItemDto> latestItems,
  ) async {
    var candidates = List<BaseItemDto>.from(latestItems);

    if (profile.seenItemIds.isNotEmpty) {
      try {
        final topId = profile.seenItemIds.first;
        final similar = await _client.similar(topId, limit: 24);
        candidates = _dedup([...candidates, ...similar]);
      } on Exception catch (_) {
        // Ignore — similar endpoint may not be available in all setups.
      }
    }

    final filtered =
        candidates.where((i) => !profile.seenItemIds.contains(i.id)).toList()
          ..sort((a, b) => score(b, profile).compareTo(score(a, profile)));

    return filtered.take(24).toList();
  }

  /// "Parce que vous avez aimé X" — up to 2 rails, one per top-played item.
  Future<List<RecommendationRail>> _similarRails(TasteProfile profile) async {
    if (profile.seenItemIds.isEmpty) return const [];

    final sources = profile.seenItemIds.take(2).toList();
    final railsOut = <RecommendationRail>[];

    for (final sourceId in sources) {
      try {
        final similar = await _client.similar(sourceId, limit: 24);
        final filtered =
            similar.where((i) => !profile.seenItemIds.contains(i.id)).toList()
              ..sort((a, b) => score(b, profile).compareTo(score(a, profile)));

        if (filtered.isEmpty) continue;

        // Source name comes from the taste profile — it was captured at
        // history-parse time (`TasteProfile.fromHistory` resolves seriesName
        // or name per seen id). Using a similar item's `seriesName` here
        // was meaningless: it pointed at the *similar* item's parent show,
        // not the seed's. Resulted in null almost always, so the rail
        // collapsed to the generic "Parce que vous avez aimé…" title.
        final sourceName = profile.seenItemNames[sourceId];

        railsOut.add(
          RecommendationRail(
            id: 'because_$sourceId',
            // Inline the source title in the rail name so the user knows
            // which watch this rail is anchored to. Falls back to the
            // generic form when the similar response didn't carry a usable
            // seriesName (rare, but the section would otherwise stay
            // opaque).
            title: sourceName != null
                ? 'Parce que vous avez aimé $sourceName'
                : 'Parce que vous avez aimé…',
            reason: sourceName != null
                ? RailReason(sourceItemId: sourceId)
                : null,
            items: filtered.take(24).toList(),
          ),
        );
      } on Exception catch (_) {
        // Skip rails where the similar call fails.
      }
    }

    return railsOut;
  }

  /// Pépites cachées: high-rated (≥ 7.5) unseen items, scored.
  ///
  /// [excludeIds] contains item ids already claimed by earlier rails ("Pour
  /// vous", "Parce que…") so Pépites never repeats the same content.
  List<BaseItemDto> _pepitesItems(
    List<BaseItemDto> latestItems,
    TasteProfile profile, {
    Set<String> excludeIds = const {},
  }) {
    return latestItems.where((i) {
      final id = i.id;
      if (id == null) return false;
      if (profile.seenItemIds.contains(id)) return false;
      if (excludeIds.contains(id)) return false;
      final rating = i.communityRating ?? 0;
      return rating >= 7.5;
    }).toList()..sort((a, b) => score(b, profile).compareTo(score(a, profile)));
  }

  /// Vite vu: items with runTimeTicks ≤ 95 minutes, scored.
  ///
  /// [excludeIds] contains item ids already claimed by earlier rails so this
  /// rail never repeats content shown above.
  List<BaseItemDto> _vitevuItems(
    List<BaseItemDto> latestItems,
    TasteProfile profile, {
    Set<String> excludeIds = const {},
  }) {
    const maxTicks = 95 * 60 * 10000000; // 95 minutes in 100-ns ticks.
    return latestItems.where((i) {
      final id = i.id;
      if (id == null) return false;
      if (profile.seenItemIds.contains(id)) return false;
      if (excludeIds.contains(id)) return false;
      final rt = i.runTimeTicks;
      return rt != null && rt > 0 && rt <= maxTicks;
    }).toList()..sort((a, b) => score(b, profile).compareTo(score(a, profile)));
  }

  // ---------------------------------------------------------------------------
  // Score sub-signals (all pure)
  // ---------------------------------------------------------------------------

  double _genreScore(BaseItemDto item, TasteProfile profile) {
    if (profile.genreWeights.isEmpty) return 0;
    final genres = item.genres;
    if (genres == null || genres.isEmpty) return 0;

    var weightedOverlap = 0.0;
    var totalProfileWeight = 0.0;

    for (final entry in profile.genreWeights.entries) {
      totalProfileWeight += entry.value;
      if (genres.contains(entry.key)) {
        weightedOverlap += entry.value;
      }
    }

    if (totalProfileWeight == 0) return 0;
    return (weightedOverlap / totalProfileWeight).clamp(0.0, 1.0);
  }

  double _peopleScore(BaseItemDto item, TasteProfile profile) {
    if (profile.peopleWeights.isEmpty) return 0;
    final people = item.people;
    if (people == null || people.isEmpty) return 0;

    var weightedOverlap = 0.0;
    var totalProfileWeight = 0.0;

    for (final entry in profile.peopleWeights.entries) {
      totalProfileWeight += entry.value;
      if (people.any((p) => p.name == entry.key)) {
        weightedOverlap += entry.value;
      }
    }

    if (totalProfileWeight == 0) return 0;
    return (weightedOverlap / totalProfileWeight).clamp(0.0, 1.0);
  }

  double _studioScore(BaseItemDto item, TasteProfile profile) {
    if (profile.studioWeights.isEmpty) return 0;
    final studios = item.studios;
    if (studios == null || studios.isEmpty) return 0;

    var weightedOverlap = 0.0;
    var totalProfileWeight = 0.0;

    for (final entry in profile.studioWeights.entries) {
      totalProfileWeight += entry.value;
      if (studios.any((s) => s.name == entry.key)) {
        weightedOverlap += entry.value;
      }
    }

    if (totalProfileWeight == 0) return 0;
    return (weightedOverlap / totalProfileWeight).clamp(0.0, 1.0);
  }

  double _yearScore(BaseItemDto item, TasteProfile profile) {
    final meanYear = profile.meanProductionYear;
    if (meanYear == null) return 0;
    final itemYear = item.productionYear;
    if (itemYear == null) return 0;
    return math.max(0, 1.0 - (itemYear - meanYear).abs() / 50.0);
  }

  double _runtimeScore(BaseItemDto item, TasteProfile profile) {
    final medianRt = profile.medianRuntimeMinutes;
    if (medianRt == 0) return 0;
    final rtTicks = item.runTimeTicks;
    if (rtTicks == null || rtTicks <= 0) return 0;
    final itemRt = rtTicks / 600000000.0; // 100-ns ticks → minutes.
    return math.max(0, 1.0 - (itemRt - medianRt).abs() / medianRt);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Deduplicates a list by item id, preserving original order.
  static List<BaseItemDto> _dedup(List<BaseItemDto> items) {
    final seen = <String>{};
    return items.where((i) {
      final id = i.id;
      if (id == null) return false;
      return seen.add(id);
    }).toList();
  }
}
