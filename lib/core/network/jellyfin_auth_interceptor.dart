import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/reauth_events.dart';
import '../auth/session.dart';
import 'jellyfin_auth_header.dart';

/// Adds Jellyfin auth headers to outgoing requests. Shared between
/// `jellyfinDioProvider` (talking to Jellyfin core APIs) and
/// `bridgeDioProvider` (talking to the Jellyfish.Bridge plugin under
/// `/jellyfish/...`). Both reuse the same `Authorization: MediaBrowser …`
/// token and the same optional reverse-proxy Basic-Auth handling.
///
/// On the way back, it watches for HTTP 401 responses that came from Jellyfin
/// itself (not from a reverse-proxy Basic Auth gate) and emits a
/// [ReauthSignal] so the router can route the user to the re-auth screen.
class JellyfinAuthInterceptor extends Interceptor {
  JellyfinAuthInterceptor({
    required this.session,
    required this.deviceId,
    this.reauthSink,
  });

  final Session? session;
  final String? deviceId;
  final StreamSink<ReauthSignal>? reauthSink;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Without a deviceId we reject the request rather than send it with an
    // empty device — the FutureProvider should resolve a few ms after app
    // start and the next rebuild will retry.
    final id = deviceId;
    if (id == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'DeviceId not yet initialised',
        ),
      );
      return;
    }

    final s = session;
    final mediaBrowser = mediaBrowserHeader(
      accessToken: s?.accessToken ?? '',
      deviceId: id,
    );

    final hasPresetAuth = options.headers.containsKey('Authorization');
    final proxyAuth = s?.proxyAuth;

    if (!hasPresetAuth) {
      if (proxyAuth != null) {
        options.headers['Authorization'] = proxyAuth;
        options.headers['X-Emby-Authorization'] = mediaBrowser;
      } else {
        options.headers['Authorization'] = mediaBrowser;
      }
    } else if (proxyAuth != null) {
      options.headers['X-Emby-Authorization'] = mediaBrowser;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final s = session;
    final code = err.response?.statusCode;
    // Only surface 401s that came from Jellyfin (no `WWW-Authenticate: Basic`
    // header) and only when we have an active session to reauth against. The
    // onboarding flow can legitimately receive 401s — those carry no session
    // and we mustn't push the user to a screen for an account that doesn't
    // exist yet.
    if (code == 401 && s != null && reauthSink != null) {
      final www = err.response?.headers.value('www-authenticate') ?? '';
      final isProxyChallenge = www.toLowerCase().startsWith('basic');
      if (!isProxyChallenge) {
        reauthSink!.add(ReauthSignal(serverId: s.serverId, userId: s.userId));
      }
    }
    handler.next(err);
  }
}
