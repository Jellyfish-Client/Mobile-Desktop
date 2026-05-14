import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/bridge/bridge_services.dart';
import '../../core/upcoming/models.dart';
import '../../core/upcoming/upcoming_client.dart';
import '../../l10n/l10n_extension.dart';

/// Range of upcoming releases to surface, in days from today.
enum CalendarRange {
  d30(30, '30 jours'),
  d90(90, '3 mois'),
  d365(365, '1 an');

  const CalendarRange(this.days, this.label);

  final int days;
  final String label;
}

enum CalendarKindFilter {
  all('Tout'),
  movies('Films'),
  episodes('Épisodes');

  const CalendarKindFilter(this.label);

  final String label;
}

class CalendarFilters {
  const CalendarFilters({
    this.range = CalendarRange.d30,
    this.kind = CalendarKindFilter.all,
    this.onlyMissing = true,
  });

  final CalendarRange range;
  final CalendarKindFilter kind;
  final bool onlyMissing;

  CalendarFilters copyWith({
    CalendarRange? range,
    CalendarKindFilter? kind,
    bool? onlyMissing,
  }) {
    return CalendarFilters(
      range: range ?? this.range,
      kind: kind ?? this.kind,
      onlyMissing: onlyMissing ?? this.onlyMissing,
    );
  }
}

final calendarFiltersProvider = StateProvider<CalendarFilters>(
  (_) => const CalendarFilters(),
);

/// Fetches `/jellyfish/upcoming` with the current filters. autoDispose so the
/// list refreshes on every filter change without leaking older queries.
final calendarItemsProvider = FutureProvider.autoDispose<List<UpcomingItem>>((
  ref,
) async {
  final filters = ref.watch(calendarFiltersProvider);
  final services = await ref.watch(bridgeServicesProvider.future);
  if (!services.radarrAvailable && !services.sonarrAvailable) {
    return const [];
  }
  final kinds = switch (filters.kind) {
    CalendarKindFilter.all => {UpcomingKind.movies, UpcomingKind.episodes},
    CalendarKindFilter.movies => {UpcomingKind.movies},
    CalendarKindFilter.episodes => {UpcomingKind.episodes},
  };
  return ref
      .read(upcomingClientProvider)
      .get(
        days: filters.range.days,
        kinds: kinds,
        onlyMissing: filters.onlyMissing,
        limit: 200,
      );
});

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(bridgeServicesProvider);
    final filters = ref.watch(calendarFiltersProvider);
    final itemsAsync = ref.watch(calendarItemsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.calendarTitle)),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            _EmptyState(message: context.l10n.calendarNoData),
        data: (services) {
          if (!services.pluginInstalled) {
            return _EmptyState(message: context.l10n.calendarNoPlugin);
          }
          if (!services.radarrAvailable && !services.sonarrAvailable) {
            return _EmptyState(message: context.l10n.calendarNoServices);
          }
          return Column(
            children: [
              _Filters(filters: filters),
              const Divider(height: 1),
              Expanded(
                child: itemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      _EmptyState(message: context.l10n.calendarLoadError),
                  data: (items) {
                    if (items.isEmpty) {
                      return _EmptyState(
                        message: context.l10n.calendarNoItems,
                      );
                    }
                    return _GroupedList(items: items);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.filters});

  final CalendarFilters filters;

  String _kindLabel(BuildContext context, CalendarKindFilter k) {
    final l10n = context.l10n;
    return switch (k) {
      CalendarKindFilter.all => l10n.calendarAllTypes,
      CalendarKindFilter.movies => l10n.calendarMovies,
      CalendarKindFilter.episodes => l10n.calendarEpisodes,
    };
  }

  String _rangeLabel(BuildContext context, CalendarRange r) {
    final l10n = context.l10n;
    return switch (r) {
      CalendarRange.d30 => l10n.calendar30Days,
      CalendarRange.d90 => l10n.calendar90Days,
      CalendarRange.d365 => l10n.calendar365Days,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calendarFiltersProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final k in CalendarKindFilter.values)
                ChoiceChip(
                  label: Text(_kindLabel(context, k)),
                  selected: filters.kind == k,
                  onSelected: (_) =>
                      notifier.update((s) => s.copyWith(kind: k)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final r in CalendarRange.values)
                      ChoiceChip(
                        label: Text(_rangeLabel(context, r)),
                        selected: filters.range == r,
                        onSelected: (_) =>
                            notifier.update((s) => s.copyWith(range: r)),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(context.l10n.calendarMissing),
                  Switch(
                    value: filters.onlyMissing,
                    onChanged: (v) =>
                        notifier.update((s) => s.copyWith(onlyMissing: v)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.items});

  final List<UpcomingItem> items;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(items);
    final dayKeys = grouped.keys.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: dayKeys.length,
      itemBuilder: (context, i) {
        final dayKey = dayKeys[i];
        final dayItems = grouped[dayKey]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                _formatDayHeader(dayItems.first.releaseDate),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final item in dayItems) _UpcomingTile(item: item),
          ],
        );
      },
    );
  }

  Map<int, List<UpcomingItem>> _groupByDay(List<UpcomingItem> items) {
    final out = <int, List<UpcomingItem>>{};
    for (final item in items) {
      final d = item.releaseDate;
      final key = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      out.putIfAbsent(key, () => <UpcomingItem>[]).add(item);
    }
    return out;
  }

  String _formatDayHeader(DateTime d) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    const weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.item});

  final UpcomingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: item.posterUrl.isEmpty
          ? const Icon(Icons.movie_outlined, size: 40)
          : ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 40,
                height: 60,
                child: Image.network(
                  item.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.movie_outlined, size: 40),
                ),
              ),
            ),
      title: Text(switch (item) {
        UpcomingMovie(:final title) => title,
        UpcomingEpisode(:final seriesTitle) => seriesTitle,
      }),
      subtitle: Text(
        switch (item) {
          UpcomingMovie(:final year) => year == null ? 'Film' : 'Film · $year',
          UpcomingEpisode(
            :final seasonNumber,
            :final episodeNumber,
            :final title,
          ) =>
            'S${seasonNumber.toString().padLeft(2, '0')}'
                'E${episodeNumber.toString().padLeft(2, '0')} · $title',
        },
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: item.hasFile
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
