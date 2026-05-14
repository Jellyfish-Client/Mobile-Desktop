import 'package:flutter/material.dart';

enum HudKind { brightness, volume }

class BrightnessVolumeIndicator extends StatelessWidget {
  const BrightnessVolumeIndicator({
    required this.value,
    required this.kind,
    super.key,
  });

  /// 0..1
  final double value;
  final HudKind kind;

  @override
  Widget build(BuildContext context) {
    final icon = kind == HudKind.brightness
        ? _brightnessIcon(value)
        : _volumeIcon(value);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _brightnessIcon(double v) {
    if (v < 0.34) return Icons.brightness_low;
    if (v < 0.67) return Icons.brightness_medium;
    return Icons.brightness_high;
  }

  IconData _volumeIcon(double v) {
    if (v <= 0) return Icons.volume_off;
    if (v < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }
}
