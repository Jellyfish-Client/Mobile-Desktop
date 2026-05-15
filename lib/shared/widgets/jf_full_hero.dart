import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../l10n/l10n_extension.dart';
import 'jf_button.dart';

/// One slide of [JfFullHero]. Carries the full editorial payload —
/// rating/year/age-rating/runtime/genres — so the hero can render the same
/// dense layout as the upstream `IAmParadox27/jellyfin-plugin-media-bar`
/// plugin's slideshow.
///
/// Seerr slides keep most fields null and use a "Demander" primary CTA;
/// Jellyfin slides fill everything.
class JfFullHeroSlide {
  const JfFullHeroSlide({
    required this.id,
    required this.title,
    this.overview,
    this.backdropUrl,
    this.logoUrl,
    this.year,
    this.rating,
    this.ageRating,
    this.runtimeMinutes,
    this.genres = const [],
    this.isFavorite,
    this.primaryLabel,
    this.primaryIcon = Icons.play_arrow,
  });

  final String id;
  final String title;
  final String? overview;
  final String? backdropUrl;
  final String? logoUrl;

  final int? year;
  final double? rating;
  final String? ageRating;
  final int? runtimeMinutes;
  final List<String> genres;
  final bool? isFavorite;

  final String? primaryLabel;
  final IconData primaryIcon;
}

/// Full-bleed editorial hero — covers ~65% of the viewport at the top of the
/// home screen, with a Ken-Burns backdrop, an item logo, the rich metadata
/// strip (rating · year · age · runtime · genres), an overview, and a 3-button
/// CTA row (info / play / favourite). The bottom of the backdrop feathers
/// into the page background via a ShaderMask so the first home rail visually
/// continues the hero instead of butting against a hard edge.
///
/// Designed to be placed directly in a sliver list (no horizontal padding —
/// it bleeds edge-to-edge), at index 0 of the home `CustomScrollView`.
class JfFullHero extends StatefulWidget {
  const JfFullHero({
    required this.slides,
    required this.onPrimaryTap,
    this.onDetailTap,
    this.onFavoriteToggle,
    this.topPadding = 0,
    this.heightFraction = 0.72,
    this.minHeight = 520,
    this.maxHeight = 760,
    this.autoplayInterval = const Duration(seconds: 10),
    super.key,
  });

  final List<JfFullHeroSlide> slides;
  final ValueChanged<JfFullHeroSlide> onPrimaryTap;

  /// Optional `info` action. When null the round info button is hidden.
  final ValueChanged<JfFullHeroSlide>? onDetailTap;

  /// Optional favourite toggle. When null the round heart button is hidden.
  final ValueChanged<JfFullHeroSlide>? onFavoriteToggle;

  final double topPadding;
  final double heightFraction;
  final double minHeight;
  final double maxHeight;
  final Duration autoplayInterval;

  @override
  State<JfFullHero> createState() => _JfFullHeroState();
}

class _JfFullHeroState extends State<JfFullHero> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _scheduleAutoplay();
  }

  @override
  void didUpdateWidget(covariant JfFullHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compare the slide id sequence rather than just the count — a
    // pull-to-refresh may return the same number of items in a different
    // order, in which case we still need to reset to slide 0.
    final changed =
        widget.slides.length != oldWidget.slides.length ||
        !_sameSlideIds(widget.slides, oldWidget.slides);
    if (changed) {
      if (_controller.hasClients) _controller.jumpToPage(0);
      _index = 0;
      _scheduleAutoplay();
      _precacheAll();
    }
  }

  static bool _sameSlideIds(List<JfFullHeroSlide> a, List<JfFullHeroSlide> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAll();
  }

  void _precacheAll() {
    for (final slide in widget.slides) {
      final url = slide.backdropUrl;
      if (url != null && url.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
      final logo = slide.logoUrl;
      if (logo != null && logo.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(logo), context);
      }
    }
  }

  void _scheduleAutoplay() {
    _timer?.cancel();
    if (widget.slides.length < 2) return;
    _timer = Timer.periodic(widget.autoplayInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      _advance();
    });
  }

  void _advance() {
    final next = (_index + 1) % widget.slides.length;
    _controller.animateToPage(
      next,
      duration: AppMotion.medium,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      final h = (MediaQuery.of(context).size.height * widget.heightFraction)
          .clamp(widget.minHeight, widget.maxHeight);
      return SizedBox(height: h);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final available = mq.size.height;
        final h = (available * widget.heightFraction).clamp(
          widget.minHeight,
          widget.maxHeight,
        );

        return SizedBox(
          height: h,
          child: Stack(
            children: [
              // ── Backdrop + Ken-Burns + bottom-fade mask ────────────────
              Positioned.fill(
                child: _BackdropPager(
                  controller: _controller,
                  slides: widget.slides,
                  onIndexChanged: (i) {
                    setState(() => _index = i);
                    _scheduleAutoplay();
                  },
                ),
              ),

              // ── Foreground content ──────────────────────────────────────
              Positioned.fill(
                child: AnimatedSwitcher(
                  // 300ms: no exact token match (between medium=220 & slow=360)
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  // Override the default `Stack(alignment: center)` layout —
                  // it visibly drifts the logo/text to the middle during the
                  // crossfade because the unsized Column collapses to its
                  // intrinsic size and gets centred in the stack. Forcing
                  // each child to fill the stack keeps the Column's
                  // `mainAxisAlignment: end` + `crossAxisAlignment: start`
                  // pinned to bottom-left throughout the animation.
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    fit: StackFit.expand,
                    children: [
                      for (final c in previousChildren)
                        Positioned.fill(child: c),
                      if (currentChild != null)
                        Positioned.fill(child: currentChild),
                    ],
                  ),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _HeroContent(
                    key: ValueKey(widget.slides[_index].id),
                    slide: widget.slides[_index],
                    topPadding: widget.topPadding,
                    onPrimaryTap: () =>
                        widget.onPrimaryTap(widget.slides[_index]),
                    onDetailTap: widget.onDetailTap == null
                        ? null
                        : () => widget.onDetailTap!(widget.slides[_index]),
                    onFavoriteToggle: widget.onFavoriteToggle == null
                        ? null
                        : () => widget.onFavoriteToggle!(widget.slides[_index]),
                  ),
                ),
              ),

              if (widget.slides.length > 1)
                Positioned(
                  right: AppSpacing.lg,
                  bottom: AppSpacing.xxl + AppSpacing.lg,
                  child: ExcludeSemantics(
                    child: _DotIndicator(
                      count: widget.slides.length,
                      activeIndex: _index,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Backdrop layer
// ─────────────────────────────────────────────────────────────────────────────

/// PageView of backdrops with Ken-Burns scale on the active page, a frosted
/// crossfade between pages, and a bottom-fade ShaderMask so the image
/// feathers into the page background.
class _BackdropPager extends StatefulWidget {
  const _BackdropPager({
    required this.controller,
    required this.slides,
    required this.onIndexChanged,
  });

  final PageController controller;
  final List<JfFullHeroSlide> slides;
  final ValueChanged<int> onIndexChanged;

  @override
  State<_BackdropPager> createState() => _BackdropPagerState();
}

class _BackdropPagerState extends State<_BackdropPager> {
  int _activeIndex = 0;

  void _onPageChanged(int i) {
    setState(() => _activeIndex = i);
    widget.onIndexChanged(i);
    _prefetchAdjacent(i);
  }

  void _prefetchAdjacent(int idx) {
    final slides = widget.slides;
    if (slides.length < 2) return;
    for (final n in [
      (idx + 1) % slides.length,
      (idx - 1 + slides.length) % slides.length,
    ]) {
      final url = slides[n].backdropUrl;
      if (url != null && url.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
      final logo = slides[n].logoUrl;
      if (logo != null && logo.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(logo), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      itemCount: widget.slides.length,
      onPageChanged: _onPageChanged,
      // PageScrollPhysics keeps the horizontal swipe distinct from the
      // surrounding vertical CustomScrollView — a diagonal drag biases to
      // the page change instead of stealing the scroll.
      physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
      itemBuilder: (context, i) {
        final slide = widget.slides[i];
        final isActive = i == _activeIndex;
        return _BackdropPage(slide: slide, isActive: isActive);
      },
    );
  }
}

class _BackdropPage extends StatefulWidget {
  const _BackdropPage({required this.slide, required this.isActive});

  final JfFullHeroSlide slide;
  final bool isActive;

  @override
  State<_BackdropPage> createState() => _BackdropPageState();
}

class _BackdropPageState extends State<_BackdropPage>
    with SingleTickerProviderStateMixin {
  // Per-page Ken Burns controller: rebuilds stay local to this slide so a
  // page change doesn't tick AnimatedBuilders on neighbours.
  // Duration 10s + easeOut matches Moonfin: quick start, then settles.
  late final AnimationController _kenBurns = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _kenBurns.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _BackdropPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _kenBurns.forward(from: 0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _kenBurns.stop();
    }
  }

  @override
  void dispose() {
    _kenBurns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      // Feather the bottom of the hero into the page background — matches
      // the plugin's `mask-image: linear-gradient(to top, transparent 2%,
      // … 8%)`. Confined to a single page so the gradient shader doesn't
      // recompose across the whole PageView during horizontal scrolls.
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.black, Colors.transparent],
          stops: [0, 0.78, 1],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _kenBurns,
            builder: (context, child) {
              final t = Curves.easeOut.transform(_kenBurns.value);
              final scale = 1.0 + 0.08 * t;
              return Transform.scale(scale: scale, child: child);
            },
            child: ExcludeSemantics(child: _BackdropImage(slide: widget.slide)),
          ),
          const ExcludeSemantics(child: _ScrimLayer()),
        ],
      ),
    );
  }
}

class _BackdropImage extends StatelessWidget {
  const _BackdropImage({required this.slide});

  final JfFullHeroSlide slide;

  @override
  Widget build(BuildContext context) {
    final url = slide.backdropUrl;
    if (url == null || url.isEmpty) {
      return const ColoredBox(color: AppColors.surface);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.25),
      // 350ms: no exact token match (closest to slow=360)
      fadeInDuration: const Duration(milliseconds: 350),
      placeholder: (_, __) => const ColoredBox(color: AppColors.surface),
      errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.surface),
    );
  }
}

class _ScrimLayer extends StatelessWidget {
  const _ScrimLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Diagonal scrim — darker on the bottom-left where text/CTA sit.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-1, -0.6),
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          // Strong vertical bottom-to-top gradient for the metadata strip.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0),
                ],
                stops: const [0, 0.32, 0.7],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Foreground content
// ─────────────────────────────────────────────────────────────────────────────

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.slide,
    required this.topPadding,
    required this.onPrimaryTap,
    required this.onDetailTap,
    required this.onFavoriteToggle,
    super.key,
  });

  final JfFullHeroSlide slide;
  final double topPadding;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onDetailTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topPadding + AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _LogoOrTitle(slide: slide),
          const SizedBox(height: AppSpacing.md),
          _MetadataStrip(slide: slide),
          if (slide.genres.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _Genres(genres: slide.genres),
          ],
          if (slide.overview != null && slide.overview!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              slide.overview!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.35,
                shadows: const [
                  Shadow(
                    color: Color(0x99000000),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _ActionsRow(
            slide: slide,
            onPrimaryTap: onPrimaryTap,
            onDetailTap: onDetailTap,
            onFavoriteToggle: onFavoriteToggle,
          ),
        ],
      ),
    );
  }
}

class _LogoOrTitle extends StatelessWidget {
  const _LogoOrTitle({required this.slide});

  final JfFullHeroSlide slide;

  // Fixed reservation for the logo/title area. Keeping a constant bounding
  // box across slides is what makes the AnimatedSwitcher crossfade look
  // stable — otherwise two logos with different intrinsic widths share the
  // same left edge but the visual centre appears to "drift" leftward as
  // the wider, fading-out logo loses opacity.
  static const double _boxWidth = 320;
  static const double _boxHeight = 110;

  @override
  Widget build(BuildContext context) {
    final logo = slide.logoUrl;
    final fallback = SizedBox(
      width: _boxWidth,
      height: _boxHeight,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: _TitleFallback(title: slide.title),
      ),
    );
    if (logo == null || logo.isEmpty) return fallback;
    // Setting width + height on CachedNetworkImage forces the Image's
    // render box to a constant size — the actual bitmap is then painted
    // inside via fit:contain at the bottom-left corner. Whatever the
    // logo's intrinsic ratio, its bounding box stays identical across
    // slides, so the AnimatedSwitcher crossfade has no perceived
    // horizontal drift.
    return CachedNetworkImage(
      imageUrl: logo,
      width: _boxWidth,
      height: _boxHeight,
      fit: BoxFit.contain,
      alignment: Alignment.bottomLeft,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}

class _TitleFallback extends StatelessWidget {
  const _TitleFallback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.displaySmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        height: 1,
        shadows: const [
          Shadow(
            color: Color(0xCC000000),
            blurRadius: 18,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _MetadataStrip extends StatelessWidget {
  const _MetadataStrip({required this.slide});

  final JfFullHeroSlide slide;

  @override
  Widget build(BuildContext context) {
    final parts = <Widget>[];

    if (slide.rating != null) {
      parts.add(_RatingBadge(rating: slide.rating!));
    }
    if (slide.year != null) {
      parts.add(_MetaText(text: slide.year!.toString()));
    }
    if (slide.ageRating != null && slide.ageRating!.isNotEmpty) {
      parts.add(_AgeChip(label: slide.ageRating!));
    }
    if (slide.runtimeMinutes != null && slide.runtimeMinutes! > 0) {
      parts.add(_MetaText(text: _formatRuntime(slide.runtimeMinutes!)));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const _Separator(),
          parts[i],
        ],
      ],
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.display(
        size: 13,
        weight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.92),
      ),
    );
  }
}

String _formatRuntime(int minutes) {
  if (minutes < 60) return '${minutes}min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '${h}h';
  return '${h}h ${m.toString().padLeft(2, '0')}';
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.55),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF2B01E)),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: AppTypography.display(
            size: 13,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AgeChip extends StatelessWidget {
  const _AgeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Genres extends StatelessWidget {
  const _Genres({required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    final shown = genres.take(3).toList();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const _Separator(),
          Text(
            shown[i],
            style: AppTypography.display(
              size: 12,
              weight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.slide,
    required this.onPrimaryTap,
    required this.onDetailTap,
    required this.onFavoriteToggle,
  });

  final JfFullHeroSlide slide;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onDetailTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onDetailTap != null) ...[
          _CircleButton(
            icon: Icons.info_outline,
            onTap: onDetailTap!,
            tooltip: context.l10n.heroDetails,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: JfButton.primary(
            label: slide.primaryLabel ?? context.l10n.commonPlay,
            icon: slide.primaryIcon,
            onPressed: onPrimaryTap,
          ),
        ),
        if (onFavoriteToggle != null) ...[
          const SizedBox(width: AppSpacing.sm),
          _CircleButton(
            icon: (slide.isFavorite ?? false)
                ? Icons.favorite
                : Icons.favorite_border,
            onTap: onFavoriteToggle!,
            tooltip: (slide.isFavorite ?? false)
                ? context.l10n.heroFavoriteRemove
                : context.l10n.heroFavoriteAdd,
            iconColor: (slide.isFavorite ?? false)
                ? const Color(0xFFE53935)
                : Colors.white,
          ),
        ],
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, size: 22, color: iconColor ?? Colors.white),
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          // 300ms: no exact token match (between medium=220 & slow=360)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}
