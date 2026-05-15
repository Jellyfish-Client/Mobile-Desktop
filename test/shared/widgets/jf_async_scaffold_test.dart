import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/l10n/app_localizations.dart';
import 'package:jellyfish/shared/widgets/empty_state.dart';
import 'package:jellyfish/shared/widgets/jf_async_scaffold.dart';

void main() {
  Widget harness(AsyncValue<List<String>> value, {
    bool Function(List<String>)? isEmpty,
    Widget Function(Object, StackTrace)? error,
    Widget? empty,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: JfAsyncScaffold<List<String>>(
          value: value,
          isEmpty: isEmpty,
          error: error,
          empty: empty,
          data: (d) => Column(
            children: [
              for (final item in d) Text(item, key: ValueKey<String>(item)),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders a centred progress indicator while loading',
      (tester) async {
    await tester.pumpWidget(harness(const AsyncValue<List<String>>.loading()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('falls back to EmptyState on error', (tester) async {
    await tester.pumpWidget(
      harness(
        AsyncValue<List<String>>.error(
          Exception('boom'),
          StackTrace.empty,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
  });

  testWidgets('renders the data builder when items are present',
      (tester) async {
    await tester.pumpWidget(
      harness(
        const AsyncValue<List<String>>.data(['alpha', 'beta']),
        isEmpty: (d) => d.isEmpty,
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('alpha')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('beta')), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('falls back to empty EmptyState when isEmpty returns true',
      (tester) async {
    await tester.pumpWidget(
      harness(
        const AsyncValue<List<String>>.data(<String>[]),
        isEmpty: (d) => d.isEmpty,
      ),
    );
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('alpha')), findsNothing);
  });

  testWidgets('honours an explicit empty slot when provided', (tester) async {
    await tester.pumpWidget(
      harness(
        const AsyncValue<List<String>>.data(<String>[]),
        isEmpty: (d) => d.isEmpty,
        empty: const Text('custom-empty', key: ValueKey<String>('custom')),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('custom')), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });
}
