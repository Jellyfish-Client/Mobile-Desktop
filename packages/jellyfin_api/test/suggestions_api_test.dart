import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for SuggestionsApi
void main() {
  final instance = JellyfinApi().getSuggestionsApi();

  group(SuggestionsApi, () {
    // Gets suggestions.
    //
    //Future<BaseItemDtoQueryResult> getSuggestions({ String userId, BuiltList<MediaType> mediaType, BuiltList<BaseItemKind> type, int startIndex, int limit, bool enableTotalRecordCount }) async
    test('test getSuggestions', () async {
      // TODO
    });
  });
}
