import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// Frame structuré décodé depuis le canal WebSocket Jellyfin.
///
/// Le SDK généré expose `OutboundWebSocketMessage` (serveur → client) comme
/// une union `oneOf` discriminée par `MessageType`, mais sa désérialisation
/// auto-générée ne fonctionne pas de manière fiable pour SyncPlay : les
/// variantes `SyncPlayCommandMessage` / `SyncPlayGroupUpdateMessage` portent
/// des payloads polymorphes (`GroupUpdate` est lui-même un `oneOf`) que le
/// `built_value` runtime ne sait pas router correctement sans contexte.
///
/// On décode donc manuellement le JSON brut, on lit `MessageType`, et on
/// délègue au serializer adéquat. Les types inconnus tombent dans
/// [JellyfinWsFrameUnknown] pour qu'on puisse logger / ignorer sans crasher
/// la connexion.
sealed class JellyfinWsFrame {
  const JellyfinWsFrame();

  /// Décode un message WebSocket texte en frame structuré.
  ///
  /// Retourne [JellyfinWsFrameUnknown] si le JSON est mal formé ou si le type
  /// de message n'est pas reconnu : on ne veut pas faire tomber la pompe à
  /// frames sur un message exotique.
  factory JellyfinWsFrame.decode(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return JellyfinWsFrameUnknown(raw: <String, dynamic>{'raw': raw});
      }
      final messageType = json['MessageType'] as String?;
      switch (messageType) {
        case 'KeepAlive':
          return const JellyfinWsFrameKeepAlive();
        case 'ForceKeepAlive':
          final data = json['Data'];
          // ForceKeepAlive transporte un timeout en secondes — c'est un int
          // côté SDK, mais on garde un fallback de 30 s au cas où le serveur
          // omet la valeur.
          final timeoutSeconds = data is int ? data : 30;
          return JellyfinWsFrameForceKeepAlive(timeoutSeconds: timeoutSeconds);
        case 'SyncPlayGroupUpdate':
          final update = _deserializeWith<SyncPlayGroupUpdateMessage>(
            json,
            const FullType(SyncPlayGroupUpdateMessage),
          );
          final inner = update?.data;
          if (inner == null) return JellyfinWsFrameUnknown(raw: json);
          return JellyfinWsFrameSyncPlayGroupUpdate(update: inner);
        case 'SyncPlayCommand':
          final command = _deserializeWith<SyncPlayCommandMessage>(
            json,
            const FullType(SyncPlayCommandMessage),
          );
          final inner = command?.data;
          if (inner == null) return JellyfinWsFrameUnknown(raw: json);
          return JellyfinWsFrameSyncPlayCommand(command: inner);
        default:
          return JellyfinWsFrameUnknown(raw: json);
      }
    } on Object {
      return JellyfinWsFrameUnknown(raw: <String, dynamic>{'raw': raw});
    }
  }

  static T? _deserializeWith<T>(
    Map<String, dynamic> json,
    FullType specifiedType,
  ) {
    try {
      // `built_value` attend un `Iterable<Object?>` alternant clé/valeur, pas
      // une `Map<String, dynamic>`. On aplatit récursivement la structure
      // pour que les payloads imbriqués (`Data`, `Data.Data`) soient eux
      // aussi désérialisables par le SDK.
      final flat = _flatten(json);
      return standardSerializers.deserialize(flat, specifiedType: specifiedType)
          as T?;
    } on Object {
      return null;
    }
  }

  /// Convertit récursivement une représentation JSON parsée en
  /// `Iterable<Object?>` alternant clé/valeur (format `built_value`).
  static Object? _flatten(Object? value) {
    if (value is Map) {
      final out = <Object?>[];
      for (final entry in value.entries) {
        out
          ..add(entry.key)
          ..add(_flatten(entry.value));
      }
      return out;
    }
    if (value is List) {
      return value.map(_flatten).toList();
    }
    return value;
  }
}

/// Frame "KeepAlive" reçu du serveur (rare en pratique : le serveur n'en
/// émet que si le client en envoie un, conformément au protocole).
class JellyfinWsFrameKeepAlive extends JellyfinWsFrame {
  const JellyfinWsFrameKeepAlive();
}

/// Indique au client à quelle fréquence (en secondes) il doit pousser des
/// KeepAlive vers le serveur. Émis périodiquement par Jellyfin.
class JellyfinWsFrameForceKeepAlive extends JellyfinWsFrame {
  const JellyfinWsFrameForceKeepAlive({required this.timeoutSeconds});

  final int timeoutSeconds;
}

/// Mise à jour d'état SyncPlay (StateUpdate, PlayQueue, GroupJoined, etc.).
class JellyfinWsFrameSyncPlayGroupUpdate extends JellyfinWsFrame {
  const JellyfinWsFrameSyncPlayGroupUpdate({required this.update});

  final GroupUpdate update;
}

/// Commande SyncPlay temporisée (Pause/Unpause/Seek/Stop) avec horodatage
/// serveur — c'est cette frame qui pilote la synchro fine côté client.
class JellyfinWsFrameSyncPlayCommand extends JellyfinWsFrame {
  const JellyfinWsFrameSyncPlayCommand({required this.command});

  final SendCommand command;
}

/// Frame non reconnu ou non géré : conservé pour le logging / debug, jamais
/// propagé à la couche métier SyncPlay.
class JellyfinWsFrameUnknown extends JellyfinWsFrame {
  const JellyfinWsFrameUnknown({required this.raw});

  final Map<String, dynamic> raw;
}
