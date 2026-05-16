import 'package:jellyfin_api/jellyfin_api.dart' as jf;

import 'sync_play_session.dart';

/// Convertit un `GroupInfoDto` (DTO SDK) vers le modèle domain. On dégage les
/// nullabilités du DTO en supposant `id` et `name` non vides — la pratique
/// montre que Jellyfin renvoie systématiquement ces deux champs sur les
/// endpoints `/SyncPlay/*`. Les `participants` sont des noms d'utilisateur
/// affichables : on les utilise tel quel comme `id` faute de mieux côté
/// serveur.
SyncPlayGroup syncPlayGroupFromDto(jf.GroupInfoDto dto) {
  final participants =
      dto.participants
          ?.map((name) => SyncPlayMember(id: name, displayName: name))
          .toList() ??
      const <SyncPlayMember>[];
  return SyncPlayGroup(
    id: dto.groupId ?? '',
    name: dto.groupName ?? '',
    members: participants,
    lastUpdatedAt: dto.lastUpdatedAt,
  );
}

/// Applique un `GroupStateUpdate` (StateUpdate frame WS) à un groupe donné
/// pour produire un nouvel état [SyncPlaySession]. La position et l'item
/// effectifs sont conservés depuis l'état précédent quand le serveur ne les
/// fournit pas — Jellyfin ne renvoie pas systématiquement la position lors
/// d'un simple changement d'état.
///
/// `previous` est l'état courant : il sert à préserver `position`,
/// `playlistItemId` et `anchorServerUtc` quand le serveur n'émet qu'un
/// `GroupStateType` nu.
SyncPlaySession syncPlaySessionFromStateUpdate({
  required SyncPlayGroup group,
  required jf.GroupStateUpdate update,
  required SyncPlaySession previous,
}) {
  final state = update.state;
  if (state == jf.GroupStateType.idle) {
    return SyncPlaySessionIdle(group: group);
  }
  if (state == jf.GroupStateType.waiting) {
    // On ne connaît pas les membres bufferisant sans frame BufferingUpdate
    // dédiée — on les copie depuis l'état précédent si déjà en Waiting.
    final buffering = previous is SyncPlaySessionWaiting
        ? previous.bufferingMemberIds
        : const <String>{};
    return SyncPlaySessionWaiting(group: group, bufferingMemberIds: buffering);
  }
  if (state == jf.GroupStateType.paused) {
    final position = switch (previous) {
      SyncPlaySessionPaused(:final position) => position,
      SyncPlaySessionPlaying(:final positionAtAnchor) => positionAtAnchor,
      _ => Duration.zero,
    };
    final playlistItemId = switch (previous) {
      SyncPlaySessionPaused(:final playlistItemId) => playlistItemId,
      SyncPlaySessionPlaying(:final playlistItemId) => playlistItemId,
      _ => null,
    };
    return SyncPlaySessionPaused(
      group: group,
      position: position,
      playlistItemId: playlistItemId,
    );
  }
  if (state == jf.GroupStateType.playing) {
    // Pas d'ancrage temporel fourni — on prend `now` comme proxy. Sera
    // corrigé dès qu'une frame SyncPlayCommand arrive avec `When`.
    final anchor = DateTime.now().toUtc();
    final position = switch (previous) {
      SyncPlaySessionPaused(:final position) => position,
      SyncPlaySessionPlaying(:final positionAtAnchor) => positionAtAnchor,
      _ => Duration.zero,
    };
    final playlistItemId = switch (previous) {
      SyncPlaySessionPaused(:final playlistItemId) => playlistItemId,
      SyncPlaySessionPlaying(:final playlistItemId) => playlistItemId,
      _ => null,
    };
    return SyncPlaySessionPlaying(
      group: group,
      positionAtAnchor: position,
      anchorServerUtc: anchor,
      playlistItemId: playlistItemId,
    );
  }
  // GroupStateType inconnu : on garde l'état courant pour éviter de faire
  // disparaître le groupe sur un message exotique.
  return previous;
}

/// Convertit une frame `SendCommand` (Pause/Unpause/Seek/Stop) avec
/// timing serveur en transition d'état. La position en ticks est convertie
/// en `Duration` (1 tick = 100 ns).
SyncPlaySession syncPlaySessionFromCommand({
  required SyncPlayGroup group,
  required jf.SendCommand command,
  required SyncPlaySession previous,
}) {
  final cmd = command.command;
  final ticks = command.positionTicks ?? 0;
  final position = Duration(microseconds: ticks ~/ 10);
  final whenUtc = command.when?.toUtc() ?? DateTime.now().toUtc();
  final playlistItemId =
      command.playlistItemId ??
      switch (previous) {
        SyncPlaySessionPaused(:final playlistItemId) => playlistItemId,
        SyncPlaySessionPlaying(:final playlistItemId) => playlistItemId,
        _ => null,
      };

  if (cmd == jf.SendCommandType.pause || cmd == jf.SendCommandType.stop) {
    return SyncPlaySessionPaused(
      group: group,
      position: position,
      playlistItemId: playlistItemId,
    );
  }
  if (cmd == jf.SendCommandType.unpause) {
    return SyncPlaySessionPlaying(
      group: group,
      positionAtAnchor: position,
      anchorServerUtc: whenUtc,
      playlistItemId: playlistItemId,
    );
  }
  if (cmd == jf.SendCommandType.seek) {
    // Seek garde l'orientation play/pause précédente. On ré-ancre la position.
    if (previous is SyncPlaySessionPlaying) {
      return SyncPlaySessionPlaying(
        group: group,
        positionAtAnchor: position,
        anchorServerUtc: whenUtc,
        playlistItemId: playlistItemId,
      );
    }
    return SyncPlaySessionPaused(
      group: group,
      position: position,
      playlistItemId: playlistItemId,
    );
  }
  return previous;
}
