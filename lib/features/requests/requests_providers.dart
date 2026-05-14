import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bridge/bridge_error_bus.dart';
import '../../core/bridge/bridge_errors.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum RequestFilter { all, pending, processing, available }

enum RequestSort { recent, oldest, status, title }

// ---------------------------------------------------------------------------
// Raw data
// ---------------------------------------------------------------------------

/// Fetches the signed-in user's Seerr requests (enriched with title/poster).
///
/// Not autoDispose: the data is kept alive across navigations so returning to
/// this page is instant. Pull-to-refresh calls ref.invalidate(myRequestsProvider)
/// to force a re-fetch.
final myRequestsProvider = FutureProvider<List<SeerrRequest>>((ref) async {
  final client = ref.watch(seerrClientProvider);
  try {
    return await client.myRequests(take: 100);
  } on DioException catch (e) {
    // Surface noJellyseerrAccount / not-configured to the user — but keep
    // the page renderable with an empty list rather than an error state, so
    // the toast is the primary signal.
    final mapped = mapBridgeError(e);
    if (mapped != null) {
      ref.read(bridgeErrorBusProvider.notifier).state = mapped;
      return const <SeerrRequest>[];
    }
    rethrow;
  }
});

// ---------------------------------------------------------------------------
// Filter + sort state
// ---------------------------------------------------------------------------

final requestFilterProvider = StateProvider<RequestFilter>(
  (_) => RequestFilter.all,
);

final requestSortProvider = StateProvider<RequestSort>(
  (_) => RequestSort.recent,
);

// ---------------------------------------------------------------------------
// Derived — filtered + sorted view
// ---------------------------------------------------------------------------

final filteredRequestsProvider = Provider<AsyncValue<List<SeerrRequest>>>((
  ref,
) {
  final raw = ref.watch(myRequestsProvider);
  final filter = ref.watch(requestFilterProvider);
  final sort = ref.watch(requestSortProvider);

  return raw.whenData((requests) {
    // --- filter ---
    final filtered = switch (filter) {
      RequestFilter.all => requests,
      RequestFilter.pending =>
        requests
            .where((r) => r.availability == SeerrAvailability.pending)
            .toList(),
      RequestFilter.processing =>
        requests
            .where((r) => r.availability == SeerrAvailability.processing)
            .toList(),
      RequestFilter.available =>
        requests
            .where((r) => r.availability == SeerrAvailability.available)
            .toList(),
    };

    // --- sort ---
    final sorted = List<SeerrRequest>.from(filtered);
    switch (sort) {
      case RequestSort.recent:
        sorted.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
      case RequestSort.oldest:
        sorted.sort(
          (a, b) => (a.createdAt ?? DateTime(0)).compareTo(
            b.createdAt ?? DateTime(0),
          ),
        );
      case RequestSort.status:
        // available → processing → partiallyAvailable → pending → unknown
        const order = {
          SeerrAvailability.available: 0,
          SeerrAvailability.processing: 1,
          SeerrAvailability.partiallyAvailable: 2,
          SeerrAvailability.pending: 3,
          SeerrAvailability.unknown: 4,
        };
        sorted.sort(
          (a, b) => (order[a.availability] ?? 99).compareTo(
            order[b.availability] ?? 99,
          ),
        );
      case RequestSort.title:
        sorted.sort(
          (a, b) => (a.title ?? '').toLowerCase().compareTo(
            (b.title ?? '').toLowerCase(),
          ),
        );
    }

    return sorted;
  });
});
