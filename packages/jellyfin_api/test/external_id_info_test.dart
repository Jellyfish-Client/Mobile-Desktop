import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

// tests for ExternalIdInfo
void main() {
  final instance = ExternalIdInfoBuilder();
  // TODO add properties to the builder and call build()

  group(ExternalIdInfo, () {
    // Gets or sets the display name of the external id provider (IE: IMDB, MusicBrainz, etc).
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Gets or sets the unique key for this id. This key should be unique across all providers.
    // String key
    test('to test the property `key`', () async {
      // TODO
    });

    // ExternalIdMediaType type
    test('to test the property `type`', () async {
      // TODO
    });
  });
}
