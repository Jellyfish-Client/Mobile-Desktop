import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'jellyfin_ws_frame.dart';

/// Fabrique de canal WebSocket — injectable pour les tests via un fake
/// `StreamChannelController`. La signature accepte une URL telle que reçue par
/// [JellyfinWebSocket] (déjà signée avec `api_key`/`deviceId`) et retourne un
/// canal full-duplex que la pompe peut écouter et alimenter.
typedef JellyfinWebSocketChannelFactory =
    StreamChannel<dynamic> Function(Uri url);

StreamChannel<dynamic> _defaultChannelFactory(Uri url) =>
    WebSocketChannel.connect(url);

/// Service singleton géré par `jellyfinWebSocketProvider`. Maintient une
/// connexion WS persistante vers `/socket` tant qu'une session active existe ;
/// gère un keep-alive applicatif et un reconnect exponentiel. Le canal expose
/// un broadcast stream de [JellyfinWsFrame] consommé par n'importe quelle
/// feature qui veut écouter des events serveur (SyncPlay aujourd'hui ;
/// LibraryChanged, UserDataChanged demain).
///
/// IMPORTANT : ce service NE déclenche PAS de reconnect tant que
/// [start] n'a pas été appelé, et un [stop] explicite empêche définitivement
/// toute nouvelle tentative. La pompe Riverpod orchestre ces appels en
/// fonction de la session active.
class JellyfinWebSocket {
  JellyfinWebSocket({
    required String accessToken,
    required String deviceId,
    required String serverUrl,
    JellyfinWebSocketChannelFactory channelFactory = _defaultChannelFactory,
  }) : _accessToken = accessToken,
       _deviceId = deviceId,
       _serverUrl = serverUrl,
       _channelFactory = channelFactory;

  static final _log = Logger('JellyfinWebSocket');

  final String _accessToken;
  final String _deviceId;
  final String _serverUrl;
  final JellyfinWebSocketChannelFactory _channelFactory;

  final StreamController<JellyfinWsFrame> _framesController =
      StreamController<JellyfinWsFrame>.broadcast();

  StreamChannel<dynamic>? _channel;
  // Cancelled via [_closeChannel] — the analyzer can't follow the indirection.
  // ignore: cancel_subscriptions
  StreamSubscription<dynamic>? _channelSub;
  Timer? _keepAliveTimer;
  Timer? _reconnectTimer;
  Duration _keepAliveInterval = const Duration(seconds: 30);
  int _reconnectAttempt = 0;
  bool _started = false;
  bool _disposed = false;
  bool _intentionalClose = false;
  bool _connected = false;

  /// Stream broadcast des frames décodées. Plusieurs consommateurs peuvent
  /// s'y abonner (SyncPlay, futurs handlers d'events serveur).
  Stream<JellyfinWsFrame> get frames => _framesController.stream;

  /// True quand le socket est ouvert et prêt à recevoir / émettre.
  bool get isConnected => _connected;

  /// Démarre la connexion. Idempotent — un second appel est un no-op.
  void start() {
    if (_disposed || _started) return;
    _started = true;
    _intentionalClose = false;
    _connect();
  }

  /// Ferme proprement le socket et empêche tout reconnect ultérieur.
  Future<void> stop() async {
    _intentionalClose = true;
    _started = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    await _closeChannel();
    _connected = false;
  }

  /// Libère toutes les ressources. Après [dispose], l'instance ne peut plus
  /// être redémarrée.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    await _framesController.close();
  }

  /// Envoie un message texte brut au serveur. Silencieusement no-op si le
  /// canal n'est pas connecté — les commandes SyncPlay passent par HTTP, ce
  /// hook est réservé aux KeepAlive et à de futurs use-cases.
  void sendRaw(String message) {
    final channel = _channel;
    if (channel == null || !_connected) return;
    try {
      channel.sink.add(message);
    } on Object catch (e) {
      _log.fine('sendRaw failed: $e');
    }
  }

  Uri _buildUri() {
    final base = Uri.parse(_serverUrl);
    final isSecure = base.scheme == 'https';
    return base.replace(
      scheme: isSecure ? 'wss' : 'ws',
      path: '${base.path.endsWith('/') ? base.path : '${base.path}/'}socket',
      queryParameters: <String, String>{
        'api_key': _accessToken,
        'deviceId': _deviceId,
      },
    );
  }

  void _connect() {
    if (_disposed || !_started) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final url = _buildUri();
    _log.fine('Connecting to $url');
    try {
      _channel = _channelFactory(url);
    } on Object catch (e, st) {
      _log.warning('Channel construction failed: $e', e, st);
      _scheduleReconnect();
      return;
    }

    _connected = true;
    _reconnectAttempt = 0;
    _scheduleKeepAlive(_keepAliveInterval);

    _channelSub = _channel!.stream.listen(
      _onMessage,
      onError: _onChannelError,
      onDone: _onChannelDone,
      cancelOnError: false,
    );
  }

  void _onMessage(dynamic message) {
    final text = switch (message) {
      final String s => s,
      final List<int> bytes => utf8.decode(bytes, allowMalformed: true),
      _ => message.toString(),
    };
    final frame = JellyfinWsFrame.decode(text);
    // ForceKeepAlive change la cadence du keep-alive applicatif. On l'observe
    // ici plutôt que dans la feature SyncPlay, car c'est purement transport.
    if (frame is JellyfinWsFrameForceKeepAlive) {
      final newInterval = Duration(seconds: frame.timeoutSeconds);
      if (newInterval != _keepAliveInterval) {
        _keepAliveInterval = newInterval;
        _scheduleKeepAlive(_keepAliveInterval);
      }
    }
    _framesController.add(frame);
  }

  void _onChannelError(Object error, StackTrace st) {
    _log.warning('WebSocket error: $error', error, st);
    _connected = false;
    _scheduleReconnect();
  }

  void _onChannelDone() {
    _connected = false;
    _keepAliveTimer?.cancel();
    if (_intentionalClose || _disposed || !_started) return;
    _log.fine('WebSocket closed by peer, scheduling reconnect');
    _scheduleReconnect();
  }

  Future<void> _closeChannel() async {
    final sub = _channelSub;
    _channelSub = null;
    await sub?.cancel();
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      try {
        // Fire-and-forget : `WebSocketChannel.sink.close()` peut ne JAMAIS
        // résoudre quand le peer a déjà coupé la connexion (le close handshake
        // attend un `Close` qui n'arrive jamais). On capture le futur dans un
        // unawaited pour ne pas bloquer le dispose, mais on garde le try/catch
        // pour éviter de propager une éventuelle erreur synchrone.
        unawaited(channel.sink.close());
      } on Object {
        // Best effort — un close pendant un error est attendu.
      }
    }
  }

  void _scheduleKeepAlive(Duration interval) {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(interval, (_) {
      // Format documenté côté Jellyfin : payload minimaliste avec uniquement
      // `MessageType`. Pas d'`OutboundKeepAliveMessage` complet pour éviter de
      // se trimballer un faux MessageId.
      sendRaw('{"MessageType":"KeepAlive"}');
    });
  }

  void _scheduleReconnect() {
    if (_disposed || _intentionalClose || !_started) return;
    _keepAliveTimer?.cancel();
    // Backoff exponentiel borné : 1 → 2 → 4 → 8 → 16 → 30 s. On reset
    // `_reconnectAttempt` après chaque connexion réussie (cf. [_connect]).
    final attempts = _reconnectAttempt.clamp(0, 5);
    final secs = attempts >= 5 ? 30 : (1 << attempts);
    _reconnectAttempt = attempts + 1;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: secs), () async {
      await _closeChannel();
      _connect();
    });
  }
}
