import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_async_scaffold.dart';
import 'activity_log_providers.dart';

class AdminActivityLogScreen extends ConsumerStatefulWidget {
  const AdminActivityLogScreen({super.key});

  @override
  ConsumerState<AdminActivityLogScreen> createState() =>
      _AdminActivityLogScreenState();
}

class _AdminActivityLogScreenState
    extends ConsumerState<AdminActivityLogScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    // Trigger the next page when the user is within ~400px of the bottom so
    // the spinner has time to land before the list bottoms out.
    final remaining = _controller.position.maxScrollExtent -
        _controller.position.pixels;
    if (remaining < 400) {
      ref.read(adminActivityLogProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminActivityLogProvider);
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminActivityLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: l.adminActivityFiltersTooltip,
            onPressed: () => _openFilters(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(adminActivityLogProvider.notifier).refresh(),
        child: JfAsyncScaffold(
          value: async,
          maxWidth: double.infinity,
          padding: EdgeInsets.zero,
          error: (e, _) => ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(context.l10n.adminErrorPrefix(e.toString())),
                ),
              ),
            ],
          ),
          data: (state) {
            if (state.entries.isEmpty) {
              return Center(child: Text(l.adminActivityEmpty));
            }
            return ListView.builder(
              controller: _controller,
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              itemCount: state.entries.length + (state.hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= state.entries.length) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _ActivityTile(entry: state.entries[i]);
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final l = context.l10n;
    final state = ref.read(adminActivityLogProvider).valueOrNull;
    if (state == null) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.adminActivityFiltersTitle,
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                  ),
                ),
                Consumer(
                  builder: (_, innerRef, __) {
                    final s = innerRef.watch(adminActivityLogProvider).valueOrNull;
                    final last7 = s?.filterLast7Days ?? false;
                    final userOnly = s?.filterUserOnly ?? false;
                    return Column(
                      children: [
                        SwitchListTile(
                          title: Text(l.adminActivityFilterLast7Days),
                          value: last7,
                          onChanged: (v) => innerRef
                              .read(adminActivityLogProvider.notifier)
                              .setFilterLast7Days(value: v),
                        ),
                        SwitchListTile(
                          title: Text(l.adminActivityFilterUserOnly),
                          value: userOnly,
                          onChanged: (v) => innerRef
                              .read(adminActivityLogProvider.notifier)
                              .setFilterUserOnly(value: v),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});

  final ActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = _iconAndColor(entry.severity, scheme);
    final subtitleParts = <String>[
      if ((entry.shortOverview ?? '').isNotEmpty) entry.shortOverview!,
      if ((entry.userId ?? '').isNotEmpty &&
          (entry.shortOverview ?? '').isEmpty)
        // When there's no overview but we have a user id, show a tiny marker
        // so the row isn't blank — name not always available on the DTO.
        '·',
      if (entry.date != null)
        DateFormat.yMd().add_Hm().format(entry.date!.toLocal()),
    ];

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(entry.name ?? '—', overflow: TextOverflow.ellipsis),
      subtitle: subtitleParts.isEmpty
          ? null
          : Text(
              subtitleParts.join(' • '),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
      isThreeLine: subtitleParts.length > 1,
    );
  }

  (IconData, Color) _iconAndColor(LogLevel? severity, ColorScheme scheme) {
    // LogLevel is built_value's EnumClass (not a sealed Dart enum) so the
    // analyzer can't prove exhaustiveness — fall through to "info" for
    // anything we don't recognise.
    if (severity == LogLevel.warning) {
      return (Icons.warning_amber, Colors.orange);
    }
    if (severity == LogLevel.error || severity == LogLevel.critical) {
      return (Icons.error_outline, scheme.error);
    }
    if (severity == LogLevel.debug || severity == LogLevel.trace) {
      return (Icons.bug_report_outlined, scheme.onSurfaceVariant);
    }
    if (severity == LogLevel.none) {
      return (Icons.notes, scheme.onSurfaceVariant);
    }
    return (Icons.info_outline, scheme.primary);
  }
}
