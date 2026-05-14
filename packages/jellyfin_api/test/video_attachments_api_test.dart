import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for VideoAttachmentsApi
void main() {
  final instance = JellyfinApi().getVideoAttachmentsApi();

  group(VideoAttachmentsApi, () {
    // Get video attachment.
    //
    //Future<Uint8List> getAttachment(String videoId, String mediaSourceId, int index) async
    test('test getAttachment', () async {
      // TODO
    });
  });
}
