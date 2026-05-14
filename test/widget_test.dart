import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jellyfish/app/theme/app_theme.dart';

void main() {
  testWidgets('Theme builds without errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
