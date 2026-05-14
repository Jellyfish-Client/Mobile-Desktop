// One-shot script: compose branding assets from source logo.
// Run with: dart run tool/build_branding.dart
//
// Outputs:
//   assets/branding/icon.png           — 1024×1024 white logo on #000000
//   assets/branding/icon_foreground.png — 1024×1024 logo centred in 66% safe area, rest transparent

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final logoBytes = File('assets/branding/logo.png').readAsBytesSync();
  final logo = img.decodePng(logoBytes)!;

  _buildIcon(logo);
  _buildIconForeground(logo);
}

void _buildIcon(img.Image logo) {
  final canvas = img.Image(width: 1024, height: 1024);
  img.fill(canvas, color: img.ColorRgb8(0, 0, 0));

  final scaled = img.copyResize(logo, width: 1024, height: 1024);
  img.compositeImage(canvas, scaled, dstX: 0, dstY: 0);

  File('assets/branding/icon.png').writeAsBytesSync(img.encodePng(canvas));
  stderr.writeln('Written assets/branding/icon.png');
}

void _buildIconForeground(img.Image logo) {
  const canvasSize = 1024;
  // 17% margin each side → logo occupies centre 66%
  final margin = (canvasSize * 0.17).round();
  final logoSize = canvasSize - margin * 2;

  final canvas = img.Image(width: canvasSize, height: canvasSize);
  // Transparent background — no fill needed; image initialises to 0,0,0,0.

  final scaled = img.copyResize(logo, width: logoSize, height: logoSize);
  img.compositeImage(canvas, scaled, dstX: margin, dstY: margin);

  File(
    'assets/branding/icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(canvas));
  stderr.writeln('Written assets/branding/icon_foreground.png');
}
