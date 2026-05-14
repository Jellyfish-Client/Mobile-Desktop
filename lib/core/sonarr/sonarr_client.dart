import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bridge/bridge_dio_provider.dart';
import 'models.dart';

const _prefix = 'jellyfish/sonarr/';

final sonarrClientProvider = Provider<SonarrClient>((ref) {
  return SonarrClient(ref.watch(bridgeDioProvider));
});

/// Thin wrapper around the Sonarr v3 endpoints exposed by Jellyfish.Bridge.
class SonarrClient {
  SonarrClient(this._dio);

  final Dio _dio;

  Future<SonarrSystemStatus> systemStatus() async {
    final res = await _dio.get<Map<String, dynamic>>('${_prefix}system/status');
    return SonarrSystemStatus.fromJson(res.data ?? const {});
  }

  Future<List<SonarrSeries>> series() async {
    final res = await _dio.get<List<dynamic>>('${_prefix}series');
    final raw = res.data ?? const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => SonarrSeries.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<SonarrSeries> seriesById(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('${_prefix}series/$id');
    return SonarrSeries.fromJson(res.data ?? const {});
  }

  Future<List<SonarrEpisode>> episodes({required int seriesId}) async {
    final res = await _dio.get<List<dynamic>>(
      '${_prefix}episode',
      queryParameters: {'seriesId': seriesId},
    );
    final raw = res.data ?? const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => SonarrEpisode.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<SonarrQueuePage> queue({int page = 1, int pageSize = 20}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}queue',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return SonarrQueuePage.fromJson(res.data ?? const {});
  }

  Future<SonarrHistoryPage> history({int page = 1, int pageSize = 20}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${_prefix}history',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return SonarrHistoryPage.fromJson(res.data ?? const {});
  }

  Future<List<SonarrCalendarEntry>> calendar({
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
        .map((m) => SonarrCalendarEntry.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// Admin-only on the plugin side (403 for non-admin Jellyfin users).
  Future<void> deleteQueueItem(int id) async {
    await _dio.delete<void>('${_prefix}queue/$id');
  }
}
