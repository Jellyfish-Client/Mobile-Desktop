import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/recommender/taste_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

int _minTicks(int minutes) => minutes * 60 * 10000000;

UserItemDataDto _played({bool played = true, int playedTicks = 0}) =>
    UserItemDataDto(
      (b) => b
        ..isFavorite = false
        ..played = played
        ..playbackPositionTicks = playedTicks,
    );

BaseItemDto _item({
  required String id,
  required String title,
  List<String> genres = const [],
  int? year,
  int runtimeMinutes = 90,
  double? rating,
  bool played = true,
  int partialMinutes = 0,
  String? seriesId,
}) {
  final ticks = _minTicks(runtimeMinutes);
  final playedTicks = partialMinutes > 0 ? _minTicks(partialMinutes) : 0;
  return BaseItemDto(
    (b) => b
      ..id = id
      ..name = title
      ..type = BaseItemKind.movie
      ..productionYear = year
      ..runTimeTicks = ticks
      ..communityRating = rating
      ..seriesId = seriesId
      ..genres = ListBuilder<String>(genres)
      ..userData = _played(
        played: played,
        playedTicks: played ? ticks : playedTicks,
      ).toBuilder(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TasteProfile.empty', () {
    test('is zero-signal with empty collections', () {
      const p = TasteProfile.empty;
      expect(p.sampleSize, 0);
      expect(p.genreWeights, isEmpty);
      expect(p.peopleWeights, isEmpty);
      expect(p.studioWeights, isEmpty);
      expect(p.medianRuntimeMinutes, 0);
      expect(p.meanProductionYear, isNull);
      expect(p.meanCommunityRating, 0);
      expect(p.seenItemIds, isEmpty);
      expect(p.seriesIdsInProgress, isEmpty);
    });
  });

  group('TasteProfile.fromHistory', () {
    test('returns empty profile for empty history', () {
      final p = TasteProfile.fromHistory([]);
      expect(p.sampleSize, 0);
      expect(p.genreWeights, isEmpty);
    });

    test('excludes items with no play data', () {
      final untouched = BaseItemDto(
        (b) => b
          ..id = 'x'
          ..name = 'X'
          ..type = BaseItemKind.movie
          ..genres = ListBuilder<String>(['Horror'])
          ..userData = UserItemDataDto(
            (b) => b
              ..isFavorite = false
              ..played = false
              ..playbackPositionTicks = 0,
          ).toBuilder(),
      );
      final p = TasteProfile.fromHistory([untouched]);
      expect(p.sampleSize, 0);
      expect(p.genreWeights, isEmpty);
    });

    test('genre weights are normalised to [0, 1]', () {
      final items = [
        _item(id: 'a', title: 'A', genres: ['Drama', 'Sci-Fi']),
        _item(id: 'b', title: 'B', genres: ['Drama']),
        _item(id: 'c', title: 'C', genres: ['Drama']),
      ];
      final p = TasteProfile.fromHistory(items);

      // Drama appears 3 times → 1.0; Sci-Fi appears 1 time → 1/3 ≈ 0.333.
      expect(p.genreWeights['Drama'], closeTo(1.0, 0.001));
      expect(p.genreWeights['Sci-Fi'], closeTo(1.0 / 3.0, 0.001));
    });

    test('partially-played items contribute weight 0.5', () {
      final items = [
        _item(
          id: 'a',
          title: 'A',
          genres: ['Drama'],
          played: false,
          partialMinutes: 30,
        ),
        _item(id: 'b', title: 'B', genres: ['Drama']),
      ];
      // A = 0.5, B = 1.0 → max = 1.0 → A normalised = 0.5
      final p = TasteProfile.fromHistory(items);
      expect(p.sampleSize, 2);
      expect(p.genreWeights['Drama'], closeTo(1.0, 0.001));
    });

    test('fully-played items are added to seenItemIds', () {
      final items = [
        _item(id: 'seen-1', title: 'S1', genres: ['Drama']),
        _item(
          id: 'partial-1',
          title: 'P1',
          genres: ['Action'],
          played: false,
          partialMinutes: 20,
        ),
      ];
      final p = TasteProfile.fromHistory(items);
      expect(p.seenItemIds, contains('seen-1'));
      expect(p.seenItemIds, isNot(contains('partial-1')));
    });

    test('seriesId of started items lands in seriesIdsInProgress', () {
      final items = [
        _item(
          id: 'ep1',
          title: 'Episode 1',
          genres: ['Drama'],
          played: false,
          partialMinutes: 15,
          seriesId: 'series-abc',
        ),
      ];
      final p = TasteProfile.fromHistory(items);
      expect(p.seriesIdsInProgress, contains('series-abc'));
    });

    test('medianRuntimeMinutes is computed correctly', () {
      final items = [
        _item(id: 'a', title: 'A', genres: ['X'], runtimeMinutes: 60),
        _item(id: 'b', title: 'B', genres: ['X'], runtimeMinutes: 90),
        _item(id: 'c', title: 'C', genres: ['X'], runtimeMinutes: 120),
      ];
      final p = TasteProfile.fromHistory(items);
      expect(p.medianRuntimeMinutes, closeTo(90.0, 0.001));
    });

    test('meanProductionYear is rounded average', () {
      final items = [
        _item(id: 'a', title: 'A', genres: ['X'], year: 2000),
        _item(id: 'b', title: 'B', genres: ['X'], year: 2010),
        _item(id: 'c', title: 'C', genres: ['X'], year: 2020),
      ];
      final p = TasteProfile.fromHistory(items);
      expect(p.meanProductionYear, 2010);
    });

    test('meanCommunityRating is average', () {
      final items = [
        _item(id: 'a', title: 'A', genres: ['X'], rating: 8),
        _item(id: 'b', title: 'B', genres: ['X'], rating: 6),
      ];
      final p = TasteProfile.fromHistory(items);
      expect(p.meanCommunityRating, closeTo(7.0, 0.001));
    });
  });
}
