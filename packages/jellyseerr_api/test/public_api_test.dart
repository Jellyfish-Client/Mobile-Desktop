import 'package:test/test.dart';
import 'package:jellyseerr_api/jellyseerr_api.dart';

/// tests for PublicApi
void main() {
  final instance = JellyseerrApi().getPublicApi();

  group(PublicApi, () {
    // Get application data volume status
    //
    // For Docker installs, returns whether or not the volume mount was configured properly. Always returns true for non-Docker installs.
    //
    //Future<StatusAppdataGet200Response> statusAppdataGet() async
    test('test statusAppdataGet', () async {
      // TODO
    });

    // Get Seerr status
    //
    // Returns the current Seerr status in a JSON object.
    //
    //Future<StatusGet200Response> statusGet() async
    test('test statusGet', () async {
      // TODO
    });
  });
}
