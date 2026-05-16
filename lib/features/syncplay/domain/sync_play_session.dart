import 'package:flutter/foundation.dart';

/// État d'un participant SyncPlay. On garde un modèle pauvre — le serveur
/// ne nous remonte que des `participants` sous forme de noms (cf.
/// `GroupInfoDto.participants: BuiltList<String>`). On modélise quand même
/// un `id` distinct pour permettre, plus tard, l'enrichissement (latence,
/// avatar) sans casser l'API.
@immutable
class SyncPlayMember {
  const SyncPlayMember({required this.id, required this.displayName});

  final String id;
  final String displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncPlayMember &&
          other.id == id &&
          other.displayName == displayName;

  @override
  int get hashCode => Object.hash(id, displayName);
}

/// Item dans la file d'attente partagée. Le `playlistItemId` est l'identifiant
/// stable côté SyncPlay, distinct de l'`itemId` Jellyfin (un même item peut
/// apparaître plusieurs fois dans la queue avec des `playlistItemId`
/// différents).
@immutable
class SyncPlayQueueItem {
  const SyncPlayQueueItem({required this.itemId, required this.playlistItemId});

  final String itemId;
  final String playlistItemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncPlayQueueItem &&
          other.itemId == itemId &&
          other.playlistItemId == playlistItemId;

  @override
  int get hashCode => Object.hash(itemId, playlistItemId);
}

/// Groupe SyncPlay observé côté client. Domain agnostique du SDK : les
/// adaptateurs vers les DTOs vivent dans `sync_play_mappers.dart`.
@immutable
class SyncPlayGroup {
  const SyncPlayGroup({
    required this.id,
    required this.name,
    required this.members,
    this.lastUpdatedAt,
  });

  final String id;
  final String name;
  final List<SyncPlayMember> members;
  final DateTime? lastUpdatedAt;

  SyncPlayGroup copyWith({
    String? id,
    String? name,
    List<SyncPlayMember>? members,
    DateTime? lastUpdatedAt,
  }) {
    return SyncPlayGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

/// Famille d'erreurs distinctes côté SyncPlay — on les expose au lieu d'un
/// simple `String` parce que le wording localisé et l'action recovery
/// (réessayer ? rejoindre un autre groupe ? logout ?) varient.
enum SyncPlayErrorKind {
  /// `SyncPlayLibraryAccessDenied` : la lib courante n'est pas accessible au
  /// groupe (différence d'ACL entre membres).
  libraryAccessDenied,

  /// `SyncPlayGroupDoesNotExist` : le groupe ciblé n'existe plus côté serveur.
  groupDoesNotExist,

  /// `SyncPlayNotInGroup` : l'utilisateur a quitté ou jamais rejoint.
  notInGroup,

  /// Erreur transport (socket fermé, HTTP 5xx, timeout DNS) — recovery par
  /// reconnect + retry du dernier verbe utilisateur.
  transport,

  /// Erreur inconnue, capturée en bout de chaîne pour ne pas masquer un
  /// crash silencieux.
  unknown,
}

/// État machine du session controller. Sealed pour forcer un `switch`
/// exhaustif dans les consumers (bridge player, UI).
sealed class SyncPlaySession {
  const SyncPlaySession();

  /// Helper court : `null` si l'on n'est pas dans un groupe, sinon le groupe
  /// courant. Utilisé par le bridge pour décider d'activer son pont
  /// player ↔ serveur.
  SyncPlayGroup? get group => switch (this) {
    SyncPlaySessionDisconnected() => null,
    SyncPlaySessionError() => null,
    SyncPlaySessionIdle(:final group) => group,
    SyncPlaySessionWaiting(:final group) => group,
    SyncPlaySessionPaused(:final group) => group,
    SyncPlaySessionPlaying(:final group) => group,
  };

  /// True dès que le client est rattaché à un groupe (quel que soit l'état
  /// de lecture). Le bridge et l'UI s'appuient là-dessus pour activer leurs
  /// chemins SyncPlay.
  bool get isInGroup => group != null;

  /// Sucre syntaxique pour la couche UI : `state.isPlayingState`, etc.
  bool get isPlaying => this is SyncPlaySessionPlaying;
  bool get isPaused => this is SyncPlaySessionPaused;
  bool get isWaiting => this is SyncPlaySessionWaiting;

  /// Constructeur des variantes — exposé sous forme de factories nommées
  /// pour rester lisible côté consumers (`SyncPlaySession.disconnected()`,
  /// etc.).
  const factory SyncPlaySession.disconnected() = SyncPlaySessionDisconnected;
  const factory SyncPlaySession.idle({required SyncPlayGroup group}) =
      SyncPlaySessionIdle;
  const factory SyncPlaySession.waiting({
    required SyncPlayGroup group,
    required Set<String> bufferingMemberIds,
  }) = SyncPlaySessionWaiting;
  const factory SyncPlaySession.paused({
    required SyncPlayGroup group,
    required Duration position,
    String? playlistItemId,
  }) = SyncPlaySessionPaused;
  const factory SyncPlaySession.playing({
    required SyncPlayGroup group,
    required Duration positionAtAnchor,
    required DateTime anchorServerUtc,
    String? playlistItemId,
    double playbackRate,
  }) = SyncPlaySessionPlaying;
  const factory SyncPlaySession.error({
    required SyncPlayErrorKind kind,
    required String message,
  }) = SyncPlaySessionError;
}

/// Aucune session active — soit jamais rejointe, soit explicitement quittée.
class SyncPlaySessionDisconnected extends SyncPlaySession {
  const SyncPlaySessionDisconnected();
}

/// Groupe rejoint mais aucun item n'est sélectionné — état initial après
/// `joinGroup` quand la queue est vide.
class SyncPlaySessionIdle extends SyncPlaySession {
  const SyncPlaySessionIdle({required SyncPlayGroup group}) : _group = group;

  final SyncPlayGroup _group;

  @override
  SyncPlayGroup get group => _group;
}

/// Le serveur attend que tous les membres signalent `Ready`. Tant qu'au moins
/// un membre est dans `bufferingMemberIds`, on reste dans cet état.
class SyncPlaySessionWaiting extends SyncPlaySession {
  const SyncPlaySessionWaiting({
    required SyncPlayGroup group,
    required this.bufferingMemberIds,
  }) : _group = group;

  final SyncPlayGroup _group;
  final Set<String> bufferingMemberIds;

  @override
  SyncPlayGroup get group => _group;
}

/// Lecture en pause à `position` (position absolue dans le média). On stocke
/// l'item courant pour permettre au bridge de détecter un switch d'item
/// pendant la pause.
class SyncPlaySessionPaused extends SyncPlaySession {
  const SyncPlaySessionPaused({
    required SyncPlayGroup group,
    required this.position,
    this.playlistItemId,
  }) : _group = group;

  final SyncPlayGroup _group;
  final Duration position;
  final String? playlistItemId;

  @override
  SyncPlayGroup get group => _group;
}

/// Lecture en cours. La position effective n'est PAS stockée directement :
/// on garde un ancrage (`positionAtAnchor` à `anchorServerUtc`) et le bridge
/// extrapole en temps réel via le clock offset.
///
/// `playbackRate` reste à `1.0` aujourd'hui — réservé pour un usage futur si
/// on supporte le rate change collectif.
class SyncPlaySessionPlaying extends SyncPlaySession {
  const SyncPlaySessionPlaying({
    required SyncPlayGroup group,
    required this.positionAtAnchor,
    required this.anchorServerUtc,
    this.playlistItemId,
    this.playbackRate = 1.0,
  }) : _group = group;

  final SyncPlayGroup _group;
  final Duration positionAtAnchor;
  final DateTime anchorServerUtc;
  final String? playlistItemId;
  final double playbackRate;

  @override
  SyncPlayGroup get group => _group;
}

/// État terminal applicatif — le controller passe par là avant de revenir à
/// `disconnected` dans la plupart des cas. Les erreurs métiers
/// (LibraryAccessDenied, GroupDoesNotExist, NotInGroup) montent jusqu'ici.
class SyncPlaySessionError extends SyncPlaySession {
  const SyncPlaySessionError({required this.kind, required this.message});

  final SyncPlayErrorKind kind;
  final String message;
}
