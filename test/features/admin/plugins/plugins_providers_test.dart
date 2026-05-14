import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/plugins/plugins_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockPluginsApi extends Mock implements PluginsApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

PluginInfo _plugin({
  String id = 'plugin1',
  String name = 'TestPlugin',
  String version = '1.0.0',
}) =>
    PluginInfo(
      (b) => b
        ..id = id
        ..name = name
        ..version = version,
    );

void main() {
  late _MockJellyfinApi api;
  late _MockPluginsApi pluginsApi;

  setUp(() {
    api = _MockJellyfinApi();
    pluginsApi = _MockPluginsApi();
    when(() => api.getPluginsApi()).thenReturn(pluginsApi);
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('AdminPluginsNotifier', () {
    test('build returns plugins sorted alphabetically by name', () async {
      final plugins = BuiltList<PluginInfo>.of([
        _plugin(id: 'p3', name: 'Zebra Plugin'),
        _plugin(id: 'p1', name: 'Alpha Plugin'),
        _plugin(id: 'p2', name: 'Beta Plugin'),
      ]);
      when(() => pluginsApi.getPlugins())
          .thenAnswer((_) async => _ok(plugins));

      final c = makeContainer();
      final list = await c.read(adminPluginsProvider.future);

      expect(list.length, 3);
      expect(list.first.name, 'Alpha Plugin');
      expect(list.last.name, 'Zebra Plugin');
    });

    test('build returns empty list when server returns empty', () async {
      when(() => pluginsApi.getPlugins()).thenAnswer(
        (_) async => _ok(BuiltList<PluginInfo>.of([])),
      );

      final c = makeContainer();
      final list = await c.read(adminPluginsProvider.future);

      expect(list, isEmpty);
    });

    test('build exposes AsyncError when API throws', () async {
      when(() => pluginsApi.getPlugins()).thenThrow(Exception('unauthorized'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminPluginsProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminPluginsProvider).hasError, isTrue);
    });

    test('setEnabled(true) calls enablePlugin with correct pluginId and version',
        () async {
      final plugins = BuiltList<PluginInfo>.of([_plugin()]);
      when(() => pluginsApi.getPlugins())
          .thenAnswer((_) async => _ok(plugins));
      when(() => pluginsApi.enablePlugin(
            pluginId: any(named: 'pluginId'),
            version: any(named: 'version'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminPluginsProvider.future);
      await c.read(adminPluginsProvider.notifier).setEnabled(
            'plugin1',
            '1.0.0',
            value: true,
          );

      verify(() => pluginsApi.enablePlugin(
            pluginId: 'plugin1',
            version: '1.0.0',
          )).called(1);
    });

    test('setEnabled(false) calls disablePlugin with correct pluginId and version',
        () async {
      final plugins = BuiltList<PluginInfo>.of([_plugin()]);
      when(() => pluginsApi.getPlugins())
          .thenAnswer((_) async => _ok(plugins));
      when(() => pluginsApi.disablePlugin(
            pluginId: any(named: 'pluginId'),
            version: any(named: 'version'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminPluginsProvider.future);
      await c.read(adminPluginsProvider.notifier).setEnabled(
            'plugin1',
            '1.0.0',
            value: false,
          );

      verify(() => pluginsApi.disablePlugin(
            pluginId: 'plugin1',
            version: '1.0.0',
          )).called(1);
    });

    test('uninstall calls uninstallPlugin with correct pluginId and refreshes',
        () async {
      final plugins = BuiltList<PluginInfo>.of([_plugin()]);
      when(() => pluginsApi.getPlugins())
          .thenAnswer((_) async => _ok(plugins));
      // uninstallPlugin is deprecated in favour of uninstallPluginByVersion,
      // but the notifier intentionally uses it — mirror that here.
      // ignore: deprecated_member_use
      when(() => pluginsApi.uninstallPlugin(
            pluginId: any(named: 'pluginId'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminPluginsProvider.future);
      await c.read(adminPluginsProvider.notifier).uninstall('plugin1');

      // Verifying the deprecated method the notifier itself calls.
      // ignore: deprecated_member_use
      verify(() => pluginsApi.uninstallPlugin(pluginId: 'plugin1')).called(1);
      verify(() => pluginsApi.getPlugins()).called(2);
    });
  });
}
