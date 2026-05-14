import 'package:flutter/material.dart';

class JfLogo extends StatelessWidget {
  const JfLogo({this.size = 80, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
