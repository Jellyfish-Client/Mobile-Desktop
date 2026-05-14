import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/playback/playback_providers.dart';
import '../../../l10n/l10n_extension.dart';
import 'chapters_sheet.dart';
import 'speed_sheet.dart';
import 'subtitle_audio_sheet.dart';

class TransportRow extends ConsumerWidget {
  const TransportRow({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackStateProvider);
    final backend = ref.watch(playerBackendProvider);
    // `chapters` is an SDK-only field — read the DTO directly. The domain
    // model is reserved for screens that don't need raw SDK structures.
    final item = ref.watch(playerItemDtoProvider(itemId)).valueOrNull;
    final hasChapters = item?.chapters?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                backend.seek(state.position - const Duration(seconds: 10)),
            icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () async {
              if (state.isPlaying) {
                await backend.pause();
              } else {
                await backend.play();
              }
            },
            icon: Icon(
              state.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () =>
                backend.seek(state.position + const Duration(seconds: 10)),
            icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
          ),
          const Spacer(),
          if (hasChapters)
            IconButton(
              tooltip: context.l10n.playerChapters,
              onPressed: () => showChaptersSheet(context, itemId),
              icon: const Icon(Icons.format_list_bulleted, color: Colors.white),
            ),
          IconButton(
            tooltip: context.l10n.playerSubtitlesAudio,
            onPressed: () => showSubtitleAudioSheet(context),
            icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
          ),
          IconButton(
            tooltip: context.l10n.playerSpeed,
            onPressed: () => showSpeedSheet(context, ref),
            icon: Text(
              '${state.speed.toStringAsFixed(state.speed == state.speed.roundToDouble() ? 1 : 2)}x',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
