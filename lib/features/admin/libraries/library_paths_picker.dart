import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/jellyfin/jellyfin_client.dart';
import '../../../l10n/l10n_extension.dart';

/// Opens the modal bottom-sheet picker. Resolves to the path the user picked
/// (or `null` if they dismissed the sheet).
Future<String?> showLibraryPathsPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const LibraryPathsPicker(),
  );
}

/// Sheet that walks the server-side filesystem via `EnvironmentApi`. Lets the
/// admin drill into directories, jump back up, and validate the final path
/// before returning it to the caller.
class LibraryPathsPicker extends ConsumerStatefulWidget {
  const LibraryPathsPicker({super.key});

  @override
  ConsumerState<LibraryPathsPicker> createState() => _LibraryPathsPickerState();
}

class _LibraryPathsPickerState extends ConsumerState<LibraryPathsPicker> {
  String? _currentPath;
  List<FileSystemEntryInfo> _entries = const [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final api = ref.read(jellyfinApiProvider);
      final defaultRes =
          await api.getEnvironmentApi().getDefaultDirectoryBrowser();
      final start = defaultRes.data?.path;
      if (start == null || start.isEmpty) {
        // No default — fall back to drives at root.
        final drives = await api.getEnvironmentApi().getDrives();
        if (!mounted) return;
        setState(() {
          _currentPath = null;
          _entries = drives.data?.toList() ?? const [];
          _loading = false;
        });
        return;
      }
      await _loadPath(start);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadPath(String path) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(jellyfinApiProvider);
      final res = await api.getEnvironmentApi().getDirectoryContents(
            path: path,
            includeDirectories: true,
          );
      if (!mounted) return;
      setState(() {
        _currentPath = path;
        _entries = res.data?.toList() ?? const [];
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _goUp() async {
    final current = _currentPath;
    if (current == null) return;
    try {
      final api = ref.read(jellyfinApiProvider);
      final res = await api.getEnvironmentApi().getParentPath(path: current);
      final parent = res.data;
      if (parent == null || parent.isEmpty) {
        // Reached the top — show drives.
        final drives = await api.getEnvironmentApi().getDrives();
        if (!mounted) return;
        setState(() {
          _currentPath = null;
          _entries = drives.data?.toList() ?? const [];
        });
        return;
      }
      await _loadPath(parent);
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminFailurePrefix(e.toString()))),
      );
    }
  }

  Future<void> _validateAndPop() async {
    final current = _currentPath;
    if (current == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l = context.l10n;
    try {
      await ref.read(jellyfinApiProvider).getEnvironmentApi().validatePath(
            validatePathDto: ValidatePathDto((b) => b..path = current),
          );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.adminLibraryPathValidationWarning(e.toString()))),
      );
    }
    if (!mounted) return;
    navigator.pop(current);
  }

  bool _isNavigable(FileSystemEntryInfo entry) {
    final type = entry.type;
    return type == FileSystemEntryType.directory ||
        type == FileSystemEntryType.networkComputer ||
        type == FileSystemEntryType.networkShare;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.85,
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
                    Icon(Icons.folder_open, color: scheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l.adminLibraryPathPickerTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: l.adminLibraryPathPickerClose,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l.adminLibraryPathPickerUp,
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: _currentPath == null ? null : _goUp,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _currentPath ?? l.adminLibraryPathPickerRoot,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: AppSpacing.lg),
              Expanded(
                child: _buildBody(context),
              ),
              if (_currentPath != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: _validateAndPop,
                      icon: const Icon(Icons.check),
                      label: Text(l.adminLibraryPathPickerValidate),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(context.l10n.adminErrorPrefix(_error.toString())),
        ),
      );
    }
    final navigable = _entries.where(_isNavigable).toList();
    if (navigable.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(context.l10n.adminLibraryPathPickerEmpty),
        ),
      );
    }
    return ListView.builder(
      itemCount: navigable.length,
      itemBuilder: (context, index) {
        final entry = navigable[index];
        final name = entry.name ?? entry.path ?? '—';
        final path = entry.path;
        return ListTile(
          leading: Icon(
            entry.type == FileSystemEntryType.directory
                ? Icons.folder_outlined
                : Icons.lan_outlined,
          ),
          title: Text(name),
          subtitle: path == null
              ? null
              : Text(
                  path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          onTap: path == null ? null : () => _loadPath(path),
          trailing: path == null
              ? null
              : IconButton(
                  tooltip: context.l10n.adminLibraryPathPickerSelect,
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () => Navigator.of(context).pop(path),
                ),
        );
      },
    );
  }
}
