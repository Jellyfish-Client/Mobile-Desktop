import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../jellyfin/models/jellyfin_item.dart';
import '../playback/playback_reporting_service.dart';
import 'cast_device.dart';
import 'cast_player_backend.dart';
import 'cast_service.dart';
import 'cast_session_state.dart';

/// Singleton long-lived. Survit à toutes les navigations — la session Cast
/// peut persister au-delà de l'écran qui l'a déclenchée.
final castServiceProvider = Provider<CastService>((ref) {
  final svc = CastService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// Init best-effort déclenché au boot par `main.dart`. N'échoue jamais
/// fatalement — si le SDK natif ne peut pas s'initialiser (Play Services
/// manquants, plateforme non supportée), la feature Cast est simplement
/// désactivée.
final castInitProvider = FutureProvider<void>((ref) async {
  await ref.read(castServiceProvider).ensureInitialized();
});

/// Stream des appareils visibles. Démarre/arrête le discovery via le cycle
/// de vie du provider : si plus aucun écran ne le watch, on coupe pour
/// économiser la batterie et le réseau mDNS.
final castDevicesProvider = StreamProvider.autoDispose<List<CastDevice>>((ref) {
  final svc = ref.watch(castServiceProvider)..startDiscovery();
  ref.onDispose(svc.stopDiscovery);
  return svc.devicesStream;
});

/// État courant de la session. **Non autoDispose** : doit survivre au
/// PlayerScreen pour permettre au mini-player de continuer à afficher la
/// lecture après navigation.
///
/// Le `StreamController.broadcast` sous-jacent n'émet rien à la première
/// subscription → les consumers flasheraient `AsyncLoading` pendant quelques
/// frames même quand une session est déjà active.
/// Fix : on préfixe le stream natif par un `Stream.value` du snapshot courant
/// grâce à [_replayThenFollow], de sorte que le premier événement arrive
/// synchroniquement. `distinct()` évite un doublon si le stream sous-jacent
/// ré-émet la même valeur immédiatement (rendu possible par l'implémentation
/// de `==` dans [CastSessionSnapshot]).
final castSessionProvider = StreamProvider<CastSessionSnapshot>((ref) {
  final svc = ref.watch(castServiceProvider);
  return _replayThenFollow(svc.currentSnapshot, svc.sessionStream).distinct();
});

/// Crée un stream qui émet [seed] immédiatement, puis tous les événements de
/// [tail]. Équivalent à `BehaviorSubject` de rxdart mais sans dépendance.
Stream<T> _replayThenFollow<T>(T seed, Stream<T> tail) async* {
  yield seed;
  yield* tail;
}

/// Booléen pratique pour l'UI ("cast_connected" vs "cast" sur le bouton).
final isCastConnectedProvider = Provider<bool>((ref) {
  final snapshot = ref.watch(castSessionProvider).valueOrNull;
  if (snapshot != null) return snapshot.isConnected;
  // Fallback synchrone : la première frame avant que le stream émette.
  return ref.watch(castServiceProvider).currentSnapshot.isConnected;
});

/// Indique si le SDK Cast est utilisable. Faux sur émulateurs sans Play
/// Services, sur plateformes desktop, ou si l'init a échoué. Les widgets
/// Cast s'effacent visuellement quand ce provider est faux.
final castSupportedProvider = Provider<bool>((ref) {
  return ref.watch(castServiceProvider).isSupported;
});

/// Métadonnées de la lecture Cast active. Détenu par [CastNowPlayingNotifier]
/// qui fait l'aller-retour avec le receiver.
@immutable
class CastNowPlaying {
  const CastNowPlaying({
    required this.item,
    required this.backend,
    required this.session,
    this.reporting,
  });
  final JellyfinItem item;
  final CastPlayerBackend backend;
  final Session session;

  /// Reporte `/Sessions/Playing*` côté serveur Jellyfin. Avec le Default
  /// Media Receiver, c'est l'app qui doit le faire (le receiver générique
  /// ne connaît pas Jellyfin).
  final PlaybackReportingService? reporting;
}

/// Conserve l'item Cast en cours, son backend et son reporting. Stoppe le
/// reporting et dispose le backend quand on remplace l'état (changement de
/// média ou fin de session).
class CastNowPlayingNotifier extends StateNotifier<CastNowPlaying?> {
  CastNowPlayingNotifier() : super(null);

  Future<void> set(CastNowPlaying? next) async {
    final previous = state;
    state = next;
    if (previous != null && previous.backend != next?.backend) {
      await previous.reporting?.stop();
      await previous.backend.dispose();
    }
  }

  @override
  void dispose() {
    final s = state;
    if (s != null) {
      // Best-effort cleanup. We can't await in dispose, so we let these
      // futures run; they're idempotent and short.
      s.reporting?.stop();
      s.backend.dispose();
    }
    super.dispose();
  }
}

final castNowPlayingProvider =
    StateNotifierProvider<CastNowPlayingNotifier, CastNowPlaying?>((ref) {
  return CastNowPlayingNotifier();
});

/// Backend Cast actif (ou null). Pratique pour l'écran Now Playing et le
/// mini-player.
final castBackendProvider = Provider<CastPlayerBackend?>((ref) {
  return ref.watch(castNowPlayingProvider)?.backend;
});
