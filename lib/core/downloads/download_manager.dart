import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../auth/account_key.dart';
import '../auth/auth_controller.dart';
import '../jellyfin/jellyfin_client.dart';
import '../network/dio_provider.dart';
import '../storage/app_database.dart';
import '../storage/app_database_provider.dart';
import '../storage/device_id.dart';
import 'download_settings.dart';
import 'download_url_builder.dart';

const _kDownloadsDir = 'downloads';
const _kImagesDir = 'downloads/images';
const _kGroup = 'jellyfish';

class DownloadManager {
  DownloadManager(this._ref) {
    _bootstrap();
  }

  final Ref _ref;
  final FileDownloader _fd = FileDownloader();
  final Logger _log = Logger('DownloadManager');
  final Uuid _uuid = const Uuid();
  StreamSubscription<TaskUpdate>? _updatesSub;
  AppLifecycleListener? _lifecycle;
  // Serializes DB writes per task so concurrent progress / status events for
  // the same task can't race (e.g. a delayed progress event overwriting a
  // completed status, or pause being clobbered by a buffered running event).
  final Map<String, Future<void>> _updateChain = {};
  // Tracks itemIds we auto-paused when the app went to background so we know
  // which ones to auto-resume on return (only the ones we touched).
  final Set<String> _autoPaused = <String>{};
  // Caches the notification-permission request so we only prompt once per
  // session. Android 13+ and iOS need this for progress notifications to show.
  Future<PermissionStatus>? _notifPermissionFuture;

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  /// Resolved on every call so the manager stays correct across account
  /// switches without needing to be torn down. Returns [legacyAccountKey]
  /// when no session is active; in that state the public API will refuse to
  /// enqueue anyway.
  String get _accountKey {
    final session = _ref.read(authControllerProvider).valueOrNull?.session;
    return accountKeyForSession(session);
  }

  void _bootstrap() {
    // Subscribe synchronously so we never miss an update fired between
    // configureNotification and trackTasks. The handler queues writes per
    // taskId, so events that arrive before trackTasks() returns are processed
    // in arrival order against the same DB.
    _updatesSub = _fd.updates.listen(
      _onUpdate,
      onError: (Object e, StackTrace s) {
        _log.warning('Download stream error', e, s);
      },
    );
    _fd.configureNotification(
      running: const TaskNotification(
        '{displayName}',
        '{progress} — {networkSpeed} — {timeRemaining} left',
      ),
      complete: const TaskNotification('Downloaded', '{displayName}'),
      error: const TaskNotification('Download failed', '{displayName}'),
      paused: const TaskNotification('Paused', '{displayName}'),
      progressBar: true,
      tapOpensFile: false,
    );
    unawaited(_fd.trackTasks());
    // `onPause` is the reliable "user backgrounded the app" signal on both
    // iOS and Android. `onHide` only fires when the surface is fully off-
    // screen and is inconsistent on iOS for lock-screen / control-centre.
    _lifecycle = AppLifecycleListener(
      onPause: _onAppBackground,
      onResume: _onAppForeground,
    );
  }

  /// Called synchronously by `ref.onDispose`. We can't await here, but
  /// `StreamSubscription.cancel()` is safe to fire-and-forget for teardown.
  void dispose() {
    _updatesSub?.cancel();
    _updatesSub = null;
    _lifecycle?.dispose();
    _lifecycle = null;
  }

  /// Pauses every running/queued task when the user turns OFF background
  /// downloads in Settings and the app moves out of the foreground. Note:
  /// `AppLifecycleListener.onPause` returns `void`, so the async work below
  /// races against the OS suspending the isolate. iOS only grants ~5s of
  /// background time; the simple `pause` calls usually fit, but if the user
  /// has many running downloads some pauses may not land before suspension.
  Future<void> _onAppBackground() async {
    final settings = _ref.read(downloadSettingsProvider).valueOrNull;
    if (settings?.backgroundEnabled ?? true) return;
    final rows = await _db.findActive(_accountKey);
    for (final r in rows) {
      if (r.taskId == null) continue;
      final t = await _fd.taskForId(r.taskId!);
      if (t is DownloadTask) {
        final paused = await _fd.pause(t);
        if (paused) _autoPaused.add(r.itemId);
      }
    }
  }

  /// Resumes whatever we auto-paused on background when the user comes back.
  Future<void> _onAppForeground() async {
    if (_autoPaused.isEmpty) return;
    final ids = _autoPaused.toList();
    _autoPaused.clear();
    for (final itemId in ids) {
      final row = await _db.findByItemId(_accountKey, itemId);
      if (row?.taskId == null) continue;
      final t = await _fd.taskForId(row!.taskId!);
      if (t is DownloadTask) {
        await _fd.resume(t);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches the item DTO from the server and enqueues it. Used by UI code
  /// that holds only an [itemId] (e.g. the migrated detail screens that
  /// surface a `JellyfinItem` rather than the raw SDK type).
  Future<void> enqueueItemById(String itemId) async {
    final dto = await _ref.read(jellyfinClientProvider).item(itemId);
    await enqueueItem(dto);
  }

  Future<void> enqueueItem(BaseItemDto item) async {
    final itemId = item.id;
    if (itemId == null) {
      throw ArgumentError('BaseItemDto has no id');
    }
    final existing = await _db.findByItemId(_accountKey, itemId);
    if (existing != null &&
        (existing.status == DownloadStatus.completed ||
            existing.status == DownloadStatus.running ||
            existing.status == DownloadStatus.queued ||
            existing.status == DownloadStatus.paused)) {
      _log.fine('Skip enqueue, already known: $itemId (${existing.status})');
      return;
    }

    final session = _ref.read(authControllerProvider).valueOrNull?.session;
    final deviceId = _ref.read(deviceIdProvider).valueOrNull;
    if (session == null || deviceId == null) {
      throw StateError('Cannot enqueue download without active session');
    }

    final settings =
        _ref.read(downloadSettingsProvider).valueOrNull ??
        DownloadSettings.defaults;

    final container = await _resolveContainer(itemId);
    final filename = '$itemId${container == null ? '' : '.$container'}';

    final endpoint = buildDownloadEndpoint(
      session: session,
      deviceId: deviceId,
      itemId: itemId,
    );

    // Use a fresh UUID per enqueue so re-downloading the same item after a
    // cancel/fail can't collide with the old task in background_downloader's
    // task DB. The mapping back to itemId lives on DownloadRow.taskId.
    final task = DownloadTask(
      taskId: _uuid.v4(),
      url: endpoint.url,
      filename: filename,
      headers: endpoint.headers,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: _kDownloadsDir,
      group: _kGroup,
      updates: Updates.statusAndProgress,
      requiresWiFi: settings.wifiOnly,
      allowPause: true,
      retries: 3,
      displayName: item.name ?? itemId,
    );

    final genres = item.genres?.toList();
    await _db.upsertRow(
      DownloadsCompanion.insert(
        accountKey: Value(_accountKey),
        itemId: itemId,
        itemType: _itemTypeOf(item),
        name: item.name ?? itemId,
        status: DownloadStatus.queued,
        createdAt: DateTime.now(),
        seriesId: Value(item.seriesId),
        seriesName: Value(item.seriesName),
        seasonId: Value(item.seasonId),
        seasonNumber: Value(item.parentIndexNumber),
        episodeNumber: Value(item.indexNumber),
        runtimeTicks: Value(item.runTimeTicks),
        container: Value(container),
        taskId: Value(task.taskId),
        overview: Value(item.overview),
        productionYear: Value(item.productionYear),
        communityRating: Value(item.communityRating),
        officialRating: Value(item.officialRating),
        genres: Value(
          (genres == null || genres.isEmpty) ? null : jsonEncode(genres),
        ),
      ),
    );

    // Image downloads are best-effort: a failure here should not block the
    // media download itself. Fire-and-forget so enqueue stays snappy.
    unawaited(_downloadImagesFor(item));

    await _ensureNotificationPermission();
    final ok = await _fd.enqueue(task);
    if (!ok) {
      await _db.setStatus(
        _accountKey,
        itemId,
        DownloadStatus.failed,
        error: 'enqueue rejected',
      );
    }
  }

  /// Best-effort download of poster + backdrop (+ series poster for episodes)
  /// into `applicationDocuments/downloads/images/`. Persists the resulting
  /// paths on the matching DownloadRow.
  Future<void> _downloadImagesFor(BaseItemDto item) async {
    final itemId = item.id;
    if (itemId == null) return;
    final client = _ref.read(jellyfinClientProvider);
    final dio = _ref.read(jellyfinDioProvider);
    final dir = await _imagesDirectory();

    Future<String?> grab(String? url, String filename) async {
      if (url == null) return null;
      final path = p.join(dir.path, filename);
      try {
        await dio.download(url, path);
        return path;
      } on Object catch (e, s) {
        _log.fine('Image download failed for $filename', e, s);
        return null;
      }
    }

    final posterUrl = client.imageUrl(
      item,
      imageType: 'Primary',
      maxWidth: 600,
    );
    final backdropUrl = client.imageUrl(
      item,
      imageType: 'Backdrop',
      maxWidth: 1280,
    );
    final posterPath = await grab(posterUrl, '${itemId}_poster.jpg');
    final backdropPath = await grab(backdropUrl, '${itemId}_backdrop.jpg');

    String? seriesPosterPath;
    final seriesId = item.seriesId;
    final seriesTag = item.seriesPrimaryImageTag;
    if (item.type == BaseItemKind.episode &&
        seriesId != null &&
        seriesTag != null) {
      final seriesUrl = client.imageUrlById(
        seriesId,
        'Primary',
        seriesTag,
        maxWidth: 600,
      );
      seriesPosterPath = await grab(seriesUrl, '${seriesId}_series.jpg');
    }

    await _db.setImagePaths(
      _accountKey,
      itemId,
      posterPath: posterPath,
      backdropPath: backdropPath,
      seriesPosterPath: seriesPosterPath,
    );
  }

  Future<Directory> _imagesDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, _kImagesDir));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<void> enqueueSeason({
    required String seriesId,
    required String seasonId,
  }) async {
    final client = _ref.read(jellyfinClientProvider);
    final episodes = await client.episodes(seriesId, seasonId: seasonId);
    const concurrency = 4;
    for (var i = 0; i < episodes.length; i += concurrency) {
      final chunk = episodes.skip(i).take(concurrency);
      await Future.wait(
        chunk.map((ep) async {
          if (ep.id == null) return;
          // Defer the "should we skip?" decision to enqueueItem so that
          // previously failed/cancelled episodes are retried rather than
          // permanently skipped.
          try {
            await enqueueItem(ep);
          } on Object catch (e, s) {
            _log.warning('Failed to enqueue episode ${ep.id}', e, s);
          }
        }),
      );
    }
  }

  Future<void> pause(String itemId) async {
    final row = await _db.findByItemId(_accountKey, itemId);
    if (row?.taskId == null) return;
    final t = await _fd.taskForId(row!.taskId!);
    if (t is DownloadTask) {
      await _fd.pause(t);
    }
  }

  Future<void> resume(String itemId) async {
    final row = await _db.findByItemId(_accountKey, itemId);
    if (row?.taskId == null) return;
    final t = await _fd.taskForId(row!.taskId!);
    if (t is DownloadTask) {
      await _fd.resume(t);
    }
  }

  Future<void> cancel(String itemId) async {
    final row = await _db.findByItemId(_accountKey, itemId);
    if (row?.taskId == null) return;
    await _fd.cancelTaskWithId(row!.taskId!);
    await _db.setStatus(_accountKey, itemId, DownloadStatus.cancelled);
  }

  Future<void> deleteDownload(String itemId) async {
    final row = await _db.findByItemId(_accountKey, itemId);
    if (row == null) return;
    if (row.taskId != null && row.status != DownloadStatus.completed) {
      await _fd.cancelTaskWithId(row.taskId!);
    }
    if (row.localFilePath != null) {
      try {
        final f = File(row.localFilePath!);
        if (f.existsSync()) await f.delete();
      } on Object catch (e, s) {
        _log.warning('Failed to delete file ${row.localFilePath}', e, s);
      }
    }
    for (final path in [row.imagePath, row.backdropImagePath]) {
      await _tryDeleteFile(path);
    }
    // Series poster is shared across episodes — only delete it once the
    // last episode of the series is gone.
    if (row.seriesImagePath != null && row.seriesId != null) {
      final siblings = await _db.bySeries(_accountKey, row.seriesId!);
      final remaining = siblings.where((s) => s.itemId != itemId).isNotEmpty;
      if (!remaining) {
        await _tryDeleteFile(row.seriesImagePath);
      }
    }
    await _db.deleteByItemId(_accountKey, itemId);
  }

  Future<void> _tryDeleteFile(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (f.existsSync()) await f.delete();
    } on Object catch (e, s) {
      _log.fine('Failed to delete image $path', e, s);
    }
  }

  Future<String?> localPathFor(String itemId) async {
    final row = await _db.findByItemId(_accountKey, itemId);
    if (row == null || row.status != DownloadStatus.completed) return null;
    final path = row.localFilePath;
    if (path == null) return null;
    if (!File(path).existsSync()) return null;
    return path;
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  void _onUpdate(TaskUpdate update) {
    // Per-taskId serial queue: chain each handler onto the previous one so DB
    // writes for the same task are strictly ordered.
    final taskId = update.task.taskId;
    final prev = _updateChain[taskId] ?? Future<void>.value();
    final next = prev.then((_) => _handleUpdate(update)).catchError((
      Object e,
      StackTrace s,
    ) {
      _log.warning('Update handler failed for $taskId', e, s);
    });
    _updateChain[taskId] = next;
    // Drop the chain entry once it settles to avoid unbounded growth.
    next.whenComplete(() {
      if (identical(_updateChain[taskId], next)) {
        _updateChain.remove(taskId);
      }
    });
  }

  Future<void> _handleUpdate(TaskUpdate update) async {
    final taskId = update.task.taskId;
    final row = await _db.findByTaskId(taskId);
    if (row == null) {
      _log.fine('Update for unknown taskId $taskId — ignoring');
      return;
    }
    // Use the row's own accountKey rather than the currently-active one: a
    // task update may land while the user has already switched accounts, and
    // we must still write the update against the account that owned the task.
    final ownerKey = row.accountKey;
    switch (update) {
      case TaskProgressUpdate(:final progress):
        if (progress >= 0 && progress <= 1) {
          await _db.updateProgress(ownerKey, row.itemId, progress);
        }
      case TaskStatusUpdate(:final status, :final exception):
        switch (status) {
          case TaskStatus.enqueued:
            await _db.setStatus(ownerKey, row.itemId, DownloadStatus.queued);
          case TaskStatus.running:
          case TaskStatus.waitingToRetry:
            await _db.setStatus(ownerKey, row.itemId, DownloadStatus.running);
          case TaskStatus.paused:
            await _db.setStatus(ownerKey, row.itemId, DownloadStatus.paused);
          case TaskStatus.complete:
            final path = await update.task.filePath();
            int? size;
            try {
              size = File(path).statSync().size;
            } on Object {
              size = null;
            }
            await _db.markCompleted(ownerKey, row.itemId, path, size);
          case TaskStatus.canceled:
            await _db.setStatus(ownerKey, row.itemId, DownloadStatus.cancelled);
          case TaskStatus.failed:
          case TaskStatus.notFound:
            await _db.setStatus(
              ownerKey,
              row.itemId,
              DownloadStatus.failed,
              error: exception?.description ?? status.name,
            );
        }
    }
  }

  /// Asks the OS for permission to show download notifications on first use.
  /// Required on Android 13+ (POST_NOTIFICATIONS) and iOS. The request is
  /// cached so the user is only prompted once per session even when batch-
  /// enqueueing a season.
  ///
  /// The cache is not refreshed if the user revokes permission from system
  /// settings mid-session — they will need to restart the app to re-prompt.
  ///
  /// If permission is denied the download still proceeds; only the
  /// notification UI is silently dropped by the OS.
  Future<void> _ensureNotificationPermission() async {
    _notifPermissionFuture ??= () async {
      try {
        final current = await _fd.permissions.status(
          PermissionType.notifications,
        );
        if (current == PermissionStatus.granted) return current;
        return await _fd.permissions.request(PermissionType.notifications);
      } on Object catch (e, s) {
        _log.warning('Notification permission request failed', e, s);
        return PermissionStatus.requestError;
      }
    }();
    final result = await _notifPermissionFuture!;
    if (result != PermissionStatus.granted) {
      _log.info('Download notifications not granted (status: $result)');
    }
  }

  Future<String?> _resolveContainer(String itemId) async {
    try {
      final info = await _ref.read(jellyfinClientProvider).playbackInfo(itemId);
      final ms = info.mediaSources?.toList();
      if (ms == null || ms.isEmpty) return null;
      return ms.first.container;
    } on Object catch (e, s) {
      _log.warning(
        'playbackInfo failed for $itemId — proceeding with no extension',
        e,
        s,
      );
      return null;
    }
  }

  String _itemTypeOf(BaseItemDto item) {
    final t = item.type;
    if (t == BaseItemKind.episode) return 'Episode';
    return 'Movie';
  }
}

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final mgr = DownloadManager(ref);
  ref.onDispose(mgr.dispose);
  return mgr;
});

/// State of a download relative to a UI consumer (movie/episode detail).
enum ItemDownloadState {
  notDownloaded,
  queued,
  running,
  paused,
  completed,
  failed,
  cancelled,
}

ItemDownloadState _toUiState(DownloadStatus? s) => switch (s) {
  null => ItemDownloadState.notDownloaded,
  DownloadStatus.queued => ItemDownloadState.queued,
  DownloadStatus.running => ItemDownloadState.running,
  DownloadStatus.paused => ItemDownloadState.paused,
  DownloadStatus.completed => ItemDownloadState.completed,
  DownloadStatus.failed => ItemDownloadState.failed,
  DownloadStatus.cancelled => ItemDownloadState.cancelled,
};

class ItemDownloadStatus {
  const ItemDownloadStatus({required this.state, required this.progress});

  final ItemDownloadState state;
  final double progress;

  static const none = ItemDownloadStatus(
    state: ItemDownloadState.notDownloaded,
    progress: 0,
  );
}

String _currentAccountKey(Ref ref) => ref.watch(
  authControllerProvider.select(
    (s) => accountKeyForSession(s.valueOrNull?.session),
  ),
);

final downloadRowProvider = StreamProvider.autoDispose
    .family<DownloadRow?, String>((ref, itemId) {
      final db = ref.watch(appDatabaseProvider);
      return db.watchByItemId(_currentAccountKey(ref), itemId);
    });

final itemDownloadStatusProvider = Provider.autoDispose
    .family<ItemDownloadStatus, String>((ref, itemId) {
      final row = ref.watch(downloadRowProvider(itemId)).valueOrNull;
      return ItemDownloadStatus(
        state: _toUiState(row?.status),
        progress: row?.progress ?? 0,
      );
    });

final allDownloadsProvider = StreamProvider.autoDispose<List<DownloadRow>>((
  ref,
) {
  return ref.watch(appDatabaseProvider).watchAll(_currentAccountKey(ref));
});
