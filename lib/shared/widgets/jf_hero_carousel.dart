import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import 'jf_button.dart';

/// One slide in [JfHeroCarousel] — a featured item shown with a backdrop
/// image and a logo (or title text fallback).
class JfHeroSlide {
  const JfHeroSlide({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.logoUrl,
    this.subtitle,
    this.actionLabel = 'Play',
    this.actionIcon = Icons.play_arrow,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final String? logoUrl;
  final String? subtitle;

  /// CTA label rendered on the slide's button. Default `Play` for Jellyfin
  /// items already on the server; override (e.g. `Demander`) for Seerr items
  /// the user has to request first.
  final String actionLabel;
  final IconData actionIcon;
}

/// Compact featured carousel — card-style, sitting just below the status-bar
/// notch.
///
/// Built on a [PageView] so the OS-level scrolling is buttery and the
/// rendering layer is lean — no nested `AnimatedBuilder` + `ShaderMask`
/// stacks that triggered Stack Overflows / 500+ skipped frames on Impeller.
/// A subtle scale + opacity fade is applied per page based on the page
/// controller's offset.
class JfHeroCarousel extends StatefulWidget {
  const JfHeroCarousel({
    required this.slides,
    required this.onSlideTap,
    this.height = 380,
    this.topPadding = 0,
    this.autoplayInterval = const Duration(seconds: 6),
    super.key,
  });

  final List<JfHeroSlide> slides;
  final ValueChanged<JfHeroSlide> onSlideTap;

  /// Height of the visible card area (excluding [topPadding]).
  final double height;
  final double topPadding;
  final Duration autoplayInterval;

  @override
  State<JfHeroCarousel> createState() => _JfHeroCarouselState();
}

class _JfHeroCarouselState extends State<JfHeroCarousel> {
  late final PageController _pageController = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _scheduleAutoplay();
  }

  @override
  void didUpdateWidget(covariant JfHeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slides.length != oldWidget.slides.length) {
      // Slide list shape changed (e.g. pull-to-refresh) — reset to first page
      // so we don't end up on an out-of-range index.
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _index = 0;
      _scheduleAutoplay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleAutoplay() {
    _timer?.cancel();
    if (widget.slides.length < 2) return;
    _timer = Timer.periodic(widget.autoplayInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_index + 1) % widget.slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: AppMotion.emphasized,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final cardTop = widget.topPadding + AppSpacing.lg;

    return SizedBox(
      height: cardTop + widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: cardTop),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _Slide(
                    slide: widget.slides[i],
                    controller: _pageController,
                    pageIndex: i,
                    onTap: () => widget.onSlideTap(widget.slides[i]),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.md,
                  child: _DotIndicator(
                    count: widget.slides.length,
                    activeIndex: _index,
                    scheme: scheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.slide,
    required this.controller,
    required this.pageIndex,
    required this.onTap,
  });

  final JfHeroSlide slide;
  final PageController controller;
  final int pageIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Page offset relative to this slide's position. 0 when this slide is
        // fully visible; ±1 when it's the adjacent slide. We dampen scale +
        // opacity slightly off-centre so the swipe feels alive without going
        // overboard.
        var t = 0.0;
        if (controller.position.haveDimensions) {
          t =
              (controller.page ?? controller.initialPage.toDouble()) -
              pageIndex;
        }
        final dist = t.abs().clamp(0.0, 1.0);
        final scale = 1 - 0.04 * dist;
        final opacity = 1 - 0.25 * dist;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (slide.imageUrl != null && slide.imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: slide.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: AppColors.surface),
                    errorWidget: (_, __, ___) =>
                        const ColoredBox(color: AppColors.surface),
                  )
                else
                  const ColoredBox(color: AppColors.surface),

                // Gradient scrim for text legibility — top + bottom.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0, 0.35, 1],
                      ),
                    ),
                  ),
                ),

                // Content (title/logo + subtitle + CTA), pinned to bottom-left.
                Positioned(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xxl + AppSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (slide.logoUrl != null && slide.logoUrl!.isNotEmpty)
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 70,
                            maxWidth: 220,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: slide.logoUrl!,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomLeft,
                            errorWidget: (_, __, ___) =>
                                _titleFallback(theme, slide.title),
                          ),
                        )
                      else
                        _titleFallback(theme, slide.title),
                      if (slide.subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          slide.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      JfButton.primary(
                        label: slide.actionLabel,
                        onPressed: onTap,
                        icon: slide.actionIcon,
                      ),
                    ],
                  ),
                ),

                // Subtle inner border highlight.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.count,
    required this.activeIndex,
    required this.scheme,
  });

  final int count;
  final int activeIndex;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    if (count < 2) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: AppMotion.standard,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

Widget _titleFallback(ThemeData theme, String title) {
  return Text(
    title,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: theme.textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.05,
      shadows: const [
        Shadow(color: Color(0xAA000000), blurRadius: 20, offset: Offset(0, 2)),
      ],
    ),
  );
}
