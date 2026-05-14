import 'package:flutter/material.dart';

import '../../../core/playback/segments_provider.dart';

class SkipSegmentButton extends StatelessWidget {
  const SkipSegmentButton({
    required this.segment,
    required this.onSkip,
    super.key,
  });

  final SkipSegment segment;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 24, 96),
          child: Material(
            color: Colors.white,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onSkip,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      segment.actionLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.skip_next, color: Colors.black, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
