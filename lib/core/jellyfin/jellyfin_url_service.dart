import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../auth/auth_controller.dart';
import '../auth/session.dart';
import '../network/dio_provider.dart';
import 'models/jellyfin_item.dart';
import 'models/jellyfin_person.dart';

final jellyfinUrlServiceProvider = Provider<JellyfinUrlService>((ref) {
  final dio = ref.watch(jellyfinDioProvider);
  final session = ref.watch(authControllerProvider).valueOrNull?.session;
  return JellyfinUrlService(dio: dio, session: session);
});

/// Builds URLs for Jellyfin image/stream endpoints from a [JellyfinItem].
///
/// Centralises the URL templating that previously lived directly on
/// `JellyfinClient`. Decoupling it from the API client means the UI layer
/// only needs to depend on this service plus the domain models — never on
/// the generated SDK types.
///
/// `Dio.options.baseUrl` is read on every call so a server reconnect (which
/// re-creates the dio with a new base URL) takes effect without rebuilding
/// the service.
class JellyfinUrlService {
  JellyfinUrlService({required Dio dio, required Session? session})
    : _dio = dio,
      _session = session;

  final Dio _dio;
  final Session? _session;

  /// Primary/Backdrop/Logo/etc. image URL for an item. Returns null when no
  /// tag is exposed for the requested type — a tag-less Jellyfin image URL
  /// just 404s server-side. For Backdrops, falls back to the first entry of
  /// [JellyfinItem.backdropImageTags] when `imageTags['Backdrop']` is absent.
  String? imageUrl(
    JellyfinItem item, {
    String type = 'Primary',
    int? maxWidth,
    int? maxHeight,
  }) {
    var tag = item.imageTags[type];
    if (tag == null &&
        type == 'Backdrop' &&
        item.backdropImageTags.isNotEmpty) {
      tag = item.backdropImageTags.first;
    }
    if (tag == null) return null;
    return _buildImageUrl(
      item.id,
      type,
      tag,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// Resolves the official logo URL for an item. Episodes don't carry their
  /// own logo — Jellyfin exposes the series logo through
  /// [JellyfinItem.parentLogoItemId] + [JellyfinItem.parentLogoImageTag],
  /// which we consult as a fallback.
  String? logoUrl(JellyfinItem item, {int? maxWidth}) {
    final ownTag = item.imageTags['Logo'];
    if (ownTag != null) {
      return _buildImageUrl(item.id, 'Logo', ownTag, maxWidth: maxWidth);
    }
    final pId = item.parentLogoItemId;
    final pTag = item.parentLogoImageTag;
    if (pId != null && pTag != null) {
      return _buildImageUrl(pId, 'Logo', pTag, maxWidth: maxWidth);
    }
    return null;
  }

  /// Picks the best landscape-shaped image for a card. Walks an
  /// episode-aware fallback chain: episode still → series backdrop → series
  /// poster → parent thumb. For non-episodes prefers the item's own
  /// backdrop and falls back to its primary image.
  String? landscapeUrl(JellyfinItem item, {int? maxWidth}) {
    if (item.type == BaseItemKind.episode) {
      final primary = item.imageTags['Primary'];
      if (primary != null) {
        return _buildImageUrl(item.id, 'Primary', primary, maxWidth: maxWidth);
      }
      final pbId = item.parentBackdropItemId;
      if (pbId != null && item.parentBackdropImageTags.isNotEmpty) {
        return _buildImageUrl(
          pbId,
          'Backdrop',
          item.parentBackdropImageTags.first,
          maxWidth: maxWidth,
        );
      }
      final sId = item.seriesId;
      final sTag = item.seriesPrimaryImageTag;
      if (sId != null && sTag != null) {
        return _buildImageUrl(sId, 'Primary', sTag, maxWidth: maxWidth);
      }
      final ptId = item.parentThumbItemId;
      final ptTag = item.parentThumbImageTag;
      if (ptId != null && ptTag != null) {
        return _buildImageUrl(ptId, 'Thumb', ptTag, maxWidth: maxWidth);
      }
      return null;
    }

    final ownBackdrop = item.imageTags['Backdrop'];
    if (ownBackdrop != null) {
      return _buildImageUrl(
        item.id,
        'Backdrop',
        ownBackdrop,
        maxWidth: maxWidth,
      );
    }
    if (item.backdropImageTags.isNotEmpty) {
      return _buildImageUrl(
        item.id,
        'Backdrop',
        item.backdropImageTags.first,
        maxWidth: maxWidth,
      );
    }
    final ownPrimary = item.imageTags['Primary'];
    if (ownPrimary != null) {
      return _buildImageUrl(item.id, 'Primary', ownPrimary, maxWidth: maxWidth);
    }
    return null;
  }

  /// Builds the primary image URL for a person. Returns null when either
  /// the id or the primary tag is missing — callers should fall back to a
  /// placeholder (avatar with initials).
  String? personUrl(JellyfinPerson person, {int? maxWidth}) {
    final id = person.id;
    final tag = person.primaryImageTag;
    if (id == null || tag == null) return null;
    return _buildImageUrl(id, 'Primary', tag, maxWidth: maxWidth);
  }

  /// URL for a single trickplay tile image. `tileIndex` addresses the grid
  /// of thumbnails (tileWidth × tileHeight per image). The `width` must
  /// match a key from the trickplay manifest.
  ///
  /// Throws [StateError] when no session is available or the access token
  /// is empty — callers always invoke this from playback code paths where
  /// an authenticated session is required.
  String trickplayTileUrl({
    required String itemId,
    required int width,
    required int tileIndex,
  }) {
    final s = _session;
    if (s == null || s.accessToken.isEmpty) {
      throw StateError('JellyfinUrlService.trickplayTileUrl: no valid session');
    }
    return '${_joinUrl('Videos/$itemId/Trickplay/$width/$tileIndex.jpg')}'
        '?ApiKey=${s.accessToken}';
  }

  /// URL for a chapter thumbnail. `index` is the position in the chapter list.
  String chapterUrl({
    required String itemId,
    required int index,
    required String tag,
    int? maxWidth,
  }) {
    final qp = <String, String>{
      'tag': tag,
      if (maxWidth != null) 'maxWidth': '$maxWidth',
      'quality': '90',
    };
    final query = qp.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '${_joinUrl('Items/$itemId/Images/Chapter/$index')}?$query';
  }

  /// Direct-play stream URL — used when libmpv handles the source natively.
  /// Uses the modern `ApiKey=` query param (legacy `api_key` is deprecated).
  ///
  /// Throws [StateError] when no session is available or the access token
  /// is empty.
  String streamUrl({required String itemId, required String mediaSourceId}) {
    final s = _session;
    if (s == null || s.accessToken.isEmpty) {
      throw StateError('JellyfinUrlService.streamUrl: no valid session');
    }
    return '${_joinUrl('Videos/$itemId/stream')}'
        '?static=true'
        '&mediaSourceId=$mediaSourceId'
        '&ApiKey=${s.accessToken}';
  }

  String _joinUrl(String relative) {
    final base = _dio.options.baseUrl;
    final left = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final right = relative.startsWith('/') ? relative.substring(1) : relative;
    return '$left/$right';
  }

  String _buildImageUrl(
    String itemId,
    String imageType,
    String tag, {
    int? maxWidth,
    int? maxHeight,
  }) {
    final qp = <String, String>{
      'tag': tag,
      if (maxWidth != null) 'maxWidth': '$maxWidth',
      if (maxHeight != null) 'maxHeight': '$maxHeight',
      'quality': '90',
    };
    final query = qp.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '${_joinUrl('Items/$itemId/Images/$imageType')}?$query';
  }
}
