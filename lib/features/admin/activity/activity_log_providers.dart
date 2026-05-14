import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Page size when paginating server activity log entries. Matches what the
/// Jellyfin web dashboard requests so we don't surprise admins coming from
/// there with a different rhythm of "load more" taps.
const int _pageSize = 50;

/// Immutable snapshot of the activity log screen — entries plus pagination
/// markers plus filter state. The notifier replaces the entire object on
/// every transition so the UI never observes a half-updated view.
class ActivityLogState {
  const ActivityLogState({
    required this.entries,
    required this.hasMore,
    required this.isLoadingMore,
    required this.filterLast7Days,
    required this.filterUserOnly,
  });

  final List<ActivityLogEntry> entries;
  final bool hasMore;
  final bool isLoadingMore;
  final bool filterLast7Days;
  final bool filterUserOnly;

  ActivityLogState copyWith({
    List<ActivityLogEntry>? entries,
    bool? hasMore,
    bool? isLoadingMore,
    bool? filterLast7Days,
    bool? filterUserOnly,
  }) {
    return ActivityLogState(
      entries: entries ?? this.entries,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterLast7Days: filterLast7Days ?? this.filterLast7Days,
      filterUserOnly: filterUserOnly ?? this.filterUserOnly,
    );
  }
}

class AdminActivityLogNotifier
    extends AutoDisposeAsyncNotifier<ActivityLogState> {
  bool _filterLast7Days = false;
  bool _filterUserOnly = false;

  @override
  Future<ActivityLogState> build() async {
    return _loadFirstPage();
  }

  Future<ActivityLogState> _loadFirstPage() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getActivityLogApi().getLogEntries(
          startIndex: 0,
          limit: _pageSize,
          minDate: _filterLast7Days
              ? DateTime.now().toUtc().subtract(const Duration(days: 7))
              : null,
          hasUserId: _filterUserOnly ? true : null,
        );
    final data = res.data;
    final items = data?.items?.toList() ?? const <ActivityLogEntry>[];
    final total = data?.totalRecordCount ?? items.length;
    return ActivityLogState(
      entries: items,
      hasMore: items.length < total,
      isLoadingMore: false,
      filterLast7Days: _filterLast7Days,
      filterUserOnly: _filterUserOnly,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFirstPage);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final api = ref.read(jellyfinApiProvider);
      final res = await api.getActivityLogApi().getLogEntries(
            startIndex: current.entries.length,
            limit: _pageSize,
            minDate: current.filterLast7Days
                ? DateTime.now().toUtc().subtract(const Duration(days: 7))
                : null,
            hasUserId: current.filterUserOnly ? true : null,
          );
      final data = res.data;
      final more = data?.items?.toList() ?? const <ActivityLogEntry>[];
      final total = data?.totalRecordCount ?? 0;
      final merged = [...current.entries, ...more];
      state = AsyncData(
        current.copyWith(
          entries: merged,
          hasMore: merged.length < total,
          isLoadingMore: false,
        ),
      );
    } on Object catch (e, st) {
      // Surface the error but keep the page we already had so the user
      // doesn't lose what they've already scrolled through.
      state = AsyncError(e, st);
    }
  }

  Future<void> setFilterLast7Days({required bool value}) async {
    if (_filterLast7Days == value) return;
    _filterLast7Days = value;
    await refresh();
  }

  Future<void> setFilterUserOnly({required bool value}) async {
    if (_filterUserOnly == value) return;
    _filterUserOnly = value;
    await refresh();
  }
}

final adminActivityLogProvider = AutoDisposeAsyncNotifierProvider<
    AdminActivityLogNotifier, ActivityLogState>(
  AdminActivityLogNotifier.new,
);
