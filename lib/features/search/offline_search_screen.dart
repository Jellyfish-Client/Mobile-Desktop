import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/auth/account_key.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/app_database_provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/jf_text_field.dart';

/// Search restricted to locally-downloaded items when offline.
class OfflineSearchScreen extends ConsumerStatefulWidget {
  const OfflineSearchScreen({super.key});

  @override
  ConsumerState<OfflineSearchScreen> createState() =>
      _OfflineSearchScreenState();
}

class _OfflineSearchScreenState extends ConsumerState<OfflineSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final accountKey = ref.watch(
      authControllerProvider.select(
        (s) => accountKeyForSession(s.valueOrNull?.session),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.offlineSearchTitle),
        toolbarHeight: 72,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: JfTextField(
              controller: _controller,
              hint: context.l10n.offlineSearchHint,
              prefixIcon: Icons.search,
              autocorrect: false,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<DownloadRow>>(
        stream: db.watchCompleted(accountKey),
        builder: (context, snap) {
          final rows = snap.data ?? const <DownloadRow>[];
          final filtered = _query.isEmpty
              ? rows
              : rows.where((r) {
                  final name = r.name.toLowerCase();
                  final series = (r.seriesName ?? '').toLowerCase();
                  return name.contains(_query) || series.contains(_query);
                }).toList();
          if (filtered.isEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              title: _query.isEmpty
                  ? context.l10n.offlineSearchNoDownloads
                  : context.l10n.offlineSearchNoResults,
              message: _query.isEmpty
                  ? context.l10n.offlineSearchNoDownloadsMessage
                  : context.l10n.offlineSearchNoResultsMessage(_query),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final r = filtered[i];
              return _OfflineSearchTile(row: r);
            },
          );
        },
      ),
    );
  }
}

class _OfflineSearchTile extends StatelessWidget {
  const _OfflineSearchTile({required this.row});
  final DownloadRow row;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final poster = row.imagePath ?? row.seriesImagePath;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: 44,
          height: 66,
          child: poster == null
              ? _placeholder(scheme)
              : Image.file(
                  File(poster),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(scheme),
                ),
        ),
      ),
      title: Text(
        row.itemType == 'Episode' ? row.seriesName ?? row.name : row.name,
      ),
      subtitle: row.itemType == 'Episode'
          ? Text(
              'S${row.seasonNumber ?? '?'}·E${row.episodeNumber ?? '?'} — ${row.name}',
            )
          : (row.productionYear != null ? Text('${row.productionYear}') : null),
      onTap: () => context.push('/items/${row.itemId}'),
    );
  }

  Widget _placeholder(ColorScheme scheme) => ColoredBox(
    color: scheme.surfaceContainerHigh,
    child: Icon(Icons.movie_outlined, color: scheme.onSurfaceVariant),
  );
}
