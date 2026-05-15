import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/auth/reauth_events.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/admin/activity/activity_log_screen.dart';
import '../features/admin/admin_hub_screen.dart';
import '../features/admin/api_keys/api_keys_screen.dart';
import '../features/admin/backup/backup_screen.dart';
import '../features/admin/dashboard/dashboard_screen.dart';
import '../features/admin/devices/devices_screen.dart';
import '../features/admin/libraries/libraries_screen.dart';
import '../features/admin/libraries/library_edit_screen.dart';
import '../features/admin/logs/log_file_viewer_screen.dart';
import '../features/admin/logs/server_logs_screen.dart';
import '../features/admin/plugins/plugins_screen.dart';
import '../features/admin/server_config/server_branding_screen.dart';
import '../features/admin/server_config/server_config_screen.dart';
import '../features/admin/sessions/sessions_screen.dart';
import '../features/admin/tasks/tasks_screen.dart';
import '../features/admin/users/user_create_screen.dart';
import '../features/admin/users/user_edit_screen.dart';
import '../features/admin/users/users_list_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/cast/cast_now_playing_screen.dart';
import '../features/details/detail_screen.dart';
import '../features/details/offline_series_screen.dart';
import '../features/downloads/downloads_screen.dart';
import '../features/home/home_screen.dart';
import '../features/library/library_screen.dart';
import '../features/onboarding/login_screen.dart';
import '../features/onboarding/onboarding_server_screen.dart';
import '../features/player/play_extra.dart';
import '../features/player/player_screen.dart';
import '../features/requests/requests_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/about_settings_screen.dart';
import '../features/settings/downloads_settings_screen.dart';
import '../features/settings/language_settings_screen.dart';
import '../features/settings/playback_settings_screen.dart';
import '../features/settings/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/watch_provider/watch_provider_screen.dart';
import '../shared/layout/app_navigation_shell.dart';

/// Listenable wrapper around the reauth stream. Holds the last (unhandled)
/// signal so the router's redirect can read it synchronously, and notifies
/// the router to re-evaluate redirects whenever a new signal arrives.
class _ReauthListenable extends ChangeNotifier {
  ReauthSignal? _pending;
  ReauthSignal? get pending => _pending;

  void emit(ReauthSignal signal) {
    // Coalesce burst events: when parallel requests all hit a 401 the
    // interceptor fires multiple signals in quick succession, and we'd
    // otherwise schedule N redundant redirects with N postFrame consumes.
    if (_pending != null) return;
    _pending = signal;
    notifyListeners();
  }

  /// Marks the current signal as handled. Called from a post-frame callback so
  /// we never mutate state during a router redirect pass.
  void consume() {
    if (_pending == null) return;
    _pending = null;
  }
}

final _reauthListenableProvider = Provider<_ReauthListenable>((ref) {
  final notifier = _ReauthListenable();
  final sub = ref
      .read(reauthEventsControllerProvider)
      .stream
      .listen(notifier.emit);
  ref.onDispose(() {
    unawaited(sub.cancel());
    notifier.dispose();
  });
  return notifier;
});

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final reauth = ref.watch(_reauthListenableProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding/server',
    refreshListenable: reauth,
    redirect: (context, state) {
      final matched = state.matchedLocation;
      final loggingIn =
          matched.startsWith('/onboarding') || matched == '/login';
      final hasSession = auth.valueOrNull?.hasSession ?? false;
      final qp = state.uri.queryParameters;
      final isAddFlow = qp['add'] == '1';
      final isReauthFlow = qp['reauth'] == '1';

      // Pending reauth signal: a request just got a 401 for the active
      // account. Surface the dedicated re-auth login (pre-filled with the
      // saved username) unless we're already on it.
      final pending = reauth.pending;
      if (pending != null && hasSession) {
        final alreadyHere =
            matched == '/login' &&
            isReauthFlow &&
            qp['serverId'] == pending.serverId &&
            qp['userId'] == pending.userId;
        if (!alreadyHere) {
          // Schedule consume so a later redirect pass doesn't refire on the
          // same signal — we mutate ChangeNotifier state outside the redirect
          // callback to keep this side-effect-free.
          WidgetsBinding.instance.addPostFrameCallback((_) => reauth.consume());
          return Uri(
            path: '/login',
            queryParameters: {
              'reauth': '1',
              'serverId': pending.serverId,
              'userId': pending.userId,
            },
          ).toString();
        }
      }

      if (!hasSession && !loggingIn) return '/onboarding/server';
      // The "add another account" flow needs to reach /onboarding/server and
      // /login even when a session is already active, so we make an explicit
      // exception when ?add=1 is present.
      if (hasSession && loggingIn && !isAddFlow && !isReauthFlow) {
        return '/home';
      }
      // Admin routes guard: deep links and lingering navigation history must
      // not let a demoted user reach /settings/admin/*. The Settings screen
      // already hides the entry tile based on the same flag.
      if (matched.startsWith('/settings/admin')) {
        final isAdmin = auth.valueOrNull?.session?.isAdmin ?? false;
        if (!isAdmin) return '/settings';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding/server',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const OnboardingServerScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/accounts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AccountsScreen(),
      ),
      // IndexedStack-backed shell so the 6 tabs stay mounted across switches.
      // This keeps Home's Riverpod providers alive when the user pops into
      // Library/Search/etc. mid-fetch, instead of disposing them and
      // re-running the network calls on the way back.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (_, __) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (_, __) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (_, __) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/downloads',
                builder: (_, __) => const DownloadsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Routes hors-shell: `parentNavigatorKey` force le push sur le root
      // navigator pour que ces écrans recouvrent toute la shell et que le
      // retour les dépile proprement (sinon, selon le contexte, le push peut
      // atterrir sur le navigator de la branche courante et le retour fait
      // sortir de l'app).
      //
      // `/requests` is no longer in the bottom bar (the bridge plugin handles
      // request creation inline from any item detail). It stays reachable via
      // a Settings tile and as a top-level pushable route.
      GoRoute(
        path: '/requests',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const RequestsScreen(),
      ),
      GoRoute(
        path: '/items/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            DetailScreen(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/offline/series/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final name = state.uri.queryParameters['name'] ?? 'Série';
          return OfflineSeriesScreen(
            seriesId: state.pathParameters['id']!,
            seriesName: name,
          );
        },
      ),
      GoRoute(
        path: '/play/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => PlayerScreen(
          itemId: state.pathParameters['id']!,
          extra: state.extra is PlayExtra ? state.extra! as PlayExtra : null,
        ),
      ),
      GoRoute(
        path: '/cast/now-playing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CastNowPlayingScreen(),
      ),
      GoRoute(
        path: '/settings/downloads',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const DownloadsSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/playback',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PlaybackSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AboutSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminHubScreen(),
      ),
      GoRoute(
        path: '/settings/admin/dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/settings/admin/libraries',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminLibrariesScreen(),
      ),
      GoRoute(
        path: '/settings/admin/tasks',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminTasksScreen(),
      ),
      GoRoute(
        path: '/settings/admin/users',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminUsersListScreen(),
      ),
      GoRoute(
        path: '/settings/admin/users/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminUserCreateScreen(),
      ),
      GoRoute(
        path: '/settings/admin/users/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            AdminUserEditScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings/admin/sessions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminSessionsScreen(),
      ),
      GoRoute(
        path: '/settings/admin/devices',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminDevicesScreen(),
      ),
      GoRoute(
        path: '/settings/admin/activity',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminActivityLogScreen(),
      ),
      GoRoute(
        path: '/settings/admin/logs',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminServerLogsScreen(),
      ),
      GoRoute(
        path: '/settings/admin/logs/:name',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => LogFileViewerScreen(
          name: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
      GoRoute(
        path: '/settings/admin/plugins',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminPluginsScreen(),
      ),
      GoRoute(
        path: '/settings/admin/api-keys',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminApiKeysScreen(),
      ),
      GoRoute(
        path: '/settings/admin/libraries/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LibraryEditScreen(),
      ),
      GoRoute(
        path: '/settings/admin/server-config',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminServerConfigScreen(),
      ),
      GoRoute(
        path: '/settings/admin/branding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminBrandingScreen(),
      ),
      GoRoute(
        path: '/settings/admin/backup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminBackupScreen(),
      ),
      GoRoute(
        path: '/watch-provider/:type/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final type = state.pathParameters['type']!;
          final id = int.tryParse(state.pathParameters['id']!) ?? 0;
          final name = state.extra is String
              ? state.extra! as String
              : 'Provider';
          return WatchProviderScreen(
            providerId: id,
            isTv: type == 'tv',
            providerName: name,
          );
        },
      ),
    ],
  );
});
