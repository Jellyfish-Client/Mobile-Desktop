import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/jellyfin/jellyfin_client.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import 'libraries_providers.dart';

class AdminLibrariesScreen extends ConsumerWidget {
  const AdminLibrariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminLibrariesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminLibraries)),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminLibrariesProvider.future),
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
          data: (folders) => ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: FilledButton.icon(
                  onPressed: () => _triggerGlobalScan(context, ref),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.adminLibrariesScanAll),
                ),
              ),
              if (folders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(context.l10n.adminLibrariesEmpty),
                  ),
                )
              else
                ...folders.map(
                  (f) => _LibraryTile(folder: f, onScan: () => _scanOne(context, ref, f)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _triggerGlobalScan(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showJfConfirm(
      context,
      title: l.adminLibrariesScanAllTitle,
      message: l.adminLibrariesScanAllMessage,
      confirmLabel: l.adminLibrariesScanAllConfirm,
      confirmIcon: Icons.refresh,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(jellyfinApiProvider).getLibraryApi().refreshLibrary();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminLibrariesScanSnack)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    }
  }

  Future<void> _scanOne(
    BuildContext context,
    WidgetRef ref,
    VirtualFolderInfo folder,
  ) async {
    final id = folder.itemId;
    if (id == null) return;
    try {
      await ref
          .read(jellyfinApiProvider)
          .getItemRefreshApi()
          .refreshItem(itemId: id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.adminLibrariesScanOneSnack(folder.name ?? '—'),
          ),
        ),
      );
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

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.folder, required this.onScan});

  final VirtualFolderInfo folder;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locations = folder.locations?.toList() ?? const [];
    final subtitle = [
      if (folder.collectionType != null) _typeLabel(folder.collectionType!),
      if (locations.isNotEmpty)
        '${locations.length} chemin${locations.length > 1 ? 's' : ''}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(_iconFor(folder.collectionType), color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name ?? '—',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    for (final p in locations)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          p,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontFeatures: const [],
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.l10n.adminLibrariesTooltipScan,
                icon: const Icon(Icons.refresh),
                onPressed: folder.itemId == null ? null : onScan,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(CollectionTypeOptions? type) {
    return switch (type) {
      CollectionTypeOptions.movies => Icons.movie_outlined,
      CollectionTypeOptions.tvshows => Icons.tv_outlined,
      CollectionTypeOptions.music => Icons.library_music_outlined,
      CollectionTypeOptions.musicvideos => Icons.music_video_outlined,
      CollectionTypeOptions.homevideos => Icons.video_library_outlined,
      CollectionTypeOptions.boxsets => Icons.collections_bookmark_outlined,
      CollectionTypeOptions.books => Icons.menu_book_outlined,
      _ => Icons.folder_outlined,
    };
  }

  String _typeLabel(CollectionTypeOptions type) {
    return switch (type) {
      CollectionTypeOptions.movies => 'Films',
      CollectionTypeOptions.tvshows => 'Séries',
      CollectionTypeOptions.music => 'Musique',
      CollectionTypeOptions.musicvideos => 'Clips',
      CollectionTypeOptions.homevideos => 'Vidéos perso.',
      CollectionTypeOptions.boxsets => 'Collections',
      CollectionTypeOptions.books => 'Livres',
      _ => 'Mixte',
    };
  }
}
