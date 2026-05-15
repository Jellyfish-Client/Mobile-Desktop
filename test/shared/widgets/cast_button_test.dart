import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/cast/cast_providers.dart';
import 'package:jellyfish/l10n/app_localizations.dart';
import 'package:jellyfish/shared/widgets/cast_button.dart';

void main() {
  Widget harness({
    required bool supported,
    required bool connected,
  }) {
    return ProviderScope(
      overrides: [
        castSupportedProvider.overrideWithValue(supported),
        isCastConnectedProvider.overrideWithValue(connected),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: null,
          body: Center(child: CastButton()),
        ),
      ),
    );
  }

  testWidgets('hides itself when Cast is not supported', (tester) async {
    await tester.pumpWidget(harness(supported: false, connected: false));
    await tester.pump();
    expect(find.byIcon(Icons.cast), findsNothing);
    expect(find.byIcon(Icons.cast_connected), findsNothing);
    expect(find.byType(CastButton), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('shows the idle cast icon when supported but not connected',
      (tester) async {
    await tester.pumpWidget(harness(supported: true, connected: false));
    await tester.pump();
    expect(find.byIcon(Icons.cast), findsOneWidget);
    expect(find.byIcon(Icons.cast_connected), findsNothing);
  });

  testWidgets('shows the connected icon when a session is active',
      (tester) async {
    await tester.pumpWidget(harness(supported: true, connected: true));
    await tester.pump();
    expect(find.byIcon(Icons.cast_connected), findsOneWidget);
    expect(find.byIcon(Icons.cast), findsNothing);
  });
}
