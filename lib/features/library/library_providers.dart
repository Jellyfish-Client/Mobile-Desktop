import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../core/jellyfin/jellyfin_client.dart';
import '../../core/jellyfin/mappers/base_item_dto_mapper.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../l10n/app_localizations.dart';

final userViewsProvider = FutureProvider.autoDispose<List<JellyfinItem>>((
  ref,
) async {
  final dtos = await ref.read(jellyfinClientProvider).userViews();
  return dtos.toDomainList();
});

class LibraryState {
  const LibraryState({
    this.items = const [],
    this.selectedView,
    this.searchTerm = '',
    this.startIndex = 0,
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<JellyfinItem> items;
  final JellyfinItem? selectedView;
  final String searchTerm;
  final int startIndex;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;

  bool get hasMore => items.length < totalCount;

  LibraryState copyWith({
    List<JellyfinItem>? items,
    String? searchTerm,
    int? startIndex,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return LibraryState(
      items: items ?? this.items,
      selectedView: selectedView,
      searchTerm: searchTerm ?? this.searchTerm,
      startIndex: startIndex ?? this.startIndex,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LibraryNotifier extends AutoDisposeNotifier<LibraryState> {
  static const _pageSize = 50;

  // Bumped whenever fetch/setView/setSearch starts a new request cycle.
  // In-flight awaits compare against this and bail out if superseded —
  // prevents stale results from leaking into a newer scope.
  int _gen = 0;

  // Cached kinds derived from userViews; survives userViewsProvider's
  // autoDispose so loadMore() doesn't trigger a network refetch.
  List<BaseItemKind>? _cachedRootKinds;

  @override
  LibraryState build() {
    Future.microtask(fetch);
    return const LibraryState(isLoading: true);
  }

  JellyfinClient get _client => ref.read(jellyfinClientProvider);

  Future<({String? parentId, List<BaseItemKind>? kinds})>
  _resolveScope() async {
    final view = state.selectedView;
    if (view != null) {
      // queryItems uses recursive=true so Jellyfin would otherwise descend
      // into Series → Seasons → Episodes. Force kinds derived from this
      // view's collectionType to keep only top-level items in the grid.
      return (parentId: view.id, kinds: rootKindsForViews([view]));
    }
    final cached = _cachedRootKinds;
    if (cached != null) {
      return (parentId: null, kinds: cached);
    }
    final views = await ref.read(userViewsProvider.future);
    final kinds = rootKindsForViews(views);
    _cachedRootKinds = kinds;
    return (parentId: null, kinds: kinds);
  }

  Future<void> fetch() async {
    final gen = ++_gen;
    state = state.copyWith(
      isLoading: true,
      items: const [],
      startIndex: 0,
      totalCount: 0,
      clearError: true,
    );
    try {
      final scope = await _resolveScope();
      if (gen != _gen) return;
      final result = await _client.queryItems(
        parentId: scope.parentId,
        searchTerm: state.searchTerm.isEmpty ? null : state.searchTerm,
        includeItemTypes: scope.kinds,
        startIndex: 0,
        limit: _pageSize,
      );
      if (gen != _gen) return;
      final mapped = (result.items?.toList() ?? const <BaseItemDto>[])
          .toDomainList();
      state = state.copyWith(
        items: mapped,
        totalCount: result.totalRecordCount ?? 0,
        startIndex: mapped.length,
        isLoading: false,
      );
    } on Exception catch (e) {
      if (gen != _gen) return;
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final gen = _gen;
    state = state.copyWith(isLoadingMore: true);
    try {
      final scope = await _resolveScope();
      if (gen != _gen) return;
      final result = await _client.queryItems(
        parentId: scope.parentId,
        searchTerm: state.searchTerm.isEmpty ? null : state.searchTerm,
        includeItemTypes: scope.kinds,
        startIndex: state.startIndex,
        limit: _pageSize,
      );
      if (gen != _gen) return;
      final newItems = (result.items?.toList() ?? const <BaseItemDto>[])
          .toDomainList();
      state = state.copyWith(
        items: [...state.items, ...newItems],
        totalCount: result.totalRecordCount ?? state.totalCount,
        startIndex: state.startIndex + newItems.length,
        isLoadingMore: false,
      );
    } on Exception catch (e) {
      if (gen != _gen) return;
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  void setView(JellyfinItem? view) {
    if (state.selectedView?.id == view?.id) return;
    state = LibraryState(
      selectedView: view,
      searchTerm: state.searchTerm,
      isLoading: true,
    );
    fetch();
  }

  void setSearch(String term) {
    if (state.searchTerm == term) return;
    state = state.copyWith(searchTerm: term);
    fetch();
  }
}

final libraryNotifierProvider =
    AutoDisposeNotifierProvider<LibraryNotifier, LibraryState>(
      LibraryNotifier.new,
    );

/// Maps the user's libraries to the set of top-level item kinds that should
/// appear when no library is selected. Excludes Season/Episode so series stay
/// grouped under their parent.
List<BaseItemKind> rootKindsForViews(List<JellyfinItem> views) {
  final kinds = <BaseItemKind>{};
  var sawUnknown = false;
  for (final v in views) {
    final type = v.collectionType;
    if (type == CollectionType.movies) {
      kinds.add(BaseItemKind.movie);
    } else if (type == CollectionType.tvshows) {
      kinds.add(BaseItemKind.series);
    } else if (type == CollectionType.boxsets) {
      kinds.add(BaseItemKind.boxSet);
    } else if (type == CollectionType.music) {
      kinds.add(BaseItemKind.musicAlbum);
    } else if (type == CollectionType.books) {
      kinds.add(BaseItemKind.book);
    } else if (type == CollectionType.homevideos) {
      kinds
        ..add(BaseItemKind.video)
        ..add(BaseItemKind.photo);
    } else if (type == CollectionType.musicvideos) {
      kinds.add(BaseItemKind.musicVideo);
    } else if (type == CollectionType.photos) {
      kinds.add(BaseItemKind.photo);
    } else if (type == CollectionType.trailers) {
      kinds.add(BaseItemKind.trailer);
    } else if (type == CollectionType.playlists) {
      kinds.add(BaseItemKind.playlist);
    } else {
      sawUnknown = true;
    }
  }
  if (sawUnknown || kinds.isEmpty) {
    kinds
      ..add(BaseItemKind.movie)
      ..add(BaseItemKind.series);
  }
  return kinds.toList();
}

/// One entry per rail to display on Home for a given Jellyfin library view.
/// For TV shows we surface two distinct rails — newly added episodes and
/// newly added series — because they answer different questions ("what's new
/// to watch tonight" vs "what new shows did the server pick up").
class HomeLibraryRailKind {
  const HomeLibraryRailKind({required this.kind, required this.suffix});

  final BaseItemKind kind;

  /// Human-readable label appended after the library name (e.g. "Nouveaux
  /// épisodes", "Nouveaux films").
  final String suffix;
}

List<HomeLibraryRailKind> latestRailKindsForView(
  JellyfinItem view,
  AppLocalizations l10n,
) {
  final type = view.collectionType;
  if (type == CollectionType.movies) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.movie,
        suffix: l10n.libraryRailNewMovies,
      ),
    ];
  }
  if (type == CollectionType.tvshows) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.episode,
        suffix: l10n.libraryRailNewEpisodes,
      ),
      HomeLibraryRailKind(
        kind: BaseItemKind.series,
        suffix: l10n.libraryRailNewSeries,
      ),
    ];
  }
  if (type == CollectionType.boxsets) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.boxSet,
        suffix: l10n.libraryRailNewBoxsets,
      ),
    ];
  }
  if (type == CollectionType.music) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.musicAlbum,
        suffix: l10n.libraryRailNewAlbums,
      ),
    ];
  }
  if (type == CollectionType.musicvideos) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.musicVideo,
        suffix: l10n.libraryRailNewMusicVideos,
      ),
    ];
  }
  if (type == CollectionType.books) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.book,
        suffix: l10n.libraryRailNewBooks,
      ),
    ];
  }
  if (type == CollectionType.homevideos) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.video,
        suffix: l10n.libraryRailNewVideos,
      ),
    ];
  }
  if (type == CollectionType.photos) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.photo,
        suffix: l10n.libraryRailNewPhotos,
      ),
    ];
  }
  if (type == CollectionType.trailers) {
    return [
      HomeLibraryRailKind(
        kind: BaseItemKind.trailer,
        suffix: l10n.libraryRailNewTrailers,
      ),
    ];
  }
  return const [];
}
