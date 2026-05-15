import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;

import '../../core/cast/cast_player_backend.dart';
import '../../core/cast/cast_providers.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/playback/player_backend.dart';
import '../../l10n/l10n_extension.dart';
import '../details/_format.dart';
import '../player/widgets/subtitle_audio_sheet.dart';

/// Plein-écran de pilotage de la session Cast active. Survit à la navigation
/// — fermer cet écran NE déconnecte PAS la session, le mini-player prend
/// alors le relais.
///
/// Force l'orientation portrait : on hérite peut-être d'un PlayerScreen
/// landscape (cas du auto-play après connexion Cast) qui n'a pas eu le
/// temps de restaurer l'orientation avant qu'on push par-dessus.
class CastNowPlayingScreen extends ConsumerStatefulWidget {
  const CastNowPlayingScreen({super.key});

  @override
  ConsumerState<CastNowPlayingScreen> createState() =>
      _CastNowPlayingScreenState();
}

class _CastNowPlayingScreenState extends ConsumerState<CastNowPlayingScreen> {
  bool _navigatingAway = false;

  @override
  void initState() {
    super.initState();
    // Force portrait dès l'arrivée sur l'écran. On ne restore rien au
    // dispose : chaque écran de l'app gère sa propre orientation à
    // l'entrée (PlayerScreen force landscape, le reste reste portrait).
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final nowPlaying = ref.watch(castNowPlayingProvider);
    if (nowPlaying == null) {
      // Aucun cast actif — fallback : on retourne à Home.
      // Le flag évite d'empiler plusieurs callbacks si le provider émet
      // null de façon transitoire sur plusieurs frames consécutives.
      if (!_navigatingAway) {
        _navigatingAway = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/home');
        });
      }
      return const Scaffold(body: SizedBox.shrink());
    }
    _navigatingAway = false;

    final item = nowPlaying.item;
    final backend = nowPlaying.backend;
    final l10n = context.l10n;
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final backdropUrl = urls.landscapeUrl(item, maxWidth: 1080);
    final posterUrl = urls.imageUrl(item, type: 'Primary', maxWidth: 600);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.castNowPlayingTitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (backdropUrl != null)
            CachedNetworkImage(
              imageUrl: backdropUrl,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.55),
              colorBlendMode: BlendMode.darken,
            ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Poster s'adapte à la hauteur dispo : on lui laisse au plus
                // 45 % de l'espace, et on borne à [120, 280] pour qu'il ne
                // soit ni un timbre-poste ni qu'il pousse les contrôles
                // hors de l'écran en landscape.
                final posterMax =
                    (constraints.maxHeight * 0.45).clamp(120.0, 280.0);
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (posterUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: posterUrl,
                              height: posterMax,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Column(
                          children: [
                            Text(
                              _titleFor(item),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_subtitleFor(item) case final sub when sub.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  sub,
                                  style:
                                      const TextStyle(color: Colors.white70),
                                ),
                              ),
                          ],
                        ),
                        Column(
                          children: [
                            _CastSeekBar(backend: backend),
                            const SizedBox(height: 8),
                            _CastTransportRow(backend: backend),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            await ref.read(castServiceProvider).disconnect();
                            await ref
                                .read(castNowPlayingProvider.notifier)
                                .set(null);
                            if (context.mounted) context.pop();
                          },
                          icon: const Icon(Icons.cancel_outlined,
                              color: Colors.white),
                          label: Text(
                            l10n.castMiniPlayerStop,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(JellyfinItem item) {
    if (item.type == BaseItemKind.episode) {
      return item.seriesName ?? item.name ?? '';
    }
    return item.name ?? '';
  }

  String _subtitleFor(JellyfinItem item) {
    if (item.type == BaseItemKind.episode) {
      final code = formatEpisodeCode(item);
      final name = item.name ?? '';
      if (code.isEmpty) return name;
      return name.isEmpty ? code : '$code · $name';
    }
    return '';
  }
}

class _CastSeekBar extends StatefulWidget {
  const _CastSeekBar({required this.backend});
  final CastPlayerBackend backend;

  @override
  State<_CastSeekBar> createState() => _CastSeekBarState();
}

class _CastSeekBarState extends State<_CastSeekBar> {
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double? _scrubValue;

  @override
  void initState() {
    super.initState();
    _position = widget.backend.position;
    _duration = widget.backend.duration;
    _posSub = widget.backend.positionStream.listen((p) {
      if (mounted && _scrubValue == null) setState(() => _position = p);
    });
    _durSub = widget.backend.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = _duration.inMilliseconds.toDouble();
    final value = (_scrubValue ?? _position.inMilliseconds.toDouble())
        .clamp(0.0, maxMs <= 0 ? 1.0 : maxMs);
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
          ),
          child: Slider(
            min: 0,
            max: maxMs <= 0 ? 1 : maxMs,
            value: value,
            onChanged: maxMs <= 0
                ? null
                : (v) => setState(() => _scrubValue = v),
            onChangeEnd: maxMs <= 0
                ? null
                : (v) async {
                    await widget.backend
                        .seek(Duration(milliseconds: v.toInt()));
                    if (mounted) {
                      setState(() {
                        _position = Duration(milliseconds: v.toInt());
                        _scrubValue = null;
                      });
                    }
                  },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(_position),
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_format(_duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  static String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _CastTransportRow extends StatefulWidget {
  const _CastTransportRow({required this.backend});
  final CastPlayerBackend backend;

  @override
  State<_CastTransportRow> createState() => _CastTransportRowState();
}

class _CastTransportRowState extends State<_CastTransportRow> {
  StreamSubscription<BackendState>? _stateSub;
  late BackendState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.backend.state;
    _stateSub = widget.backend.stateStream.listen((s) {
      if (mounted) setState(() => _state = s);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _state == BackendState.playing;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          iconSize: 36,
          color: Colors.white,
          onPressed: () async {
            final next = widget.backend.position - const Duration(seconds: 10);
            await widget.backend.seek(
              next < Duration.zero ? Duration.zero : next,
            );
          },
          icon: const Icon(Icons.replay_10),
        ),
        IconButton(
          iconSize: 56,
          color: Colors.white,
          onPressed: () =>
              isPlaying ? widget.backend.pause() : widget.backend.play(),
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
        ),
        IconButton(
          iconSize: 36,
          color: Colors.white,
          onPressed: () async {
            await widget.backend.seek(
              widget.backend.position + const Duration(seconds: 10),
            );
          },
          icon: const Icon(Icons.forward_10),
        ),
        IconButton(
          iconSize: 28,
          color: Colors.white,
          tooltip: context.l10n.playerSubtitlesAudio,
          onPressed: () => showSubtitleAudioSheet(
            context,
            backend: widget.backend,
          ),
          icon: const Icon(Icons.subtitles_outlined),
        ),
      ],
    );
  }
}
