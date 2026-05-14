import 'package:jellyfin_api/jellyfin_api.dart';

/// An immutable snapshot of the user's taste built from recently-played items.
///
/// All maps are normalised so every value is in [0, 1]: divide each map's raw
/// count by the largest raw count in that map. Weights therefore express
/// *relative* preference, not absolute counts.
///
/// Items are only included in the profile if `userData.played == true` OR
/// `userData.playbackPositionTicks > 0`. Items the user has never touched are
/// excluded entirely so that newly-added library content does not pollute the
/// taste signal.
///
/// Partially-watched items (started but not finished) are treated with a
/// weight of 0.5 relative to a fully-played item. This is a deliberate choice:
/// a half-watched film still signals interest, but we don't want an abandoned
/// horror movie to unfairly dominate the "Horror" genre weight.
class TasteProfile {
  const TasteProfile({
    required this.genreWeights,
    required this.peopleWeights,
    required this.studioWeights,
    required this.medianRuntimeMinutes,
    required this.meanProductionYear,
    required this.meanCommunityRating,
    required this.seenItemIds,
    required this.seenItemNames,
    required this.seriesIdsInProgress,
    required this.sampleSize,
  });

  /// Normalised genre → weight, sum ≤ 1.0.
  final Map<String, double> genreWeights;

  /// Top cast/directors per item (up to 6), normalised.
  final Map<String, double> peopleWeights;

  /// Studio names → normalised weight.
  final Map<String, double> studioWeights;

  /// Median runtime across played items (in minutes). 0 if unknown.
  final double medianRuntimeMinutes;

  /// Mean production year. null if no year data in the sample.
  final int? meanProductionYear;

  /// Mean community rating of played items. 0 if no ratings available.
  final double meanCommunityRating;

  /// All item IDs the user has fully played. Used for deduplication.
  final Set<String> seenItemIds;

  /// Display name for each seen id. Drives the title of the per-seed
  /// "Parce que vous avez aimé X" rails — kept on the profile so callers
  /// (`Recommender._similarRails`) don't have to fetch the source item
  /// again just to resolve its name. Series ids map to the series name;
  /// episode ids map to the parent series name (so the rail reads
  /// "Parce que vous avez aimé Friends" rather than the episode title).
  final Map<String, String> seenItemNames;

  /// Series that have been *started* (partial plays). Drives "À finir" rail.
  final Set<String> seriesIdsInProgress;

  /// How many items contributed to the profile.
  final int sampleSize;

  /// An empty, zero-signal profile — returned when history is unavailable.
  static const TasteProfile empty = TasteProfile(
    genreWeights: {},
    peopleWeights: {},
    studioWeights: {},
    medianRuntimeMinutes: 0,
    meanProductionYear: null,
    meanCommunityRating: 0,
    seenItemIds: {},
    seenItemNames: {},
    seriesIdsInProgress: {},
    sampleSize: 0,
  );

  /// Build a [TasteProfile] from a list of recently-played [BaseItemDto]s.
  ///
  /// Only items with `userData.played == true` or
  /// `userData.playbackPositionTicks > 0` are considered.
  /// Fully-played items contribute weight 1.0; partially-played items 0.5.
  factory TasteProfile.fromHistory(List<BaseItemDto> history) {
    if (history.isEmpty) return TasteProfile.empty;

    final rawGenres = <String, double>{};
    final rawPeople = <String, double>{};
    final rawStudios = <String, double>{};
    final seenIds = <String>{};
    final seenNames = <String, String>{};
    final seriesInProgress = <String>{};
    final runtimes = <double>[];
    final years = <int>[];
    final ratings = <double>[];
    var sampleSize = 0;

    for (final item in history) {
      final ud = item.userData;
      final played = ud?.played ?? false;
      final positionTicks = ud?.playbackPositionTicks ?? 0;

      // Skip items the user has never interacted with.
      if (!played && positionTicks == 0) continue;

      // Items that have been started on a series contribute to in-progress.
      final seriesId = item.seriesId;
      if (seriesId != null && seriesId.isNotEmpty) {
        seriesInProgress.add(seriesId);
      }

      // Fully played items → seenIds, with a display name resolved for the
      // "Parce que vous avez aimé X" rail title. For episodes we prefer the
      // parent series name so the rail reads as the show, not the episode.
      final id = item.id;
      if (played && id != null) {
        seenIds.add(id);
        final name = item.seriesName ?? item.name;
        if (name != null && name.isNotEmpty) seenNames[id] = name;
      }

      // Contribution weight: 1.0 for fully played, 0.5 for partial.
      final weight = played ? 1.0 : 0.5;
      sampleSize++;

      // Genres
      final genres = item.genres;
      if (genres != null) {
        for (final g in genres) {
          rawGenres[g] = (rawGenres[g] ?? 0) + weight;
        }
      }

      // People — use first 6 cast/directors per item to limit influence.
      final people = item.people;
      if (people != null) {
        final capped = people.take(6);
        for (final p in capped) {
          final name = p.name;
          if (name != null && name.isNotEmpty) {
            rawPeople[name] = (rawPeople[name] ?? 0) + weight;
          }
        }
      }

      // Studios
      final studios = item.studios;
      if (studios != null) {
        for (final s in studios) {
          final name = s.name;
          if (name != null && name.isNotEmpty) {
            rawStudios[name] = (rawStudios[name] ?? 0) + weight;
          }
        }
      }

      // Runtime
      final rt = item.runTimeTicks;
      if (rt != null && rt > 0) {
        runtimes.add(_ticksToMinutes(rt));
      }

      // Year
      final year = item.productionYear;
      if (year != null) years.add(year);

      // Rating
      final rating = item.communityRating;
      if (rating != null) ratings.add(rating);
    }

    return TasteProfile(
      genreWeights: _normalise(rawGenres),
      peopleWeights: _normalise(rawPeople),
      studioWeights: _normalise(rawStudios),
      medianRuntimeMinutes: _median(runtimes),
      meanProductionYear: years.isEmpty
          ? null
          : (years.reduce((a, b) => a + b) / years.length).round(),
      meanCommunityRating: ratings.isEmpty
          ? 0
          : ratings.reduce((a, b) => a + b) / ratings.length,
      seenItemIds: seenIds,
      seenItemNames: seenNames,
      seriesIdsInProgress: seriesInProgress,
      sampleSize: sampleSize,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Normalises a raw-count map so the largest value becomes 1.0 and all
  /// others are in (0, 1]. Returns an empty map unchanged.
  static Map<String, double> _normalise(Map<String, double> raw) {
    if (raw.isEmpty) return const {};
    final maxVal = raw.values.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return const {};
    return {for (final e in raw.entries) e.key: e.value / maxVal};
  }

  /// Returns the median of a list of doubles, or 0 if empty.
  static double _median(List<double> values) {
    if (values.isEmpty) return 0;
    final sorted = List<double>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// Converts .NET 100-nanosecond ticks to minutes.
  static double _ticksToMinutes(int ticks) => ticks / 600000000;
}
