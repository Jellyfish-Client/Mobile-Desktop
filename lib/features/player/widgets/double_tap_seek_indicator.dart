import 'package:flutter/material.dart';

/// Transient overlay used by the player when the user double-taps to seek.
/// Hosted in the `Stack` and toggled by setState from PlayerScreen.
class DoubleTapSeekIndicator extends StatelessWidget {
  const DoubleTapSeekIndicator({
    required this.alignLeft,
    required this.seconds,
    super.key,
  });

  final bool alignLeft;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final icon = alignLeft ? Icons.fast_rewind : Icons.fast_forward;
    final text = '${alignLeft ? '−' : '+'}${seconds}s';
    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: 140,
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
