import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bridge/bridge_dio_provider.dart';
import 'models.dart';

const _prefix = 'jellyfish/radarr/';

final radarrClientProvider = Provider<RadarrClient>((ref) {
  return RadarrClient(ref.watch(bridgeDioProvider));
});

/// Thin wrapper around the Radarr v3 endpoints exposed by Jellyfish.Bridge.
/// All responses are pure passthrough of Radarr's JSON.
class RadarrClient {
  RadarrClient(this._dio);

  final Dio _dio;

  Future<RadarrSystemStatus> systemStatus() async {
    final res = await _dio.get<Map<String, dynamic>>('${_prefix}system/status');
    return RadarrSystemStatus.fromJson(res.data ?? const {});
  }

  Future<List<RadarrMovie>> movies() async {
    final res = await _dio.get<List<dynamic>>('${_prefix}movie');
    final raw = res.data ?? const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => RadarrMovie.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<RadarrMovie> movie(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('${_prefix}movie/$id');
    return RadarrMovie.fromJson(res.data ?? const {});
  }

  Future<RadarrQueuePage> queue({int page = 1, int pageSize = 20}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}queue',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return RadarrQueuePage.fromJson(res.data ?? const {});
  }

  Future<RadarrHistoryPage> history({int page = 1, int pageSize = 20}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}history',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return RadarrHistoryPage.fromJson(res.data ?? const {});
  }

  Future<List<RadarrCalendarEntry>> calendar({
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '${_prefix}calendar',
      queryParameters: {
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
      },
    );
    final raw = res.data ?? const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => RadarrCalendarEntry.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// Admin-only on the plugin side (403 for non-admin Jellyfin users).
  Future<void> deleteQueueItem(int id) async {
    await _dio.delete<void>('${_prefix}queue/$id');
  }
}
