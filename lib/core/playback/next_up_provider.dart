import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../jellyfin/jellyfin_client.dart';
import '../jellyfin/mappers/base_item_dto_mapper.dart';
import '../jellyfin/models/jellyfin_item.dart';

/// `null` seriesId → returns null (movie playback, no next-up).
///
/// Differs from `features/details/detail_providers.dart` `seriesNextUpProvider`
/// in error handling: failures here resolve to `null` so the player overlay
/// stays out of the way, rather than surfacing an error UI mid-playback.
final playerNextUpProvider = FutureProvider.autoDispose
    .family<JellyfinItem?, String?>((ref, seriesId) async {
      if (seriesId == null) return null;
      final client = ref.watch(jellyfinClientProvider);
      try {
        final dto = await client.seriesNextUp(seriesId);
        return dto?.toDomain();
      } on Object catch (_) {
        return null;
      }
    });
