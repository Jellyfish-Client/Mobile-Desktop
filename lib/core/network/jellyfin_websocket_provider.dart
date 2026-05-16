import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../storage/device_id.dart';
import 'jellyfin_websocket.dart';
import 'jellyfin_ws_frame.dart';

/// Singleton lié à la session active : recrée et démarre un [JellyfinWebSocket]
/// dès qu'une session est disponible (token + serveur), le dispose lorsqu'elle
/// disparaît (logout, switch d'account).
///
/// Retourne `null` tant qu'aucune session n'est résolue : les consumers
/// doivent garder ce cas en tête plutôt que de supposer la présence du
/// service.
final jellyfinWebSocketProvider = Provider<JellyfinWebSocket?>((ref) {
  final session = ref.watch(authControllerProvider).valueOrNull?.session;
  final deviceId = ref.watch(deviceIdProvider).valueOrNull;
  if (session == null || deviceId == null) return null;
  final ws = JellyfinWebSocket(
    accessToken: session.accessToken,
    deviceId: deviceId,
    serverUrl: session.serverUrl,
  )..start();
  ref.onDispose(ws.dispose);
  return ws;
});

/// Stream broadcast des frames décodées. Émet en erreur si aucune session
/// n'est active — les consumers SyncPlay s'attendent à n'écouter qu'à partir
/// du moment où ils ont confirmé la présence d'une session.
final jellyfinWebSocketFramesProvider = StreamProvider<JellyfinWsFrame>((ref) {
  final ws = ref.watch(jellyfinWebSocketProvider);
  if (ws == null) {
    return const Stream<JellyfinWsFrame>.empty();
  }
  return ws.frames;
});
