import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemDto;

import '../../core/jellyfin/jellyfin_client.dart';
import '../../core/jellyfin/mappers/base_item_dto_mapper.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.jellyfin = const [],
    this.seerr = const [],
    this.seerrCollections = const [],
    this.jellyfinError,
    this.seerrError,
  });

  final String query;
  final bool isLoading;
  final List<JellyfinItem> jellyfin;
  final List<SeerrMedia> seerr;
  final List<SeerrCollection> seerrCollections;
  final Object? jellyfinError;
  final Object? seerrError;

  bool get isEmpty => query.trim().isEmpty;
  bool get hasResults =>
      jellyfin.isNotEmpty || seerr.isNotEmpty || seerrCollections.isNotEmpty;

  SearchState copyWith({
    String? query,
    bool? isLoading,
    List<JellyfinItem>? jellyfin,
    List<SeerrMedia>? seerr,
    List<SeerrCollection>? seerrCollections,
    Object? jellyfinError,
    Object? seerrError,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      jellyfin: jellyfin ?? this.jellyfin,
      seerr: seerr ?? this.seerr,
      seerrCollections: seerrCollections ?? this.seerrCollections,
      jellyfinError: jellyfinError,
      seerrError: seerrError,
    );
  }
}

class SearchNotifier extends AutoDisposeNotifier<SearchState> {
  static const _debounceMs = 350;
  static const _jellyfinLimit = 30;

  Timer? _debounce;
  int _requestId = 0;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void setQuery(String value) {
    final trimmed = value.trim();
    state = state.copyWith(query: value);

    _debounce?.cancel();

    if (trimmed.isEmpty) {
      // Drop pending results but keep the raw text in state.
      _requestId++;
      state = SearchState(query: value);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      _runSearch(trimmed);
    });
  }

  Future<void> retry() async {
    final trimmed = state.query.trim();
    if (trimmed.isEmpty) return;
    _debounce?.cancel();
    await _runSearch(trimmed);
  }

  Future<void> _runSearch(String query) async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true);

    final jellyfinClient = ref.read(jellyfinClientProvider);
    final seerrClient = ref.read(seerrClientProvider);

    final jellyfinFuture = _safe<List<JellyfinItem>>(() async {
      final res = await jellyfinClient.queryItems(
        searchTerm: query,
        limit: _jellyfinLimit,
      );
      return (res.items?.toList() ?? const <BaseItemDto>[]).toDomainList();
    }, fallback: const []);

    final seerrFuture = seerrClient.isLinked
        ? _safe<_SeerrSearchPayload>(() async {
            final result = await seerrClient.search(query);
            return _SeerrSearchPayload(
              media: result.media,
              collections: result.collections,
            );
          }, fallback: const _SeerrSearchPayload(media: [], collections: []))
        : Future.value(
            const _Outcome<_SeerrSearchPayload>(
              value: _SeerrSearchPayload(media: [], collections: []),
              error: null,
            ),
          );

    final (jfOutcome, seerrOutcome) = await (jellyfinFuture, seerrFuture).wait;

    if (requestId != _requestId) return;

    state = state.copyWith(
      isLoading: false,
      jellyfin: jfOutcome.value,
      seerr: seerrOutcome.value.media,
      seerrCollections: seerrOutcome.value.collections,
      jellyfinError: jfOutcome.error,
      seerrError: seerrOutcome.error,
    );
  }

  void clear() {
    _debounce?.cancel();
    _requestId++;
    state = const SearchState();
  }

  Future<_Outcome<T>> _safe<T>(
    Future<T> Function() task, {
    required T fallback,
  }) async {
    try {
      return _Outcome(value: await task(), error: null);
    } on Object catch (e) {
      return _Outcome(value: fallback, error: e);
    }
  }
}

class _Outcome<T> {
  const _Outcome({required this.value, required this.error});
  final T value;
  final Object? error;
}

class _SeerrSearchPayload {
  const _SeerrSearchPayload({required this.media, required this.collections});
  final List<SeerrMedia> media;
  final List<SeerrCollection> collections;
}

final searchNotifierProvider =
    AutoDisposeNotifierProvider<SearchNotifier, SearchState>(
      SearchNotifier.new,
    );
