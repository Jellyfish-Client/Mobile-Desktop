import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/bridge/bridge_dio_provider.dart';
import 'package:jellyfish/core/bridge/bridge_services.dart';

void main() {
  group('bridgeServicesProvider', () {
    test(
      'returns pluginInstalled=false when /jellyfish/services 404s',
      () async {
        final services = await _resolveWith(
          _FakeAdapter((opts) {
            return ResponseBody.fromString('not found', 404);
          }),
        );
        expect(services.pluginInstalled, isFalse);
        expect(services.jellyseerrAvailable, isFalse);
        expect(services.radarrAvailable, isFalse);
        expect(services.sonarrAvailable, isFalse);
      },
    );

    test('maps the JSON payload to availability flags', () async {
      final services = await _resolveWith(
        _FakeAdapter((opts) {
          expect(opts.path, contains('jellyfish/services'));
          return ResponseBody.fromString(
            jsonEncode({
              'jellyseerr': {'available': true},
              'radarr': {'available': true},
              'sonarr': {'available': false},
            }),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          );
        }),
      );
      expect(services.pluginInstalled, isTrue);
      expect(services.jellyseerrAvailable, isTrue);
      expect(services.radarrAvailable, isTrue);
      expect(services.sonarrAvailable, isFalse);
    });
  });
}

/// Builds a ProviderContainer that overrides bridgeDioProvider with a Dio
/// using the supplied adapter, then resolves bridgeServicesProvider.
Future<BridgeServices> _resolveWith(_FakeAdapter adapter) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test/'))
    ..httpClientAdapter = adapter;
  final container = ProviderContainer(
    overrides: [bridgeDioProvider.overrideWithValue(dio)],
  );
  addTearDown(container.dispose);
  return container.read(bridgeServicesProvider.future);
}

/// In-memory Dio adapter: invokes the handler closure for each request and
/// returns its [ResponseBody]. No real network involved.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
