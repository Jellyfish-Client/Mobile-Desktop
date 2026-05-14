import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/reauth_events.dart';
import '../network/jellyfin_auth_interceptor.dart';
import '../storage/device_id.dart';

/// Dio used to talk to the Jellyfish.Bridge plugin endpoints under
/// `/jellyfish/...`. Same base URL and same `Authorization: MediaBrowser …`
/// token as the regular Jellyfin client — the plugin lives at the same
/// origin and reuses Jellyfin's auth.
final bridgeDioProvider = Provider<Dio>((ref) {
  final session = ref.watch(authControllerProvider).valueOrNull?.session;
  final deviceId = ref.watch(deviceIdProvider).valueOrNull;
  final reauthSink = ref.watch(reauthEventsControllerProvider).sink;
  final baseUrl = session?.serverUrl;

  final normalizedBase = (baseUrl == null || baseUrl.isEmpty)
      ? ''
      : (baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');

  final dio = Dio(
    BaseOptions(
      baseUrl: normalizedBase,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    JellyfinAuthInterceptor(
      session: session,
      deviceId: deviceId,
      reauthSink: reauthSink,
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
  }

  ref.onDispose(dio.close);
  return dio;
});
