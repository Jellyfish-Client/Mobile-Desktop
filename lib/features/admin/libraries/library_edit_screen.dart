import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import 'libraries_providers.dart';
import 'library_paths_picker.dart';

/// Form used to spin up a brand-new virtual folder. Edition of an existing
/// library is intentionally limited to rename + add/remove path (handled via
/// the popup menu on the list screen) to keep this scope small.
class LibraryEditScreen extends ConsumerStatefulWidget {
  const LibraryEditScreen({super.key});

  @override
  ConsumerState<LibraryEditScreen> createState() => _LibraryEditScreenState();
}

class _LibraryEditScreenState extends ConsumerState<LibraryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  CollectionTypeOptions _collectionType = CollectionTypeOptions.movies;
  final List<String> _paths = [];
  bool _refreshLibrary = true;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  static const _types = <CollectionTypeOptions>[
    CollectionTypeOptions.movies,
    CollectionTypeOptions.tvshows,
    CollectionTypeOptions.music,
    CollectionTypeOptions.musicvideos,
    CollectionTypeOptions.homevideos,
    CollectionTypeOptions.boxsets,
    CollectionTypeOptions.books,
    CollectionTypeOptions.mixed,
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.adminLibraryEditTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.adminLibraryNameLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.adminLibraryNameRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<CollectionTypeOptions>(
              initialValue: _collectionType,
              decoration: InputDecoration(
                labelText: l.adminLibraryTypeLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final t in _types)
                  DropdownMenuItem<CollectionTypeOptions>(
                    value: t,
                    child: Text(_typeLabel(context, t)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _collectionType = v);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.adminLibraryPathsLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_paths.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  l.adminLibraryNoPaths,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              for (final p in _paths)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(p, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      tooltip: l.adminLibraryRemovePath,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _paths.remove(p)),
                    ),
                  ),
                ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: _pickPath,
                icon: const Icon(Icons.add),
                label: Text(l.adminLibraryAddPath),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: Text(l.adminLibraryRefreshAfter),
              subtitle: Text(l.adminLibraryRefreshAfterSubtitle),
              value: _refreshLibrary,
              onChanged: (v) => setState(() => _refreshLibrary = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.tonalIcon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.library_add_outlined),
              label: Text(l.adminLibraryCreateButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPath() async {
    final picked = await showLibraryPathsPicker(context);
    if (picked == null || !mounted) return;
    if (_paths.contains(picked)) return;
    setState(() => _paths.add(picked));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminLibraryPathsRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(adminLibrariesProvider.notifier).create(
            name: _name.text.trim(),
            collectionType: _collectionType,
            paths: List<String>.unmodifiable(_paths),
            refreshLibrary: _refreshLibrary,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminLibraryCreatedSnack)),
      );
      context.pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminFailurePrefix(e.toString())),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _typeLabel(BuildContext context, CollectionTypeOptions type) {
    final l = context.l10n;
    return switch (type) {
      CollectionTypeOptions.movies => l.adminLibraryTypeMovies,
      CollectionTypeOptions.tvshows => l.adminLibraryTypeTvshows,
      CollectionTypeOptions.music => l.adminLibraryTypeMusic,
      CollectionTypeOptions.musicvideos => l.adminLibraryTypeMusicvideos,
      CollectionTypeOptions.homevideos => l.adminLibraryTypeHomevideos,
      CollectionTypeOptions.boxsets => l.adminLibraryTypeBoxsets,
      CollectionTypeOptions.books => l.adminLibraryTypeBooks,
      _ => l.adminLibraryTypeMixed,
    };
  }
}
