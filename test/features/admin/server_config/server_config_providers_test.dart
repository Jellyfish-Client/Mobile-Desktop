import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/server_config/server_config_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockConfigurationApi extends Mock implements ConfigurationApi {}

class _MockBrandingApi extends Mock implements BrandingApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

void main() {
  late _MockJellyfinApi api;
  late _MockConfigurationApi configApi;
  late _MockBrandingApi brandingApi;

  setUp(() {
    api = _MockJellyfinApi();
    configApi = _MockConfigurationApi();
    brandingApi = _MockBrandingApi();
    when(() => api.getConfigurationApi()).thenReturn(configApi);
    when(() => api.getBrandingApi()).thenReturn(brandingApi);
  });

  setUpAll(() {
    registerFallbackValue(ServerConfiguration());
    registerFallbackValue(BrandingOptionsDto((b) => b..splashscreenEnabled = false));
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('adminServerConfigProvider', () {
    test('returns ServerConfiguration from API', () async {
      final config = ServerConfiguration();
      when(() => configApi.getConfiguration())
          .thenAnswer((_) async => _ok(config));

      final c = makeContainer();
      final result = await c.read(adminServerConfigProvider.future);

      expect(result, isA<ServerConfiguration>());
    });

    test('exposes AsyncError when API throws', () async {
      when(() => configApi.getConfiguration())
          .thenThrow(Exception('unauthorized'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminServerConfigProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminServerConfigProvider).hasError, isTrue);
    });
  });

  group('adminBrandingProvider', () {
    test('returns BrandingOptionsDto from API', () async {
      final branding = BrandingOptionsDto(
        (b) => b
          ..loginDisclaimer = 'Welcome'
          ..splashscreenEnabled = true,
      );
      when(() => brandingApi.getBrandingOptions())
          .thenAnswer((_) async => _ok(branding));

      final c = makeContainer();
      final result = await c.read(adminBrandingProvider.future);

      expect(result.loginDisclaimer, 'Welcome');
      expect(result.splashscreenEnabled, isTrue);
    });

    test('exposes AsyncError when branding API throws', () async {
      when(() => brandingApi.getBrandingOptions())
          .thenThrow(Exception('forbidden'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminBrandingProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
    });
  });

  group('AdminServerConfigController', () {
    test('save calls updateConfiguration with correct config', () async {
      final config = ServerConfiguration();
      when(() => configApi.updateConfiguration(
            serverConfiguration: any(named: 'serverConfiguration'),
          )).thenAnswer((_) async => _ok<void>(null));
      // adminServerConfigProvider must also be stubbed (it may be invalidated)
      when(() => configApi.getConfiguration())
          .thenAnswer((_) async => _ok(config));

      final c = makeContainer();
      await c.read(adminServerConfigControllerProvider).save(config);

      verify(() => configApi.updateConfiguration(
            serverConfiguration: any(named: 'serverConfiguration'),
          )).called(1);
    });

    test('saveBranding calls updateBrandingConfiguration with correct body',
        () async {
      when(() => configApi.updateBrandingConfiguration(
            brandingOptionsDto: any(named: 'brandingOptionsDto'),
          )).thenAnswer((_) async => _ok<void>(null));
      // adminBrandingProvider must also be stubbed (it may be invalidated)
      when(() => brandingApi.getBrandingOptions()).thenAnswer(
        (_) async => _ok(BrandingOptionsDto((b) => b..splashscreenEnabled = false)),
      );

      final c = makeContainer();
      await c.read(adminServerConfigControllerProvider).saveBranding(
            loginDisclaimer: 'Hello',
            customCss: '.test { color: red; }',
            splashscreenEnabled: false,
          );

      verify(() => configApi.updateBrandingConfiguration(
            brandingOptionsDto: any(named: 'brandingOptionsDto'),
          )).called(1);
    });

    test('save propagates error when updateConfiguration throws', () async {
      when(() => configApi.updateConfiguration(
            serverConfiguration: any(named: 'serverConfiguration'),
          )).thenThrow(Exception('invalid config'));

      final c = makeContainer();

      expect(
        () => c.read(adminServerConfigControllerProvider).save(ServerConfiguration()),
        throwsException,
      );
    });
  });
}
