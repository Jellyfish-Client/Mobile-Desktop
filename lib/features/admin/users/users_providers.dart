import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Active list of Jellyfin users on the connected server. The notifier exposes
/// CRUD operations as instance methods so callers can chain `await
/// ref.read(adminUsersProvider.notifier).delete(id)` and let the UI refresh
/// from the resulting state update.
class AdminUsersNotifier extends AutoDisposeAsyncNotifier<List<UserDto>> {
  @override
  Future<List<UserDto>> build() => _fetch();

  Future<List<UserDto>> _fetch() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getUserApi().getUsers();
    final list = (res.data?.toList() ?? <UserDto>[])
      ..sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
          (b.name ?? '').toLowerCase(),
        ),
      );
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<UserDto> create({
    required String username,
    required String password,
    required bool isAdmin,
  }) async {
    final api = ref.read(jellyfinApiProvider);
    final body = CreateUserByName(
      (b) => b
        ..name = username
        ..password = password,
    );
    final created = await api.getUserApi().createUserByName(
          createUserByName: body,
        );
    final newUser = created.data!;
    // The /Users/New endpoint creates a non-admin user; flip the policy in a
    // follow-up call when admin was requested. Keeping the rest of the policy
    // at server defaults so we don't accidentally lock the new user out.
    if (isAdmin) {
      final policy = (newUser.policy?.toBuilder() ?? UserPolicyBuilder())
        ..isAdministrator = true;
      await api.getUserApi().updateUserPolicy(
            userId: newUser.id!,
            userPolicy: policy.build(),
          );
    }
    await refresh();
    return newUser;
  }

  Future<void> updatePolicy(String userId, UserPolicy policy) async {
    final api = ref.read(jellyfinApiProvider);
    await api
        .getUserApi()
        .updateUserPolicy(userId: userId, userPolicy: policy);
    await refresh();
  }

  Future<void> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    final api = ref.read(jellyfinApiProvider);
    // First call: reset existing password (admin override). Required by
    // Jellyfin even when we're acting as admin — without it, the second call
    // is rejected with "password cannot be empty".
    await api.getUserApi().updateUserPassword(
          userId: userId,
          updateUserPassword: UpdateUserPassword(
            (b) => b..resetPassword = true,
          ),
        );
    await api.getUserApi().updateUserPassword(
          userId: userId,
          updateUserPassword: UpdateUserPassword(
            (b) => b
              ..currentPw = ''
              ..newPw = newPassword,
          ),
        );
  }

  Future<void> delete(String userId) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getUserApi().deleteUser(userId: userId);
    await refresh();
  }
}

final adminUsersProvider =
    AutoDisposeAsyncNotifierProvider<AdminUsersNotifier, List<UserDto>>(
  AdminUsersNotifier.new,
);

/// Single-user fetch used by the edit screen. Pulls the freshest copy so the
/// policy edits are based on current server state rather than the list cache.
final adminUserByIdProvider =
    FutureProvider.autoDispose.family<UserDto, String>((ref, userId) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getUserApi().getUserById(userId: userId);
  return res.data!;
});
