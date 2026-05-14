import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Virtual folders (a.k.a. media libraries) configured on the server, with
/// their paths, collection type, and metadata. Backs the libraries admin
/// screen and the per-library access toggles in the user editor.
final adminLibrariesProvider =
    FutureProvider.autoDispose<List<VirtualFolderInfo>>((ref) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getLibraryStructureApi().getVirtualFolders();
  return res.data?.toList() ?? const [];
});
