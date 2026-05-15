import 'package:flutter/material.dart';

import '../../../l10n/l10n_extension.dart';

class LockOSDOverlay extends StatelessWidget {
  const LockOSDOverlay({required this.onUnlock, super.key});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Material(
            color: Colors.black.withValues(alpha: 0.6),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: context.l10n.playerUnlockControls,
              onPressed: onUnlock,
              icon: const Icon(Icons.lock, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
