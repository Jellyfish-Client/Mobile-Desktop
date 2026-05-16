import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/breakpoints.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/jellyfin/models/jellyfin_person.dart';
import '../../core/network/offline_mode_provider.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '../details/widgets/seerr_collection_request_sheet.dart';
import '../details/widgets/seerr_request_sheet.dart';
import 'offline_search_screen.dart';
import 'search_providers.dart';
import 'widgets/search_section_header.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(searchNotifierProvider.notifier).setQuery(value);
  }

  void _clearQuery() {
    _controller.clear();
    ref.read(searchNotifierProvider.notifier).clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(offlineModeProvider)) {
      return const OfflineSearchScreen();
    }
    final state = ref.watch(searchNotifierProvider);
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final seerrClient = ref.watch(seerrClientProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            titleSpacing: 0,
            // JfTextField (outline + 12px vertical content padding + suffix
            // IconButton) needs more vertical space than kToolbarHeight (56).
            // Without this the title overflows the AppBar slot by ~20–40px
            // depending on suffix visibility.
            toolbarHeight: 72,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: JfTextField(
                controller: _controller,
                focusNode: _focusNode,
                hint: context.l10n.searchTitle,
                prefixIcon: Icons.search,
                autocorrect: false,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                suffix: AnimatedOpacity(
                  duration: AppMotion.fast,
                  opacity: state.query.isEmpty ? 0 : 1,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: context.l10n.searchClear,
                    onPressed: state.query.isEmpty ? null : _clearQuery,
                  ),
                ),
              ),
            ),
            actions: const [SyncPlayButton()],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: SizedBox(
                height: 2,
                child: state.isLoading
                    ? const LinearProgressIndicator(minHeight: 2)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          ..._buildBody(state, urls, seerrClient),
        ],
      ),
    );
  }

  List<Widget> _buildBody(
    SearchState state,
    JellyfinUrlService urls,
    SeerrClient seerrClient,
  ) {
    if (state.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _SearchIntro(seerrLinked: seerrClient.isLinked),
        ),
      ];
    }

    if (state.isLoading && !state.hasResults) {
      return const [_SkeletonGrid()];
    }

    final showSeerrSection =
        seerrClient.isLinked &&
        (state.seerr.isNotEmpty ||
            state.seerrCollections.isNotEmpty ||
            state.seerrError != null);
    final showJellyfinSection =
        state.jellyfin.isNotEmpty || state.jellyfinError != null;
    final showPersonsSection = state.persons.isNotEmpty;

    if (!showJellyfinSection && !showSeerrSection && !showPersonsSection) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.search_off,
            title: context.l10n.searchNoResults,
            message: context.l10n.searchNoResultsMessage(state.query),
          ),
        ),
      ];
    }

    return [
      if (showPersonsSection) ...[
        SliverToBoxAdapter(
          child: SearchSectionHeader(
            eyebrow: context.l10n.searchPersonsSection,
            title: context.l10n.searchPersonsTitle,
            count: state.persons.length,
          ),
        ),
        SliverToBoxAdapter(
          child: _PersonsRail(persons: state.persons, urls: urls),
        ),
      ],
      if (showJellyfinSection) ...[
        SliverToBoxAdapter(
          child: SearchSectionHeader(
            eyebrow: context.l10n.searchJellyfinSection,
            title: context.l10n.searchJellyfinTitle,
            count: state.jellyfin.length,
            errorLabel: state.jellyfinError != null
                ? context.l10n.searchJellyfinLoadError
                : null,
            onRetry: state.jellyfinError != null
                ? () => ref.read(searchNotifierProvider.notifier).retry()
                : null,
          ),
        ),
        if (state.jellyfin.isEmpty && state.jellyfinError == null)
          SliverToBoxAdapter(
            child: _SectionEmpty(message: context.l10n.searchJellyfinEmpty),
          )
        else
          _JellyfinGrid(items: state.jellyfin, urls: urls),
      ],
      if (showSeerrSection) ...[
        SliverToBoxAdapter(
          child: SearchSectionHeader(
            eyebrow: context.l10n.searchSeerrSection,
            title: context.l10n.searchSeerrTitle,
            count: state.seerr.length + state.seerrCollections.length,
            errorLabel: state.seerrError != null
                ? context.l10n.searchSeerrLoadError
                : null,
            onRetry: state.seerrError != null
                ? () => ref.read(searchNotifierProvider.notifier).retry()
                : null,
          ),
        ),
        if (state.seerrCollections.isNotEmpty)
          _SeerrCollectionsRail(
            collections: state.seerrCollections,
            client: seerrClient,
          ),
        if (state.seerr.isEmpty &&
            state.seerrCollections.isEmpty &&
            state.seerrError == null)
          SliverToBoxAdapter(
            child: _SectionEmpty(message: context.l10n.searchSeerrEmpty),
          )
        else if (state.seerr.isNotEmpty)
          _SeerrGrid(items: state.seerr, client: seerrClient),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
    ];
  }
}

class _JellyfinGrid extends StatelessWidget {
  const _JellyfinGrid({required this.items, required this.urls});

  final List<JellyfinItem> items;
  final JellyfinUrlService urls;

  @override
  Widget build(BuildContext context) {
    final gridExtent = Breakpoints.gridMaxCrossAxisExtent(
      MediaQuery.sizeOf(context).width,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      sliver: _posterGrid(
        gridExtent: gridExtent,
        childCount: items.length,
        builder: (context, index) {
          final item = items[index];
          final url = urls.imageUrl(item, maxWidth: 300);
          return JfPosterCard(
            title: item.name ?? '',
            imageUrl: url,
            subtitle: item.productionYear?.toString(),
            onTap: () => context.push('/items/${item.id}'),
          );
        },
      ),
    );
  }
}

class _SeerrGrid extends StatelessWidget {
  const _SeerrGrid({required this.items, required this.client});

  final List<SeerrMedia> items;
  final SeerrClient client;

  @override
  Widget build(BuildContext context) {
    final gridExtent = Breakpoints.gridMaxCrossAxisExtent(
      MediaQuery.sizeOf(context).width,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      sliver: _posterGrid(
        gridExtent: gridExtent,
        childCount: items.length,
        builder: (context, index) {
          final media = items[index];
          return JfPosterCard(
            title: media.title,
            imageUrl: client.posterUrl(media),
            subtitle: media.year?.toString(),
            onTap: () => showSeerrRequestSheet(context, media: media),
          );
        },
      ),
    );
  }
}

/// See library_screen.dart's `_posterGrid` for the rationale. We resolve the
/// real cell width via [SliverLayoutBuilder] and derive a matching aspect
/// ratio so the poster + text never overflow the cell.
Widget _posterGrid({
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
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: gridExtent,
          childAspectRatio: ratio,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        delegate: SliverChildBuilderDelegate(builder, childCount: childCount),
      );
    },
  );
}

class _PersonsRail extends StatelessWidget {
  const _PersonsRail({required this.persons, required this.urls});

  final List<JellyfinPerson> persons;
  final JellyfinUrlService urls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: 152,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: persons.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final p = persons[i];
          final name = p.name ?? '';
          final id = p.id;
          final url = urls.personUrl(p, maxWidth: 200);
          final tile = SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'person-avatar-${id ?? name}',
                  child: ClipOval(
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: url != null
                          ? CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: scheme.surfaceContainerHigh),
                              errorWidget: (_, __, ___) =>
                                  JfAvatarInitials(name: name),
                            )
                          : JfAvatarInitials(name: name),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
          if (id == null) return tile;
          return JfTappable(
            semanticLabel: name,
            onTap: () => context.push('/person/$id'),
            borderRadius: BorderRadius.circular(8),
            child: tile,
          );
        },
      ),
    );
  }
}

class _SeerrCollectionsRail extends StatelessWidget {
  const _SeerrCollectionsRail({
    required this.collections,
    required this.client,
  });

  final List<SeerrCollection> collections;
  final SeerrClient client;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = Breakpoints.landscapeCardWidth(
              constraints.maxWidth,
            );
            final cardHeight = cardWidth * 9 / 16;
            return SizedBox(
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: collections.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final c = collections[index];
                  return JfLandscapeCard(
                    title: c.name,
                    subtitle: context.l10n.searchSeerrCollection,
                    imageUrl: client.collectionImageUrl(c),
                    width: cardWidth,
                    onTap: () =>
                        showSeerrCollectionRequestSheet(context, stub: c),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SearchIntro extends StatelessWidget {
  const _SearchIntro({required this.seerrLinked});

  final bool seerrLinked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.search,
                  size: 36,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.searchIntroTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                seerrLinked
                    ? context.l10n.searchIntroWithSeerr
                    : context.l10n.searchIntroWithoutSeerr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              _SearchIntroRow(
                icon: Icons.video_library_outlined,
                title: context.l10n.searchIntroJellyfin,
                description: context.l10n.searchIntroJellyfinDescription,
                tone: JfChipTone.brand,
              ),
              if (seerrLinked) ...[
                const SizedBox(height: AppSpacing.sm),
                _SearchIntroRow(
                  icon: Icons.auto_awesome_outlined,
                  title: context.l10n.searchIntroSeerr,
                  description: context.l10n.searchIntroSeerrDescription,
                  tone: JfChipTone.info,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchIntroRow extends StatelessWidget {
  const _SearchIntroRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String description;
  final JfChipTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (bg, fg) = switch (tone) {
      JfChipTone.brand => (scheme.primaryContainer, scheme.onPrimaryContainer),
      JfChipTone.info => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      _ => (scheme.surfaceContainerHigh, scheme.onSurfaceVariant),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final gridExtent = Breakpoints.gridMaxCrossAxisExtent(
      MediaQuery.sizeOf(context).width,
    );
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: _posterGrid(
        gridExtent: gridExtent,
        childCount: 12,
        builder: (_, __) => const JfPosterCard(title: '', imageUrl: null),
      ),
    );
  }
}
