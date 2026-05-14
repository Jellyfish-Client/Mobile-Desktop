import 'package:test/test.dart';
import 'package:jellyseerr_api/jellyseerr_api.dart';

/// tests for CollectionApi
void main() {
  final instance = JellyseerrApi().getCollectionApi();

  group(CollectionApi, () {
    // Get collection details
    //
    // Returns full collection details in a JSON object.
    //
    //Future<Collection> collectionCollectionIdGet(num collectionId, { String language }) async
    test('test collectionCollectionIdGet', () async {
      // TODO
    });
  });
}
