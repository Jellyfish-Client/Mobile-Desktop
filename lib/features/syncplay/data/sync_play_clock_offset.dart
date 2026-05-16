import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Round-trip de mesure : `serverUtc` est le `ResponseTransmissionTime` lu sur
/// la réponse Jellyfin (instant serveur le plus tardif), `sentUtc` et
/// `receivedUtc` sont les bornes client.
typedef ClockOffsetSample = ({
  DateTime serverUtc,
  DateTime sentUtc,
  DateTime receivedUtc,
});

/// Sondeur injectable pour les tests. Le provider concret bind cette
/// fonction sur `TimeSyncApi.getUtcTime`.
typedef ClockOffsetProbe = Future<ClockOffsetSample> Function();

/// Décalage estimé entre l'horloge serveur et l'horloge client
/// (`serverUtc - clientUtc`). Utilisé par le bridge player pour exécuter une
/// commande SyncPlay à `when` (instant serveur) en planifiant un timer local
/// sur `when - offset`.
///
/// Méthode : on appelle `GetUtcTime` plusieurs fois, on enregistre le RTT de
/// chaque appel, et on garde la mesure de plus faible RTT (donc la moins
/// polluée par la jitter réseau). Formule équivalente à un ping NTP basique :
///
/// ```text
/// offset = serverReception - midpoint(t0_client, t1_client)
/// ```
///
/// Ce provider auto-refresh n'est PAS branché — c'est aux consumers
/// (`SyncPlayPlayerBridge`) d'invalider toutes les 5 min via leur propre
/// timer, pour éviter de tirer un appel HTTP en arrière-plan tant que
/// personne ne s'y abonne.
final syncPlayClockOffsetProvider = FutureProvider.autoDispose<Duration>((
  ref,
) async {
  final api = ref.watch(jellyfinApiProvider).getTimeSyncApi();
  return measureClockOffset(probe: () => _probeServer(api));
});

Future<ClockOffsetSample> _probeServer(TimeSyncApi api) async {
  final sent = DateTime.now().toUtc();
  final res = await api.getUtcTime();
  final received = DateTime.now().toUtc();
  // Jellyfin renvoie deux timestamps : `RequestReceptionTime` (entrée
  // serveur) et `ResponseTransmissionTime` (sortie serveur). On prend leur
  // milieu pour absorber le temps de traitement serveur côté mesure.
  final body = res.data;
  if (body == null) {
    throw StateError('TimeSync: empty response');
  }
  final serverIn = body.requestReceptionTime ?? sent;
  final serverOut = body.responseTransmissionTime ?? received;
  final serverMid = serverIn.add(
    Duration(microseconds: serverOut.difference(serverIn).inMicroseconds ~/ 2),
  );
  return (serverUtc: serverMid, sentUtc: sent, receivedUtc: received);
}

/// Effectue [samples] round-trips puis sélectionne la mesure de plus faible
/// RTT pour calculer le décalage. Visible pour les tests.
Future<Duration> measureClockOffset({
  required ClockOffsetProbe probe,
  int samples = 5,
}) async {
  Duration? bestOffset;
  Duration? bestRtt;
  for (var i = 0; i < samples; i++) {
    try {
      final result = await probe();
      final rtt = result.receivedUtc.difference(result.sentUtc);
      // Offset = serverReception - midpoint(client). Une horloge client en
      // retard de 200 ms donne un offset positif de +200 ms.
      final midpoint = result.sentUtc.add(
        Duration(microseconds: rtt.inMicroseconds ~/ 2),
      );
      final offset = result.serverUtc.difference(midpoint);
      if (bestRtt == null || rtt < bestRtt) {
        bestRtt = rtt;
        bestOffset = offset;
      }
    } on Object {
      // On ignore les échecs individuels — un seul succès suffit pour
      // produire une estimation.
      continue;
    }
  }
  return bestOffset ?? Duration.zero;
}
