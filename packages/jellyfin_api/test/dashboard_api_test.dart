import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// tests for DashboardApi
void main() {
  final instance = JellyfinApi().getDashboardApi();

  group(DashboardApi, () {
    // Gets the configuration pages.
    //
    //Future<BuiltList<ConfigurationPageInfo>> getConfigurationPages({ bool enableInMainMenu }) async
    test('test getConfigurationPages', () async {
      // TODO
    });

    // Gets a dashboard configuration page.
    //
    //Future<Uint8List> getDashboardConfigurationPage({ String name }) async
    test('test getDashboardConfigurationPage', () async {
      // TODO
    });
  });
}
