import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;

import '../../../core/jellyfin/models/jellyfin_item.dart';
import '../../../core/playback/playback_providers.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/cast_button.dart';
import '../../../shared/widgets/sync_play_button.dart';
import '../../details/_format.dart';

class TopBar extends ConsumerWidget {
  const TopBar({
    required this.itemId,
    required this.onLock,
    this.onPip,
    this.onFullscreen,
    this.isFullscreen = false,
    super.key,
  });

  final String itemId;
  final VoidCallback onLock;
  final VoidCallback? onPip;

  /// Null on platforms without an OS-window fullscreen toggle (mobile).
  final VoidCallback? onFullscreen;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(playerItemProvider(itemId)).valueOrNull;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              tooltip: context.l10n.playerBack,
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _titleFor(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item != null && _subtitleFor(item).isNotEmpty)
                    Text(
                      _subtitleFor(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            // Bouton SyncPlay — rendu visible ou non selon la plateforme
            // en interne (desktop uniquement).
            const SyncPlayButton(color: Colors.white),
            CastButton(itemId: itemId, color: Colors.white),
            if (onPip != null)
              IconButton(
                onPressed: onPip,
                icon: const Icon(
                  Icons.picture_in_picture_alt,
                  color: Colors.white,
                ),
                tooltip: context.l10n.playerPictureInPicture,
              )
            else if (Platform.isIOS)
              Tooltip(
                message: context.l10n.playerPipUnavailableIos,
                child: IconButton(
                  // null désactive le bouton tout en le rendant visible.
                  onPressed: null,
                  icon: Icon(
                    Icons.picture_in_picture_alt,
                    color: Colors.white.withValues(alpha: 0.38),
                  ),
                ),
              ),
            if (onFullscreen != null)
              IconButton(
                onPressed: onFullscreen,
                icon: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                tooltip: isFullscreen
                    ? context.l10n.playerExitFullscreen
                    : context.l10n.playerFullscreen,
              ),
            IconButton(
              onPressed: onLock,
              icon: const Icon(Icons.lock_outline, color: Colors.white),
              tooltip: context.l10n.playerLockControls,
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(JellyfinItem? item) {
    if (item == null) return '';
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
