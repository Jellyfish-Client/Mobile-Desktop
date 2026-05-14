import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for TmdbApi
void main() {
  final instance = JellyfinApi().getTmdbApi();

  group(TmdbApi, () {
    // Gets the TMDb image configuration options.
    //
    //Future<ConfigImageTypes> tmdbClientConfiguration() async
    test('test tmdbClientConfiguration', () async {
      // TODO
    });
  });
}
