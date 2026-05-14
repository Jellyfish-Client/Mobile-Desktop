import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/playback/trickplay.dart';

/// Wraps a plain `Map<String, Map<...>>` into the SDK's nested `BuiltMap`
/// shape so `trickplay.replace()` accepts it.
BuiltMap<String, BuiltMap<String, TrickplayInfoDto>> _trickplayBuilt(
  Map<String, Map<String, TrickplayInfoDto>> source,
) {
  return BuiltMap.of({
    for (final e in source.entries) e.key: BuiltMap.of(e.value),
  });
}

BaseItemDto _itemWithTrickplay({
  required Map<String, Map<String, TrickplayInfoDto>> trickplay,
  String? id,
}) {
  return BaseItemDto((b) {
    if (id != null) b.id = id;
    b
      ..name = 'whatever'
      ..trickplay.replace(_trickplayBuilt(trickplay));
  });
}

TrickplayInfoDto _info({
  int width = 320,
  int height = 180,
  int tileWidth = 10,
  int tileHeight = 10,
  int thumbnailCount = 100,
  int intervalMs = 1000,
}) {
  return TrickplayInfoDto(
    (b) => b
      ..width = width
      ..height = height
      ..tileWidth = tileWidth
      ..tileHeight = tileHeight
      ..thumbnailCount = thumbnailCount
      ..interval = intervalMs,
  );
}

void main() {
  group('TrickplayManifest.fromItem', () {
    test('returns null when no trickplay metadata', () {
      final item = BaseItemDto(
        (b) => b
          ..id = 'i'
          ..name = 'n',
      );
      expect(TrickplayManifest.fromItem(item), isNull);
    });

    test('returns null when trickplay map is empty', () {
      final item = _itemWithTrickplay(trickplay: const {}, id: 'i');
      expect(TrickplayManifest.fromItem(item), isNull);
    });

    test('picks the widest tile size when multiple are available', () {
      final item = _itemWithTrickplay(
        trickplay: {
          'src1': {
            '160': _info(width: 160),
            '320': _info(width: 320),
            '640': _info(width: 640),
          },
        },
        id: 'i',
      );
      final m = TrickplayManifest.fromItem(item)!;
      expect(m.width, 640);
    });

    test('skips entries with missing required fields', () {
      // First mediaSource has incomplete info; second is valid.
      final partial = TrickplayInfoDto(
        (b) => b
          ..width = 320
          // height intentionally omitted
          ..tileWidth = 10
          ..tileHeight = 10
          ..thumbnailCount = 100
          ..interval = 1000,
      );
      final item = _itemWithTrickplay(
        trickplay: {
          'src-bad': {'320': partial},
          'src-ok': {'320': _info()},
        },
        id: 'i',
      );
      final m = TrickplayManifest.fromItem(item);
      expect(m, isNotNull);
      expect(m!.itemId, 'i');
    });

    test('returns null when item id is null', () {
      // Build a DTO without an id but with valid trickplay — fromItem must
      // still bail because the URL it would feed downstream needs an id.
      final item = _itemWithTrickplay(
        trickplay: {
          'src': {'320': _info()},
        },
      );
      expect(TrickplayManifest.fromItem(item), isNull);
    });
  });

  group('TrickplayManifest.indexFor', () {
    const manifest = TrickplayManifest(
      itemId: 'i',
      width: 320,
      height: 180,
      tileCols: 10,
      tileRows: 10,
      thumbnailCount: 100,
      intervalMs: 1000,
    );

    test('position at 0 maps to (tile=0, col=0, row=0)', () {
      final r = manifest.indexFor(Duration.zero)!;
      expect(r.tileIndex, 0);
      expect(r.col, 0);
      expect(r.row, 0);
    });

    test('mid-grid position maps to the right cell', () {
      // global thumbnail index = 5500ms / 1000ms = 5
      // tile 0 contains thumbnails 0..99, so this is still tile 0.
      // within = 5 → col=5, row=0.
      final r = manifest.indexFor(const Duration(milliseconds: 5500))!;
      expect(r.tileIndex, 0);
      expect(r.col, 5);
      expect(r.row, 0);
    });

    test('returns null when position exceeds thumbnailCount window', () {
      // 100 thumbnails × 1000ms = 100s window. 200s is past the end.
      expect(manifest.indexFor(const Duration(seconds: 200)), isNull);
    });

    test('returns null on a degenerate interval', () {
      const broken = TrickplayManifest(
        itemId: 'i',
        width: 320,
        height: 180,
        tileCols: 10,
        tileRows: 10,
        thumbnailCount: 100,
        intervalMs: 0,
      );
      expect(broken.indexFor(const Duration(seconds: 1)), isNull);
    });

    test('returns null when tilesPerImage is zero', () {
      const broken = TrickplayManifest(
        itemId: 'i',
        width: 320,
        height: 180,
        tileCols: 0,
        tileRows: 10,
        thumbnailCount: 100,
        intervalMs: 1000,
      );
      expect(broken.indexFor(const Duration(seconds: 1)), isNull);
    });
  });
}
