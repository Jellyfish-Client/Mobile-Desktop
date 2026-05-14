import 'package:flutter/material.dart';

/// Soft, ambient shadows for the dark UI. Three levels — pick the lowest
/// that still reads as "raised" on the surrounding surface.
class AppElevation {
  const AppElevation._();

  static const List<BoxShadow> level1 = [
    BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x55000000), blurRadius: 40, offset: Offset(0, 16)),
  ];
}
