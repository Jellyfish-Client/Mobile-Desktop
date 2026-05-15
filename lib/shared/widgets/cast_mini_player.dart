import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;

import '../../app/theme/app_radius.dart';
import '../../core/cast/cast_player_backend.dart';
import '../../core/cast/cast_providers.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/playback/player_backend.dart';
import '../../l10n/l10n_extension.dart';

/// Mini-player persistant qui suit toutes les destinations du shell tant
/// qu'une session Cast diffuse un média. Tap = ouvre l'écran "Now Casting".
class CastMiniPlayer extends ConsumerWidget {
  const CastMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(castNowPlayingProvider);
    if (nowPlaying == null) return const SizedBox.shrink();
    return _CastMiniPlayerBody(
      item: nowPlaying.item,
      backend: nowPlaying.backend,
    );
  }
}

class _CastMiniPlayerBody extends ConsumerStatefulWidget {
  const _CastMiniPlayerBody({required this.item, required this.backend});
  final JellyfinItem item;
  final CastPlayerBackend backend;

  @override
  ConsumerState<_CastMiniPlayerBody> createState() =>
      _CastMiniPlayerBodyState();
}

class _CastMiniPlayerBodyState extends ConsumerState<_CastMiniPlayerBody> {
  StreamSubscription<BackendState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  BackendState _state = BackendState.idle;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _state = widget.backend.state;
    _position = widget.backend.position;
    _duration = widget.backend.duration;
    _stateSub = widget.backend.stateStream.listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _posSub = widget.backend.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durSub = widget.backend.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final poster = urls.imageUrl(widget.item, type: 'Primary', maxWidth: 160);
    final scheme = Theme.of(context).colorScheme;
    final isPlaying = _state == BackendState.playing;
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return Material(
      color: scheme.surfaceContainerHighest,
      elevation: 6,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.push('/cast/now-playing'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: poster == null
                          ? Container(color: scheme.surface)
                          : CachedNetworkImage(
                              imageUrl: poster,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _titleFor(widget.item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.cast_connected,
                              size: 12,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _subtitleFor(widget.item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isPlaying ? 'Pause' : 'Play',
                    onPressed: () => isPlaying
                        ? widget.backend.pause()
                        : widget.backend.play(),
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    tooltip: l10n.castMiniPlayerStop,
                    onPressed: () async {
                      await ref.read(castServiceProvider).disconnect();
                      await ref.read(castNowPlayingProvider.notifier).set(null);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              backgroundColor: Colors.transparent,
            ),
          ],
        ),
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
      return item.name ?? '';
    }
    return item.productionYear?.toString() ?? '';
  }
}
