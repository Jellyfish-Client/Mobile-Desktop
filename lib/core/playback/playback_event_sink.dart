import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';

import '../jellyfin/jellyfin_client.dart';
import '../storage/app_database.dart';

/// Abstracts where playback events go: directly to Jellyfin (online) or into
/// the SyncQueue (offline) to be flushed when connectivity returns.
abstract class PlaybackEventSink {
  Future<void> start({required int positionTicks});
  Future<void> progress({required int positionTicks, required bool isPaused});
  Future<void> stop({required int positionTicks});
}

class OnlinePlaybackSink implements PlaybackEventSink {
  OnlinePlaybackSink({
    required this.client,
    required this.itemId,
    required this.playSessionId,
    required this.mediaSourceId,
  });

  static final _log = Logger('OnlinePlaybackSink');

  final JellyfinClient client;
  final String itemId;
  final String playSessionId;
  final String mediaSourceId;

  @override
  Future<void> start({required int positionTicks}) async {
    try {
      await client.reportPlaybackStart(
        itemId: itemId,
        playSessionId: playSessionId,
        mediaSourceId: mediaSourceId,
        positionTicks: positionTicks,
      );
    } on Object catch (e) {
      _log.warning('reportPlaybackStart failed: $e');
    }
  }

  @override
  Future<void> progress({
    required int positionTicks,
    required bool isPaused,
  }) async {
    try {
      await client.reportPlaybackProgress(
        itemId: itemId,
        playSessionId: playSessionId,
        mediaSourceId: mediaSourceId,
        positionTicks: positionTicks,
        isPaused: isPaused,
      );
    } on Object catch (e) {
      _log.fine('reportPlaybackProgress failed: $e');
    }
  }

  @override
  Future<void> stop({required int positionTicks}) async {
    try {
      await client.reportPlaybackStopped(
        itemId: itemId,
        playSessionId: playSessionId,
        mediaSourceId: mediaSourceId,
        positionTicks: positionTicks,
      );
    } on Object catch (e) {
      _log.warning('reportPlaybackStopped failed: $e');
    }
  }
}

/// Persists playback events into Drift so `SyncService` can replay them once
/// connectivity is restored. PlaybackStart is dropped: Jellyfin's session
/// model expects a live session id, and we'd just be flooding the server with
/// stale "started 4 hours ago" pings.
class OfflinePlaybackSink implements PlaybackEventSink {
  OfflinePlaybackSink({
    required this.db,
    required this.accountKey,
    required this.itemId,
    required this.playSessionId,
    required this.mediaSourceId,
  });

  final AppDatabase db;
  final String accountKey;
  final String itemId;
  final String playSessionId;
  final String mediaSourceId;

  Map<String, Object?> _payload({required int positionTicks, bool? isPaused}) =>
      <String, Object?>{
        'playSessionId': playSessionId,
        'mediaSourceId': mediaSourceId,
        'positionTicks': positionTicks,
        if (isPaused != null) 'isPaused': isPaused,
      };

  @override
  Future<void> start({required int positionTicks}) async {
    // Intentionally no-op offline.
  }

  @override
  Future<void> progress({
    required int positionTicks,
    required bool isPaused,
  }) async {
    await db.upsertPlaybackProgress(
      accountKey: accountKey,
      itemId: itemId,
      payloadJson: jsonEncode(
        _payload(positionTicks: positionTicks, isPaused: isPaused),
      ),
    );
  }

  @override
  Future<void> stop({required int positionTicks}) async {
    await db.enqueueSync(
      accountKey: accountKey,
      itemId: itemId,
      operation: SyncOperation.playbackStopped,
      payloadJson: jsonEncode(_payload(positionTicks: positionTicks)),
    );
  }
}
