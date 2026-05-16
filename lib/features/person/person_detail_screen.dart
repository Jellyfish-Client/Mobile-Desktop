import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/jellyfin/jellyfin_url_service.dart';
import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '../details/widgets/detail_chrome.dart' show SynopsisExpander;
import 'person_providers.dart';
import 'widgets/person_filmography_grid.dart';
import 'widgets/person_filter_chips.dart';
import 'widgets/person_hero.dart';

/// Page dédiée à un acteur / une personne : photo + nom + biographie +
/// filmographie filtrable (Tout / Films / Séries) avec les titres Jellyfin
/// d'abord puis les autres crédits TMDB via Seerr en mode "à demander".
class PersonDetailScreen extends ConsumerStatefulWidget {
  const PersonDetailScreen({required this.personId, super.key});

  final String personId;

  @override
  ConsumerState<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends ConsumerState<PersonDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _titleFadeThreshold = 80;
  double _titleOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final opacity = (offset / _titleFadeThreshold).clamp(0.0, 1.0);
    if (opacity != _titleOpacity) {
      setState(() => _titleOpacity = opacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personProvider(widget.personId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: personAsync.when(
        loading: () => const Center(child: JfLoading()),
        error: (e, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: context.l10n.personFilmographyEmptyTitle,
            message: '$e',
          ),
        ),
        data: (person) => _PersonBody(
          person: person,
          scrollController: _scrollController,
          titleOpacity: _titleOpacity,
        ),
      ),
    );
  }
}

class _PersonBody extends ConsumerWidget {
  const _PersonBody({
    required this.person,
    required this.scrollController,
    required this.titleOpacity,
  });

  final JellyfinItem person;
  final ScrollController scrollController;
  final double titleOpacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(jellyfinUrlServiceProvider);
    final filmography = ref.watch(personFilmographyProvider(person.id));
    final titleCount = filmography.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );
    final photoUrl = urls.imageUrl(person, maxWidth: 320);
    final bio = person.overview;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.bg.withValues(alpha: titleOpacity),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: titleOpacity,
            child: Text(
              person.name ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: PersonHero(
            personId: person.id,
            name: person.name ?? '',
            titleCount: titleCount,
            imageUrl: photoUrl,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        if (bio != null && bio.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: JfReadingPanel(
                maxWidth: 700,
                child: SynopsisExpander(text: bio, maxLines: 3),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        SliverToBoxAdapter(
          child: JfReadingPanel(
            maxWidth: 900,
            child: PersonFilterChips(personId: person.id),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: PersonFilmographyGrid(
            jellyfinPersonId: person.id,
            tmdbPersonId: person.tmdbId,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xxxl)),
      ],
    );
  }
}
