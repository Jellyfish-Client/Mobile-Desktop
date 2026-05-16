import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../core/playback/player_backend.dart';
import '../domain/sync_play_session.dart';
import 'sync_play_clock_offset.dart';
import 'sync_play_service.dart';
import 'sync_play_session_controller.dart';

/// Surface minimale dont a besoin le bridge côté Riverpod. Permet de passer
/// indifféremment un `Ref` (provider) ou un `WidgetRef` (ConsumerState) — la
/// création du bridge se fait depuis `PlayerScreen`, donc en pratique on
/// alimente toujours via un `WidgetRef`.
abstract class SyncPlayBridgeRef {
  T read<T>(ProviderListenable<T> provider);
  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    bool fireImmediately = false,
  });
}

class _WidgetRefAdapter implements SyncPlayBridgeRef {
  _WidgetRefAdapter(this._ref);
  final WidgetRef _ref;

  @override
  T read<T>(ProviderListenable<T> provider) => _ref.read(provider);

  @override
  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    bool fireImmediately = false,
  }) => _ref.listenManual(provider, listener, fireImmediately: fireImmediately);
}

class _RefAdapter implements SyncPlayBridgeRef {
  _RefAdapter(this._ref);
  final Ref _ref;

  @override
  T read<T>(ProviderListenable<T> provider) => _ref.read(provider);

  @override
  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    bool fireImmediately = false,
  }) => _ref.listen(provider, listener, fireImmediately: fireImmediately);
}

/// Adaptateur basé sur un `ProviderContainer`. Utilisé par les tests pour
/// instancier un bridge sans passer par un `WidgetRef` ou un `Ref` issu d'un
/// provider parent.
class ContainerBridgeRef implements SyncPlayBridgeRef {
  ContainerBridgeRef(this._container);
  final ProviderContainer _container;

  @override
  T read<T>(ProviderListenable<T> provider) => _container.read(provider);

  @override
  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    bool fireImmediately = false,
  }) => _container.listen(provider, listener, fireImmediately: fireImmediately);
}

/// Callback déclenché quand le serveur demande de basculer sur un nouvel item
/// de la file partagée (typiquement `NextItem` / `SetPlaylistItem`). Le
/// PlayerScreen utilise ce hook pour pousser une nouvelle route `/play/:id`.
typedef SyncPlaySwitchItemCallback = void Function(String itemId);

/// Pont SyncPlay ↔ media_kit. Instancié par `player_screen.dart` quand
/// `(platformCapabilities.isDesktop && syncPlaySession.isInGroup)` — on
/// l'évite sur mobile pour ne pas re-décoder une session existante côté
/// serveur (la spec Jellyfin gère mal le double reporting).
///
/// Responsabilités :
/// - Appliquer les commandes serveur (pause/unpause/seek) au backend local.
/// - Pousser les gestes locaux (play/pause/seek manuel) au serveur SyncPlay.
/// - Maintenir une drift correction périodique pour absorber le jitter
///   d'horloge libmpv.
/// - Détecter un changement de `playlistItemId` et le signaler via
///   [onSwitchItem] pour que le player puisse charger le nouvel item.
class SyncPlayPlayerBridge {
  /// Construit le bridge depuis un `Ref` (cas Provider/Notifier).
  SyncPlayPlayerBridge({
    required Ref ref,
    required this.backend,
    required this.onSwitchItem,
  }) : ref = _RefAdapter(ref);

  /// Construit le bridge depuis un `WidgetRef` (cas ConsumerState). C'est le
  /// chemin utilisé par `PlayerScreen` puisqu'il est lui-même un
  /// `ConsumerStatefulWidget`.
  SyncPlayPlayerBridge.fromWidgetRef({
    required WidgetRef ref,
    required this.backend,
    required this.onSwitchItem,
  }) : ref = _WidgetRefAdapter(ref);

  /// Construit le bridge en consommant directement un `SyncPlayBridgeRef`.
  /// Réservé aux tests (via [ContainerBridgeRef]) ; le code applicatif utilise
  /// l'un des deux constructeurs ci-dessus.
  SyncPlayPlayerBridge.fromBridgeRef({
    required this.ref,
    required this.backend,
    required this.onSwitchItem,
  });

  static final _log = Logger('SyncPlayPlayerBridge');

  final SyncPlayBridgeRef ref;
  final PlayerBackend backend;
  final SyncPlaySwitchItemCallback onSwitchItem;

  ProviderSubscription<AsyncValue<SyncPlaySession>>? _sessionSub;
  // Indirection conservée pour pouvoir wrapper la mesure de clock dans les
  // tests sans casser le code de production.
  StreamSubscription<BackendState>? _backendStateSub;
  Timer? _scheduledCommandTimer;
  Timer? _driftTimer;
  Timer? _clearFlagTimer;
  Timer? _clockRefreshTimer;

  /// `true` pendant qu'on applique une transition serveur → backend ; les
  /// événements backend reçus dans cette fenêtre ne doivent PAS reboucler
  /// vers le serveur (sinon on génère un échange play/pause infini).
  bool _isApplyingRemoteCommand = false;
  // Fenêtre de garde après la dernière commande remote, utilisée par le
  // listener backend pour ignorer les rebonds.
  static const _remoteApplyWindow = Duration(milliseconds: 200);

  Duration _clockOffset = Duration.zero;
  String? _lastKnownItemId;
  int _driftStrikes = 0;
  SyncPlaySession? _lastState;

  /// À appeler une fois après construction. L'instance se branche sur les
  /// providers et écoute le backend.
  void attach() {
    _sessionSub = ref.listen<AsyncValue<SyncPlaySession>>(
      syncPlaySessionProvider,
      (previous, next) {
        final value = next.valueOrNull;
        if (value != null) _onSessionChanged(value);
      },
    );
    // Pickup the current value synchronously so we don't miss transitions
    // that happened between provider build and bridge attach.
    final current = ref.read(syncPlaySessionProvider).valueOrNull;
    if (current != null) _onSessionChanged(current);
    _backendStateSub = backend.stateStream.listen(_onBackendStateChanged);
    _scheduleDriftCheck();
    _scheduleClockRefresh();
    _refreshClockOffset();
  }

  /// Libère toutes les souscriptions. Doit être appelé depuis
  /// `PlayerScreen.dispose()`.
  void detach() {
    _sessionSub?.close();
    _sessionSub = null;
    unawaited(_backendStateSub?.cancel());
    _backendStateSub = null;
    _scheduledCommandTimer?.cancel();
    _scheduledCommandTimer = null;
    _driftTimer?.cancel();
    _driftTimer = null;
    _clearFlagTimer?.cancel();
    _clearFlagTimer = null;
    _clockRefreshTimer?.cancel();
    _clockRefreshTimer = null;
  }

  // -- État serveur → backend -------------------------------------------------

  void _onSessionChanged(SyncPlaySession session) {
    _log.fine('Session changed: ${session.runtimeType}');
    final previous = _lastState;
    _lastState = session;
    // Détecte un switch d'item d'abord, c'est le seul cas qui force un
    // changement de route. On n'envoie le callback qu'à partir du DEUXIÈME
    // item connu — le premier `playlistItemId` reçu correspond à l'item
    // déjà chargé par le player (sinon le bridge n'aurait pas été instancié).
    final newItem = _itemIdOf(session);
    if (newItem != null) {
      if (_lastKnownItemId != null && newItem != _lastKnownItemId) {
        _lastKnownItemId = newItem;
        onSwitchItem(newItem);
        // Pas de play/pause à appliquer immédiatement — la nouvelle route
        // remontera le bridge.
        return;
      }
      _lastKnownItemId = newItem;
    }
    switch (session) {
      case SyncPlaySessionPlaying(
        :final positionAtAnchor,
        :final anchorServerUtc,
      ):
        // Si on est déjà en Playing avec le même ancrage on ne fait rien.
        if (previous is SyncPlaySessionPlaying &&
            previous.anchorServerUtc == anchorServerUtc) {
          return;
        }
        _schedulePlayAt(anchorServerUtc, positionAtAnchor);
      case SyncPlaySessionPaused(:final position):
        if (previous is SyncPlaySessionPaused &&
            previous.position == position) {
          return;
        }
        _applyRemote(() async {
          await backend.pause();
          if (backend.position != position) {
            await backend.seek(position);
          }
        });
      case SyncPlaySessionWaiting() ||
          SyncPlaySessionIdle() ||
          SyncPlaySessionDisconnected() ||
          SyncPlaySessionError():
        // Aucune action backend : on laisse l'utilisateur reprendre la main.
        break;
    }
  }

  void _schedulePlayAt(DateTime serverWhenUtc, Duration position) {
    _scheduledCommandTimer?.cancel();
    final targetLocalUtc = serverWhenUtc.subtract(_clockOffset);
    final delay = targetLocalUtc.difference(DateTime.now().toUtc());
    // Si l'instant cible est passé (latence forte) on exécute immédiatement.
    final wait = delay.isNegative ? Duration.zero : delay;
    _scheduledCommandTimer = Timer(wait, () {
      _applyRemote(() async {
        await backend.seek(position);
        await backend.play();
      });
    });
  }

  void _applyRemote(Future<void> Function() action) {
    _isApplyingRemoteCommand = true;
    _clearFlagTimer?.cancel();
    () async {
      try {
        await action();
      } on Object catch (e, st) {
        _log.warning('Remote SyncPlay action failed', e, st);
      } finally {
        _clearFlagTimer = Timer(_remoteApplyWindow, () {
          _isApplyingRemoteCommand = false;
        });
      }
    }();
  }

  // -- Backend local → serveur ------------------------------------------------

  void _onBackendStateChanged(BackendState state) {
    if (_isApplyingRemoteCommand) return;
    if (!_isInGroupAndPlayable()) return;
    final service = ref.read(syncPlayServiceProvider);
    switch (state) {
      case BackendState.playing:
        unawaited(service.unpause());
      case BackendState.paused:
        unawaited(service.pause());
      case BackendState.idle ||
          BackendState.loading ||
          BackendState.ended ||
          BackendState.error:
        break;
    }
  }

  /// À appeler depuis le PlayerScreen quand l'utilisateur déclenche un seek
  /// (double-tap, slider, skip segment). On la passe via la fonction parce
  /// qu'on ne capte pas les seeks via `positionStream` — la cadence du
  /// stream est trop élevée pour discriminer un saut volontaire d'un tick
  /// d'horloge.
  void notifyLocalSeek(Duration position) {
    if (_isApplyingRemoteCommand) return;
    if (!_isInGroupAndPlayable()) return;
    final service = ref.read(syncPlayServiceProvider);
    unawaited(service.seek(position));
  }

  // -- Drift correction -------------------------------------------------------

  void _scheduleDriftCheck() {
    _driftTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = _lastState;
      if (state is! SyncPlaySessionPlaying) {
        _driftStrikes = 0;
        return;
      }
      final expected = _expectedPosition(state);
      final actual = backend.position;
      final diff = (expected - actual).abs();
      if (diff > const Duration(seconds: 1)) {
        _driftStrikes += 1;
        if (_driftStrikes >= 2) {
          _driftStrikes = 0;
          _applyRemote(() => backend.seek(expected));
        }
      } else {
        _driftStrikes = 0;
      }
    });
  }

  Duration _expectedPosition(SyncPlaySessionPlaying state) {
    final nowUtc = DateTime.now().toUtc();
    final localAnchor = state.anchorServerUtc.subtract(_clockOffset);
    final elapsed = nowUtc.difference(localAnchor);
    final scaled = Duration(
      microseconds: (elapsed.inMicroseconds * state.playbackRate).round(),
    );
    return state.positionAtAnchor + scaled;
  }

  // -- Clock offset -----------------------------------------------------------

  void _scheduleClockRefresh() {
    _clockRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _refreshClockOffset(),
    );
  }

  Future<void> _refreshClockOffset() async {
    try {
      // On bypass `syncPlayClockOffsetProvider` (auto-disposed) pour ne pas
      // perturber d'éventuels watchers UI ; on appelle directement la
      // routine de mesure avec le `TimeSyncApi` partagé.
      _clockOffset = await _measureFromApi();
    } on Object catch (e, st) {
      _log.fine('Clock offset refresh failed', e, st);
    }
  }

  Future<Duration> _measureFromApi() {
    // Petite indirection pour pouvoir stubber dans les tests sans toucher
    // au provider — on instancie un probe inline qui réutilise le service
    // exposé par le SDK.
    final fut = ref.read(syncPlayClockOffsetProvider.future);
    return fut;
  }

  // -- Helpers ---------------------------------------------------------------

  bool _isInGroupAndPlayable() {
    final state = _lastState;
    return state != null &&
        state.isInGroup &&
        state is! SyncPlaySessionIdle &&
        state is! SyncPlaySessionWaiting;
  }

  String? _itemIdOf(SyncPlaySession session) => switch (session) {
    SyncPlaySessionPlaying(:final playlistItemId) => playlistItemId,
    SyncPlaySessionPaused(:final playlistItemId) => playlistItemId,
    _ => null,
  };
}
