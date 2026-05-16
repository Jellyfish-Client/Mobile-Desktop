import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart' as jf;
import 'package:logging/logging.dart';

import '../../../core/network/jellyfin_websocket_provider.dart';
import '../../../core/network/jellyfin_ws_frame.dart';
import '../domain/sync_play_mappers.dart';
import '../domain/sync_play_session.dart';
import 'sync_play_service.dart';

/// Notifier d'état SyncPlay : consomme les frames WS, applique la machine à
/// états, et expose les verbes utilisateur (`create`, `join`, `leave`,
/// `pause`, `unpause`, `seek`, etc.).
///
/// Convention de transition :
/// - **Frame WS** (entrée serveur) → recalcul authoritative de l'état.
/// - **Commande utilisateur** → optimistic update + appel HTTP ; si l'appel
///   échoue on rollback en `error`, le serveur réenverra la frame
///   correctrice quand le réseau revient.
class SyncPlaySessionController extends AsyncNotifier<SyncPlaySession> {
  static final _log = Logger('SyncPlaySessionController');

  StreamSubscription<JellyfinWsFrame>? _framesSub;

  @override
  Future<SyncPlaySession> build() async {
    // On (re)wire l'abonnement explicitement pour traiter le flux complet,
    // pas uniquement le dernier événement émis par le StreamProvider — un
    // `whenData` ne couvre que la dernière frame, ce qui suffit côté UI mais
    // pas pour la machine à états.
    unawaited(_framesSub?.cancel());
    final ws = ref.watch(jellyfinWebSocketProvider);
    if (ws != null) {
      _framesSub = ws.frames.listen(_onFrame);
      ref.onDispose(() {
        unawaited(_framesSub?.cancel());
      });
    }
    return const SyncPlaySession.disconnected();
  }

  // -- Verbes utilisateurs ----------------------------------------------------

  /// Crée un nouveau groupe et bascule l'état en `Idle` optimistiquement.
  /// La frame `GroupJoined` arrivera ensuite et confirmera l'état.
  Future<void> create({required String name}) async {
    final service = ref.read(syncPlayServiceProvider);
    try {
      final group = await service.createGroup(name: name);
      state = AsyncData(SyncPlaySession.idle(group: group));
    } on Object catch (e, st) {
      _log.warning('createGroup failed', e, st);
      state = AsyncData(
        SyncPlaySession.error(
          kind: SyncPlayErrorKind.transport,
          message: e.toString(),
        ),
      );
    }
  }

  /// Rejoint un groupe par id. Pas d'optimistic update : on attend la frame
  /// `GroupJoined` pour basculer hors de `disconnected`, parce qu'on ne
  /// connaît pas encore les participants côté client.
  Future<void> join(String groupId) async {
    final service = ref.read(syncPlayServiceProvider);
    try {
      await service.joinGroup(groupId);
    } on Object catch (e, st) {
      _log.warning('joinGroup failed', e, st);
      state = AsyncData(
        SyncPlaySession.error(
          kind: SyncPlayErrorKind.transport,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> leave() async {
    final service = ref.read(syncPlayServiceProvider);
    try {
      await service.leaveGroup();
      state = const AsyncData(SyncPlaySession.disconnected());
    } on Object catch (e, st) {
      _log.warning('leaveGroup failed', e, st);
      // On bascule quand même hors du groupe côté client — sinon l'UI reste
      // bloquée si le serveur a déjà perdu notre session.
      state = const AsyncData(SyncPlaySession.disconnected());
    }
  }

  Future<void> pause() async {
    final service = ref.read(syncPlayServiceProvider);
    try {
      await service.pause();
    } on Object catch (e, st) {
      _log.warning('pause failed', e, st);
    }
  }

  Future<void> unpause() async {
    final service = ref.read(syncPlayServiceProvider);
    try {
      await service.unpause();
    } on Object catch (e, st) {
      _log.warning('unpause failed', e, st);
    }
  }

  Future<void> seek(Duration position) async {
    final service = ref.read(syncPlayServiceProvider);
    try {
      await service.seek(position);
    } on Object catch (e, st) {
      _log.warning('seek failed', e, st);
    }
  }

  Future<void> setRepeatMode(jf.GroupRepeatMode mode) async {
    final service = ref.read(syncPlayServiceProvider);
    try {
      await service.setRepeatMode(mode);
    } on Object catch (e, st) {
      _log.warning('setRepeatMode failed', e, st);
    }
  }

  Future<void> setShuffleMode(jf.GroupShuffleMode mode) async {
    final service = ref.read(syncPlayServiceProvider);
    try {
      await service.setShuffleMode(mode);
    } on Object catch (e, st) {
      _log.warning('setShuffleMode failed', e, st);
    }
  }

  // -- Pompe WS ---------------------------------------------------------------

  void _onFrame(JellyfinWsFrame frame) {
    switch (frame) {
      case JellyfinWsFrameSyncPlayGroupUpdate(:final update):
        _applyGroupUpdate(update);
      case JellyfinWsFrameSyncPlayCommand(:final command):
        _applyCommand(command);
      case JellyfinWsFrameKeepAlive():
      case JellyfinWsFrameForceKeepAlive():
      case JellyfinWsFrameUnknown():
        break;
    }
  }

  void _applyGroupUpdate(jf.GroupUpdate update) {
    // `update.oneOf.value` est typé `Object?` côté generated code — on
    // switch sur le type runtime pour router vers la bonne variante.
    final value = update.oneOf.value;
    switch (value) {
      case final jf.SyncPlayGroupJoinedUpdate joined:
        final dto = joined.data;
        if (dto == null) return;
        state = AsyncData(
          SyncPlaySession.idle(group: syncPlayGroupFromDto(dto)),
        );
      case final jf.SyncPlayGroupLeftUpdate _:
        state = const AsyncData(SyncPlaySession.disconnected());
      case final jf.SyncPlayUserJoinedUpdate _:
      case final jf.SyncPlayUserLeftUpdate _:
        // On pourrait raffiner la liste de membres ici. Pas indispensable au
        // MVP : la liste est portée par le DTO `GroupInfoDto` envoyé sur
        // `GroupJoined`, et l'UI n'affiche qu'un compteur global.
        break;
      case final jf.SyncPlayStateUpdate stateUpdate:
        _applyStateUpdate(stateUpdate);
      case final jf.SyncPlayPlayQueueUpdate _:
        // PlayQueueUpdate n'altère pas l'état Play/Pause/Idle ; le bridge
        // observera `playlistItemId` via SendCommand. À implémenter en
        // détail quand on supportera la liste de file UI.
        break;
      case final jf.SyncPlayLibraryAccessDeniedUpdate _:
        state = const AsyncData(
          SyncPlaySession.error(
            kind: SyncPlayErrorKind.libraryAccessDenied,
            message: 'Library access denied by the SyncPlay group host.',
          ),
        );
      case final jf.SyncPlayGroupDoesNotExistUpdate _:
        state = const AsyncData(
          SyncPlaySession.error(
            kind: SyncPlayErrorKind.groupDoesNotExist,
            message: 'The requested SyncPlay group does not exist anymore.',
          ),
        );
      case final jf.SyncPlayNotInGroupUpdate _:
        state = const AsyncData(
          SyncPlaySession.error(
            kind: SyncPlayErrorKind.notInGroup,
            message:
                'You are no longer a member of any SyncPlay group on this server.',
          ),
        );
      default:
        // OneOf inconnu — on logge et on garde l'état.
        _log.fine('Unhandled GroupUpdate oneOf: ${value.runtimeType}');
    }
  }

  void _applyStateUpdate(jf.SyncPlayStateUpdate update) {
    final previous = state.valueOrNull;
    if (previous == null) return;
    final group = previous.group;
    if (group == null) {
      _log.fine('Ignoring StateUpdate received without an active group');
      return;
    }
    final data = update.data;
    if (data == null) return;
    state = AsyncData(
      syncPlaySessionFromStateUpdate(
        group: group,
        update: data,
        previous: previous,
      ),
    );
  }

  void _applyCommand(jf.SendCommand command) {
    final previous = state.valueOrNull;
    if (previous == null) return;
    final group = previous.group;
    if (group == null) {
      _log.fine('Ignoring SendCommand received without an active group');
      return;
    }
    state = AsyncData(
      syncPlaySessionFromCommand(
        group: group,
        command: command,
        previous: previous,
      ),
    );
  }
}

final syncPlaySessionProvider =
    AsyncNotifierProvider<SyncPlaySessionController, SyncPlaySession>(
      SyncPlaySessionController.new,
    );

/// Indicateur synchrone pour la couche UI / bridge : `true` dès que l'état
/// résolu est dans un des sous-types "in-group" (Idle/Waiting/Paused/Playing).
final syncPlayInGroupProvider = Provider<bool>((ref) {
  final session = ref.watch(syncPlaySessionProvider).valueOrNull;
  return session?.isInGroup ?? false;
});
