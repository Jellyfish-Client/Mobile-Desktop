import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/features/onboarding/quick_connect_controller.dart';

void main() {
  group('QuickConnectState (sealed)', () {
    test('exhaustive pattern matching covers every variant', () {
      // If a new state is added to the sealed type, this switch will fail to
      // compile until the new case is handled — the test exists to catch UI
      // branches that silently fall through on a new state.
      String describe(QuickConnectState s) => switch (s) {
        QcIdle() => 'idle',
        QcLoading() => 'loading',
        QcPending(:final code) => 'pending:$code',
        QcApproved() => 'approved',
        QcDone() => 'done',
        QcError(:final message) => 'error:$message',
        QcTimeout() => 'timeout',
      };

      expect(describe(const QcIdle()), 'idle');
      expect(describe(const QcLoading()), 'loading');
      expect(describe(const QcPending(code: 'ABC123')), 'pending:ABC123');
      expect(describe(const QcApproved()), 'approved');
      expect(describe(const QcDone()), 'done');
      expect(describe(const QcError('boom')), 'error:boom');
      expect(describe(const QcTimeout()), 'timeout');
    });

    test('QcPending exposes the code typed for the user', () {
      const state = QcPending(code: '123 456');
      expect(state.code, '123 456');
    });
  });

  group('QuickConnectArgs', () {
    test('keeps server context for downstream auth calls', () {
      const args = QuickConnectArgs(
        serverUrl: 'https://jelly.example.com',
        proxyAuth: 'Basic Zm9vOmJhcg==',
        serverName: 'Home',
        serverId: 'srv-1',
      );
      expect(args.serverUrl, 'https://jelly.example.com');
      expect(args.proxyAuth, isNotNull);
      expect(args.serverName, 'Home');
      expect(args.serverId, 'srv-1');
    });
  });
}
