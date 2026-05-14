import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;

import '../../core/jellyfin/models/jellyfin_item.dart';
import '../library/library_providers.dart';
import 'home_section.dart';
import 'reco_seeds.dart';
import 'seer_moods.dart';

const String _kJellyfinGroupId = 'header_jellyfin';
const String _kSeerrGroupId = 'header_seer';

/// Assembles the Home sections list from the user's libraries and the
/// linked-Seerr state. Pure function — call sites pass their freshly resolved
/// inputs (no side effects, no provider access).
///
/// The result is ordered top-to-bottom:
///   1. Continue Watching + Next Up (Jellyfin head).
///   2. "Vos contenus" header.
///   3. One or two rails per [JellyfinItem] view (movies → "Nouveaux films" ;
///      tv → "Nouveaux épisodes" + "Nouvelles séries" ; …).
///   4. Recommender-driven rails (Pour vous, Pépites, Vite vu, Parce que…).
///   5. "À découvrir" header (only when Seerr is linked).
///   6. Seerr rails (trending, popular, upcoming, watchlist, recommendations,
///      genre sliders, genre rails).
///   7. When Seerr is NOT available (plugin missing or unconfigured), the
///      whole Seer block is omitted. The home screen renders a banner about
///      the missing plugin — there is no inline CTA.
List<HomeSection> buildHomeCatalog({
  required List<JellyfinItem> views,
  required bool isSeerLinked,
  List<RecoSeed> recoSeeds = const [],
}) {
  final out = <HomeSection>[
    const HomeJellyfinRail(
      id: 'continue',
      title: 'Continuer à regarder',
      style: RailStyle.landscape,
    ),
    const HomeJellyfinRail(
      id: 'next_up',
      title: 'À finir',
      style: RailStyle.landscape,
    ),
    const HomeSectionHeader(
      id: _kJellyfinGroupId,
      title: 'Vos contenus',
      eyebrow: 'JELLYFIN',
    ),
    // Cross-library "what's new" rail. Always present so brand-new users
    // (empty Resume/NextUp/profile) still see real content immediately —
    // and a useful overview for everyone else. Fed by `latestItemsProvider`
    // (limit=24, SWR-cached, warmed in main.dart) so it paints from disk
    // on cold start.
    const HomeJellyfinRail(
      id: 'latest',
      title: 'Nouveautés',
      subtitle: 'Ajouts récents',
      style: RailStyle.landscape,
    ),
  ];

  // Per-library rails — one per (view, kind) pair returned by
  // `latestRailKindsForView`. The rail style follows the kind so episodes get
  // landscape cards, movies/series posters, etc.
  for (final view in views) {
    final name = view.name;
    if (name == null) continue;
    final railKinds = latestRailKindsForView(view);
    for (final rk in railKinds) {
      out.add(
        HomeLibraryRail(
          id: 'lib_${view.id}_${rk.kind.name}',
          title: '$name • ${rk.suffix}',
          style: _styleForKind(rk.kind),
          parentId: view.id,
          kind: rk.kind,
        ),
      );
    }
  }

  // Recommender rails (same ids as the legacy catalog so `_findRail` in
  // `home_section_view.dart` keeps matching them), followed by the two
  // Upcoming rails (Radarr movies + Sonarr episodes). Upcoming sits between
  // the user's own Jellyfin content and the Seer discovery block — it surfaces
  // what the user has already asked the *arr stack to watch for, so it's
  // closer in spirit to "your stuff" than to discovery. Each upcoming rail
  // self-hides when its upstream is unavailable (cf. providers).
  out.addAll(const [
    HomeJellyfinRail(
      id: 'pour_vous',
      title: 'Pour vous',
      style: RailStyle.spotlightRow,
    ),
    HomeJellyfinRail(
      id: 'pepites',
      title: 'Pépites',
      style: RailStyle.editorial,
    ),
    HomeJellyfinRail(
      id: 'vite_vu',
      title: 'Vite vu',
      style: RailStyle.posterDense,
    ),
    HomeJellyfinRail(
      id: 'because_',
      title: 'Parce que vous avez aimé…',
      style: RailStyle.posterStandard,
    ),
    HomeUpcomingRail(
      id: 'upcoming_movies',
      title: 'Films à venir',
      kind: HomeUpcomingKind.movies,
    ),
    HomeUpcomingRail(
      id: 'upcoming_episodes',
      title: 'Épisodes à venir',
      kind: HomeUpcomingKind.episodes,
    ),
  ]);

  // Jellyseerr unavailable (plugin missing or admin hasn't configured it):
  // we render no Seerr section. The home screen's plugin-missing banner is
  // the single point of communication — no inline CTA, no "link Seerr"
  // card. There's nothing the user can do from the app anyway since auth
  // is shared with Jellyfin.
  if (!isSeerLinked) return out;

  out
    ..addAll(const [
    HomeSectionHeader(
      id: _kSeerrGroupId,
      title: 'À découvrir',
      eyebrow: 'SEER',
    ),
    HomeSeerWatchProviders(
      id: 'seer_watch_providers_movies',
      title: 'Disponible sur…',
      kind: HomeSeerWatchProvidersKind.movies,
      eyebrow: 'EXTERNAL · SEER',
    ),
    HomeSeerRail(
      id: 'seer_trending',
      title: "Tendance aujourd'hui",
      eyebrow: 'EXTERNAL · SEER',
      source: SeerTrending(),
    ),
    HomeMiniHero(id: 'minihero_popular', source: SeerPopularMovies()),
    HomeSeerRail(
      id: 'seer_popular_series',
      title: 'Séries qui cartonnent',
      eyebrow: 'EXTERNAL · SEER',
      source: SeerPopularSeries(),
    ),
    HomeSeerRail(
      id: 'seer_watchlist',
      title: 'Votre watchlist',
      eyebrow: 'EXTERNAL · SEER',
      source: SeerWatchlist(),
    ),
  ])
    // Per-seed reco rails — picked at random per session by `recoSeedsProvider`
    // with an anime bias. Empty list when the user has zero history seeds and
    // the popular fallback hasn't loaded yet — in that case the whole reco
    // block disappears (no skeleton, no placeholder rail).
    ..addAll(recoSeeds.map(_buildRecoRail))
    ..addAll(const [
    HomeSeerGenreSlider(
      id: 'seer_genre_slider_movies',
      title: 'Films par genre',
      kind: HomeSeerGenreSliderKind.movies,
      eyebrow: 'EXTERNAL · SEER',
    ),
    HomeSeerGenreSlider(
      id: 'seer_genre_slider_tv',
      title: 'Séries par genre',
      kind: HomeSeerGenreSliderKind.tv,
      eyebrow: 'EXTERNAL · SEER',
    ),
  ])
    // Mood-based rails replace the old per-genre rails (Action / Drames / …):
    // a single movie is usually tagged with multiple genres so those produced
    // the same 7 blockbusters in every list. Each mood combines genre + sort
    // + voteCount filters (see `seer_moods.dart`), and the aggregate provider
    // dedups items already shown by an earlier Seer rail or a previous mood
    // — so each rail surfaces fresh content.
    ..addAll(SeerMoodId.values.map(buildSeerMoodRail))
    ..add(
      const HomeSeerWatchProviders(
        id: 'seer_watch_providers_tv',
        title: 'Séries par service',
        kind: HomeSeerWatchProvidersKind.tv,
        eyebrow: 'EXTERNAL · SEER',
      ),
    );
  return out;
}

HomeSeerRail _buildRecoRail(RecoSeed seed) {
  return HomeSeerRail(
    id: 'seer_reco_${seed.type.name}_${seed.tmdbId}',
    title: seed.fromHistory
        ? 'Parce que vous avez regardé ${seed.title}'
        : 'Comme ${seed.title}',
    eyebrow: 'EXTERNAL · SEER',
    source: SeerSimilarToSeed(tmdbId: seed.tmdbId, type: seed.type),
  );
}

RailStyle _styleForKind(BaseItemKind kind) {
  if (kind == BaseItemKind.episode) return RailStyle.landscape;
  if (kind == BaseItemKind.musicAlbum) return RailStyle.posterDense;
  if (kind == BaseItemKind.musicVideo) return RailStyle.landscape;
  return RailStyle.posterStandard;
}
