import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/jellyfin/models/jellyfin_item.dart';
import '../../../shared/widgets/widgets.dart';

/// Wraps an item's production studios as info chips. Hides when none.
class StudiosRow extends StatelessWidget {
  const StudiosRow({required this.item, super.key});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context) {
    final names = [
      for (final s in item.studios)
        if (s.name != null && s.name!.isNotEmpty) s.name!,
    ];
    if (names.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final n in names) JfChip(label: n, icon: Icons.business_rounded),
      ],
    );
  }
}
