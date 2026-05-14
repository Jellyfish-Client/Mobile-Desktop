import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;
import 'package:logging/logging.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:uuid/uuid.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/auth/account_key.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/downloads/download_manager.dart';
import '../../core/downloads/download_settings.dart';
import '../../core/jellyfin/jellyfin_client.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/network/offline_mode_provider.dart';
import '../../core/platform/platform_capabilities.dart';
import '../../core/playback/media_session_service.dart';
import '../../core/playback/media_source_resolver.dart';
import '../../core/playback/next_up_provider.dart';
import '../../core/playback/pip_service.dart';
import '../../core/playback/playback_event_sink.dart';
import '../../core/playback/playback_providers.dart';
import '../../core/playback/playback_reporting_service.dart';
import '../../core/playback/player_backend.dart';
import '../../core/playback/segments_provider.dart';
import '../../core/storage/app_database_provider.dart';
import '../../l10n/l10n_extension.dart';
import '../details/_format.dart';
import 'play_extra.dart';
import 'widgets/brightness_volume_indicator.dart';
import 'widgets/controls_overlay.dart';
import 'widgets/double_tap_seek_indicator.dart';
import 'widgets/lock_osd_overlay.dart';
import 'widgets/next_up_overlay.dart';
import 'widgets/skip_segment_button.dart';
import 'widgets/video_surface.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({required this.itemId, this.extra, super.key});

  final String itemId;
  final PlayExtra? extra;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with WidgetsBindingObserver {
  static final _log = Logger('PlayerScreen');

  late final String _playSessionId = const Uuid().v4();
  PlaybackReportingService? _reporting;

  // Visibility of the player chrome (top bar, bottom bar, side controls).
  // Owns its own auto-hide timer so toggling does not rebuild the Scaffold.
  late final _ControlsVisibilityController _controlsController =
      _ControlsVisibilityController();

  // Transient double-tap-to-seek indicator (◁◁  /  ▷▷). Lives in its own
  // subtree to scope rebuilds on the 600ms auto-fade.
  late final _DoubleTapIndicatorController _doubleTapController =
      _DoubleTapIndicatorController();

  // "Resuming from …" toast shown once when playback starts on a resumed item.
  late final _ResumeToastController _resumeToastController =
      _ResumeToastController();

  bool _locked = false;

  Duration _resumeFrom = Duration.zero;
  bool _readyShown = false;

  StreamSubscription<BackendState>? _stateSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<Duration>? _positionSub;

  SkipSegment? _activeSkipSegment;

  bool _nextUpDismissed = false;
  bool _showNextUp = false;

  HudKind? _hudKind;
  double _hudValue = 0;
  Timer? _hudTimer;

  double? _dragStartBrightness;
  double? _dragStartVolume;

  StreamSubscription<double>? _volumeSub;
  bool _isMuted = false;
  // Subtitle index that was active right before the mute transition.
  // Null while we are not currently in an "auto-enabled by mute" state.
  int? _subtitleIndexBeforeMute;
  // The track index we forced ON when the user muted. Used to detect manual
  // subtitle changes during mute so we don't override the user on unmute.
  int? _subtitleIndexSetByMute;

  bool _initialized = false;
  bool _disposed = false;
  bool _attachedToAudioHandler = false;

  bool _inPip = false;
  StreamSubscription<PiPStatus>? _pipSub;

  late final PlatformCapabilities _caps;

  @override
  void initState() {
    super.initState();
    _caps = ref.read(platformCapabilitiesProvider);
    WidgetsBinding.instance.addObserver(this);
    _enterImmersive();
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
      _wirePipStream();
      _initMuteSubtitleSync();
    });
  }

  void _wirePipStream() {
    final pip = ref.read(pipServiceProvider);
    final stream = pip.statusStream;
    if (stream == null) return;
    _pipSub = stream.listen((status) {
      if (!mounted) return;
      final inPip = status == PiPStatus.enabled;
      if (inPip != _inPip) {
        if (inPip) {
          _controlsController.hide();
          // PiP owns the system overlay — pull the MediaItem so we don't
          // expose two parallel control surfaces.
          if (_attachedToAudioHandler) {
            ref.read(audioHandlerProvider).detachBackend();
            _attachedToAudioHandler = false;
          }
        } else {
          // PiP exit → re-attach so lockscreen / shade controls come back.
          final item = ref.read(playerItemProvider(widget.itemId)).valueOrNull;
          if (item != null) {
            _attachAudioHandler(
              item: item,
              backend: ref.read(playerBackendProvider),
            );
          }
        }
        setState(() => _inPip = inPip);
      }
    });
  }

  Future<void> _enterPip() async {
    final pip = ref.read(pipServiceProvider);
    if (!pip.isSupported) return;
    if (!await pip.isAvailable) return;
    await pip.enterPip();
  }

  Future<void> _initialize() async {
    if (_initialized || _disposed) return;
    _initialized = true;
    try {
      final localPath = await ref
          .read(downloadManagerProvider)
          .localPathFor(widget.itemId);
      if (localPath != null) {
        await _initFromLocal(localPath);
        return;
      }

      final client = ref.read(jellyfinClientProvider);
      final session = ref.read(authControllerProvider).valueOrNull?.session;
      if (session == null) {
        throw StateError('No session available for playback');
      }
      final item = await ref.read(playerItemProvider(widget.itemId).future);
      final info = await ref.read(
        playerPlaybackInfoProvider(widget.itemId).future,
      );

      final resolver = MediaSourceResolver(session);
      final resolved = resolver.resolve(widget.itemId, info);

      final resumeTicks = item.playbackPositionTicks ?? 0;
      final startPos = (resumeTicks > 0 && !(item.played ?? false))
          ? Duration(microseconds: resumeTicks ~/ 10)
          : Duration.zero;
      _resumeFrom = startPos;

      final backend = ref.read(playerBackendProvider);
      _wireBackendListeners(backend);

      await backend.open(resolved.streamUrl, startPosition: startPos);

      _attachAudioHandler(item: item, backend: backend);
      unawaited(ref.read(pipServiceProvider).enableAutoEnter());

      _reporting = PlaybackReportingService(
        sink: _buildSink(client, resolved.mediaSourceId),
        positionTicksProvider: () => backend.position.inMicroseconds * 10,
      );
      await _reporting!.start(startTicks: startPos.inMicroseconds * 10);
    } on Object catch (e, st) {
      _log.warning('Player initialization failed', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(context.l10n.playerError(e.toString()))),
      );
      if (mounted) context.pop();
    }
  }

  /// Plays the local downloaded file. Best-effort resume from server-side
  /// playback position when the item metadata is still reachable; otherwise
  /// starts at 0. Reporting is routed through a [PlaybackEventSink] so
  /// progress is sent to Jellyfin when online, or queued in Drift when not.
  Future<void> _initFromLocal(String localPath) async {
    var startPos = Duration.zero;
    JellyfinItem? localItem;
    try {
      final item = await ref.read(playerItemProvider(widget.itemId).future);
      localItem = item;
      final resumeTicks = item.playbackPositionTicks ?? 0;
      if (resumeTicks > 0 && !(item.played ?? false)) {
        startPos = Duration(microseconds: resumeTicks ~/ 10);
      }
    } on Object catch (e, s) {
      _log.fine(
        'Offline play — item metadata unavailable, starting at 0',
        e,
        s,
      );
    }
    _resumeFrom = startPos;

    final backend = ref.read(playerBackendProvider);
    _wireBackendListeners(backend);
    await backend.open(localPath, startPosition: startPos);

    if (localItem != null) {
      _attachAudioHandler(item: localItem, backend: backend);
    }
    unawaited(ref.read(pipServiceProvider).enableAutoEnter());

    // Even with a local file, we still want to track progress: route it
    // through a sink that picks online (direct API) vs offline (SyncQueue)
    // based on current connectivity.
    final client = ref.read(jellyfinClientProvider);
    _reporting = PlaybackReportingService(
      sink: _buildSink(client, widget.itemId),
      positionTicksProvider: () => backend.position.inMicroseconds * 10,
    );
    await _reporting!.start(startTicks: startPos.inMicroseconds * 10);
  }

  void _attachAudioHandler({
    required JellyfinItem item,
    required PlayerBackend backend,
  }) {
    // PiP owns its own native controls — don't surface a duplicate notif.
    if (_inPip) return;
    final urlService = ref.read(jellyfinUrlServiceProvider);
    final posterUrl = urlService.imageUrl(item, type: 'Primary', maxWidth: 512);
    final mediaItem = MediaItem(
      id: widget.itemId,
      title: item.name ?? '',
      artist: item.seriesName ?? '',
      album: item.seriesName,
      duration: backend.duration > Duration.zero ? backend.duration : null,
      artUri: posterUrl != null ? Uri.parse(posterUrl) : null,
    );
    ref.read(audioHandlerProvider).attachBackend(
      backend: backend,
      item: mediaItem,
      onSkipNext: _hasNextUp() ? _playNextUp : null,
    );
    _attachedToAudioHandler = true;
  }

  bool _hasNextUp() {
    final item = ref.read(playerItemProvider(widget.itemId)).valueOrNull;
    final seriesId = item?.seriesId;
    if (seriesId == null) return false;
    return ref.read(playerNextUpProvider(seriesId)).valueOrNull != null;
  }

  PlaybackEventSink _buildSink(JellyfinClient client, String mediaSourceId) {
    final offline = ref.read(offlineModeProvider);
    if (offline) {
      final session = ref.read(authControllerProvider).valueOrNull?.session;
      return OfflinePlaybackSink(
        db: ref.read(appDatabaseProvider),
        accountKey: accountKeyForSession(session),
        itemId: widget.itemId,
        playSessionId: _playSessionId,
        mediaSourceId: mediaSourceId,
      );
    }
    return OnlinePlaybackSink(
      client: client,
      itemId: widget.itemId,
      playSessionId: _playSessionId,
      mediaSourceId: mediaSourceId,
    );
  }

  void _wireBackendListeners(PlayerBackend backend) {
    _stateSub = backend.stateStream.listen((s) {
      if (!mounted) return;
      if (s == BackendState.playing && !_readyShown) {
        _readyShown = true;
        if (_resumeFrom > Duration.zero) {
          _resumeToastController.show(from: _resumeFrom);
        }
      }
      // Forward play/pause transitions to Jellyfin reporting so a system
      // notification or BT-key pause stays in sync with the server. The
      // audio handler triggers pause through backend.pause(), which lands
      // here — no parallel reporting path.
      if (s == BackendState.playing) {
        _reporting?.onPauseChanged(paused: false);
      } else if (s == BackendState.paused) {
        _reporting?.onPauseChanged(paused: true);
      }
    });
    _errorSub = backend.errorStream.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(context.l10n.playerError(msg))),
      );
    });
    _completedSub = backend.completedStream.listen((_) async {
      if (!mounted) return;
      _onNearOrAtEnd();
      final settings = ref.read(downloadSettingsProvider).valueOrNull;
      if (settings?.autoDeleteWatched ?? false) {
        // Stop reporting first so the playback-stopped POST doesn't race with
        // file deletion on Android (advisory file locking).
        await _reporting?.stop();
        _reporting = null;
        await ref.read(downloadManagerProvider).deleteDownload(widget.itemId);
      }
    });
    _positionSub = backend.positionStream.listen(_onPosition);
  }

  void _onPosition(Duration position) {
    if (!mounted) return;
    _updateSkipSegment(position);
    _maybeTriggerNextUp(position);
    // Subtitle tracks may load after the volume listener already fired a
    // mute event; reconcile on each tick until tracks are available.
    if (_isMuted && _subtitleIndexBeforeMute == null) {
      _applyMutedSubtitles();
    }
  }

  Future<void> _initMuteSubtitleSync() async {
    // Desktop: no reliable VolumeController implementation, and the mute→subs
    // UX is mobile-specific anyway. Skip wiring.
    if (!_caps.supportsVolumeGesture) return;
    if (_volumeSub != null) return;
    try {
      final initial = await VolumeController().getVolume();
      if (!mounted) return;
      _isMuted = initial <= 0.001;
    } on Object catch (_) {
      _isMuted = false;
    }
    _volumeSub = VolumeController().listener(_onSystemVolumeChange);
    if (_isMuted) _applyMutedSubtitles();
  }

  void _onSystemVolumeChange(double volume) {
    if (!mounted) return;
    final wasMuted = _isMuted;
    final nowMuted = volume <= 0.001;
    if (wasMuted == nowMuted) return;
    _isMuted = nowMuted;
    _applyMutedSubtitles();
  }

  void _applyMutedSubtitles() {
    final backend = ref.read(playerBackendProvider);
    final tracks = backend.subtitleTracks;
    _log.fine(
      'mute-sub sync: muted=$_isMuted tracks=${tracks.length} '
      'currentSub=${backend.currentSubtitleIndex} '
      'savedBefore=$_subtitleIndexBeforeMute setByUs=$_subtitleIndexSetByMute',
    );
    if (_isMuted) {
      if (tracks.isEmpty) return;
      if (backend.currentSubtitleIndex >= 0) {
        // Subtitles were already on at mute time — remember that so unmute
        // is a no-op and we don't restore over a user-chosen track.
        _subtitleIndexBeforeMute = backend.currentSubtitleIndex;
        return;
      }
      _subtitleIndexBeforeMute = -1;
      _subtitleIndexSetByMute = 0;
      unawaited(backend.setSubtitleTrack(0));
    } else {
      final saved = _subtitleIndexBeforeMute;
      final setByUs = _subtitleIndexSetByMute;
      _subtitleIndexBeforeMute = null;
      _subtitleIndexSetByMute = null;
      // Only restore when we actually forced subtitles on AND the user has
      // not manually picked a different track since.
      if (saved != null &&
          setByUs != null &&
          backend.currentSubtitleIndex == setByUs) {
        unawaited(backend.setSubtitleTrack(saved));
      }
    }
  }

  void _updateSkipSegment(Duration position) {
    final segments =
        ref.read(playerSegmentsProvider(widget.itemId)).valueOrNull ??
        const <SkipSegment>[];
    SkipSegment? match;
    for (final s in segments) {
      if (s.contains(position)) {
        match = s;
        break;
      }
    }
    if (match != _activeSkipSegment) {
      setState(() => _activeSkipSegment = match);
    }
  }

  void _maybeTriggerNextUp(Duration position) {
    if (_showNextUp || _nextUpDismissed) return;
    final backend = ref.read(playerBackendProvider);
    final dur = backend.duration;
    if (dur <= Duration.zero) return;
    if (position.inMilliseconds / dur.inMilliseconds < 0.8) return;
    _onNearOrAtEnd();
  }

  void _onNearOrAtEnd() {
    if (_showNextUp || _nextUpDismissed || !mounted) return;
    final item = ref.read(playerItemProvider(widget.itemId)).valueOrNull;
    final seriesId = item?.seriesId;
    if (item?.type != BaseItemKind.episode || seriesId == null) return;
    final next = ref.read(playerNextUpProvider(seriesId)).valueOrNull;
    if (next == null) return;
    // Surface the system "Next" control now that we have a real next-up.
    if (_attachedToAudioHandler) {
      ref.read(audioHandlerProvider).updateSkipNext(_playNextUp);
    }
    setState(() => _showNextUp = true);
  }

  void _showHud(HudKind kind, double value) {
    setState(() {
      _hudKind = kind;
      _hudValue = value;
    });
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _hudKind = null);
    });
  }

  Future<void> _onDoubleTapDown(TapDownDetails details, Size size) async {
    if (_locked) return;
    final isLeft = details.localPosition.dx < size.width / 2;
    final backend = ref.read(playerBackendProvider);
    final newPos = isLeft
        ? backend.position - const Duration(seconds: 10)
        : backend.position + const Duration(seconds: 10);
    final clamped = newPos < Duration.zero ? Duration.zero : newPos;
    await backend.seek(clamped);
    _reporting?.onSeek();
    if (!mounted) return;
    _doubleTapController.show(left: isLeft);
  }

  Future<void> _onVerticalDragStart(DragStartDetails details, Size size) async {
    if (_locked) return;
    if (!_caps.supportsVolumeGesture) return;
    if (details.localPosition.dx < size.width / 2) {
      try {
        _dragStartBrightness = await ScreenBrightness().current;
      } on Object catch (_) {
        _dragStartBrightness = 0.5;
      }
      _dragStartVolume = null;
    } else {
      _dragStartVolume = await VolumeController().getVolume();
      _dragStartBrightness = null;
    }
  }

  Future<void> _onVerticalDragUpdate(
    DragUpdateDetails details,
    Size size,
  ) async {
    if (_locked) return;
    final delta = -details.primaryDelta! / size.height * 2;
    if (_dragStartBrightness != null) {
      final next = (_dragStartBrightness! + delta).clamp(0.0, 1.0);
      _dragStartBrightness = next;
      try {
        await ScreenBrightness().setScreenBrightness(next);
      } on Object catch (_) {
        // ScreenBrightness control is best-effort; ignore platform failures.
      }
      _showHud(HudKind.brightness, next);
    } else if (_dragStartVolume != null) {
      final next = (_dragStartVolume! + delta).clamp(0.0, 1.0);
      _dragStartVolume = next;
      VolumeController().setVolume(next, showSystemUI: false);
      // The platform volume listener does not fire reliably on programmatic
      // setVolume() calls — drive the mute-subtitle sync from here too.
      _onSystemVolumeChange(next);
      _showHud(HudKind.volume, next);
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _dragStartBrightness = null;
    _dragStartVolume = null;
  }

  void _onLock() {
    _controlsController.hide();
    setState(() => _locked = true);
  }

  void _onUnlock() {
    _controlsController.show();
    setState(() => _locked = false);
  }

  Future<void> _playNextUp() async {
    final item = ref.read(playerItemProvider(widget.itemId)).valueOrNull;
    final seriesId = item?.seriesId;
    final next = seriesId == null
        ? null
        : ref.read(playerNextUpProvider(seriesId)).valueOrNull;
    if (next == null || !mounted) return;
    await _reporting?.stop();
    if (_attachedToAudioHandler) {
      // Clear the notification cleanly so the next route's _initialize can
      // attach with fresh metadata instead of stale title/poster.
      await ref.read(audioHandlerProvider).detachBackend();
      _attachedToAudioHandler = false;
    }
    if (!mounted) return;
    context.pushReplacement('/play/${next.id}');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Keep playback alive on paused/inactive — that's the whole point of
    // the system media session. We still pause on `detached` (process going
    // away) so libmpv doesn't keep decoding after the engine tears down.
    if (state == AppLifecycleState.detached) {
      final backend = ref.read(playerBackendProvider);
      if (backend.isPlaying) {
        backend.pause();
        _reporting?.onPauseChanged(paused: true);
      }
    }
  }

  Future<void> _enterImmersive() async {
    if (!_caps.supportsImmersiveMode) return;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _exitImmersive() async {
    if (!_caps.supportsImmersiveMode) return;
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _disposed = true;
    if (_attachedToAudioHandler) {
      // Fire-and-forget — detach cancels its subs internally and emits an
      // idle PlaybackState that clears the system notification.
      ref.read(audioHandlerProvider).detachBackend();
      _attachedToAudioHandler = false;
    }
    unawaited(ref.read(pipServiceProvider).disableAutoEnter());
    WidgetsBinding.instance.removeObserver(this);
    _controlsController.dispose();
    _doubleTapController.dispose();
    _resumeToastController.dispose();
    _hudTimer?.cancel();
    _stateSub?.cancel();
    _errorSub?.cancel();
    _completedSub?.cancel();
    _positionSub?.cancel();
    _pipSub?.cancel();
    _volumeSub?.cancel();
    _reporting?.stop();
    if (_caps.supportsScreenBrightness) {
      ScreenBrightness().resetScreenBrightness().catchError((_) {});
    }
    WakelockPlus.disable();
    _exitImmersive();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            fit: StackFit.expand,
            children: [
              const VideoSurface(),
              if (!_locked)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _controlsController.toggle,
                    onDoubleTapDown: (d) => _onDoubleTapDown(d, size),
                    onDoubleTap: () {},
                    onVerticalDragStart: _caps.supportsVolumeGesture
                        ? (d) => _onVerticalDragStart(d, size)
                        : null,
                    onVerticalDragUpdate: _caps.supportsVolumeGesture
                        ? (d) => _onVerticalDragUpdate(d, size)
                        : null,
                    onVerticalDragEnd: _caps.supportsVolumeGesture
                        ? _onVerticalDragEnd
                        : null,
                  ),
                ),
              _DoubleTapIndicatorScope(controller: _doubleTapController),
              if (_hudKind != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: BrightnessVolumeIndicator(
                      value: _hudValue,
                      kind: _hudKind!,
                    ),
                  ),
                ),
              if (!_locked && !_inPip)
                _ControlsVisibilityScope(
                  controller: _controlsController,
                  itemId: widget.itemId,
                  onLock: _onLock,
                  onPip: ref.read(pipServiceProvider).isSupported
                      ? _enterPip
                      : null,
                ),
              if (_activeSkipSegment != null && !_locked)
                SkipSegmentButton(
                  segment: _activeSkipSegment!,
                  onSkip: () async {
                    final backend = ref.read(playerBackendProvider);
                    await backend.seek(_activeSkipSegment!.end);
                    _reporting?.onSeek();
                  },
                ),
              if (_showNextUp && !_locked) _buildNextUp(),
              if (_locked) LockOSDOverlay(onUnlock: _onUnlock),
              _ResumeToastScope(controller: _resumeToastController),
              const _BufferingIndicator(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNextUp() {
    final item = ref.read(playerItemProvider(widget.itemId)).valueOrNull;
    final seriesId = item?.seriesId;
    final next = seriesId == null
        ? null
        : ref.watch(playerNextUpProvider(seriesId)).valueOrNull;
    if (next == null) return const SizedBox.shrink();
    return NextUpOverlay(
      next: next,
      onPlay: _playNextUp,
      onDismiss: () => setState(() {
        _showNextUp = false;
        _nextUpDismissed = true;
      }),
    );
  }
}

class _BufferingIndicator extends ConsumerWidget {
  const _BufferingIndicator();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackStateProvider);
    if (!state.isBuffering) return const SizedBox.shrink();
    return const Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
      ),
    );
  }
}

class _ResumeToast extends StatelessWidget {
  const _ResumeToast({required this.from});
  final Duration from;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        context.l10n.playerResumeFrom(
          formatRuntime(from.inMicroseconds * 10),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ephemeral overlay scopes — extracted from `_PlayerScreenState` so their
// rebuild fan-out stays within their own subtree. Each owns its own timer.
// ---------------------------------------------------------------------------

/// Controls visibility of the player chrome with a 3-second auto-hide.
class _ControlsVisibilityController extends ChangeNotifier {
  _ControlsVisibilityController() {
    _scheduleHide();
  }

  bool _visible = true;
  Timer? _hideTimer;

  bool get visible => _visible;

  void toggle() {
    _visible = !_visible;
    notifyListeners();
    if (_visible) {
      _scheduleHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  void show() {
    if (!_visible) {
      _visible = true;
      notifyListeners();
    }
    _scheduleHide();
  }

  void hide() {
    _hideTimer?.cancel();
    if (_visible) {
      _visible = false;
      notifyListeners();
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (_visible) {
        _visible = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }
}

class _ControlsVisibilityScope extends StatefulWidget {
  const _ControlsVisibilityScope({
    required this.controller,
    required this.itemId,
    required this.onLock,
    required this.onPip,
  });

  final _ControlsVisibilityController controller;
  final String itemId;
  final VoidCallback onLock;
  final Future<void> Function()? onPip;

  @override
  State<_ControlsVisibilityScope> createState() =>
      _ControlsVisibilityScopeState();
}

class _ControlsVisibilityScopeState extends State<_ControlsVisibilityScope> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant _ControlsVisibilityScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ControlsOverlay(
        itemId: widget.itemId,
        visible: widget.controller.visible,
        onLock: widget.onLock,
        onPip: widget.onPip,
      ),
    );
  }
}

/// Drives the transient ◁◁ / ▷▷ overlay shown after a double-tap seek.
class _DoubleTapIndicatorController extends ChangeNotifier {
  bool? _left;
  Timer? _timer;

  bool? get left => _left;

  void show({required bool left}) {
    _left = left;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 600), () {
      _left = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _DoubleTapIndicatorScope extends StatefulWidget {
  const _DoubleTapIndicatorScope({required this.controller});

  final _DoubleTapIndicatorController controller;

  @override
  State<_DoubleTapIndicatorScope> createState() =>
      _DoubleTapIndicatorScopeState();
}

class _DoubleTapIndicatorScopeState extends State<_DoubleTapIndicatorScope> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant _DoubleTapIndicatorScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.controller.left;
    if (left == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: DoubleTapSeekIndicator(alignLeft: left, seconds: 10),
      ),
    );
  }
}

/// Drives the one-shot "Resuming from …" toast. Auto-dismisses after 2s.
class _ResumeToastController extends ChangeNotifier {
  Duration? _from;
  Timer? _timer;

  Duration? get from => _from;

  void show({required Duration from}) {
    _from = from;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      _from = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _ResumeToastScope extends StatefulWidget {
  const _ResumeToastScope({required this.controller});

  final _ResumeToastController controller;

  @override
  State<_ResumeToastScope> createState() => _ResumeToastScopeState();
}

class _ResumeToastScopeState extends State<_ResumeToastScope> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant _ResumeToastScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final from = widget.controller.from;
    if (from == null) return const SizedBox.shrink();
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(child: _ResumeToast(from: from)),
      ),
    );
  }
}
