import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/jellyfin/jellyfin_client.dart';

/// Whether the active Jellyfin session belongs to an administrator. Watched by
/// the Settings screen to surface the Administration entry, by the router to
/// guard `/settings/admin/*`, and by individual admin screens that don't want
/// to render anything if the user has just been demoted mid-session.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).valueOrNull?.session?.isAdmin ??
      false;
});

/// Boot-time resync of the active user's admin flag. The first version of the
/// app didn't persist the flag, and policies can change server-side after the
/// account was added, so we re-read `/Users/Me` whenever the active session's
/// identity changes and write back the corrected value through the auth
/// controller. Fire-and-forget: any network failure leaves the cached flag
/// untouched.
final currentUserAdminRefresherProvider = Provider<void>((ref) {
  final session = ref.watch(
    authControllerProvider.select((s) => s.valueOrNull?.session),
  );
  if (session == null) return;
  final api = ref.read(jellyfinApiProvider);
  // Capture the auth notifier outside the async gap so we don't reach back
  // into ref after a possible session change.
  final auth = ref.read(authControllerProvider.notifier);
  Future<void>(() async {
    try {
      final res = await api.getUserApi().getCurrentUser();
      final isAdmin = res.data?.policy?.isAdministrator ?? false;
      await auth.refreshAdminFlag(isAdmin: isAdmin);
    } on Object {
      // Offline / 401 / server hiccup — keep whatever flag we already have.
    }
  });
});
