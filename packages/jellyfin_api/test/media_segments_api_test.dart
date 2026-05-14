import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for MediaSegmentsApi
void main() {
  final instance = JellyfinApi().getMediaSegmentsApi();

  group(MediaSegmentsApi, () {
    // Gets all media segments based on an itemId.
    //
    //Future<MediaSegmentDtoQueryResult> getItemSegments(String itemId, { BuiltList<MediaSegmentType> includeSegmentTypes }) async
    test('test getItemSegments', () async {
      // TODO
    });
  });
}
