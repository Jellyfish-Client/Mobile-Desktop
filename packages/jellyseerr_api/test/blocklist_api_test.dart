import 'package:test/test.dart';
import 'package:jellyseerr_api/jellyseerr_api.dart';

/// tests for BlocklistApi
void main() {
  final instance = JellyseerrApi().getBlocklistApi();

  group(BlocklistApi, () {
    // Returns blocklisted items
    //
    // **DEPRECATED**: Use `/blocklist` instead. This endpoint will be deprecated soon.
    //
    //Future<BlocklistGet200Response> blacklistGet({ num take, num skip, String search, String filter }) async
    test('test blacklistGet', () async {
      // TODO
    });

    // Add media to blocklist
    //
    // **DEPRECATED**: Use `/blocklist` instead. This endpoint will be deprecated soon.
    //
    //Future blacklistPost(Blocklist blocklist) async
    test('test blacklistPost', () async {
      // TODO
    });

    // Remove media from blocklist
    //
    // **DEPRECATED**: Use `/blocklist/{tmdbId}` instead. This endpoint will be deprecated soon.
    //
    //Future blacklistTmdbIdDelete(String tmdbId, String mediaType) async
    test('test blacklistTmdbIdDelete', () async {
      // TODO
    });

    // Get media from blocklist
    //
    // **DEPRECATED**: Use `/blocklist/{tmdbId}` instead. This endpoint will be deprecated soon.
    //
    //Future blacklistTmdbIdGet(String tmdbId, String mediaType) async
    test('test blacklistTmdbIdGet', () async {
      // TODO
    });

    // Remove collection from blocklist
    //
    // Removes all movies in a collection from the blocklist
    //
    //Future blocklistCollectionCollectionIdDelete(String collectionId) async
    test('test blocklistCollectionCollectionIdDelete', () async {
      // TODO
    });

    // Add collection to blocklist
    //
    // Adds all movies in a collection to the blocklist
    //
    //Future blocklistCollectionCollectionIdPost(String collectionId, { JsonObject body }) async
    test('test blocklistCollectionCollectionIdPost', () async {
      // TODO
    });

    // Returns blocklisted items
    //
    // Returns list of all blocklisted media
    //
    //Future<BlocklistGet200Response> blocklistGet({ num take, num skip, String search, String filter }) async
    test('test blocklistGet', () async {
      // TODO
    });

    // Add media to blocklist
    //
    //Future blocklistPost(Blocklist blocklist) async
    test('test blocklistPost', () async {
      // TODO
    });

    // Remove media from blocklist
    //
    //Future blocklistTmdbIdDelete(String tmdbId, String mediaType) async
    test('test blocklistTmdbIdDelete', () async {
      // TODO
    });

    // Get media from blocklist
    //
    //Future blocklistTmdbIdGet(String tmdbId, String mediaType) async
    test('test blocklistTmdbIdGet', () async {
      // TODO
    });
  });
}
