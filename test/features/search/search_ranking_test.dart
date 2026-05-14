import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/jellyfin/models/jellyfin_item.dart';
import 'package:jellyfish/features/search/search_ranking.dart';
import 'package:jellyfish/shared/text/diacritics.dart';

JellyfinItem _item({
  required String id,
  required String name,
  String? seriesName,
  int? year,
}) => JellyfinItem(
  id: id,
  name: name,
  seriesName: seriesName,
  productionYear: year,
);

void main() {
  group('normalizeForSearch', () {
    test('lower-cases and folds diacritics', () {
      expect(normalizeForSearch('Amélie'), 'amelie');
      expect(normalizeForSearch('Pokémon'), 'pokemon');
      expect(normalizeForSearch('Cœur'), 'coeur');
    });

    test('collapses whitespace and trims', () {
      expect(normalizeForSearch('  The   Office  '), 'the office');
    });

    test('returns empty for null/blank', () {
      expect(normalizeForSearch(null), '');
      expect(normalizeForSearch('   '), '');
    });
  });

  group('rankByRelevance', () {
    test('exact match outranks prefix and word-prefix', () {
      final ranked = rankByRelevance([
        _item(id: 'prefix', name: 'Friends Reunion'),
        _item(id: 'wordPrefix', name: 'Best Friends Forever'),
        _item(id: 'exact', name: 'Friends'),
      ], 'friends');
      expect(ranked.map((e) => e.id), ['exact', 'prefix', 'wordPrefix']);
    });

    test('shorter prefix wins tiebreaker', () {
      final ranked = rankByRelevance([
        _item(id: 'long', name: 'Dune: Part Two'),
        _item(id: 'short', name: 'Dune'),
      ], 'dun');
      expect(ranked.first.id, 'short');
    });

    test('newer year wins on equal name length', () {
      final ranked = rankByRelevance([
        _item(id: 'old', name: 'Dune', year: 1984),
        _item(id: 'new', name: 'Dune', year: 2021),
      ], 'dune');
      expect(ranked.first.id, 'new');
    });

    test('diacritic-insensitive match', () {
      final ranked = rankByRelevance([
        _item(id: '1', name: 'Amélie'),
      ], 'amelie');
      expect(ranked, hasLength(1));
      expect(ranked.first.id, '1');
    });

    test('multi-word query matches via token overlap', () {
      final ranked = rankByRelevance([
        _item(id: 'unrelated', name: 'Parks and Recreation'),
        _item(id: 'office', name: 'The Office (US)'),
      ], 'office us');
      expect(ranked.first.id, 'office');
    });

    test('drops items with zero score', () {
      final ranked = rankByRelevance([
        _item(id: 'noise', name: 'Breaking Bad'),
        _item(id: 'hit', name: 'Friends'),
      ], 'friends');
      expect(ranked.map((e) => e.id), ['hit']);
    });

    test('ignores seriesName fallback (root-kinds filter handles episodes)', () {
      // Episode whose name doesn't match must not slip in just because the
      // series name does — seasons/episodes are filtered out upstream.
      final ranked = rankByRelevance([
        _item(
          id: 'ep',
          name: 'The One Where Ross Got High',
          seriesName: 'Friends',
        ),
        _item(id: 'movie', name: 'Friends with Benefits'),
      ], 'friends');
      expect(ranked.map((e) => e.id), ['movie']);
    });

    test('word-prefix beats contains-without-word-boundary', () {
      // "afriendly" contains "friend" but no token starts with it; "Friendly
      // Fire" has a token starting with "friend" → wins.
      final ranked = rankByRelevance([
        _item(id: 'contains', name: 'Unafriendly Skies'),
        _item(id: 'wordPrefix', name: 'Friendly Fire'),
      ], 'friend');
      expect(ranked.first.id, 'wordPrefix');
    });

    test('empty query returns input unchanged', () {
      final input = [_item(id: '1', name: 'A'), _item(id: '2', name: 'B')];
      expect(rankByRelevance(input, ''), input);
    });
  });
}
