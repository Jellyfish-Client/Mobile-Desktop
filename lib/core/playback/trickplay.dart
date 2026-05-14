import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import 'playback_providers.dart';

/// Resolved trickplay manifest for a single media source. Pre-computes the
/// values needed to map a playback position to a tile image + crop rect.
class TrickplayManifest {
  const TrickplayManifest({
    required this.itemId,
    required this.width,
    required this.height,
    required this.tileCols,
    required this.tileRows,
    required this.thumbnailCount,
    required this.intervalMs,
  });

  final String itemId;
  final int width;
  final int height;
  final int tileCols;
  final int tileRows;
  final int thumbnailCount;
  final int intervalMs;

  int get tilesPerImage => tileCols * tileRows;

  /// Resolves the position to (tileIndex, col, row).
  ({int tileIndex, int col, int row})? indexFor(Duration position) {
    if (intervalMs <= 0 || tilesPerImage <= 0) return null;
    final globalIndex = position.inMilliseconds ~/ intervalMs;
    if (globalIndex < 0 || globalIndex >= thumbnailCount) return null;
    final tileIndex = globalIndex ~/ tilesPerImage;
    final within = globalIndex % tilesPerImage;
    return (
      tileIndex: tileIndex,
      col: within % tileCols,
      row: within ~/ tileCols,
    );
  }

  static TrickplayManifest? fromItem(BaseItemDto item) {
    final id = item.id;
    final trickplay = item.trickplay;
    if (id == null || trickplay == null || trickplay.isEmpty) return null;

    // The outer map is keyed by mediaSourceId; we pick whichever entry is
    // present (typically there's only one for a non-multi-source item). The
    // inner map is keyed by string width; pick the widest available — the
    // preview is shown small in the UI but the source tile is fine.
    for (final entry in trickplay.values) {
      if (entry.isEmpty) continue;
      final keys = entry.keys.toList()
        ..sort((a, b) => (int.tryParse(b) ?? 0) - (int.tryParse(a) ?? 0));
      final widestKey = keys.first;
      final widthInt = int.tryParse(widestKey);
      final info = entry[widestKey];
      if (info == null || widthInt == null) continue;
      final w = info.width;
      final h = info.height;
      final tw = info.tileWidth;
      final th = info.tileHeight;
      final n = info.thumbnailCount;
      final ival = info.interval;
      if (w == null ||
          h == null ||
          tw == null ||
          th == null ||
          n == null ||
          ival == null) {
        continue;
      }
      return TrickplayManifest(
        itemId: id,
        width: w,
        height: h,
        tileCols: tw,
        tileRows: th,
        thumbnailCount: n,
        intervalMs: ival,
      );
    }
    return null;
  }
}

final playerTrickplayProvider = Provider.autoDispose
    .family<TrickplayManifest?, String>((ref, itemId) {
      // Watches the DTO provider — `trickplay` is an SDK-only field that
      // doesn't surface on [JellyfinItem]. UI code should still go through
      // `playerItemProvider` (domain).
      final item = ref.watch(playerItemDtoProvider(itemId)).valueOrNull;
      if (item == null) return null;
      return TrickplayManifest.fromItem(item);
    });
