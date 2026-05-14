import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Live list of currently connected Jellyfin sessions. The notifier keeps
/// itself in sync by refetching every 5 seconds; unlike the scheduled tasks
/// notifier this polling is continuous because sessions can come and go at
/// any time (a user starting playback elsewhere should appear within a
/// reasonable delay without forcing the operator to pull-to-refresh).
class AdminSessionsNotifier
    extends AutoDisposeAsyncNotifier<List<SessionInfoDto>> {
  Timer? _timer;

  @override
  Future<List<SessionInfoDto>> build() async {
    ref.onDispose(() => _timer?.cancel());
    final sessions = await _fetch();
    _scheduleNext();
    return sessions;
  }

  Future<List<SessionInfoDto>> _fetch() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getSessionApi().getSessions();
    final raw = res.data?.toList() ?? const <SessionInfoDto>[];
    // Drop sessions without a user (anonymous heartbeats from disconnected
    // clients) — they're noise for an admin review.
    final filtered = raw
        .where((s) => (s.userId ?? '').isNotEmpty)
        .toList()
      ..sort((a, b) {
        // Active streams first, then most recently active.
        final aPlaying = a.nowPlayingItem != null;
        final bPlaying = b.nowPlayingItem != null;
        if (aPlaying != bPlaying) return aPlaying ? -1 : 1;
        final aDate = a.lastActivityDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.lastActivityDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    return filtered;
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () async {
      try {
        final fresh = await _fetch();
        state = AsyncData(fresh);
        _scheduleNext();
      } on Object catch (e, st) {
        state = AsyncError(e, st);
        // Keep polling even after an error so the UI recovers on its own.
        _scheduleNext();
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
    _scheduleNext();
  }

  /// Sends a transient text message to the target session — Jellyfin clients
  /// surface it as a toast/popup. There is no separate "kick" endpoint exposed
  /// by SessionApi, so this is the closest equivalent to nudging a user.
  Future<void> sendMessage({
    required String sessionId,
    required String text,
    String? header,
  }) async {
    final api = ref.read(jellyfinApiProvider);
    final command = MessageCommand(
      (b) => b
        ..text = text
        ..header = header,
    );
    await api.getSessionApi().sendMessageCommand(
          sessionId: sessionId,
          messageCommand: command,
        );
    // No state-level change, but kick a refresh so any activity timestamp
    // updates land on screen.
    final fresh = await _fetch();
    state = AsyncData(fresh);
    _scheduleNext();
  }

  /// Stops the currently playing item on the target session. SessionApi has
  /// no terminate-session endpoint, so stopping playback is the strongest
  /// remote control we can offer.
  Future<void> stopPlayback(String sessionId) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getSessionApi().sendPlaystateCommand(
          sessionId: sessionId,
          command: PlaystateCommand.stop,
        );
    final fresh = await _fetch();
    state = AsyncData(fresh);
    _scheduleNext();
  }
}

final adminSessionsProvider = AutoDisposeAsyncNotifierProvider<
    AdminSessionsNotifier, List<SessionInfoDto>>(
  AdminSessionsNotifier.new,
);
