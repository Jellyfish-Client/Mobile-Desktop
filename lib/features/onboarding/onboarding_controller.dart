import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/saved_account.dart';
import '../../core/jellyfin/jellyfin_client.dart';

/// Holds the validated server URL during the onboarding flow (between
/// the server screen and the login screen). Cleared on completion.
final pendingServerProvider = StateProvider<PendingServer?>((_) => null);

/// Server info captured from the URL screen, carried over to the login screen.
class PendingServer {
  PendingServer({
    required this.url,
    this.proxyAuth,
    this.serverName,
    this.serverId,
  });
  final String url;
  final String? proxyAuth;
  final String? serverName;
  final String? serverId;
}

/// Result of probing a server URL during onboarding.
class ServerProbe {
  ServerProbe({
    required this.serverName,
    required this.serverId,
    required this.normalizedUrl,
    this.proxyAuth,
  });

  final String serverName;
  final String serverId;
  final String normalizedUrl;
  final String? proxyAuth;
}

/// Friendly, displayable error from the onboarding flow.
class OnboardingException implements Exception {
  OnboardingException(this.message);
  final String message;

  @override
  String toString() => message;
}

final onboardingControllerProvider = Provider<OnboardingController>(
  OnboardingController.new,
);

class OnboardingController {
  OnboardingController(this._ref);

  final Ref _ref;

  /// Validates a Jellyfin URL by hitting `/System/Info/Public`.
  /// Accepts `https://user:password@host` to enable reverse-proxy Basic Auth.
  Future<ServerProbe> probe(String rawUrl) async {
    final parsed = _parseUrl(rawUrl);

    final client = _ref.read(jellyfinClientProvider);
    try {
      final info = await client.systemInfoPublic(
        overrideBaseUrl: parsed.url,
        proxyAuth: parsed.proxyAuth,
      );
      return ServerProbe(
        serverName: info.serverName ?? 'Jellyfin',
        serverId: info.id ?? '',
        normalizedUrl: parsed.url,
        proxyAuth: parsed.proxyAuth,
      );
    } on DioException catch (e) {
      throw OnboardingException(_humanError(e));
    }
  }

  /// Authenticates a user against a previously-probed server. Persists the
  /// resulting credentials as a [SavedAccount] and switches the active session
  /// to it.
  Future<void> login({
    required String serverUrl,
    required String username,
    required String password,
    String? proxyAuth,
    String? serverName,
    String? serverId,
  }) async {
    final client = _ref.read(jellyfinClientProvider);
    try {
      final auth = await client.authenticateByName(
        username: username,
        password: password,
        overrideBaseUrl: serverUrl,
        proxyAuth: proxyAuth,
      );
      await _persistAuthResult(
        auth: auth,
        serverUrl: serverUrl,
        proxyAuth: proxyAuth,
        serverName: serverName,
        serverId: serverId,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Distinguish Jellyfin 401 (bad credentials) from proxy 401 (proxy auth
        // missing/wrong) via the WWW-Authenticate header.
        final wwwAuth = e.response?.headers.value('www-authenticate') ?? '';
        if (wwwAuth.toLowerCase().startsWith('basic')) {
          throw OnboardingException(
            'The reverse proxy rejected the credentials. '
            'Did you include them in the URL as https://user:pass@host?',
          );
        }
        throw OnboardingException('Invalid username or password');
      }
      throw OnboardingException(_humanError(e));
    }
  }

  /// Finalises a Quick Connect flow once an [AuthenticationResult] has been
  /// obtained (by the Quick Connect controller). Persists the new account and
  /// activates it. Kept as a separate entry point so the polling state machine
  /// can live in its own controller.
  Future<void> finalizeQuickConnect({
    required AuthenticationResult auth,
    required String serverUrl,
    String? proxyAuth,
    String? serverName,
    String? serverId,
  }) {
    return _persistAuthResult(
      auth: auth,
      serverUrl: serverUrl,
      proxyAuth: proxyAuth,
      serverName: serverName,
      serverId: serverId,
    );
  }

  Future<void> _persistAuthResult({
    required AuthenticationResult auth,
    required String serverUrl,
    String? proxyAuth,
    String? serverName,
    String? serverId,
  }) async {
    final user = auth.user;
    final accessToken = auth.accessToken;
    final userId = user?.id;
    final userName = user?.name;
    if (accessToken == null || userId == null || userName == null) {
      throw OnboardingException(
        'Server returned an incomplete authentication response',
      );
    }
    final account = SavedAccount(
      serverId: serverId ?? auth.serverId ?? '',
      serverUrl: serverUrl,
      serverName: serverName ?? 'Jellyfin',
      userId: userId,
      userName: userName,
      accessToken: accessToken,
      proxyAuth: proxyAuth,
      primaryImageTag: user?.primaryImageTag,
      isAdmin: user?.policy?.isAdministrator ?? false,
      lastUsedAt: DateTime.now().toUtc(),
    );
    await _ref.read(authControllerProvider.notifier).addAccount(account);
    _ref.read(pendingServerProvider.notifier).state = null;
  }

  /// Splits user:pass userinfo out of the URL and normalises scheme/trailing-slash.
  PendingServer _parseUrl(String input) {
    var s = input.trim();
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'https://$s';
    }
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }

    final uri = Uri.parse(s);
    String? proxyAuth;
    var cleanUri = uri;
    if (uri.userInfo.isNotEmpty) {
      proxyAuth = 'Basic ${base64Encode(utf8.encode(uri.userInfo))}';
      cleanUri = uri.replace(userInfo: '');
    }

    return PendingServer(url: cleanUri.toString(), proxyAuth: proxyAuth);
  }

  String _humanError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Server did not respond in time';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not reach server. Check the URL and your connection.';
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      final wwwAuth = e.response?.headers.value('www-authenticate') ?? '';
      if (wwwAuth.toLowerCase().startsWith('basic')) {
        return 'This server is behind a Basic Auth proxy. '
            'Use https://user:password@host to provide proxy credentials.';
      }
      return 'Server returned HTTP 401 (unauthorized)';
    }
    if (code != null) return 'Server returned HTTP $code';
    return 'Network error: ${e.message ?? 'unknown'}';
  }
}
