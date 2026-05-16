import 'package:flutter/material.dart';

/// Initials placeholder used inside any `ClipOval` avatar when the source
/// image is missing or fails to load. Pulled out of `cast_row.dart` so the
/// person detail screen renders the same fallback without duplicating logic.
class JfAvatarInitials extends StatelessWidget {
  const JfAvatarInitials({required this.name, this.fontSize = 22, super.key});

  final String name;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }

  /// First letter of the first word + first letter of the last word, uppercased.
  /// Falls back to `?` when [name] has no usable characters.
  static String initialsOf(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
