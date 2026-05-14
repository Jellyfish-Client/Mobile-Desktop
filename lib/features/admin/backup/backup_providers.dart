import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Lists every backup archive sitting in the server's BackupPath. Sorted by
/// `dateCreated` descending so the most recent restore candidate floats to
/// the top of the screen. The mutation methods refresh the same state so
/// the list stays in sync after Create / Restore.
class AdminBackupNotifier
    extends AutoDisposeAsyncNotifier<List<BackupManifestDto>> {
  @override
  Future<List<BackupManifestDto>> build() => _fetch();

  Future<List<BackupManifestDto>> _fetch() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getBackupApi().listBackups();
    final list = (res.data?.toList() ?? <BackupManifestDto>[])
      ..sort((a, b) {
        final ad = a.dateCreated;
        final bd = b.dateCreated;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Spawns a new backup on the server. We pass `null` for the options dto
  /// so the server applies its own defaults (which is what the web admin
  /// does when you click the bare "Create" button).
  Future<BackupManifestDto> create() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getBackupApi().createBackup();
    await refresh();
    return res.data!;
  }

  /// Triggers a restore against [archiveFileName] (matches `manifest.path`
  /// as exposed by /Backup). The server restarts as part of the operation,
  /// which means the response usually comes back immediately and any
  /// subsequent request will fail until the restart completes.
  Future<void> restore(String archiveFileName) async {
    final api = ref.read(jellyfinApiProvider);
    final body = BackupRestoreRequestDto(
      (b) => b..archiveFileName = archiveFileName,
    );
    await api
        .getBackupApi()
        .startRestoreBackup(backupRestoreRequestDto: body);
    await refresh();
  }
}

final adminBackupProvider = AutoDisposeAsyncNotifierProvider<
    AdminBackupNotifier, List<BackupManifestDto>>(AdminBackupNotifier.new);
