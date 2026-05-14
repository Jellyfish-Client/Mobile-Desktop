import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Polls the server's scheduled task list. When at least one task is running
/// the notifier refetches every 4 seconds so the UI tracks progress; once
/// everything is idle it stops polling to keep the request load minimal.
class AdminTasksNotifier extends AutoDisposeAsyncNotifier<List<TaskInfo>> {
  Timer? _timer;

  @override
  Future<List<TaskInfo>> build() async {
    ref.onDispose(() => _timer?.cancel());
    final tasks = await _fetch();
    _rescheduleIfNeeded(tasks);
    return tasks;
  }

  Future<List<TaskInfo>> _fetch() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getScheduledTasksApi().getTasks();
    final raw = res.data?.toList() ?? const <TaskInfo>[];
    // Hide internal / framework tasks that the web UI also hides — keeps the
    // list focused on user-actionable jobs.
    final visible = raw.where((t) => !(t.isHidden ?? false)).toList()
      ..sort(
        (a, b) => (a.category ?? '').compareTo(b.category ?? '') != 0
            ? (a.category ?? '').compareTo(b.category ?? '')
            : (a.name ?? '').compareTo(b.name ?? ''),
      );
    return visible;
  }

  void _rescheduleIfNeeded(List<TaskInfo> tasks) {
    _timer?.cancel();
    final hasRunning = tasks.any(
      (t) => t.state == TaskState.running || t.state == TaskState.cancelling,
    );
    if (!hasRunning) return;
    _timer = Timer(const Duration(seconds: 4), () async {
      try {
        final fresh = await _fetch();
        state = AsyncData(fresh);
        _rescheduleIfNeeded(fresh);
      } on Object catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }

  Future<void> start(String taskId) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getScheduledTasksApi().startTask(taskId: taskId);
    // Optimistic refresh so the user sees the state flip even before the
    // polling timer kicks in.
    final fresh = await _fetch();
    state = AsyncData(fresh);
    _rescheduleIfNeeded(fresh);
  }

  Future<void> stop(String taskId) async {
    final api = ref.read(jellyfinApiProvider);
    await api.getScheduledTasksApi().stopTask(taskId: taskId);
    final fresh = await _fetch();
    state = AsyncData(fresh);
    _rescheduleIfNeeded(fresh);
  }
}

final adminTasksProvider =
    AutoDisposeAsyncNotifierProvider<AdminTasksNotifier, List<TaskInfo>>(
  AdminTasksNotifier.new,
);
