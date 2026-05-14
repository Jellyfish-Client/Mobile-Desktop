import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Virtual folders (a.k.a. media libraries) configured on the server, with
/// their paths, collection type, and metadata. Backs the libraries admin
/// screen and the per-library access toggles in the user editor.
///
/// The notifier exposes CRUD operations as instance methods so callers can
/// chain `await ref.read(adminLibrariesProvider.notifier).rename(...)` and
/// let the UI refresh from the resulting state update.
class AdminLibrariesNotifier
    extends AutoDisposeAsyncNotifier<List<VirtualFolderInfo>> {
  @override
  Future<List<VirtualFolderInfo>> build() => _fetch();

  Future<List<VirtualFolderInfo>> _fetch() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getLibraryStructureApi().getVirtualFolders();
    return (res.data?.toList() ?? <VirtualFolderInfo>[])
      ..sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
              (b.name ?? '').toLowerCase(),
            ),
      );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Create a new virtual folder (library).
  Future<void> create({
    required String name,
    required CollectionTypeOptions collectionType,
    required List<String> paths,
    bool refreshLibrary = true,
  }) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getLibraryStructureApi().addVirtualFolder(
          name: name,
          collectionType: collectionType,
          paths: BuiltList<String>.of(paths),
          refreshLibrary: refreshLibrary,
        );
    await refresh();
  }

  /// Rename an existing virtual folder.
  Future<void> rename(String oldName, String newName) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getLibraryStructureApi().renameVirtualFolder(
          name: oldName,
          newName: newName,
          refreshLibrary: false,
        );
    await refresh();
  }

  /// Remove a virtual folder by name.
  Future<void> remove(String name) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getLibraryStructureApi().removeVirtualFolder(
          name: name,
          refreshLibrary: false,
        );
    await refresh();
  }

  /// Add a path to an existing library.
  Future<void> addPath(String libraryName, String path) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getLibraryStructureApi().addMediaPath(
          mediaPathDto: MediaPathDto(
            (b) => b
              ..name = libraryName
              ..path = path,
          ),
          refreshLibrary: false,
        );
    await refresh();
  }

  /// Remove a single path from a library.
  Future<void> removePath(String libraryName, String path) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getLibraryStructureApi().removeMediaPath(
          name: libraryName,
          path: path,
          refreshLibrary: false,
        );
    await refresh();
  }
}

final adminLibrariesProvider = AutoDisposeAsyncNotifierProvider<
    AdminLibrariesNotifier, List<VirtualFolderInfo>>(
  AdminLibrariesNotifier.new,
);
