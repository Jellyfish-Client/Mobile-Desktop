import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/breakpoints.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/network/offline_mode_provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '../home/offline_home_screen.dart';
import 'library_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(libraryNotifierProvider.notifier).setSearch(value);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(libraryNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(offlineModeProvider)) {
      return const OfflineHomeScreen();
    }
    final state = ref.watch(libraryNotifierProvider);
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final gridExtent = Breakpoints.gridMaxCrossAxisExtent(
      MediaQuery.sizeOf(context).width,
    );

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: Text(context.l10n.libraryTitle),
            pinned: true,
            floating: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(116),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    JfTextField(
                      controller: _searchController,
                      hint: context.l10n.librarySearch,
                      prefixIcon: Icons.search,
                      onChanged: _onSearch,
                      autocorrect: false,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LibraryChips(
                      selectedViewId: state.selectedView?.id,
                      onSelected: (v) =>
                          ref.read(libraryNotifierProvider.notifier).setView(v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.isLoading)
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: _posterGrid(
                context: context,
                gridExtent: gridExtent,
                childCount: 18,
                builder: (_, __) =>
                    const JfPosterCard(title: '', imageUrl: null),
              ),
            )
          else if (state.error != null && state.items.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_outline,
                title: context.l10n.libraryFailedToLoad,
                message: state.error.toString(),
                actionLabel: context.l10n.retryButton,
                onAction: () =>
                    ref.read(libraryNotifierProvider.notifier).fetch(),
              ),
            )
          else if (state.items.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.search_off,
                title: context.l10n.libraryNoResults,
                message: context.l10n.libraryNoResultsMessage,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: _posterGrid(
                context: context,
                gridExtent: gridExtent,
                childCount: state.items.length,
                builder: (context, index) {
                  final item = state.items[index];
                  final url = urls.imageUrl(item, maxWidth: 300);
                  return JfPosterCard(
                    title: item.name ?? '',
                    imageUrl: url,
                    subtitle: item.productionYear?.toString(),
                    onTap: () => context.push('/items/${item.id}'),
                  );
                },
              ),
            ),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: JfLoading(),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
        ],
      ),
    );
  }
}

/// Builds a poster grid whose cell aspect ratio is derived from the actual
/// resolved cell width, so the cells never clip the poster + 2-line title +
/// 1-line subtitle on narrow phones.
Widget _posterGrid({
  required BuildContext context,
  required double gridExtent,
  required int childCount,
  required NullableIndexedWidgetBuilder builder,
}) {
  return SliverLayoutBuilder(
    builder: (context, constraints) {
      final cellWidth = Breakpoints.gridCellWidth(
        crossAxisExtent: constraints.crossAxisExtent,
        maxExtent: gridExtent,
        crossAxisSpacing: AppSpacing.sm,
      );
      final ratio = Breakpoints.posterGridAspectRatio(
        cellWidth,
        Theme.of(context).textTheme,
      );
      return SliverGrid(
        delegate: SliverChildBuilderDelegate(builder, childCount: childCount),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: gridExtent,
          childAspectRatio: ratio,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
      );
    },
  );
}

class _LibraryChips extends ConsumerWidget {
  const _LibraryChips({required this.selectedViewId, required this.onSelected});

  final String? selectedViewId;
  final ValueChanged<JellyfinItem?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(userViewsProvider);
    final views = viewsAsync.maybeWhen(
      data: (v) => v,
      orElse: () => const <JellyfinItem>[],
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            label: context.l10n.libraryAll,
            isSelected: selectedViewId == null,
            onTap: () => onSelected(null),
          ),
          for (final v in views) ...[
            const SizedBox(width: AppSpacing.sm),
            _chip(
              label: v.name ?? '',
              isSelected: selectedViewId == v.id,
              onTap: () => onSelected(v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return JfChip(
      label: label,
      tone: isSelected ? JfChipTone.brand : JfChipTone.neutral,
      onTap: onTap,
    );
  }
}
