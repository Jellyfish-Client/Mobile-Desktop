import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/jellyfin/jellyfin_url_service.dart';
import '../../../core/jellyfin/models/jellyfin_item.dart';
import '../../../l10n/l10n_extension.dart';
import '../../details/_format.dart';

class NextUpOverlay extends ConsumerStatefulWidget {
  const NextUpOverlay({
    required this.next,
    required this.onPlay,
    required this.onDismiss,
    this.countdown = const Duration(seconds: 15),
    super.key,
  });

  final JellyfinItem next;
  final VoidCallback onPlay;
  final VoidCallback onDismiss;
  final Duration countdown;

  @override
  ConsumerState<NextUpOverlay> createState() => _NextUpOverlayState();
}

class _NextUpOverlayState extends ConsumerState<NextUpOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.countdown,
  )..forward();

  @override
  void initState() {
    super.initState();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) widget.onPlay();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final thumb = urls.landscapeUrl(widget.next, maxWidth: 400);
    return Align(
      alignment: Alignment.bottomRight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Material(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: SizedBox(
                            width: 120,
                            height: 68,
                            child: thumb != null
                                ? CachedNetworkImage(
                                    imageUrl: thumb,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: AppColors.surface),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.playerNextUp,
                                style: const TextStyle(
                                  color: AppColors.onSurfaceMuted,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _label(widget.next),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, __) => LinearProgressIndicator(
                        value: _ctrl.value,
                        minHeight: 3,
                        backgroundColor: AppColors.outline,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: widget.onDismiss,
                          child: Text(
                            context.l10n.playerDismiss,
                            style: const TextStyle(
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton(
                          onPressed: widget.onPlay,
                          child: Text(context.l10n.playerPlayNow),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _label(JellyfinItem item) {
    if (item.type == BaseItemKind.episode) {
      final code = formatEpisodeCode(item);
      final name = item.name ?? '';
      if (code.isEmpty) return name;
      return name.isEmpty ? code : '$code · $name';
    }
    return item.name ?? '';
  }
}
