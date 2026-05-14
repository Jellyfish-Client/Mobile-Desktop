import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/playback/playback_providers.dart';
import '../../../l10n/l10n_extension.dart';

const _speeds = <double>[0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

Future<void> showSpeedSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    builder: (_) => const _SpeedSheet(),
  );
}

class _SpeedSheet extends ConsumerWidget {
  const _SpeedSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(playbackStateProvider).speed;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                context.l10n.playerSpeed,
                style: const TextStyle(
                  color: AppColors.onSurfaceMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            for (final speed in _speeds)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  speed == 1.0 ? context.l10n.playerSpeedNormal : '${speed}x',
                  style: const TextStyle(color: AppColors.onSurface),
                ),
                trailing: (speed - current).abs() < 0.001
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await ref.read(playerBackendProvider).setSpeed(speed);
                  ref.read(playbackStateProvider.notifier).setSpeed(speed);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
