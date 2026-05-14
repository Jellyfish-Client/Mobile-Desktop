import 'package:test/test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

// tests for DatabaseConfigurationOptions
void main() {
  final instance = DatabaseConfigurationOptionsBuilder();
  // TODO add properties to the builder and call build()

  group(DatabaseConfigurationOptions, () {
    // Gets or Sets the type of database jellyfin should use.
    // String databaseType
    test('to test the property `databaseType`', () async {
      // TODO
    });

    // CustomDatabaseOptions customProviderOptions
    test('to test the property `customProviderOptions`', () async {
      // TODO
    });

    // DatabaseLockingBehaviorTypes lockingBehavior
    test('to test the property `lockingBehavior`', () async {
      // TODO
    });
  });
}
