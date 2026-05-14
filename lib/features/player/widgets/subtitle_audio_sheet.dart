import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/playback/playback_providers.dart';
import '../../../core/playback/player_backend.dart';
import '../../../l10n/l10n_extension.dart';

Future<void> showSubtitleAudioSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    isScrollControlled: true,
    builder: (_) => const _SubtitleAudioSheet(),
  );
}

class _SubtitleAudioSheet extends ConsumerWidget {
  const _SubtitleAudioSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ref.watch(playerBackendProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetTitle(context.l10n.playerAudioTrack),
            ..._buildAudioTiles(context, backend),
            const SizedBox(height: AppSpacing.lg),
            _SheetTitle(context.l10n.playerSubtitles),
            _OffTile(
              label: context.l10n.playerSubtitlesOff,
              isSelected: backend.currentSubtitleIndex < 0,
              onTap: () async {
                await backend.setSubtitleTrack(-1);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            ..._buildSubtitleTiles(context, backend),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAudioTiles(BuildContext context, PlayerBackend backend) {
    if (backend.audioTracks.isEmpty) {
      return [const _EmptyLabel('No audio tracks available')];
    }
    return [
      for (final track in backend.audioTracks)
        _TrackTile(
          label: track.displayLabel(),
          isSelected: track.index == backend.currentAudioIndex,
          onTap: () async {
            await backend.setAudioTrack(track.index);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
    ];
  }

  List<Widget> _buildSubtitleTiles(
    BuildContext context,
    PlayerBackend backend,
  ) {
    if (backend.subtitleTracks.isEmpty) {
      return [const _EmptyLabel('No subtitle tracks available')];
    }
    return [
      for (final track in backend.subtitleTracks)
        _TrackTile(
          label: track.displayLabel(),
          isSelected: track.index == backend.currentSubtitleIndex,
          onTap: () async {
            await backend.setSubtitleTrack(track.index);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
    ];
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onSurfaceMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: AppColors.onSurface)),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _OffTile extends StatelessWidget {
  const _OffTile({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: AppColors.onSurfaceMuted),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _EmptyLabel extends StatelessWidget {
  const _EmptyLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Text(text, style: const TextStyle(color: AppColors.onSurfaceSubtle)),
  );
}
