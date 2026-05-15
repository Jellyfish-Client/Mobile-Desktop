import 'package:flutter/material.dart';

import 'bottom_bar.dart';
import 'top_bar.dart';

class ControlsOverlay extends StatelessWidget {
  const ControlsOverlay({
    required this.itemId,
    required this.visible,
    required this.onLock,
    required this.onPip,
    super.key,
  });

  final String itemId;
  final bool visible;
  final VoidCallback onLock;
  final VoidCallback? onPip;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: !visible,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 180),
          child: Column(
            children: [
              TopBar(itemId: itemId, onLock: onLock, onPip: onPip),
              const Spacer(),
              BottomBar(itemId: itemId),
            ],
          ),
        ),
      ),
    );
  }
}
