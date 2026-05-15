import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/shared/widgets/jf_tappable.dart';

void main() {
  final hapticCalls = <String>[];

  setUp(() {
    hapticCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        hapticCalls.add(call.arguments as String? ?? '<null>');
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget harness({
    required VoidCallback? onTap,
    HapticFeedbackType haptic = HapticFeedbackType.selection,
    String label = 'play-button',
    bool excludeFromSemantics = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: JfTappable(
            semanticLabel: label,
            onTap: onTap,
            haptic: haptic,
            excludeFromSemantics: excludeFromSemantics,
            child: const SizedBox(width: 80, height: 40, child: Text('child')),
          ),
        ),
      ),
    );
  }

  testWidgets('invokes onTap when the surface is tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(harness(onTap: () => taps++));
    await tester.tap(find.byType(JfTappable));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('emits the matching HapticFeedback before invoking onTap',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(onTap: () => taps++, haptic: HapticFeedbackType.medium),
    );
    await tester.tap(find.byType(JfTappable));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(hapticCalls, contains('HapticFeedbackType.mediumImpact'));
  });

  testWidgets('skips HapticFeedback when haptic is none', (tester) async {
    await tester.pumpWidget(
      harness(onTap: () {}, haptic: HapticFeedbackType.none),
    );
    await tester.tap(find.byType(JfTappable));
    await tester.pumpAndSettle();
    expect(hapticCalls, isEmpty);
  });

  testWidgets('exposes the semantic label as a button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness(onTap: () {}, label: 'play-now'));
    expect(
      tester.getSemantics(find.byType(JfTappable)),
      matchesSemantics(
        label: 'play-now',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('marks itself disabled when no callback is supplied',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness(onTap: null));
    expect(
      tester.getSemantics(find.byType(JfTappable)),
      matchesSemantics(
        label: 'play-button',
        isButton: true,
        hasEnabledState: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('omits semantics entirely when excludeFromSemantics is true',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harness(onTap: () {}, excludeFromSemantics: true),
    );
    final finder = find.bySemanticsLabel('play-button');
    expect(finder, findsNothing);
    handle.dispose();
  });
}
