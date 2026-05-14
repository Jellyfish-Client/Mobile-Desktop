import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bridge_dio_provider.dart';

/// Availability snapshot returned by the Jellyfish.Bridge plugin at
/// `GET /jellyfish/services`. `pluginInstalled == false` means the plugin
/// itself is not present on the server (404) — distinct from a configured
/// plugin that simply has one upstream offline.
class BridgeServices {
  const BridgeServices({
    required this.pluginInstalled,
    required this.jellyseerrAvailable,
    required this.radarrAvailable,
    required this.sonarrAvailable,
  });

  final bool pluginInstalled;
  final bool jellyseerrAvailable;
  final bool radarrAvailable;
  final bool sonarrAvailable;

  /// Default when the plugin is missing or the session has no server yet.
  /// All consumers must treat this as a "nothing available" state.
  static const unavailable = BridgeServices(
    pluginInstalled: false,
    jellyseerrAvailable: false,
    radarrAvailable: false,
    sonarrAvailable: false,
  );
}

/// Resolves once per session at the first consumer. Returns
/// [BridgeServices.unavailable] on 404 (plugin not installed) so the UI
/// can degrade gracefully instead of erroring out the home screen.
final bridgeServicesProvider = FutureProvider<BridgeServices>((ref) async {
  final dio = ref.watch(bridgeDioProvider);
  try {
    final res = await dio.get<Map<String, dynamic>>('jellyfish/services');
    final data = res.data ?? const <String, dynamic>{};
    return BridgeServices(
      pluginInstalled: true,
      jellyseerrAvailable: _available(data['jellyseerr']),
      radarrAvailable: _available(data['radarr']),
      sonarrAvailable: _available(data['sonarr']),
    );
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return BridgeServices.unavailable;
    rethrow;
  }
});

bool _available(Object? entry) {
  if (entry is Map && entry['available'] == true) return true;
  return false;
}
