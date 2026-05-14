import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for MoviesApi
void main() {
  final instance = JellyfinApi().getMoviesApi();

  group(MoviesApi, () {
    // Gets movie recommendations.
    //
    //Future<BuiltList<RecommendationDto>> getMovieRecommendations({ String userId, String parentId, BuiltList<ItemFields> fields, int categoryLimit, int itemLimit }) async
    test('test getMovieRecommendations', () async {
      // TODO
    });
  });
}
