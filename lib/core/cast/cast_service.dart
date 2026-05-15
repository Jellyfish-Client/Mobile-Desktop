import 'dart:async';
import 'dart:io';

import 'package:flutter_chrome_cast/cast_context.dart';
import 'package:flutter_chrome_cast/discovery.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:flutter_chrome_cast/enums.dart';
import 'package:flutter_chrome_cast/models.dart';
import 'package:flutter_chrome_cast/session.dart';
import 'package:logging/logging.dart';

import 'cast_app_id.dart';
import 'cast_device.dart';
import 'cast_session_state.dart';

/// Façade au-dessus de `flutter_chrome_cast`. Gère l'initialisation du SDK,
/// le discovery des appareils et le cycle de vie des sessions.
///
/// Les opérations media (loadMedia, contrôle de lecture) sont déléguées au
/// CastPlayerBackend qui parle directement au RemoteMediaClient natif.
class CastService {
  CastService();

  static final _log = Logger('CastService');

  bool _supported = false;
  bool _initializeCalled = false;

  StreamSubscription<GoogleCastSession?>? _sessionSub;
  final _sessionController =
      StreamController<CastSessionSnapshot>.broadcast();

  CastSessionSnapshot _snapshot = CastSessionSnapshot.idle;

  /// True ssi le SDK Cast est utilisable sur la plateforme courante.
  bool get isSupported => _supported;

  CastSessionSnapshot get currentSnapshot => _snapshot;

  Stream<CastSessionSnapshot> get sessionStream => _sessionController.stream;

  Stream<List<CastDevice>> get devicesStream {
    if (!_supported) return const Stream.empty();
    return GoogleCastDiscoveryManager.instance.devicesStream.map(
      (devices) => devices.map(CastDevice.fromGoogle).toList(growable: false),
    );
  }

  /// Init idempotent du SDK. Best-effort : un échec côté natif (Play
  /// Services absents, etc.) n'empêche pas l'app de démarrer.
  Future<void> ensureInitialized() async {
    if (_initializeCalled) return;
    _initializeCalled = true;

    if (!(Platform.isIOS || Platform.isAndroid)) {
      _log.info('Cast non supporté sur ${Platform.operatingSystem}');
      return;
    }

    try {
      final options = Platform.isIOS
          ? IOSGoogleCastOptions(
              GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(
                kCastReceiverAppId,
              ),
            ) as GoogleCastOptions
          : GoogleCastOptionsAndroid(appId: kCastReceiverAppId);

      await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
      _supported = true;

      _sessionSub = GoogleCastSessionManager.instance.currentSessionStream
          .listen(_onSession, onError: _onSessionError);

      _log.info('Cast SDK initialisé (appId=$kCastReceiverAppId)');
    } on Object catch (e, st) {
      _log.warning('Init Cast SDK échouée — feature désactivée', e, st);
      _supported = false;
    }
  }

  Future<void> startDiscovery() async {
    if (!_supported) return;
    try {
      await GoogleCastDiscoveryManager.instance.startDiscovery();
    } on Object catch (e, st) {
      _log.warning('startDiscovery a échoué', e, st);
    }
  }

  Future<void> stopDiscovery() async {
    if (!_supported) return;
    try {
      await GoogleCastDiscoveryManager.instance.stopDiscovery();
    } on Object catch (e, st) {
      _log.warning('stopDiscovery a échoué', e, st);
    }
  }

  Future<List<GoogleCastDevice>> _peekDevices() async {
    return GoogleCastDiscoveryManager.instance.devicesStream.first
        .timeout(const Duration(seconds: 1), onTimeout: () => const []);
  }

  /// Démarre une session Cast vers [deviceId]. Met à jour [sessionStream] avec
  /// les transitions `connecting → connected` (ou `error`).
  Future<bool> connectTo(String deviceId) async {
    if (!_supported) return false;
    final devices = await _peekDevices();
    final match = devices.firstWhere(
      (d) => d.deviceID == deviceId,
      orElse: () => throw StateError('Cast device $deviceId not found'),
    );

    _emit(
      _snapshot.copyWith(
        status: CastConnectionStatus.connecting,
        device: CastDevice.fromGoogle(match),
      ),
    );

    try {
      final ok = await GoogleCastSessionManager.instance
          .startSessionWithDevice(match);
      if (!ok) {
        _emit(
          const CastSessionSnapshot(
            status: CastConnectionStatus.error,
            errorMessage: 'startSessionWithDevice returned false',
          ),
        );
      }
      return ok;
    } on Object catch (e, st) {
      _log.warning('connectTo($deviceId) a échoué', e, st);
      _emit(
        CastSessionSnapshot(
          status: CastConnectionStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Termine la session active. Si [stopReceiver] = true, le receiver
  /// Jellyfin est aussi arrêté côté TV.
  Future<void> disconnect({bool stopReceiver = true}) async {
    if (!_supported) return;
    _emit(_snapshot.copyWith(status: CastConnectionStatus.disconnecting));
    try {
      if (stopReceiver) {
        await GoogleCastSessionManager.instance.endSessionAndStopCasting();
      } else {
        await GoogleCastSessionManager.instance.endSession();
      }
    } on Object catch (e, st) {
      _log.warning('disconnect a échoué', e, st);
    }
  }

  void _onSession(GoogleCastSession? session) {
    if (session == null) {
      _emit(CastSessionSnapshot.idle);
      return;
    }
    final googleDevice = session.device;
    final device = googleDevice == null
        ? _snapshot.device
        : CastDevice.fromGoogle(googleDevice);
    _emit(
      CastSessionSnapshot(
        status: _mapStatus(session.connectionState),
        device: device,
      ),
    );
  }

  void _onSessionError(Object e, StackTrace st) {
    _log.warning('Session stream error', e, st);
    _emit(
      CastSessionSnapshot(
        status: CastConnectionStatus.error,
        errorMessage: e.toString(),
      ),
    );
  }

  CastConnectionStatus _mapStatus(GoogleCastConnectState state) {
    switch (state) {
      case GoogleCastConnectState.connecting:
        return CastConnectionStatus.connecting;
      case GoogleCastConnectState.connected:
        return CastConnectionStatus.connected;
      case GoogleCastConnectState.disconnecting:
        return CastConnectionStatus.disconnecting;
      case GoogleCastConnectState.disconnected:
        return CastConnectionStatus.idle;
    }
  }

  void _emit(CastSessionSnapshot s) {
    if (s == _snapshot) return;
    _snapshot = s;
    if (!_sessionController.isClosed) {
      _sessionController.add(s);
    }
  }

  Future<void> dispose() async {
    await _sessionSub?.cancel();
    await _sessionController.close();
  }
}
