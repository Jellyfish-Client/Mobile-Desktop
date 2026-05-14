import 'package:jellyfin_api/jellyfin_api.dart';

import '../auth/session.dart';

class ResolvedMediaSource {
  const ResolvedMediaSource({
    required this.mediaSourceId,
    required this.streamUrl,
    required this.isDirectPlay,
  });
  final String mediaSourceId;
  final String streamUrl;
  final bool isDirectPlay;
}

/// Picks the best `MediaSourceInfo` out of a `PlaybackInfoResponse` and builds
/// the absolute stream URL. Prefers a source flagged `SupportsDirectPlay` when
/// present; otherwise falls back to the server-provided `transcodingUrl`.
class MediaSourceResolver {
  const MediaSourceResolver(this._session);

  final Session _session;

  ResolvedMediaSource resolve(String itemId, PlaybackInfoResponse response) {
    final sources = response.mediaSources?.toList() ?? const [];
    if (sources.isEmpty) {
      throw StateError('No media sources returned for item $itemId');
    }

    // Prefer direct-playable sources.
    final source = sources.firstWhere(
      (s) => s.supportsDirectPlay ?? false,
      orElse: () => sources.first,
    );
    final id = source.id;
    if (id == null) {
      throw StateError('MediaSource without id for item $itemId');
    }

    if ((source.supportsDirectPlay ?? false) ||
        (source.supportsDirectStream ?? false)) {
      return ResolvedMediaSource(
        mediaSourceId: id,
        streamUrl: _directStreamUrl(itemId, id),
        isDirectPlay: true,
      );
    }

    // Transcoding fallback. The server returns a relative URL like
    // `/videos/{id}/master.m3u8?…` — prepend the server base URL.
    final transcode = source.transcodingUrl;
    if (transcode != null && transcode.isNotEmpty) {
      return ResolvedMediaSource(
        mediaSourceId: id,
        streamUrl: _absolutize(transcode),
        isDirectPlay: false,
      );
    }

    // Last-ditch: the static URL even if the server hinted at no direct play.
    return ResolvedMediaSource(
      mediaSourceId: id,
      streamUrl: _directStreamUrl(itemId, id),
      isDirectPlay: false,
    );
  }

  String _directStreamUrl(String itemId, String mediaSourceId) {
    final base = _trimSlash(_session.serverUrl);
    return '$base/Videos/$itemId/stream'
        '?static=true'
        '&mediaSourceId=$mediaSourceId'
        '&ApiKey=${_session.accessToken}';
  }

  String _absolutize(String relative) {
    if (relative.startsWith('http://') || relative.startsWith('https://')) {
      return relative;
    }
    final base = _trimSlash(_session.serverUrl);
    final rel = relative.startsWith('/') ? relative.substring(1) : relative;
    final glue = rel.contains('?') ? '&' : '?';
    return '$base/$rel${glue}ApiKey=${_session.accessToken}';
  }

  String _trimSlash(String s) =>
      s.endsWith('/') ? s.substring(0, s.length - 1) : s;
}
