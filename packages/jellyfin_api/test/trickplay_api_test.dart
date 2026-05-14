import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for TrickplayApi
void main() {
  final instance = JellyfinApi().getTrickplayApi();

  group(TrickplayApi, () {
    // Gets an image tiles playlist for trickplay.
    //
    //Future<Uint8List> getTrickplayHlsPlaylist(String itemId, int width, { String mediaSourceId }) async
    test('test getTrickplayHlsPlaylist', () async {
      // TODO
    });

    // Gets a trickplay tile image.
    //
    //Future<Uint8List> getTrickplayTileImage(String itemId, int width, int index, { String mediaSourceId }) async
    test('test getTrickplayTileImage', () async {
      // TODO
    });
  });
}
