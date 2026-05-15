import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/l10n/app_localizations.dart';
import 'package:jellyfish/shared/widgets/cast_mini_player.dart';

// Note: a "with session" test would need to mock the CastPlayerBackend,
// which calls the native Cast SDK at construction. Coverage for the
// connected state is exercised via integration testing.
void main() {
  testWidgets('renders nothing when no Cast session is active',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CastMiniPlayer()),
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.cast_connected), findsNothing);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
    expect(find.byIcon(Icons.pause), findsNothing);
    // The widget itself renders, but its body collapses to SizedBox.shrink().
    expect(find.byType(CastMiniPlayer), findsOneWidget);
  });
}
