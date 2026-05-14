import 'dart:convert';

import '../../core/cache/seerr_serialization.dart';
import '../../core/seerr/models.dart';
import 'home_section.dart';

/// Static recipe behind each [SeerMoodId]: title and eyebrow drive the rail
/// header; the remaining fields are forwarded to `SeerrClient.discoverMovies`
/// to shape the TMDB query.
class SeerMoodSpec {
  const SeerMoodSpec({
    required this.title,
    required this.eyebrow,
    required this.sortBy,
    this.genres = const [],
    this.voteCountGte,
    this.voteAverageGte,
  });

  final String title;
  final String eyebrow;
  final String sortBy;
  final List<int> genres;
  final int? voteCountGte;
  final double? voteAverageGte;
}

/// TMDB genre ids referenced below. Listed here so a stray digit in a spec
/// is obvious at review time.
const _kGenreComedy = 35;
const _kGenreHorror = 27;
const _kGenreThriller = 53;
const _kGenreDrama = 18;
const _kGenreRomance = 10749;
const _kGenreAdventure = 12;
const _kGenreFantasy = 14;
const _kGenreSciFi = 878;

const Map<SeerMoodId, SeerMoodSpec> kSeerMoods = {
  SeerMoodId.pourRire: SeerMoodSpec(
    title: 'Pour rire un bon coup',
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'popularity.desc',
    genres: [_kGenreComedy],
    voteCountGte: 100,
  ),
  SeerMoodId.pourFrissonner: SeerMoodSpec(
    title: 'Pour frissonner ce soir',
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'popularity.desc',
    genres: [_kGenreHorror, _kGenreThriller],
    voteCountGte: 100,
  ),
  SeerMoodId.pourPleurer: SeerMoodSpec(
    title: 'Pour pleurer un bon coup',
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'vote_average.desc',
    genres: [_kGenreDrama, _kGenreRomance],
    voteCountGte: 500,
  ),
  SeerMoodId.pourSEvader: SeerMoodSpec(
    title: "Pour s'évader",
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'popularity.desc',
    genres: [_kGenreAdventure, _kGenreFantasy, _kGenreSciFi],
    voteCountGte: 200,
  ),
  // No genre filter — broad acclaim only. Sits last so it absorbs any movie
  // that didn't get assigned to one of the more specific moods above.
  SeerMoodId.coupsDeCoeur: SeerMoodSpec(
    title: 'Acclamés par la critique',
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'vote_average.desc',
    voteCountGte: 2000,
    voteAverageGte: 7.5,
  ),
};

SeerMoodSpec moodSpec(SeerMoodId id) => kSeerMoods[id]!;

/// Convenience constructor used by the Home catalog so the section id stays
/// in sync with the enum and the title/eyebrow come from the single source
/// of truth ([kSeerMoods]).
HomeSeerRail buildSeerMoodRail(SeerMoodId id) {
  final spec = moodSpec(id);
  return HomeSeerRail(
    id: 'seer_mood_${id.name}',
    title: spec.title,
    eyebrow: spec.eyebrow,
    source: SeerMood(id),
  );
}

/// On-disk shape: `{"<moodName>": [<seerMedia>, …], …}`. Unknown mood names
/// (after an enum rename) are skipped on decode so the rail self-heals
/// instead of throwing.
String encodeSeerMoodMap(Map<SeerMoodId, List<SeerrMedia>> raw) {
  return jsonEncode({
    for (final entry in raw.entries)
      entry.key.name: [for (final m in entry.value) encodeSeerrMediaJson(m)],
  });
}

Map<SeerMoodId, List<SeerrMedia>>? tryDecodeSeerMoodMap(String payload) {
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! Map) return null;
    final out = <SeerMoodId, List<SeerrMedia>>{};
    for (final entry in decoded.entries) {
      final key = entry.key;
      if (key is! String) continue;
      final mood = SeerMoodId.values.where((m) => m.name == key).firstOrNull;
      if (mood == null) continue;
      final list = entry.value;
      if (list is! List) continue;
      final items = <SeerrMedia>[];
      for (final raw in list) {
        if (raw is! Map) continue;
        final m = tryDecodeSeerrMediaJson(Map<String, dynamic>.from(raw));
        if (m != null) items.add(m);
      }
      out[mood] = items;
    }
    return out;
  } on Object {
    return null;
  }
}
