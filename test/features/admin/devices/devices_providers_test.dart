import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/devices/devices_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockDevicesApi extends Mock implements DevicesApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

DeviceInfoDto _device({
  String id = 'dev1',
  String name = 'My Device',
  DateTime? dateLastActivity,
}) =>
    DeviceInfoDto(
      (b) => b
        ..id = id
        ..name = name
        ..dateLastActivity = dateLastActivity,
    );

DeviceInfoDtoQueryResult _queryResult(List<DeviceInfoDto> items) =>
    DeviceInfoDtoQueryResult(
      (b) => b..items = ListBuilder(items),
    );

void main() {
  late _MockJellyfinApi api;
  late _MockDevicesApi devicesApi;

  setUp(() {
    api = _MockJellyfinApi();
    devicesApi = _MockDevicesApi();
    when(() => api.getDevicesApi()).thenReturn(devicesApi);
  });

  setUpAll(() {
    registerFallbackValue(
      DeviceOptionsDto((b) => b..deviceId = ''),
    );
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('AdminDevicesNotifier', () {
    test('build returns devices sorted by most recent activity first', () async {
      final now = DateTime.utc(2025);
      final devices = [
        _device(id: 'old', dateLastActivity: now.subtract(const Duration(days: 1))),
        _device(id: 'recent', dateLastActivity: now),
        _device(id: 'older', dateLastActivity: now.subtract(const Duration(days: 7))),
      ];
      when(() => devicesApi.getDevices()).thenAnswer(
        (_) async => _ok(_queryResult(devices)),
      );

      final c = makeContainer();
      final list = await c.read(adminDevicesProvider.future);

      expect(list.length, 3);
      expect(list.first.id, 'recent');
      expect(list.last.id, 'older');
    });

    test('build returns empty list when server returns empty', () async {
      when(() => devicesApi.getDevices()).thenAnswer(
        (_) async => _ok(_queryResult([])),
      );

      final c = makeContainer();
      final list = await c.read(adminDevicesProvider.future);

      expect(list, isEmpty);
    });

    test('build exposes AsyncError when API throws', () async {
      when(() => devicesApi.getDevices()).thenThrow(Exception('server down'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminDevicesProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminDevicesProvider).hasError, isTrue);
    });

    test('delete calls deleteDevice with correct id and refreshes', () async {
      final devices = [_device(id: 'dev1'), _device(id: 'dev2')];
      when(() => devicesApi.getDevices()).thenAnswer(
        (_) async => _ok(_queryResult(devices)),
      );
      when(() => devicesApi.deleteDevice(id: any(named: 'id')))
          .thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminDevicesProvider.future);
      await c.read(adminDevicesProvider.notifier).delete('dev1');

      verify(() => devicesApi.deleteDevice(id: 'dev1')).called(1);
      // verify refresh was triggered (getDevices called a second time)
      verify(() => devicesApi.getDevices()).called(2);
    });

    test('rename calls updateDeviceOptions with correct id and customName',
        () async {
      final devices = [_device(id: 'dev1')];
      when(() => devicesApi.getDevices()).thenAnswer(
        (_) async => _ok(_queryResult(devices)),
      );
      when(() => devicesApi.updateDeviceOptions(
            id: any(named: 'id'),
            deviceOptionsDto: any(named: 'deviceOptionsDto'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminDevicesProvider.future);
      await c.read(adminDevicesProvider.notifier).rename(
            id: 'dev1',
            customName: 'My Custom Name',
          );

      verify(() => devicesApi.updateDeviceOptions(
            id: 'dev1',
            deviceOptionsDto: any(named: 'deviceOptionsDto'),
          )).called(1);
    });

    test('delete propagates error when API throws', () async {
      final devices = [_device(id: 'dev1')];
      when(() => devicesApi.getDevices()).thenAnswer(
        (_) async => _ok(_queryResult(devices)),
      );
      when(() => devicesApi.deleteDevice(id: any(named: 'id')))
          .thenThrow(Exception('permission denied'));

      final c = makeContainer();
      await c.read(adminDevicesProvider.future);

      expect(
        () => c.read(adminDevicesProvider.notifier).delete('dev1'),
        throwsException,
      );
    });
  });
}
