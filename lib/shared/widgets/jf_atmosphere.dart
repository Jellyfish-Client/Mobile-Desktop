import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Subtle film-grain noise overlay. Painted once with a fixed seed so the
/// pattern is stable across rebuilds — no per-frame jitter, no perf hit.
/// Use as a top-most layer in a Stack at low opacity.
class JfGrainOverlay extends StatelessWidget {
  const JfGrainOverlay({this.opacity = 0.05, this.seed = 42, super.key});

  final double opacity;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(opacity: opacity, seed: seed),
        size: Size.infinite,
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter({required this.opacity, required this.seed});

  final double opacity;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(seed);
    final density = (size.width * size.height / 6000).round().clamp(80, 4000);
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    for (var i = 0; i < density; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.seed != seed;
}
