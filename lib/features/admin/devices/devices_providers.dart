import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Registered Jellyfin devices (one entry per (user, device) pair). The
/// notifier exposes rename + delete so admins can revoke a leaked client
/// without dropping all of the user's sessions on the way out.
class AdminDevicesNotifier
    extends AutoDisposeAsyncNotifier<List<DeviceInfoDto>> {
  @override
  Future<List<DeviceInfoDto>> build() => _fetch();

  Future<List<DeviceInfoDto>> _fetch() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getDevicesApi().getDevices();
    final list = res.data?.items?.toList() ?? const <DeviceInfoDto>[];
    // Most recently active first — same ordering as the Jellyfin web UI.
    return list
      ..sort((a, b) {
        final aDate =
            a.dateLastActivity ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.dateLastActivity ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Revokes a device's access token server-side. The user will be forced to
  /// log back in on that device on its next request.
  Future<void> delete(String id) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getDevicesApi().deleteDevice(id: id);
    await refresh();
  }

  /// Persists a custom display name on the device. Empty `customName` clears
  /// it server-side (the web UI uses the same call to "reset to default").
  Future<void> rename({
    required String id,
    required String customName,
  }) async {
    final api = ref.read(jellyfinApiProvider);
    final dto = DeviceOptionsDto(
      (b) => b
        ..deviceId = id
        ..customName = customName,
    );
    await api.getDevicesApi().updateDeviceOptions(
          id: id,
          deviceOptionsDto: dto,
        );
    await refresh();
  }
}

final adminDevicesProvider = AutoDisposeAsyncNotifierProvider<
    AdminDevicesNotifier, List<DeviceInfoDto>>(
  AdminDevicesNotifier.new,
);
