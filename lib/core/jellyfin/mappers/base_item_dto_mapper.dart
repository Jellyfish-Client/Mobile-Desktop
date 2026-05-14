import 'package:built_collection/built_collection.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../models/jellyfin_external_url.dart';
import '../models/jellyfin_item.dart';
import '../models/jellyfin_person.dart';
import '../models/jellyfin_studio.dart';

/// Maps SDK [BaseItemDto] (and friends) to the feature-facing domain models.
///
/// Returns `null` when the source has no [BaseItemDto.id] — the rest of the
/// app treats id-less items as invalid (e.g. `series_detail_screen.dart:33`
/// returned an EmptyState). Filtering at the boundary lets us make
/// [JellyfinItem.id] non-nullable downstream.
extension BaseItemDtoMapper on BaseItemDto {
  JellyfinItem? toDomain() {
    final itemId = id;
    if (itemId == null) return null;
    return JellyfinItem(
      id: itemId,
      name: name,
      type: type,
      collectionType: collectionType,
      overview: overview,
      runTimeTicks: runTimeTicks,
      productionYear: productionYear,
      communityRating: communityRating,
      officialRating: officialRating,
      genres: genres?.toList(growable: false) ?? const [],
      parentIndexNumber: parentIndexNumber,
      indexNumber: indexNumber,
      seriesName: seriesName,
      seriesId: seriesId,
      seasonId: seasonId,
      premiereDate: premiereDate,
      providerIds: _providerIdsToMap(providerIds),
      studios:
          studios?.map((s) => s.toDomain()).toList(growable: false) ?? const [],
      people:
          people?.map((p) => p.toDomain()).toList(growable: false) ?? const [],
      externalUrls:
          externalUrls?.map((e) => e.toDomain()).toList(growable: false) ??
          const [],
      imageTags: imageTags == null
          ? const {}
          : Map<String, String>.from(imageTags!.asMap()),
      backdropImageTags: backdropImageTags?.toList(growable: false) ?? const [],
      parentLogoItemId: parentLogoItemId,
      parentLogoImageTag: parentLogoImageTag,
      parentBackdropItemId: parentBackdropItemId,
      parentBackdropImageTags:
          parentBackdropImageTags?.toList(growable: false) ?? const [],
      parentThumbItemId: parentThumbItemId,
      parentThumbImageTag: parentThumbImageTag,
      seriesPrimaryImageTag: seriesPrimaryImageTag,
      playbackPositionTicks: userData?.playbackPositionTicks,
      played: userData?.played,
      isFavorite: userData?.isFavorite,
    );
  }
}

/// List-of-DTOs convenience: maps each entry via [BaseItemDtoMapper.toDomain]
/// and drops `null` results (DTOs without an id). Centralises the boundary
/// pattern that several feature-layer providers used to inline.
///
/// Debug builds fire an assert per dropped entry so a malformed payload
/// surfaces during tests instead of silently shortening the rendered list.
extension IterableBaseItemDtoMapper on Iterable<BaseItemDto> {
  List<JellyfinItem> toDomainList() {
    final out = <JellyfinItem>[];
    for (final dto in this) {
      final item = dto.toDomain();
      if (item != null) {
        out.add(item);
      } else {
        assert(
          false,
          'toDomainList: dropped DTO without id (name=${dto.name})',
        );
      }
    }
    return out;
  }
}

/// Mapping for embedded persons (cast / crew). Public so providers that fetch
/// people independently of an item can reuse it.
extension BaseItemPersonMapper on BaseItemPerson {
  JellyfinPerson toDomain() => JellyfinPerson(
    id: id,
    name: name,
    role: role,
    type: type,
    primaryImageTag: primaryImageTag,
  );
}

extension NameGuidPairMapper on NameGuidPair {
  JellyfinStudio toDomain() => JellyfinStudio(id: id, name: name);
}

extension ExternalUrlMapper on ExternalUrl {
  JellyfinExternalUrl toDomain() => JellyfinExternalUrl(name: name, url: url);
}

/// Drops null values from the SDK's `BuiltMap<String, String?>` so the
/// domain side can keep `Map<String, String>`.
Map<String, String> _providerIdsToMap(BuiltMap<String, String?>? source) {
  if (source == null || source.isEmpty) return const {};
  final out = <String, String>{};
  source.forEach((k, v) {
    if (v != null) out[k] = v;
  });
  return out;
}
