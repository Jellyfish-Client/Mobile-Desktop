import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/auth/auth_controller.dart';
import 'package:jellyfish/core/auth/session.dart';
import 'package:jellyfish/core/network/dio_provider.dart';
import 'package:jellyfish/core/storage/device_id.dart';

void main() {
  group('jellyfinDioProvider', () {
    test('sends Accept: application/json', () {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(_StubAuthController.new),
          deviceIdProvider.overrideWith((_) => Future.value('test-device')),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(jellyfinDioProvider);
      expect(dio.options.headers['Accept'], 'application/json');
    });

    test('does NOT set Accept-Encoding explicitly', () {
      // Regression guard: setting Accept-Encoding manually disables dart:io's
      // HttpClient auto-decompression, causing every gzipped response to land
      // as raw bytes and silently fail JSON decoding. Let the platform layer
      // negotiate compression instead.
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(_StubAuthController.new),
          deviceIdProvider.overrideWith((_) => Future.value('test-device')),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(jellyfinDioProvider);
      expect(dio.options.headers.containsKey('Accept-Encoding'), isFalse);
    });
  });
}

/// Replaces the real [AuthController] with one that resolves to an empty
/// session synchronously — the dio provider only needs the session for the
/// base URL, which we don't care about in this header-shape test.
class _StubAuthController extends AuthController {
  @override
  Future<SessionState> build() async => SessionState.empty;
}
