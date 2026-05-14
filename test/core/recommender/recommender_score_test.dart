import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/core/recommender/recommender.dart';
import 'package:jellyfish/core/recommender/taste_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

int _minTicks(int minutes) => minutes * 60 * 10000000;

/// A minimal valid Recommender instantiated with a dummy client.
/// score() is pure and never calls _client, so the dummy is never invoked.
Recommender _makeRecommender() {
  // JellyfinClient requires Dio, Session?, JellyfinApi — all non-nullable
  // except session. Pass dummy instances that are never called.
  final dummyDio = Dio();
  final dummyApi = JellyfinApi(dio: dummyDio, interceptors: const []);
  final client = JellyfinClient(dummyDio, null, dummyApi);
  return Recommender(client);
}

BaseItemDto _candidate({
  required String id,
  List<String> genres = const [],
  int? year,
  int runtimeMinutes = 90,
  double? rating,
  String? seriesId,
  bool isFavorite = false,
}) {
  return BaseItemDto(
    (b) => b
      ..id = id
      ..name = id
      ..type = BaseItemKind.movie
      ..productionYear = year
      ..runTimeTicks = _minTicks(runtimeMinutes)
      ..communityRating = rating
      ..seriesId = seriesId
      ..genres = ListBuilder<String>(genres)
      ..userData = UserItemDataDto(
        (b) => b
          ..isFavorite = isFavorite
          ..played = false
          ..playbackPositionTicks = 0,
      ).toBuilder(),
  );
}

/// A taste profile biased toward Drama/Sci-Fi made around 2015.
TasteProfile _profile({
  Map<String, double> genres = const {'Drama': 1.0, 'Sci-Fi': 0.5},
  Map<String, double> people = const {},
  Map<String, double> studios = const {},
  double medianRuntime = 100,
  int? meanYear = 2015,
  double meanRating = 7.5,
  Set<String> seenIds = const {},
  Map<String, String> seenNames = const {},
  Set<String> seriesInProgress = const {},
}) {
  return TasteProfile(
    genreWeights: genres,
    peopleWeights: people,
    studioWeights: studios,
    medianRuntimeMinutes: medianRuntime,
    meanProductionYear: meanYear,
    meanCommunityRating: meanRating,
    seenItemIds: seenIds,
    seenItemNames: seenNames,
    seriesIdsInProgress: seriesInProgress,
    sampleSize: 10,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Recommender recommender;

  setUp(() {
    recommender = _makeRecommender();
  });

  group('Recommender.score — exclusion', () {
    test('returns -1 for items in seenItemIds', () {
      final profile = _profile(seenIds: {'seen-movie'});
      final item = _candidate(id: 'seen-movie', genres: ['Drama']);
      expect(recommender.score(item, profile), -1);
    });

    test('positive score for unseen items with matching genre', () {
      final profile = _profile(seenIds: {'other-id'});
      final item = _candidate(id: 'new-movie', genres: ['Drama']);
      expect(recommender.score(item, profile), greaterThan(0));
    });
  });

  group('Recommender.score — genre signal', () {
    test('exact genre match scores higher than no genre match', () {
      final profile = _profile();
      final match = _candidate(id: 'match', genres: ['Drama', 'Sci-Fi']);
      final noMatch = _candidate(id: 'no-match', genres: ['Horror', 'Comedy']);
      expect(
        recommender.score(match, profile),
        greaterThan(recommender.score(noMatch, profile)),
      );
    });

    test(
      'zero genres + zero people yields ≤ 0.21 score (only rating/year/rt)',
      () {
        final profile = _profile(genres: {}, people: {}, studios: {});
        // With no genre/people/studio weights, only rating/year/runtime remain.
        // Max contribution: 0.10 (rating) + 0.05 (year) + 0.05 (runtime) = 0.20.
        final item = _candidate(
          id: 'x',
          genres: [],
          year: 2015,
          runtimeMinutes: 100,
          rating: 10,
        );
        expect(recommender.score(item, profile), lessThanOrEqualTo(0.21));
      },
    );
  });

  group('Recommender.score — rating signal', () {
    test('higher-rated item scores higher (same genres)', () {
      final profile = _profile();
      final high = _candidate(
        id: 'high',
        genres: ['Drama'],
        year: 2015,
        runtimeMinutes: 100,
        rating: 9,
      );
      final low = _candidate(
        id: 'low',
        genres: ['Drama'],
        year: 2015,
        runtimeMinutes: 100,
        rating: 5,
      );
      expect(
        recommender.score(high, profile),
        greaterThan(recommender.score(low, profile)),
      );
    });
  });

  group('Recommender.score — year proximity', () {
    test('item from mean year scores higher than item 60+ years away', () {
      final profile = _profile(meanYear: 2010);
      final near = _candidate(
        id: 'near',
        genres: ['Drama'],
        year: 2010,
        runtimeMinutes: 100,
      );
      final far = _candidate(
        id: 'far',
        genres: ['Drama'],
        year: 1950,
        runtimeMinutes: 100,
      );
      expect(
        recommender.score(near, profile),
        greaterThan(recommender.score(far, profile)),
      );
    });
  });

  group('Recommender.score — runtime proximity', () {
    test(
      'item with runtime == median scores higher than one twice as long',
      () {
        final profile = _profile(medianRuntime: 90, genres: {});
        final near = _candidate(id: 'near', genres: [], runtimeMinutes: 90);
        final far = _candidate(id: 'far', genres: [], runtimeMinutes: 180);
        expect(
          recommender.score(near, profile),
          greaterThan(recommender.score(far, profile)),
        );
      },
    );
  });

  group('Recommender.score — in-progress series boost', () {
    test('item in in-progress series gets boost', () {
      final profile = _profile(seriesInProgress: {'series-1'});
      final inProgress = _candidate(
        id: 'ep1',
        genres: [],
        seriesId: 'series-1',
      );
      final unrelated = _candidate(id: 'ep2', genres: []);

      expect(
        recommender.score(inProgress, profile),
        greaterThan(recommender.score(unrelated, profile)),
      );
    });

    test('seen item in in-progress series is still excluded', () {
      final profile = _profile(
        seenIds: {'ep1'},
        seriesInProgress: {'series-1'},
      );
      final item = _candidate(id: 'ep1', genres: [], seriesId: 'series-1');
      expect(recommender.score(item, profile), -1);
    });
  });

  group('Recommender.score — favourite boost', () {
    test('favourite item gets a small boost', () {
      final profile = _profile(genres: {});
      final fav = _candidate(id: 'fav', genres: [], isFavorite: true);
      final notFav = _candidate(id: 'nfav', genres: [], isFavorite: false);

      expect(
        recommender.score(fav, profile),
        greaterThan(recommender.score(notFav, profile)),
      );
    });
  });

  group('Recommender.score — score bounds', () {
    test('score never exceeds ~1.15 even with all signals maxed', () {
      final profile = _profile(
        genres: {'Drama': 1.0},
        people: {'Actor One': 1.0},
        studios: {'Studio A': 1.0},
        medianRuntime: 90,
        meanYear: 2020,
        meanRating: 9,
        seriesInProgress: {'series-x'},
      );
      final item = BaseItemDto(
        (b) => b
          ..id = 'max'
          ..name = 'max'
          ..type = BaseItemKind.movie
          ..productionYear = 2020
          ..runTimeTicks = _minTicks(90)
          ..communityRating = 10
          ..seriesId = 'series-x'
          ..genres = ListBuilder<String>(['Drama'])
          ..studios = ListBuilder<NameGuidPair>([
            NameGuidPair((b) => b..name = 'Studio A'),
          ])
          ..people = ListBuilder<BaseItemPerson>([
            BaseItemPerson((b) => b..name = 'Actor One'),
          ])
          ..userData = UserItemDataDto(
            (b) => b
              ..isFavorite = true
              ..played = false
              ..playbackPositionTicks = 0,
          ).toBuilder(),
      );
      final s = recommender.score(item, profile);
      // Base weights: genre(0.40) + people(0.25) + studio(0.10) +
      //               rating(0.10) + year(0.05) + runtime(0.05) = 0.95
      // + boosts: inProgress(0.10) + favourite(0.05) = 0.20
      // Total max ≈ 1.15; allow small floating-point margin.
      expect(s, lessThanOrEqualTo(1.16));
      expect(s, greaterThan(0.8));
    });
  });
}
