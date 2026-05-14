import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/playback/playback_providers.dart';

class VideoSurface extends ConsumerWidget {
  const VideoSurface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ref.watch(playerBackendProvider);
    final controller = backend.videoController;
    if (controller is! VideoController) {
      return const ColoredBox(color: Colors.black);
    }
    return Video(
      controller: controller,
      controls: (_) => const SizedBox.shrink(),
      fit: BoxFit.contain,
    );
  }
}
