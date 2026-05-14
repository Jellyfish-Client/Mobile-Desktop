/// Text normalisation utilities for case- and diacritic-insensitive matching.
///
/// Used today by search ranking; reusable for any client-side filter that
/// needs to match user input against item titles regardless of accents
/// ("amelie" → "Amélie", "pokemon" → "Pokémon").
///
/// Coverage targets the languages most likely to appear in a Jellyfin
/// library: French, Spanish, Italian, Portuguese, German, Polish, Czech,
/// Turkish, Scandinavian. Greek/Cyrillic are out of scope — switch to
/// `package:diacritic` if those become relevant.
library;

const _diacriticFold = <String, String>{
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a',
  'ă': 'a', 'ą': 'a', 'æ': 'ae',
  'ç': 'c', 'č': 'c', 'ć': 'c',
  'ď': 'd', 'đ': 'd',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ė': 'e', 'ę': 'e',
  'ě': 'e',
  'ğ': 'g',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'į': 'i', 'ı': 'i',
  'ł': 'l', 'ľ': 'l',
  'ñ': 'n', 'ń': 'n', 'ň': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o',
  'ő': 'o', 'œ': 'oe',
  'ř': 'r',
  'š': 's', 'ś': 's', 'ş': 's', 'ß': 'ss',
  'ť': 't', 'þ': 'th',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ů': 'u', 'ű': 'u',
  'ý': 'y', 'ÿ': 'y',
  'ž': 'z', 'ź': 'z', 'ż': 'z',
};

/// Folds Latin-1+ diacritics to their ASCII base letter. Non-mapped characters
/// pass through unchanged. Caller is expected to lower-case first.
String foldDiacritics(String input) {
  if (input.isEmpty) return input;
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    final folded = _diacriticFold[ch];
    buffer.write(folded ?? ch);
  }
  return buffer.toString();
}

/// Normalise a string for case- and diacritic-insensitive matching:
/// lower-case → fold diacritics → collapse whitespace. Returns an empty
/// string for null/blank input.
String normalizeForSearch(String? input) {
  if (input == null) return '';
  final lowered = input.toLowerCase().trim();
  if (lowered.isEmpty) return '';
  final folded = foldDiacritics(lowered);
  return folded.replaceAll(RegExp(r'\s+'), ' ');
}
