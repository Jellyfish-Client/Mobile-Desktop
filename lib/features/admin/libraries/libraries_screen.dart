import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/jellyfin/jellyfin_client.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';
import 'libraries_providers.dart';
import 'library_paths_picker.dart';

class AdminLibrariesScreen extends ConsumerWidget {
  const AdminLibrariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminLibrariesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminLibraries)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/settings/admin/libraries/new'),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.adminLibrariesAdd),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminLibrariesProvider.notifier).refresh(),
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
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
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
                  (f) => _LibraryTile(
                    folder: f,
                    onScan: () => _scanOne(context, ref, f),
                    onRename: () => _renameLibrary(context, ref, f),
                    onDelete: () => _deleteLibrary(context, ref, f),
                    onAddPath: () => _addPath(context, ref, f),
                    onManagePaths: () => _managePaths(context, ref, f),
                  ),
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

  Future<void> _renameLibrary(
    BuildContext context,
    WidgetRef ref,
    VirtualFolderInfo folder,
  ) async {
    final oldName = folder.name;
    if (oldName == null) return;
    final l = context.l10n;
    final controller = TextEditingController(text: oldName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.adminLibraryRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.adminLibraryNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.adminLibraryRenameCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l.adminLibraryRenameConfirm),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == oldName) return;
    if (!context.mounted) return;
    try {
      await ref
          .read(adminLibrariesProvider.notifier)
          .rename(oldName, newName);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminLibraryRenamedSnack(newName))),
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

  Future<void> _deleteLibrary(
    BuildContext context,
    WidgetRef ref,
    VirtualFolderInfo folder,
  ) async {
    final name = folder.name;
    if (name == null) return;
    final l = context.l10n;
    final ok = await showJfConfirm(
      context,
      title: l.adminLibraryDeleteTitle,
      message: l.adminLibraryDeleteMessage(name),
      confirmLabel: l.adminLibraryDeleteConfirm,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(adminLibrariesProvider.notifier).remove(name);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminLibraryDeletedSnack(name))),
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

  Future<void> _addPath(
    BuildContext context,
    WidgetRef ref,
    VirtualFolderInfo folder,
  ) async {
    final name = folder.name;
    if (name == null) return;
    final l = context.l10n;
    final picked = await showLibraryPathsPicker(context);
    if (picked == null || !context.mounted) return;
    try {
      await ref
          .read(adminLibrariesProvider.notifier)
          .addPath(name, picked);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminLibraryPathAddedSnack(picked))),
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

  Future<void> _managePaths(
    BuildContext context,
    WidgetRef ref,
    VirtualFolderInfo folder,
  ) async {
    final name = folder.name;
    if (name == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ManagePathsSheet(libraryName: name),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.folder,
    required this.onScan,
    required this.onRename,
    required this.onDelete,
    required this.onAddPath,
    required this.onManagePaths,
  });

  final VirtualFolderInfo folder;
  final VoidCallback onScan;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddPath;
  final VoidCallback onManagePaths;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = context.l10n;
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
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
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
              PopupMenuButton<String>(
                tooltip: l.adminLibrariesActionsTooltip,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'scan':
                      onScan();
                    case 'rename':
                      onRename();
                    case 'add_path':
                      onAddPath();
                    case 'manage_paths':
                      onManagePaths();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'scan',
                    enabled: folder.itemId != null,
                    child: ListTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(l.adminLibrariesMenuScan),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'rename',
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l.adminLibrariesMenuRename),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'add_path',
                    child: ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(l.adminLibrariesMenuAddPath),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (locations.isNotEmpty)
                    PopupMenuItem<String>(
                      value: 'manage_paths',
                      child: ListTile(
                        leading: const Icon(Icons.folder_open),
                        title: Text(l.adminLibrariesMenuManagePaths),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: scheme.error),
                      title: Text(
                        l.adminLibrariesMenuDelete,
                        style: TextStyle(color: scheme.error),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
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

/// Bottom sheet that lists every path currently registered on a library and
/// lets the admin pop them off one by one. Reads from `adminLibrariesProvider`
/// so the list refreshes automatically after each removal.
class _ManagePathsSheet extends ConsumerWidget {
  const _ManagePathsSheet({required this.libraryName});

  final String libraryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(adminLibrariesProvider);
    final folders = async.valueOrNull ?? const <VirtualFolderInfo>[];
    VirtualFolderInfo? folder;
    for (final f in folders) {
      if (f.name == libraryName) {
        folder = f;
        break;
      }
    }
    final paths = folder?.locations?.toList() ?? const <String>[];

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.adminLibraryManagePathsTitle(libraryName),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: paths.isEmpty
                  ? Center(child: Text(l.adminLibraryNoPaths))
                  : ListView.builder(
                      itemCount: paths.length,
                      itemBuilder: (context, i) {
                        final p = paths[i];
                        return ListTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(
                            p,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            tooltip: l.adminLibraryRemovePath,
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                _removePath(context, ref, p),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removePath(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    final l = context.l10n;
    final ok = await showJfConfirm(
      context,
      title: l.adminLibraryRemovePathTitle,
      message: l.adminLibraryRemovePathMessage(path),
      confirmLabel: l.adminLibraryRemovePathConfirm,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref
          .read(adminLibrariesProvider.notifier)
          .removePath(libraryName, path);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminLibraryPathRemovedSnack(path))),
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
