import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/playback/playback_providers.dart';
import '../../../core/playback/player_backend.dart';
import '_duration_format.dart';
import 'trickplay_preview.dart';

class SeekBar extends ConsumerStatefulWidget {
  const SeekBar({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<SeekBar> {
  double? _dragValue;
  bool _wasPlayingBeforeDrag = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playbackStateProvider);
    final totalMs = state.duration.inMilliseconds.toDouble();
    final positionMs = (_dragValue ?? state.position.inMilliseconds.toDouble())
        .clamp(0.0, totalMs <= 0 ? 1.0 : totalMs);
    final progress = totalMs <= 0 ? 0.0 : positionMs / totalMs;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              formatPlayerDuration(Duration(milliseconds: positionMs.toInt())),
              style: const TextStyle(
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: AppColors.outline,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withValues(alpha: 0.18),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                      ),
                      child: Slider(
                        min: 0,
                        max: totalMs <= 0 ? 1 : totalMs,
                        value: positionMs,
                        onChangeStart: (_) {
                          _wasPlayingBeforeDrag = state.isPlaying;
                        },
                        onChanged: (v) => setState(() => _dragValue = v),
                        onChangeEnd: (v) async {
                          final backend = ref.read(playerBackendProvider);
                          await backend.seek(Duration(milliseconds: v.toInt()));
                          setState(() => _dragValue = null);
                          if (_wasPlayingBeforeDrag &&
                              backend.state != BackendState.playing) {
                            await backend.play();
                          }
                        },
                      ),
                    ),
                    if (_dragValue != null)
                      Positioned(
                        bottom: 36,
                        left: _previewLeft(c.maxWidth, progress),
                        child: IgnorePointer(
                          child: TrickplayPreview(
                            itemId: widget.itemId,
                            position: Duration(
                              milliseconds: positionMs.toInt(),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              formatPlayerDuration(state.duration),
              style: const TextStyle(
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  double _previewLeft(double trackWidth, double progress) {
    const previewWidth = 160.0;
    const padding = 4.0;
    final thumbX = trackWidth * progress;
    final left = thumbX - previewWidth / 2;
    return left.clamp(padding, trackWidth - previewWidth - padding);
  }
}
