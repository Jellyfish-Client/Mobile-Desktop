import 'package:test/test.dart';
import 'package:jellyseerr_api/jellyseerr_api.dart';

/// tests for OtherApi
void main() {
  final instance = JellyseerrApi().getOtherApi();

  group(OtherApi, () {
    // Get movie certifications
    //
    // Returns list of movie certifications from TMDB.
    //
    //Future<CertificationResponse> certificationsMovieGet() async
    test('test certificationsMovieGet', () async {
      // TODO
    });

    // Get TV certifications
    //
    // Returns list of TV show certifications from TMDB.
    //
    //Future<CertificationResponse> certificationsTvGet() async
    test('test certificationsTvGet', () async {
      // TODO
    });

    // Get keyword
    //
    // Returns a single keyword in JSON format.
    //
    //Future<Keyword> keywordKeywordIdGet(num keywordId) async
    test('test keywordKeywordIdGet', () async {
      // TODO
    });

    // Get watch provider movies
    //
    // Returns a list of all available watch providers for movies.
    //
    //Future<BuiltList<WatchProviderDetails>> watchprovidersMoviesGet(String watchRegion) async
    test('test watchprovidersMoviesGet', () async {
      // TODO
    });

    // Get watch provider regions
    //
    // Returns a list of all available watch provider regions.
    //
    //Future<BuiltList<WatchProviderRegion>> watchprovidersRegionsGet() async
    test('test watchprovidersRegionsGet', () async {
      // TODO
    });

    // Get watch provider series
    //
    // Returns a list of all available watch providers for series.
    //
    //Future<BuiltList<WatchProviderDetails>> watchprovidersTvGet(String watchRegion) async
    test('test watchprovidersTvGet', () async {
      // TODO
    });
  });
}
