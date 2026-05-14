import 'package:dio/dio.dart';

/// Discriminator for plugin-level errors returned by Jellyfish.Bridge.
/// Bridge wraps Seerr/Radarr/Sonarr errors with these slugs so the client
/// can react without parsing free-form messages.
enum BridgeErrorKind {
  /// 503 — admin has not configured the matching upstream in the plugin.
  jellyseerrNotConfigured,
  radarrNotConfigured,
  sonarrNotConfigured,

  /// 403 — current Jellyfin user has no linked Seerr account.
  noJellyseerrAccount,

  /// 502 — plugin reached the upstream but it returned an error / unreachable.
  upstreamUnreachable,

  /// 504 — plugin timed out talking to the upstream.
  upstreamTimeout,

  /// 404 from `/jellyfish/...` — plugin not installed on the server at all.
  pluginMissing,

  /// Anything else — typically the raw 4xx Seerr/Radarr/Sonarr passthrough.
  other,
}

class BridgeException implements Exception {
  BridgeException({required this.kind, this.detail, this.statusCode});

  final BridgeErrorKind kind;
  final String? detail;
  final int? statusCode;

  @override
  String toString() =>
      'BridgeException(kind: $kind, code: $statusCode, detail: $detail)';
}

/// Returns a [BridgeException] when [e] matches one of the plugin's known
/// error contracts. Returns `null` for vanilla passthrough errors (4xx
/// straight from Seerr/Radarr/Sonarr) so callers can decide how to surface
/// them themselves.
BridgeException? mapBridgeError(DioException e) {
  final status = e.response?.statusCode;
  final body = e.response?.data;
  final slug = (body is Map<String, dynamic>) ? body['error'] as String? : null;
  final detail = (body is Map<String, dynamic>)
      ? body['detail'] as String?
      : null;

  switch (status) {
    case 404:
      // 404 is only a "plugin not installed" signal for the discovery and
      // top-level service roots (services, upcoming, radarr/X, sonarr/X,
      // jellyseerr/X). 404s on identified sub-resources (movie/{id},
      // queue/{id}, …) are normal domain 404s and surface to the caller
      // as null/empty — they must NOT trigger the "plugin missing" banner.
      final path = e.requestOptions.path;
      final isServiceRoot = RegExp(
        r'^/?jellyfish/(services|upcoming|(radarr|sonarr|jellyseerr)/[a-z]+)/?$',
      ).hasMatch(path);
      if (isServiceRoot) {
        return BridgeException(
          kind: BridgeErrorKind.pluginMissing,
          statusCode: status,
          detail: detail,
        );
      }
      return null;
    case 503:
      return BridgeException(
        kind: switch (slug) {
          'jellyseerr_not_configured' =>
            BridgeErrorKind.jellyseerrNotConfigured,
          'radarr_not_configured' => BridgeErrorKind.radarrNotConfigured,
          'sonarr_not_configured' => BridgeErrorKind.sonarrNotConfigured,
          _ => BridgeErrorKind.other,
        },
        statusCode: status,
        detail: detail,
      );
    case 403:
      if (slug == 'no_jellyseerr_account') {
        return BridgeException(
          kind: BridgeErrorKind.noJellyseerrAccount,
          statusCode: status,
          detail: detail,
        );
      }
      return null;
    case 502:
      return BridgeException(
        kind: BridgeErrorKind.upstreamUnreachable,
        statusCode: status,
        detail: detail,
      );
    case 504:
      return BridgeException(
        kind: BridgeErrorKind.upstreamTimeout,
        statusCode: status,
        detail: detail,
      );
    default:
      return null;
  }
}
