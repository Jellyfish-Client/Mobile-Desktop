import 'package:test/test.dart';
import 'package:jellyseerr_api/jellyseerr_api.dart';

/// tests for OverrideruleApi
void main() {
  final instance = JellyseerrApi().getOverrideruleApi();

  group(OverrideruleApi, () {
    // Get override rules
    //
    // Returns a list of all override rules with their conditions and settings
    //
    //Future<BuiltList<OverrideRule>> overrideRuleGet() async
    test('test overrideRuleGet', () async {
      // TODO
    });

    // Create override rule
    //
    // Creates a new Override Rule from the request body.
    //
    //Future<BuiltList<OverrideRule>> overrideRulePost() async
    test('test overrideRulePost', () async {
      // TODO
    });

    // Delete override rule by ID
    //
    // Deletes the override rule with the provided ruleId.
    //
    //Future<OverrideRule> overrideRuleRuleIdDelete(num ruleId) async
    test('test overrideRuleRuleIdDelete', () async {
      // TODO
    });

    // Update override rule
    //
    // Updates an Override Rule from the request body.
    //
    //Future<BuiltList<OverrideRule>> overrideRuleRuleIdPut(num ruleId) async
    test('test overrideRuleRuleIdPut', () async {
      // TODO
    });
  });
}
