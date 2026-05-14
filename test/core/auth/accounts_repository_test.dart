import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/auth/accounts_repository.dart';
import 'package:jellyfish/core/auth/saved_account.dart';
import 'package:jellyfish/core/storage/app_database.dart';
import 'package:jellyfish/core/storage/secure_kv.dart';

class _MemoryKv implements SecureKv {
  final Map<String, String> _data = {};

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }
}

/// Tracks calls to [claimLegacyRowsFor] so the test can assert that the
/// repo invokes the Drift backfill at the right moment.
class _ClaimSpyDb implements AppDatabase {
  final List<String> claims = [];

  @override
  Future<void> claimLegacyRowsFor(String accountKey) async {
    claims.add(accountKey);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Spy AppDatabase: ${invocation.memberName} is not stubbed',
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

void main() {
  group('AccountsRepository', () {
    test('readAll returns empty when storage is empty', () async {
      final kv = _MemoryKv();
      final repo = AccountsRepository(kv);
      expect(await repo.readAll(), isEmpty);
    });

    test('upsert adds a new account', () async {
      final kv = _MemoryKv();
      final repo = AccountsRepository(kv);
      await repo.upsert(_account());
      final all = await repo.readAll();
      expect(all, hasLength(1));
      expect(all.first.userId, 'u1');
    });

    test('upsert replaces an existing (serverId, userId) entry', () async {
      final kv = _MemoryKv();
      final repo = AccountsRepository(kv);
      await repo.upsert(_account(userName: 'old'));
      await repo.upsert(_account(userName: 'new'));
      final all = await repo.readAll();
      expect(all, hasLength(1));
      expect(all.first.userName, 'new');
    });

    test('readAll is sorted by lastUsedAt desc', () async {
      final kv = _MemoryKv();
      final repo = AccountsRepository(kv);
      await repo.upsert(
        _account(userId: 'old', lastUsedAt: DateTime.utc(2024)),
      );
      await repo.upsert(
        _account(userId: 'recent', lastUsedAt: DateTime.utc(2026)),
      );
      await repo.upsert(
        _account(userId: 'mid', lastUsedAt: DateTime.utc(2025)),
      );
      final all = await repo.readAll();
      expect(all.map((a) => a.userId), ['recent', 'mid', 'old']);
    });

    test('remove drops a single account', () async {
      final kv = _MemoryKv();
      final repo = AccountsRepository(kv);
      await repo.upsert(_account(userId: 'u1'));
      await repo.upsert(_account(userId: 'u2'));
      await repo.remove('s1', 'u1');
      final all = await repo.readAll();
      expect(all.map((a) => a.userId), ['u2']);
    });

    test(
      'removeServer drops every account tied to a serverId in one pass',
      () async {
        final kv = _MemoryKv();
        final repo = AccountsRepository(kv);
        await repo.upsert(_account(serverId: 's1', userId: 'a'));
        await repo.upsert(_account(serverId: 's1', userId: 'b'));
        await repo.upsert(_account(serverId: 's2', userId: 'c'));
        final removed = await repo.removeServer('s1');
        expect(removed, 2);
        final all = await repo.readAll();
        expect(all.map((a) => '${a.serverId}|${a.userId}'), ['s2|c']);
      },
    );

    test('removeServer is a no-op when the server is unknown', () async {
      final kv = _MemoryKv();
      final repo = AccountsRepository(kv);
      await repo.upsert(_account());
      final removed = await repo.removeServer('unknown');
      expect(removed, 0);
      final all = await repo.readAll();
      expect(all, hasLength(1));
    });

    test(
      'clearAll wipes both keys and lets a future migration re-run',
      () async {
        final kv = _MemoryKv();
        final repo = AccountsRepository(kv);
        await repo.upsert(_account());
        // Seed a legacy blob that would normally be picked up by a migration.
        await kv.write(
          'session_v1',
          jsonEncode({
            'serverUrl': 'https://old.example.com',
            'serverId': 'legacy-server',
            'userId': 'legacy-user',
            'userName': 'legacy',
            'accessToken': 'legacy-token',
            'proxyAuth': null,
          }),
        );
        await repo.clearAll();
        // Both keys gone, and the memoised migration future was reset so a fresh
        // readAll() that finds nothing won't ressurect an old session.
        expect(await kv.read('accounts_v1'), isNull);
        expect(await kv.read('session_v1'), isNull);
        expect(await repo.readAll(), isEmpty);
      },
    );

    test(
      'reclaims legacy Drift rows on first readAll when accounts_v1 already '
      'exists (upgrade path from pre-scoping multi-account version)',
      () async {
        final kv = _MemoryKv();
        final db = _ClaimSpyDb();
        final repo = AccountsRepository(kv, legacyClaimDb: db);
        await repo.upsert(_account(userId: 'u1'));
        // First readAll after a cold start should trigger the claim.
        await repo.readAll();
        expect(db.claims, ['s1|u1']);
        // Second readAll same process: do NOT redo the claim — once is enough.
        await repo.readAll();
        expect(db.claims, ['s1|u1']);
      },
    );

    test('clearAll lets the legacy claim run again next cold start', () async {
      final kv = _MemoryKv();
      final db = _ClaimSpyDb();
      final repo = AccountsRepository(kv, legacyClaimDb: db);
      await repo.upsert(_account());
      await repo.readAll();
      expect(db.claims, hasLength(1));
      await repo.clearAll();
      await repo.upsert(_account(userId: 'u2'));
      await repo.readAll();
      // Flag was reset, so claim is allowed to fire once more.
      expect(db.claims, ['s1|u1', 's1|u2']);
    });

    test('concurrent first-read calls share a single migration pass', () async {
      final kv = _MemoryKv();
      // Seed a legacy session that would otherwise be migrated.
      await kv.write(
        'session_v1',
        jsonEncode({
          'serverUrl': 'https://legacy.example.com',
          'serverId': 'L',
          'userId': 'U',
          'userName': 'legacy',
          'accessToken': 'tok',
          'proxyAuth': null,
        }),
      );
      final repo = AccountsRepository(kv);

      // Fire two reads concurrently — both should resolve to the same single
      // migrated account, and the legacy key should be wiped exactly once.
      final results = await Future.wait([repo.readAll(), repo.readAll()]);
      expect(results[0], hasLength(1));
      expect(results[1], hasLength(1));
      expect(results[0].first.userId, 'U');
      expect(await kv.read('session_v1'), isNull);
    });

    test('markUsed bumps lastUsedAt to now', () async {
      final kv = _MemoryKv();
      final repo = AccountsRepository(kv);
      await repo.upsert(_account(lastUsedAt: DateTime.utc(2020)));
      final before = DateTime.now().toUtc().subtract(
        const Duration(seconds: 1),
      );
      final updated = await repo.markUsed('s1', 'u1');
      expect(updated, isNotNull);
      expect(updated!.lastUsedAt.isAfter(before), isTrue);
    });

    test('markUsed returns null for unknown account', () async {
      final kv = _MemoryKv();
      final repo = AccountsRepository(kv);
      expect(await repo.markUsed('nope', 'nope'), isNull);
    });

    test('migrates a legacy session_v1 blob into a SavedAccount', () async {
      final kv = _MemoryKv();
      // Seed with the legacy format the old SessionRepository wrote.
      await kv.write(
        'session_v1',
        jsonEncode({
          'serverUrl': 'https://old.example.com',
          'serverId': 'legacy-server',
          'userId': 'legacy-user',
          'userName': 'legacy',
          'accessToken': 'legacy-token',
          'proxyAuth': null,
        }),
      );
      final repo = AccountsRepository(kv);
      final all = await repo.readAll();
      expect(all, hasLength(1));
      expect(all.first.serverId, 'legacy-server');
      expect(all.first.userName, 'legacy');
      // Legacy key must be wiped post-migration so the two stores can't
      // diverge.
      expect(await kv.read('session_v1'), isNull);
    });

    test('discards a corrupt legacy blob without throwing', () async {
      final kv = _MemoryKv();
      await kv.write('session_v1', 'not-valid-json');
      final repo = AccountsRepository(kv);
      final all = await repo.readAll();
      expect(all, isEmpty);
      expect(await kv.read('session_v1'), isNull);
    });
  });
}
