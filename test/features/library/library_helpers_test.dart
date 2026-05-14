import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/models/jellyfin_item.dart';
import 'package:jellyfish/features/library/library_providers.dart';

JellyfinItem _view({required String id, CollectionType? type}) =>
    JellyfinItem(id: id, name: id, collectionType: type);

void main() {
  group('rootKindsForViews', () {
    test('movies view maps to movie kind', () {
      final kinds = rootKindsForViews([
        _view(id: 'a', type: CollectionType.movies),
      ]);
      expect(kinds, [BaseItemKind.movie]);
    });

    test('tvshows view maps to series kind', () {
      final kinds = rootKindsForViews([
        _view(id: 'a', type: CollectionType.tvshows),
      ]);
      expect(kinds, [BaseItemKind.series]);
    });

    test('homevideos view maps to video AND photo', () {
      final kinds = rootKindsForViews([
        _view(id: 'a', type: CollectionType.homevideos),
      ]);
      expect(kinds.toSet(), {BaseItemKind.video, BaseItemKind.photo});
    });

    test('multiple views are merged', () {
      final kinds = rootKindsForViews([
        _view(id: 'a', type: CollectionType.movies),
        _view(id: 'b', type: CollectionType.tvshows),
        _view(id: 'c', type: CollectionType.music),
      ]);
      expect(kinds.toSet(), {
        BaseItemKind.movie,
        BaseItemKind.series,
        BaseItemKind.musicAlbum,
      });
    });

    test('unknown collectionType falls back to movie + series', () {
      // Pass a view with a null collectionType — drives the `sawUnknown` path.
      final kinds = rootKindsForViews([_view(id: 'a')]);
      expect(kinds.toSet(), {BaseItemKind.movie, BaseItemKind.series});
    });

    test('empty input falls back to movie + series', () {
      final kinds = rootKindsForViews(const []);
      expect(kinds.toSet(), {BaseItemKind.movie, BaseItemKind.series});
    });

    test('known + unknown still adds the movie/series fallback', () {
      final kinds = rootKindsForViews([
        _view(id: 'a', type: CollectionType.boxsets),
        _view(id: 'b'),
      ]);
      // boxSet from the known view + movie/series from the unknown fallback.
      expect(kinds.toSet(), {
        BaseItemKind.boxSet,
        BaseItemKind.movie,
        BaseItemKind.series,
      });
    });
  });

  group('latestRailKindsForView', () {
    test('movies view yields a single "Nouveaux films" rail', () {
      final rails = latestRailKindsForView(
        _view(id: 'a', type: CollectionType.movies),
      );
      expect(rails, hasLength(1));
      expect(rails.single.kind, BaseItemKind.movie);
      expect(rails.single.suffix, 'Nouveaux films');
    });

    test('tvshows view yields both episodes and series rails in order', () {
      final rails = latestRailKindsForView(
        _view(id: 'a', type: CollectionType.tvshows),
      );
      expect(rails, hasLength(2));
      expect(rails[0].kind, BaseItemKind.episode);
      expect(rails[1].kind, BaseItemKind.series);
    });

    test('unknown collectionType yields no rails', () {
      expect(latestRailKindsForView(_view(id: 'a')), isEmpty);
    });
  });
}
