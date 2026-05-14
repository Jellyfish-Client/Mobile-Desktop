import 'package:flutter/material.dart';

/// Centers and width-caps its [child] so reading-heavy content (descriptions,
/// chip groups, primary CTAs) doesn't stretch edge-to-edge on desktop windows.
///
/// On mobile the cap is a no-op — the child just fills the available width.
/// On large windows it keeps line lengths legible (~75–85 chars) and stops
/// CTAs from becoming 1900px-wide buttons. Wrap **only** the textual /
/// button blocks inside detail screens; horizontal rails (cast, similar,
/// recommendations) must stay edge-to-edge so users can scroll the full set.
class JfReadingPanel extends StatelessWidget {
  const JfReadingPanel({required this.child, this.maxWidth = 720, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
