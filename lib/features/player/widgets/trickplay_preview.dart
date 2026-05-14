import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/jellyfin/jellyfin_url_service.dart';
import '../../../core/playback/trickplay.dart';
import '_duration_format.dart';

/// Floating preview shown above the seekbar thumb during a drag. Renders a
/// single thumbnail extracted from the trickplay tile image (image scaled
/// up by `tileCols`/`tileRows` so the crop framing isolates the right sub-tile).
class TrickplayPreview extends ConsumerWidget {
  const TrickplayPreview({
    required this.itemId,
    required this.position,
    this.previewWidth = 160,
    super.key,
  });

  final String itemId;
  final Duration position;
  final double previewWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifest = ref.watch(playerTrickplayProvider(itemId));
    if (manifest == null) {
      return _Timestamp(position: position);
    }
    final addressing = manifest.indexFor(position);
    if (addressing == null) {
      return _Timestamp(position: position);
    }
    final urls = ref.watch(jellyfinUrlServiceProvider);
    // The URL service throws when the session is missing or its access token
    // is empty — possible if the user logs out while a seek is in flight.
    // Fall back to the timestamp-only preview rather than crashing. The catch
    // is intentional and part of the documented contract of trickplayTileUrl.
    final String url;
    try {
      url = urls.trickplayTileUrl(
        itemId: manifest.itemId,
        width: manifest.width,
        tileIndex: addressing.tileIndex,
      );
      // The throw is part of `trickplayTileUrl`'s contract (no/expired
      // session), so this `Error` catch is deliberate.
      // ignore: avoid_catching_errors
    } on StateError {
      return _Timestamp(position: position);
    }
    final aspect = manifest.width / manifest.height;
    final previewHeight = previewWidth / aspect;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: _TileCrop(
                imageUrl: url,
                col: addressing.col,
                row: addressing.row,
                tileCols: manifest.tileCols,
                tileRows: manifest.tileRows,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatPlayerDuration(position),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _TileCrop extends StatelessWidget {
  const _TileCrop({
    required this.imageUrl,
    required this.col,
    required this.row,
    required this.tileCols,
    required this.tileRows,
  });

  final String imageUrl;
  final int col;
  final int row;
  final int tileCols;
  final int tileRows;

  @override
  Widget build(BuildContext context) {
    // Scale the source tile sheet by (tileCols, tileRows) so a single sub-tile
    // exactly fills the viewport, then translate so the requested (col, row)
    // is centred. Avoids decoding a region — just visual cropping.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return ClipRect(
          child: OverflowBox(
            maxWidth: w * tileCols,
            maxHeight: h * tileRows,
            alignment: Alignment(
              tileCols == 1 ? 0 : (col / (tileCols - 1)) * 2 - 1,
              tileRows == 1 ? 0 : (row / (tileRows - 1)) * 2 - 1,
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: w * tileCols,
              height: h * tileRows,
              fit: BoxFit.fill,
              placeholder: (_, __) =>
                  const ColoredBox(color: AppColors.surface),
              errorWidget: (_, __, ___) =>
                  const ColoredBox(color: AppColors.surface),
            ),
          ),
        );
      },
    );
  }
}

class _Timestamp extends StatelessWidget {
  const _Timestamp({required this.position});
  final Duration position;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        formatPlayerDuration(position),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
