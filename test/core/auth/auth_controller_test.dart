import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/auth/accounts_repository.dart';
import 'package:jellyfish/core/auth/auth_controller.dart';
import 'package:jellyfish/core/auth/saved_account.dart';
import 'package:jellyfish/core/storage/app_database.dart';
import 'package:jellyfish/core/storage/app_database_provider.dart';
import 'package:jellyfish/core/storage/secure_kv.dart';

class _MemoryKv implements SecureKv {
  final Map<String, String> _data = {};
  @override
  Future<void> delete(String key) async => _data.remove(key);
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
}

/// Lightweight AppDatabase stand-in: only the surface AuthController touches
/// (`clearCachedResponsesFor` and the legacy claim) is implemented. Everything
/// else throws via [noSuchMethod] so any unexpected call surfaces loudly in
/// the test output instead of silently no-op'ing.
class _FakeDb implements AppDatabase {
  final List<String> wipedAccounts = [];
  final List<String> claimedFor = [];

  @override
  Future<void> clearCachedResponsesFor(String accountKey) async {
    wipedAccounts.add(accountKey);
  }

  @override
  Future<void> claimLegacyRowsFor(String accountKey) async {
    claimedFor.add(accountKey);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Fake AppDatabase: ${invocation.memberName} is not stubbed',
    );
  }
}

SavedAccount _account({
  String serverId = 's1',
  String userId = 'u1',
  String userName = 'alice',
  DateTime? lastUsedAt,
}) => SavedAccount(
  serverId: serverId,
  serverUrl: 'https://$serverId.example.com',
  serverName: 'srv-$serverId',
  userId: userId,
  userName: userName,
  accessToken: 'tok-$serverId-$userId',
  lastUsedAt: lastUsedAt ?? DateTime.utc(2025),
);

ProviderContainer _container({SecureKv? kv, _FakeDb? db}) {
  final container = ProviderContainer(
    overrides: [
      secureKvProvider.overrideWithValue(kv ?? _MemoryKv()),
      appDatabaseProvider.overrideWithValue(db ?? _FakeDb()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AuthController', () {
    test('build returns empty when no accounts are persisted', () async {
      final container = _container();
      final state = await container.read(authControllerProvider.future);
      expect(state.hasSession, isFalse);
    });

    test('build picks the most-recently-used account', () async {
      final container = _container();
      final repo = container.read(accountsRepositoryProvider);
      await repo.upsert(
        _account(userId: 'old', lastUsedAt: DateTime.utc(2020)),
      );
      await repo.upsert(
        _account(userId: 'recent', lastUsedAt: DateTime.utc(2030)),
      );

      container.invalidate(authControllerProvider);
      final state = await container.read(authControllerProvider.future);
      expect(state.session?.userId, 'recent');
    });

    test(
      'addAccount activates the new account without nuking SWR cache',
      () async {
        final db = _FakeDb();
        final container = _container(db: db);
        await container.read(authControllerProvider.future);

        await container
            .read(authControllerProvider.notifier)
            .addAccount(_account(userId: 'fresh'));

        final state = container.read(authControllerProvider).requireValue;
        expect(state.session?.userId, 'fresh');
        // Scoping replaces the previous "wipe everything on switch" behaviour:
        // each account owns its own cache rows and we never wipe them on add.
        expect(db.wipedAccounts, isEmpty);
      },
    );

    test('switchTo swaps the active session and bumps lastUsedAt', () async {
      final db = _FakeDb();
      final container = _container(db: db);
      final repo = container.read(accountsRepositoryProvider);
      await repo.upsert(_account(userId: 'a', lastUsedAt: DateTime.utc(2026)));
      await repo.upsert(_account(userId: 'b', lastUsedAt: DateTime.utc(2025)));

      container.invalidate(authControllerProvider);
      await container.read(authControllerProvider.future);
      expect(
        container.read(authControllerProvider).requireValue.session?.userId,
        'a',
      );

      await container
          .read(authControllerProvider.notifier)
          .switchTo(serverId: 's1', userId: 'b');

      expect(
        container.read(authControllerProvider).requireValue.session?.userId,
        'b',
      );
      // No global wipe — each scoped cache survives the switch.
      expect(db.wipedAccounts, isEmpty);
      final all = await repo.readAll();
      expect(all.first.userId, 'b');
    });

    test('removeAccount on the active one falls back to the next and wipes '
        'its scoped cache', () async {
      final db = _FakeDb();
      final container = _container(db: db);
      final repo = container.read(accountsRepositoryProvider);
      await repo.upsert(_account(userId: 'a', lastUsedAt: DateTime.utc(2026)));
      await repo.upsert(_account(userId: 'b', lastUsedAt: DateTime.utc(2025)));

      container.invalidate(authControllerProvider);
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .removeAccount(serverId: 's1', userId: 'a');

      final state = container.read(authControllerProvider).requireValue;
      expect(state.session?.userId, 'b');
      expect(db.wipedAccounts, ['s1|a']);
    });

    test('removeAccount on the last account leaves an empty session', () async {
      final container = _container();
      final repo = container.read(accountsRepositoryProvider);
      await repo.upsert(_account());
      container.invalidate(authControllerProvider);
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .removeAccount(serverId: 's1', userId: 'u1');

      final state = container.read(authControllerProvider).requireValue;
      expect(state.hasSession, isFalse);
    });

    test('clear is a logout of the active account only', () async {
      final container = _container();
      final repo = container.read(accountsRepositoryProvider);
      await repo.upsert(_account(userId: 'a', lastUsedAt: DateTime.utc(2026)));
      await repo.upsert(_account(userId: 'b', lastUsedAt: DateTime.utc(2025)));
      container.invalidate(authControllerProvider);
      await container.read(authControllerProvider.future);

      await container.read(authControllerProvider.notifier).clear();

      final state = container.read(authControllerProvider).requireValue;
      expect(state.session?.userId, 'b');
      final remaining = await repo.readAll();
      expect(remaining.map((a) => a.userId), ['b']);
    });

    test('removeServer batch-removes every account on the server and wipes '
        "each one's cache", () async {
      final db = _FakeDb();
      final container = _container(db: db);
      final repo = container.read(accountsRepositoryProvider);
      await repo.upsert(
        _account(serverId: 's1', userId: 'a', lastUsedAt: DateTime.utc(2026)),
      );
      await repo.upsert(
        _account(serverId: 's1', userId: 'b', lastUsedAt: DateTime.utc(2025)),
      );
      await repo.upsert(
        _account(serverId: 's2', userId: 'c', lastUsedAt: DateTime.utc(2024)),
      );

      container.invalidate(authControllerProvider);
      await container.read(authControllerProvider.future);

      await container.read(authControllerProvider.notifier).removeServer('s1');

      final state = container.read(authControllerProvider).requireValue;
      expect(state.session?.userId, 'c');
      expect(db.wipedAccounts, containsAll(<String>['s1|a', 's1|b']));
      final remaining = await repo.readAll();
      expect(remaining.single.userId, 'c');
    });
  });
}
