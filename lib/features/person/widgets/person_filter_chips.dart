import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';
import '../person_providers.dart';

/// Tout / Films / Séries chip row driving `personFilterProvider(personId)`.
/// Visually identical to `_LibraryChips` in the library screen — neutral grey
/// when inactive, brand tone when selected.
class PersonFilterChips extends ConsumerWidget {
  const PersonFilterChips({required this.personId, super.key});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(personFilterProvider(personId));
    final l = context.l10n;

    void select(PersonFilter f) =>
        ref.read(personFilterProvider(personId).notifier).state = f;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _Chip(
            label: l.personFilterAll,
            semantics: l.personFilterAllSemantics,
            isSelected: selected == PersonFilter.all,
            onTap: () => select(PersonFilter.all),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: l.personFilterMovies,
            semantics: l.personFilterMoviesSemantics,
            isSelected: selected == PersonFilter.movies,
            onTap: () => select(PersonFilter.movies),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: l.personFilterSeries,
            semantics: l.personFilterSeriesSemantics,
            isSelected: selected == PersonFilter.series,
            onTap: () => select(PersonFilter.series),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.semantics,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String semantics;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: semantics,
      excludeSemantics: true,
      child: JfChip(
        label: label,
        tone: isSelected ? JfChipTone.brand : JfChipTone.neutral,
        onTap: onTap,
      ),
    );
  }
}
