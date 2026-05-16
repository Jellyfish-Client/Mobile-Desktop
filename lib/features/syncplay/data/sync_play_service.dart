import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';
import '../domain/sync_play_mappers.dart';
import '../domain/sync_play_session.dart';

/// Façade typée sur `SyncPlayApi` : traduit les DTOs SDK vers le domain
/// SyncPlay et offre des verbes plus parlants côté consumers (`pause()`
/// au lieu de `syncPlayPause()`).
///
/// Le service ne gère AUCUN état : il est sans-mémoire et délègue toute la
/// logique de transition au controller. À utiliser systématiquement via le
/// `syncPlayServiceProvider`.
class SyncPlayService {
  SyncPlayService(this._api);

  final SyncPlayApi _api;

  /// Crée un nouveau groupe et retourne ses infos. ATTENTION : Jellyfin ne
  /// retourne PAS un `GroupInfoDto` complet ici — il n'y a pas de doc claire,
  /// mais en pratique le payload retourné suffit pour mettre l'état en
  /// `Idle`. On bascule donc en attendant la frame `GroupJoined` côté WS.
  Future<SyncPlayGroup> createGroup({required String name}) async {
    final res = await _api.syncPlayCreateGroup(
      newGroupRequestDto: NewGroupRequestDto((b) => b..groupName = name),
    );
    final dto = res.data;
    if (dto == null) {
      throw StateError('SyncPlay: empty response on createGroup');
    }
    return syncPlayGroupFromDto(dto);
  }

  /// Rejoint un groupe existant. Pas de retour utile côté HTTP — l'état
  /// réel arrive via la frame `GroupJoined` du WS.
  Future<void> joinGroup(String groupId) async {
    await _api.syncPlayJoinGroup(
      joinGroupRequestDto: JoinGroupRequestDto((b) => b..groupId = groupId),
    );
  }

  Future<void> leaveGroup() async {
    await _api.syncPlayLeaveGroup();
  }

  /// Liste les groupes ouverts visibles par l'utilisateur courant. Filtre
  /// les DTOs sans `groupId` (Jellyfin retourne parfois des entrées
  /// fantômes après un crash serveur).
  Future<List<SyncPlayGroup>> listOpenGroups() async {
    final res = await _api.syncPlayGetGroups();
    final list = res.data?.toList() ?? const <GroupInfoDto>[];
    return list
        .where((d) => d.groupId != null && d.groupId!.isNotEmpty)
        .map(syncPlayGroupFromDto)
        .toList();
  }

  /// Demande la pause au groupe. Le serveur la rebroadcast à tous les
  /// membres via `SyncPlayCommand`.
  Future<void> pause() => _api.syncPlayPause();

  Future<void> unpause() => _api.syncPlayUnpause();

  Future<void> stop() => _api.syncPlayStop();

  /// Demande au groupe de se déplacer à [position]. Conversion :
  /// 1 tick = 100 ns donc `Duration.inMicroseconds * 10`.
  Future<void> seek(Duration position) async {
    await _api.syncPlaySeek(
      seekRequestDto: SeekRequestDto(
        (b) => b..positionTicks = position.inMicroseconds * 10,
      ),
    );
  }

  /// Signale au groupe que ce client est en train de bufferiser. À envoyer
  /// dès qu'on a un stall détecté côté player local.
  Future<void> reportBuffering({
    required Duration position,
    required String playlistItemId,
    bool isPlaying = false,
  }) async {
    await _api.syncPlayBuffering(
      bufferRequestDto: BufferRequestDto(
        (b) => b
          ..when = DateTime.now().toUtc()
          ..positionTicks = position.inMicroseconds * 10
          ..isPlaying = isPlaying
          ..playlistItemId = playlistItemId,
      ),
    );
  }

  /// Pendant un `Waiting`, on signale qu'on est prêt à reprendre. Le serveur
  /// repasse en `Playing` quand tous les membres ont émis ce verbe.
  Future<void> reportReady({
    required Duration position,
    required String playlistItemId,
    bool isPlaying = false,
  }) async {
    await _api.syncPlayReady(
      readyRequestDto: ReadyRequestDto(
        (b) => b
          ..when = DateTime.now().toUtc()
          ..positionTicks = position.inMicroseconds * 10
          ..isPlaying = isPlaying
          ..playlistItemId = playlistItemId,
      ),
    );
  }

  /// Mesure de latence côté client → serveur. À envoyer périodiquement
  /// pendant la session pour permettre au serveur d'ajuster sa fenêtre de
  /// délai.
  Future<void> ping(Duration latency) async {
    await _api.syncPlayPing(
      pingRequestDto: PingRequestDto((b) => b..ping = latency.inMilliseconds),
    );
  }

  /// Remplace la queue partagée. [itemIds] est l'ordre exact ; [startIndex]
  /// indique l'item à lire en premier, [startPosition] sa position initiale.
  Future<void> setNewQueue({
    required List<String> itemIds,
    int startIndex = 0,
    Duration startPosition = Duration.zero,
  }) async {
    await _api.syncPlaySetNewQueue(
      playRequestDto: PlayRequestDto(
        (b) => b
          ..playingQueue.replace(BuiltList<String>.of(itemIds))
          ..playingItemPosition = startIndex
          ..startPositionTicks = startPosition.inMicroseconds * 10,
      ),
    );
  }

  Future<void> setRepeatMode(GroupRepeatMode mode) async {
    await _api.syncPlaySetRepeatMode(
      setRepeatModeRequestDto: SetRepeatModeRequestDto((b) => b..mode = mode),
    );
  }

  Future<void> setShuffleMode(GroupShuffleMode mode) async {
    await _api.syncPlaySetShuffleMode(
      setShuffleModeRequestDto: SetShuffleModeRequestDto((b) => b..mode = mode),
    );
  }
}

final syncPlayServiceProvider = Provider<SyncPlayService>((ref) {
  final api = ref.watch(jellyfinApiProvider).getSyncPlayApi();
  return SyncPlayService(api);
});
