import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for ClientLogApi
void main() {
  final instance = JellyfinApi().getClientLogApi();

  group(ClientLogApi, () {
    // Upload a document.
    //
    //Future<ClientLogDocumentResponseDto> logFile({ MultipartFile body }) async
    test('test logFile', () async {
      // TODO
    });
  });
}
