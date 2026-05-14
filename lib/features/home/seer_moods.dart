import 'dart:convert';

import '../../core/cache/seerr_serialization.dart';
import '../../core/seerr/models.dart';
import '../../l10n/app_localizations.dart';
import 'home_section.dart';

/// Static recipe behind each [SeerMoodId]: a [titleOf] callback resolves the
/// rail header from the current [AppLocalizations] so the strings track the
/// app language. The remaining fields are forwarded to
/// `SeerrClient.discoverMovies` to shape the TMDB query.
class SeerMoodSpec {
  const SeerMoodSpec({
    required this.titleOf,
    required this.eyebrow,
    required this.sortBy,
    this.genres = const [],
    this.voteCountGte,
    this.voteAverageGte,
  });

  final String Function(AppLocalizations l10n) titleOf;
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

final Map<SeerMoodId, SeerMoodSpec> kSeerMoods = {
  SeerMoodId.pourRire: SeerMoodSpec(
    titleOf: (l10n) => l10n.homeMoodComedy,
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'popularity.desc',
    genres: const [_kGenreComedy],
    voteCountGte: 100,
  ),
  SeerMoodId.pourFrissonner: SeerMoodSpec(
    titleOf: (l10n) => l10n.homeMoodThrills,
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'popularity.desc',
    genres: const [_kGenreHorror, _kGenreThriller],
    voteCountGte: 100,
  ),
  SeerMoodId.pourPleurer: SeerMoodSpec(
    titleOf: (l10n) => l10n.homeMoodTearjerker,
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'vote_average.desc',
    genres: const [_kGenreDrama, _kGenreRomance],
    voteCountGte: 500,
  ),
  SeerMoodId.pourSEvader: SeerMoodSpec(
    titleOf: (l10n) => l10n.homeMoodEscape,
    eyebrow: 'EXTERNAL · SEER',
    sortBy: 'popularity.desc',
    genres: const [_kGenreAdventure, _kGenreFantasy, _kGenreSciFi],
    voteCountGte: 200,
  ),
  // No genre filter — broad acclaim only. Sits last so it absorbs any movie
  // that didn't get assigned to one of the more specific moods above.
  SeerMoodId.coupsDeCoeur: SeerMoodSpec(
    titleOf: (l10n) => l10n.homeMoodAcclaimed,
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
HomeSeerRail buildSeerMoodRail(SeerMoodId id, AppLocalizations l10n) {
  final spec = moodSpec(id);
  return HomeSeerRail(
    id: 'seer_mood_${id.name}',
    title: spec.titleOf(l10n),
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
