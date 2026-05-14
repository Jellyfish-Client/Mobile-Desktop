import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import 'tasks_providers.dart';

class AdminTasksScreen extends ConsumerWidget {
  const AdminTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminTasksProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminTasks)),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminTasksProvider.future),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 96),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(context.l10n.adminErrorPrefix(e.toString())),
                ),
              ),
            ],
          ),
          data: (tasks) {
            // Group by category for a tidier list, since Jellyfin tasks span
            // Maintenance / Library / Live TV / etc.
            final byCat = <String, List<TaskInfo>>{};
            for (final t in tasks) {
              byCat.putIfAbsent(t.category ?? 'Autres', () => []).add(t);
            }
            final cats = byCat.keys.toList()..sort();
            if (tasks.isEmpty) {
              return Center(child: Text(context.l10n.adminTasksNoTasks));
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                for (final cat in cats) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      cat.toUpperCase(),
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                    ),
                  ),
                  ...byCat[cat]!.map((t) => _TaskTile(task: t)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final TaskInfo task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isRunning = task.state == TaskState.running;
    final isCancelling = task.state == TaskState.cancelling;
    final last = task.lastExecutionResult;

    final l = context.l10n;
    return ListTile(
      leading: _stateIcon(scheme, task.state, last?.status),
      title: Text(task.name ?? '—'),
      subtitle: Text(_subtitleFor(context, task)),
      trailing: SizedBox(
        width: 48,
        child: isRunning || isCancelling
            ? IconButton(
                tooltip: l.adminTasksTooltipStop,
                icon: Icon(Icons.stop_circle_outlined, color: scheme.error),
                onPressed: isCancelling || task.id == null
                    ? null
                    : () => _stop(context, ref, task.id!),
              )
            : IconButton(
                tooltip: l.adminTasksTooltipStart,
                icon: const Icon(Icons.play_circle_outline),
                onPressed: task.id == null
                    ? null
                    : () => _start(context, ref, task.id!),
              ),
      ),
      onTap: last == null ? null : () => _showLastRun(context, task),
    );
  }

  Widget _stateIcon(
    ColorScheme scheme,
    TaskState? state,
    TaskCompletionStatus? lastStatus,
  ) {
    if (state == TaskState.running) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: (task.currentProgressPercentage ?? 0) / 100 == 0
              ? null
              : (task.currentProgressPercentage ?? 0) / 100,
        ),
      );
    }
    if (state == TaskState.cancelling) {
      return Icon(Icons.hourglass_top, color: scheme.error);
    }
    return switch (lastStatus) {
      TaskCompletionStatus.failed => Icon(Icons.error_outline, color: scheme.error),
      TaskCompletionStatus.cancelled || TaskCompletionStatus.aborted =>
        Icon(Icons.cancel_outlined, color: scheme.onSurfaceVariant),
      TaskCompletionStatus.completed => Icon(Icons.check_circle_outline,
          color: scheme.primary),
      _ => Icon(Icons.schedule, color: scheme.onSurfaceVariant),
    };
  }

  String _subtitleFor(BuildContext context, TaskInfo t) {
    final l = context.l10n;
    if (t.state == TaskState.running) {
      final p = t.currentProgressPercentage;
      return p == null
          ? l.adminTasksRunning
          : l.adminTasksRunningPercent(p.toStringAsFixed(0));
    }
    if (t.state == TaskState.cancelling) return l.adminTasksCancelling;
    final last = t.lastExecutionResult;
    if (last?.endTimeUtc == null) {
      return t.description ?? l.adminTasksNeverRun;
    }
    final ago = _ago(last!.endTimeUtc!);
    final ok = last.status == TaskCompletionStatus.completed;
    return ok ? l.adminTasksCompleted(ago) : l.adminTasksFailed(ago);
  }

  void _showLastRun(BuildContext context, TaskInfo t) {
    final last = t.lastExecutionResult!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.name ?? '—', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            if (t.description != null) Text(t.description!),
            const SizedBox(height: AppSpacing.md),
            _kv(context, context.l10n.adminTasksLastRunStatus, last.status?.name ?? '—'),
            _kv(context, context.l10n.adminTasksLastRunStart, last.startTimeUtc?.toLocal().toString() ?? '—'),
            _kv(context, context.l10n.adminTasksLastRunEnd, last.endTimeUtc?.toLocal().toString() ?? '—'),
            if (last.startTimeUtc != null && last.endTimeUtc != null)
              _kv(
                context,
                context.l10n.adminTasksLastRunDuration,
                last.endTimeUtc!.difference(last.startTimeUtc!).toString(),
              ),
            if (last.errorMessage != null && last.errorMessage!.isNotEmpty)
              _kv(context, context.l10n.adminTasksLastRunError, last.errorMessage!),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$k : ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: v),
          ],
        ),
      ),
    );
  }

  String _ago(DateTime when) {
    final d = DateTime.now().toUtc().difference(when.toUtc());
    if (d.inSeconds < 60) return 'il y a quelques secondes';
    if (d.inMinutes < 60) return 'il y a ${d.inMinutes} min';
    if (d.inHours < 24) return 'il y a ${d.inHours} h';
    if (d.inDays < 7) return 'il y a ${d.inDays} j';
    return 'le ${when.toLocal().toString().split(' ').first}';
  }

  Future<void> _start(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(adminTasksProvider.notifier).start(id);
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    }
  }

  Future<void> _stop(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(adminTasksProvider.notifier).stop(id);
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    }
  }
}
