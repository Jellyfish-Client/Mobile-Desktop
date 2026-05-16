import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Horizontal episode row: 16:9 still on the left, title/number/runtime on the
/// right. Optional progress bar and "watched" badge surface playback state.
///
/// When [nextUp] is true the tile is promoted: the card gets a thin white
/// rim with a soft glow, and an overline label (provided by [nextUpLabel])
/// is rendered above the title. This is how we visually anchor the "Continuer
/// — S2 · E4" episode in a season list.
class JfEpisodeTile extends StatefulWidget {
  const JfEpisodeTile({
    required this.title,
    required this.episodeNumber,
    this.imageUrl,
    this.runtime,
    this.overview,
    this.progress,
    this.watched = false,
    this.nextUp = false,
    this.nextUpLabel,
    this.onTap,
    super.key,
  });

  final String title;
  final int? episodeNumber;
  final String? imageUrl;
  final String? runtime;
  final String? overview;
  final double? progress;
  final bool watched;
  final bool nextUp;
  final String? nextUpLabel;
  final VoidCallback? onTap;

  @override
  State<JfEpisodeTile> createState() => _JfEpisodeTileState();
}

class _JfEpisodeTileState extends State<JfEpisodeTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = BorderRadius.circular(AppRadius.md);

    final isDimmed = widget.watched && !widget.nextUp;

    final heading = [
      if (widget.episodeNumber != null)
        TextSpan(
          text: '${widget.episodeNumber} · ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      TextSpan(
        text: widget.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ];

    final card = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: widget.nextUp
            ? scheme.surface
            : (_hovering ? scheme.surface : Colors.transparent),
        borderRadius: shape,
        border: widget.nextUp
            ? Border.all(color: scheme.onSurface, width: 1.2)
            : null,
        boxShadow: widget.nextUp
            ? [
                BoxShadow(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 160,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: isDimmed ? 0.55 : 1,
                        child: widget.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: widget.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    Container(color: scheme.surfaceContainerHigh),
                                errorWidget: (_, __, ___) =>
                                    Container(color: scheme.surfaceContainerHigh),
                              )
                            : Container(color: scheme.surfaceContainerHigh),
                      ),

                      // Hover overlay (desktop): subtle dim + centred play
                      // glyph. Mobile devices never trigger hover events so
                      // this stays hidden on touch.
                      AnimatedOpacity(
                        duration: AppMotion.fast,
                        opacity: _hovering ? 1 : 0,
                        child: ColoredBox(
                          color: const Color(0x66000000),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 36,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),

                      if (widget.watched && !widget.nextUp)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _WatchedBadge(scheme: scheme),
                        ),

                      if (widget.progress != null && widget.progress! > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LinearProgressIndicator(
                            value: widget.progress!.clamp(0, 1),
                            minHeight: 3,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation(scheme.onSurface),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.nextUp && widget.nextUpLabel != null) ...[
                      Text(
                        widget.nextUpLabel!,
                        style: AppTypography.eyebrow(
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                    ],
                    Opacity(
                      opacity: isDimmed ? 0.65 : 1,
                      child: Text.rich(
                        TextSpan(children: heading),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.runtime != null &&
                        widget.runtime!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.runtime!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (widget.overview != null &&
                        widget.overview!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Opacity(
                        opacity: isDimmed ? 0.6 : 1,
                        child: Text(
                          widget.overview!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: shape,
          child: card,
        ),
      ),
    );
  }
}

class _WatchedBadge extends StatelessWidget {
  const _WatchedBadge({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Icon(Icons.check_rounded, size: 14, color: scheme.onSurface),
    );
  }
}
