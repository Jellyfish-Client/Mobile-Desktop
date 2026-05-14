import 'package:flutter/foundation.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show BaseItemKind;

import '../../core/seerr/models.dart';

sealed class SeerSource {
  const SeerSource();
}

final class SeerTrending extends SeerSource {
  const SeerTrending();
}

final class SeerPopularMovies extends SeerSource {
  const SeerPopularMovies();
}

final class SeerPopularSeries extends SeerSource {
  const SeerPopularSeries();
}

final class SeerWatchlist extends SeerSource {
  const SeerWatchlist();
}

/// "Similar to a single seed" — fuels the per-seed "Parce que vous avez
/// regardé X" rails. The seed identity ([tmdbId] + [type]) doubles as the
/// family key on `seerrSimilarBySeedProvider`, so value equality matters.
@immutable
final class SeerSimilarToSeed extends SeerSource {
  const SeerSimilarToSeed({required this.tmdbId, required this.type});

  final int tmdbId;
  final SeerrMediaType type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeerSimilarToSeed &&
          other.tmdbId == tmdbId &&
          other.type == type;

  @override
  int get hashCode => Object.hash(tmdbId, type);
}

/// "Par humeur" rail — replaces the legacy by-genre rails. The fetch params
/// (sort order, genre set, minimum vote count, …) live in
/// `seer_moods.dart`'s spec table so all the curation knobs sit together.
final class SeerMood extends SeerSource {
  const SeerMood(this.id);

  final SeerMoodId id;
}

/// Catalog of "mood" rails offered on Home. Order matters: when the aggregate
/// mood provider de-duplicates across rails, an item that fits multiple moods
/// is assigned to the first one in this order. Keep critic-driven / catch-all
/// moods last so they soak up whatever's left.
enum SeerMoodId {
  pourRire,
  pourFrissonner,
  pourPleurer,
  pourSEvader,
  coupsDeCoeur,
}

enum RailStyle {
  landscape,
  posterStandard,
  posterDense,
  spotlightRow,
  editorial,
}

sealed class HomeSection {
  const HomeSection();

  String get id;
}

/// Jellyfin rail fed by the recommender (continue, next_up, pour_vous, …).
/// Library-scoped "latest by kind" rails use [HomeLibraryRail] instead so
/// the two code paths don't share a single variant with optional fields.
final class HomeJellyfinRail extends HomeSection {
  const HomeJellyfinRail({
    required this.id,
    required this.title,
    required this.style,
    this.subtitle,
  });

  @override
  final String id;
  final String title;
  final String? subtitle;
  final RailStyle style;
}

/// Rail scoped to a specific Jellyfin library (`parentId`) and item kind.
/// Reads `latestByLibraryProvider((parentId, kind))` directly — no recommender
/// involvement. Generated dynamically by `buildHomeCatalog` from the user's
/// libraries.
final class HomeLibraryRail extends HomeSection {
  const HomeLibraryRail({
    required this.id,
    required this.title,
    required this.style,
    required this.parentId,
    required this.kind,
    this.subtitle,
  });

  @override
  final String id;
  final String title;
  final String? subtitle;
  final RailStyle style;
  final String parentId;
  final BaseItemKind kind;
}

final class HomeSeerRail extends HomeSection {
  const HomeSeerRail({
    required this.id,
    required this.title,
    required this.source,
    this.subtitle,
    this.eyebrow,
  });

  @override
  final String id;
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final SeerSource source;
}

final class HomeMiniHero extends HomeSection {
  const HomeMiniHero({
    required this.id,
    required this.source,
    this.slideCount = 4,
  });

  @override
  final String id;
  final SeerSource source;
  final int slideCount;
}

final class HomeSpotlightInsert extends HomeSection {
  const HomeSpotlightInsert({
    required this.id,
    required this.source,
    this.index = 0,
  });

  @override
  final String id;
  final SeerSource source;
  final int index;
}

/// Visual divider between two logical home blocks (e.g. "Vos contenus" ▸
/// Jellyfin vs "À découvrir" ▸ Seer). Rendered as an eyebrow + display title
/// + thin gradient rule by `HomeSectionHeaderWidget`.
final class HomeSectionHeader extends HomeSection {
  const HomeSectionHeader({
    required this.id,
    required this.title,
    this.eyebrow,
    this.divider = true,
  });

  @override
  final String id;
  final String title;
  final String? eyebrow;
  final bool divider;
}

/// Watch-providers-as-tiles rail backed by `/watchproviders/{movies|tv}`.
/// Tapping a tile drills into a per-provider browse page.
final class HomeSeerWatchProviders extends HomeSection {
  const HomeSeerWatchProviders({
    required this.id,
    required this.title,
    required this.kind,
    this.eyebrow,
    this.region = 'FR',
  });

  @override
  final String id;
  final String title;
  final String? eyebrow;
  final HomeSeerWatchProvidersKind kind;
  final String region;
}

enum HomeSeerWatchProvidersKind { movies, tv }

/// Genres-as-tiles rail backed by `/discover/genreslider/{movie|tv}`. Used by
/// Home but not by [HomeSeerRail] because the payload shape (genres + backdrop
/// list) doesn't match the `SeerrMedia` rails — it gets its own section type
/// and renderer.
final class HomeSeerGenreSlider extends HomeSection {
  const HomeSeerGenreSlider({
    required this.id,
    required this.title,
    required this.kind,
    this.eyebrow,
  });

  @override
  final String id;
  final String title;
  final String? eyebrow;
  final HomeSeerGenreSliderKind kind;
}

enum HomeSeerGenreSliderKind { movies, tv }

/// Rail that surfaces what's coming up from the user's own Radarr / Sonarr
/// (via the Jellyfish.Bridge plugin's `/jellyfish/upcoming` endpoint). Two
/// flavours: movies surveiled by Radarr, episodes from Sonarr. Items render
/// release date + (for episodes) series name and SxxExx, so they need their
/// own widget instead of going through [HomeSeerRail].
final class HomeUpcomingRail extends HomeSection {
  const HomeUpcomingRail({
    required this.id,
    required this.title,
    required this.kind,
    this.subtitle,
    this.eyebrow,
  });

  @override
  final String id;
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final HomeUpcomingKind kind;
}

enum HomeUpcomingKind { movies, episodes }
