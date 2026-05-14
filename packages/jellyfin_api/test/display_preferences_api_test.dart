import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for DisplayPreferencesApi
void main() {
  final instance = JellyfinApi().getDisplayPreferencesApi();

  group(DisplayPreferencesApi, () {
    // Get Display Preferences.
    //
    //Future<DisplayPreferencesDto> getDisplayPreferences(String displayPreferencesId, String client, { String userId }) async
    test('test getDisplayPreferences', () async {
      // TODO
    });

    // Update Display Preferences.
    //
    //Future updateDisplayPreferences(String displayPreferencesId, String client, DisplayPreferencesDto displayPreferencesDto, { String userId }) async
    test('test updateDisplayPreferences', () async {
      // TODO
    });
  });
}
