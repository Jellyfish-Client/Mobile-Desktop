import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/account_key.dart';
import '../auth/auth_controller.dart';
import '../storage/app_database_provider.dart';
import 'cache_repository.dart';

/// Re-built every time the active account changes so each call site
/// transparently sees its own scoped cache slice.
final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final accountKey = ref.watch(
    authControllerProvider.select(
      (state) => accountKeyForSession(state.valueOrNull?.session),
    ),
  );
  return CacheRepository(db, accountKey: accountKey);
});
