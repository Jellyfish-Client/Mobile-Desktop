import 'dart:async';

import 'package:flutter_chrome_cast/lib.dart';
import 'package:jellyfin_api/jellyfin_api.dart' as jf;
import 'package:logging/logging.dart';

import '../auth/session.dart';
import '../jellyfin/jellyfin_client.dart';
import '../jellyfin/models/jellyfin_item.dart';
import '../playback/media_source_resolver.dart';
import '../playback/player_backend.dart';
import 'cast_device_profile.dart';

/// PlayerBackend qui pilote un Chromecast via `flutter_chrome_cast`.
///
/// L'interface est volontairement la même que `MediaKitPlayerBackend` pour
/// que `PlayerScreen`, `JellyfishAudioHandler` et le sélecteur audio/sub
/// continuent à fonctionner sans branche conditionnelle.
///
/// On cible le Default Media Receiver de Google : on lui envoie une URL
/// HTTP/HTTPS prête à lire, sans payload custom. Cela impose de résoudre
/// l'URL côté Flutter (via `getPostedPlaybackInfo` + DeviceProfile
/// Chromecast) avant de construire ce backend.
class CastPlayerBackend implements PlayerBackend {
  CastPlayerBackend({
    required this.client,
    required this.item,
    required this.session,
    required this.posterUrl,
    required jf.PlaybackInfoResponse initialInfo,
    int? initialAudioStreamIndex,
    int? initialSubtitleStreamIndex,
  }) {
    _info = initialInfo;
    _resolveSource();
    _populateTracksFromInfo();
    _currentAudioIndex = initialAudioStreamIndex ?? _defaultAudioIndex();
    _currentSubtitleIndex = initialSubtitleStreamIndex ?? -1;
    _wireStreams();
  }

  static final _log = Logger('CastPlayerBackend');

  final JellyfinClient client;
  final JellyfinItem item;
  final Session session;
  final String? posterUrl;

  late jf.PlaybackInfoResponse _info;
  late ResolvedMediaSource _source;

  /// Source HLS/Direct résolue contre le serveur Jellyfin avec le
  /// DeviceProfile Chromecast. Recalculée à chaque switch audio/sub.
  ResolvedMediaSource get source => _source;

  final StreamController<BackendState> _stateController =
      StreamController<BackendState>.broadcast();
  final StreamController<bool> _completedController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _bufferingController =
      StreamController<bool>.broadcast();

  final List<StreamSubscription<Object?>> _subs = [];

  BackendState _state = BackendState.idle;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isBuffering = false;

  // Tracks Jellyfin extraits de mediaSources.mediaStreams. Les indices sont
  // les indices Jellyfin (à passer comme audioStreamIndex/subtitleStreamIndex
  // à `getPostedPlaybackInfo`).
  List<SubtitleTrackInfo> _subtitleTracks = const [];
  List<AudioTrackInfo> _audioTracks = const [];
  int _currentSubtitleIndex = -1;
  int _currentAudioIndex = -1;

  // ----- PlayerBackend interface -----

  @override
  Stream<BackendState> get stateStream => _stateController.stream;

  @override
  Stream<bool> get completedStream => _completedController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Stream<Duration> get positionStream =>
      GoogleCastRemoteMediaClient.instance.playerPositionStream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Stream<bool> get bufferingStream => _bufferingController.stream;

  /// Le Default Media Receiver n'expose pas de buffer ahead exploitable :
  /// on émet une valeur unique zéro plutôt qu'une donnée fausse. La barre de
  /// buffer du lockscreen reste alors collée au play head, ce qui est le
  /// comportement attendu pour un flux distant piloté par le receiver.
  @override
  Stream<Duration> get bufferedPositionStream =>
      Stream<Duration>.value(Duration.zero);

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  bool get isPlaying => _state == BackendState.playing;

  @override
  bool get isBuffering => _isBuffering;

  @override
  BackendState get state => _state;

  @override
  List<SubtitleTrackInfo> get subtitleTracks => _subtitleTracks;

  @override
  List<AudioTrackInfo> get audioTracks => _audioTracks;

  @override
  int get currentSubtitleIndex => _currentSubtitleIndex;

  @override
  int get currentAudioIndex => _currentAudioIndex;

  @override
  Object? get videoController => null;

  // ----- Wiring -----

  void _wireStreams() {
    final castClient = GoogleCastRemoteMediaClient.instance;
    _subs
      ..add(castClient.mediaStatusStream.listen(_onMediaStatus))
      ..add(castClient.playerPositionStream.listen((p) => _position = p));
  }

  void _onMediaStatus(GoggleCastMediaStatus? status) {
    if (status == null) {
      _setState(BackendState.idle);
      return;
    }

    // Duration → si connue côté receiver, l'utiliser, sinon garder celle
    // qu'on a déjà déduite de item.runTimeTicks.
    final reportedDuration = status.mediaInformation?.duration;
    if (reportedDuration != null && reportedDuration != _duration) {
      _duration = reportedDuration;
      _durationController.add(_duration);
    }

    // State + buffering mapping. Les tracks sont gérées côté Jellyfin (pas
    // par le receiver Default), donc on ignore status.activeTrackIds.
    final wasBuffering = _isBuffering;
    _isBuffering = status.playerState == CastMediaPlayerState.buffering ||
        status.playerState == CastMediaPlayerState.loading;
    if (wasBuffering != _isBuffering) {
      _bufferingController.add(_isBuffering);
    }

    switch (status.playerState) {
      case CastMediaPlayerState.playing:
        _setState(BackendState.playing);
      case CastMediaPlayerState.paused:
        _setState(BackendState.paused);
      case CastMediaPlayerState.buffering:
      case CastMediaPlayerState.loading:
        _setState(BackendState.loading);
      case CastMediaPlayerState.idle:
        _handleIdle(status.idleReason);
      case CastMediaPlayerState.unknown:
        break;
    }
  }

  void _handleIdle(GoogleCastMediaIdleReason? reason) {
    switch (reason) {
      case GoogleCastMediaIdleReason.finished:
        _setState(BackendState.ended);
        _completedController.add(true);
      case GoogleCastMediaIdleReason.error:
        _setState(BackendState.error);
        _errorController.add('Cast receiver reported playback error');
      case GoogleCastMediaIdleReason.cancelled:
      case GoogleCastMediaIdleReason.interrupted:
      case GoogleCastMediaIdleReason.none:
      case null:
        _setState(BackendState.idle);
    }
  }

  void _setState(BackendState s) {
    if (_state == s) return;
    _state = s;
    _stateController.add(s);
  }

  // ----- PlayerBackend methods -----

  /// Charge le média sur le receiver. Le paramètre `url` est ignoré (l'URL
  /// définitive est déjà dans `_source.streamUrl` calculé au constructeur)
  /// — il n'est conservé que pour respecter le contrat [PlayerBackend].
  @override
  Future<void> open(String url, {Duration startPosition = Duration.zero}) async {
    _setState(BackendState.loading);
    try {
      await GoogleCastRemoteMediaClient.instance.loadMedia(
        _buildMediaInformation(),
        playPosition: startPosition,
      );
    } on Object catch (e, st) {
      _log.warning('loadMedia a échoué', e, st);
      _setState(BackendState.error);
      _errorController.add(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> play() => GoogleCastRemoteMediaClient.instance.play();

  @override
  Future<void> pause() => GoogleCastRemoteMediaClient.instance.pause();

  @override
  Future<void> seek(Duration position) {
    return GoogleCastRemoteMediaClient.instance.seek(
      GoogleCastMediaSeekOption(position: position),
    );
  }

  @override
  Future<void> setSpeed(double rate) =>
      GoogleCastRemoteMediaClient.instance.setPlaybackRate(rate);

  /// Change la piste sous-titre en cours de lecture. Avec le Default Media
  /// Receiver, cela exige un reload complet : on demande à Jellyfin une
  /// nouvelle URL transcodée avec le `subtitleStreamIndex` voulu, puis on
  /// rappelle `loadMedia` avec la position courante. Petite coupure de ~1s.
  ///
  /// `trackIndex == -1` désactive les sous-titres.
  @override
  Future<void> setSubtitleTrack(int trackIndex) async {
    if (trackIndex == _currentSubtitleIndex) return;
    _currentSubtitleIndex = trackIndex;
    await _reloadAtCurrentPosition();
  }

  /// Change la piste audio en cours de lecture. Même logique que
  /// [setSubtitleTrack] : reload complet via Jellyfin pour rebuild la
  /// transcodingUrl avec le bon `audioStreamIndex`.
  @override
  Future<void> setAudioTrack(int trackIndex) async {
    if (trackIndex == _currentAudioIndex) return;
    _currentAudioIndex = trackIndex;
    await _reloadAtCurrentPosition();
  }

  Future<void> _reloadAtCurrentPosition() async {
    final resumeFrom = _position;
    _setState(BackendState.loading);
    try {
      _info = await client.playbackInfo(
        item.id,
        deviceProfile: chromecastDeviceProfile(),
        audioStreamIndex:
            _currentAudioIndex >= 0 ? _currentAudioIndex : null,
        subtitleStreamIndex:
            _currentSubtitleIndex >= 0 ? _currentSubtitleIndex : null,
        mediaSourceId: _source.mediaSourceId,
      );
      _resolveSource();
      _populateTracksFromInfo();
      await GoogleCastRemoteMediaClient.instance.loadMedia(
        _buildMediaInformation(),
        playPosition: resumeFrom,
      );
    } on Object catch (e, st) {
      _log.warning('reloadAtCurrentPosition failed', e, st);
      _setState(BackendState.error);
      _errorController.add(e.toString());
    }
  }

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    await _stateController.close();
    await _completedController.close();
    await _errorController.close();
    await _durationController.close();
    await _bufferingController.close();
  }

  // ----- Mapping helpers -----

  void _resolveSource() {
    final resolver = MediaSourceResolver(session);
    _source = resolver.resolve(item.id, _info);
  }

  /// Extrait les pistes audio et sous-titres de la `MediaSourceInfo` choisie
  /// par le résolveur. Les `index` sont les indices Jellyfin (utilisables
  /// comme `audioStreamIndex` / `subtitleStreamIndex`).
  void _populateTracksFromInfo() {
    final sources = _info.mediaSources?.toList() ?? const [];
    if (sources.isEmpty) {
      _audioTracks = const [];
      _subtitleTracks = const [];
      return;
    }
    final picked = sources.firstWhere(
      (s) => s.id == _source.mediaSourceId,
      orElse: () => sources.first,
    );
    final streams = picked.mediaStreams?.toList() ?? const [];

    _audioTracks = [
      for (final s in streams)
        if (s.type == jf.MediaStreamType.audio && s.index != null)
          AudioTrackInfo(
            index: s.index!,
            id: s.index!.toString(),
            language: s.language,
            label: s.displayTitle ?? s.title,
          ),
    ];
    _subtitleTracks = [
      for (final s in streams)
        if (s.type == jf.MediaStreamType.subtitle && s.index != null)
          SubtitleTrackInfo(
            index: s.index!,
            id: s.index!.toString(),
            language: s.language,
            label: s.displayTitle ?? s.title,
          ),
    ];
  }

  int _defaultAudioIndex() {
    return _audioTracks.isNotEmpty ? _audioTracks.first.index : -1;
  }

  /// Construit le `GoogleCastMediaInformation` envoyé au receiver Default
  /// Media Receiver. Pas de customData — l'URL est suffisante.
  ///
  /// On envoie systématiquement `contentType: 'video/mp4'`, même pour les
  /// flux HLS : c'est ce que fait Streamyfin et c'est le mime que le
  /// Default Media Receiver accepte le plus largement. Annoncer
  /// `application/x-mpegURL` provoque parfois un rejet "Invalid Request"
  /// alors que la même URL passe avec `video/mp4`.
  GoogleCastMediaInformation _buildMediaInformation() {
    final images = <GoogleCastImage>[
      if (posterUrl != null) GoogleCastImage(url: Uri.parse(posterUrl!)),
    ];
    final metadata = GoogleCastMovieMediaMetadata(
      title: item.name ?? '',
      subtitle: item.seriesName,
      images: images,
    );

    final ticks = item.runTimeTicks;
    final duration = ticks != null && ticks > 0
        ? Duration(microseconds: ticks ~/ 10)
        : null;

    return GoogleCastMediaInformation(
      contentId: item.id,
      streamType: CastMediaStreamType.buffered,
      contentUrl: Uri.tryParse(_source.streamUrl),
      contentType: 'video/mp4',
      metadata: metadata,
      duration: duration,
    );
  }
}
