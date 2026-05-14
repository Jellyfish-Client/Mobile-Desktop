import 'package:flutter/material.dart';

import 'jf_hero_carousel.dart';

/// Compact hero carousel wrapper. Defaults to [height] 320, with slides
/// clamped to at most [slideCount] (max 4).
class JfMiniHeroCarousel extends StatelessWidget {
  const JfMiniHeroCarousel({
    required this.slides,
    required this.onSlideTap,
    this.slideCount = 4,
    this.height = 320,
    this.topPadding = 0,
    super.key,
  });

  final List<JfHeroSlide> slides;
  final ValueChanged<JfHeroSlide> onSlideTap;
  final int slideCount;
  final double height;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final clamped = slides.take(slideCount.clamp(1, 4)).toList();
    if (clamped.isEmpty) return const SizedBox.shrink();
    return JfHeroCarousel(
      slides: clamped,
      onSlideTap: onSlideTap,
      height: height,
      topPadding: topPadding,
    );
  }
}
