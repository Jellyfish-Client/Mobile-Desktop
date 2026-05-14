import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for TimeSyncApi
void main() {
  final instance = JellyfinApi().getTimeSyncApi();

  group(TimeSyncApi, () {
    // Gets the current UTC time.
    //
    //Future<UtcTimeResponse> getUtcTime() async
    test('test getUtcTime', () async {
      // TODO
    });
  });
}
