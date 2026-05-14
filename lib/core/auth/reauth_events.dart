import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Signal emitted when an active account's token has been rejected by the
/// server (HTTP 401 from Jellyfin itself, not from a reverse-proxy Basic Auth
/// gate). The router listens to this and routes the user to the re-auth
/// version of `/login` so they can re-enter credentials without losing the
/// saved account entry.
class ReauthSignal {
  const ReauthSignal({required this.serverId, required this.userId});
  final String serverId;
  final String userId;
}

/// Singleton broadcast controller for [ReauthSignal] events. The auth
/// interceptor publishes to it; the router subscribes.
final reauthEventsControllerProvider = Provider<StreamController<ReauthSignal>>(
  (ref) {
    final controller = StreamController<ReauthSignal>.broadcast();
    ref.onDispose(controller.close);
    return controller;
  },
);

/// Stream view of [reauthEventsControllerProvider] for consumers that just
/// want to listen.
final reauthEventsProvider = StreamProvider<ReauthSignal>((ref) {
  return ref.watch(reauthEventsControllerProvider).stream;
});
