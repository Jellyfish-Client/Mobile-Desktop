import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/reauth_events.dart';
import '../storage/device_id.dart';
import 'jellyfin_auth_interceptor.dart';

final jellyfinDioProvider = Provider<Dio>((ref) {
  final session = ref.watch(authControllerProvider).valueOrNull?.session;
  final deviceId = ref.watch(deviceIdProvider).valueOrNull;
  final reauthSink = ref.watch(reauthEventsControllerProvider).sink;
  final baseUrl = session?.serverUrl;

  final normalizedBase = (baseUrl == null || baseUrl.isEmpty)
      ? ''
      : (baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');

  // Don't set Accept-Encoding manually: on native platforms dart:io's
  // HttpClient already advertises gzip and auto-decompresses, but only when
  // the caller hasn't explicitly set the header — setting it ourselves
  // *disables* auto-decompression and we'd receive raw compressed bytes that
  // fail JSON decoding silently.
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
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }

  ref.onDispose(dio.close);
  return dio;
});
