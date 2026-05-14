import 'package:flutter/foundation.dart';

import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../shared/text/diacritics.dart';

/// Tiered relevance scoring for Jellyfin search results.
///
/// Jellyfin's `getItems` returns matches sorted by `SortName`, which mixes
/// "Friends" with "Friends Reunion" with "A Friend of Mine". Reordering
/// client-side by tiered match quality (exact → prefix → word-prefix →
/// contains → token-overlap) puts the result the user typed first.

final _tokenSplit = RegExp("[^a-z0-9']+");

List<String> _tokenize(String normalized) {
  if (normalized.isEmpty) return const [];
  return normalized
      .split(_tokenSplit)
      .where((t) => t.isNotEmpty)
      .toList(growable: false);
}

/// Tier scores. Spaced widely so a tiebreak inside a tier never crosses into
/// the next tier — a year bump can't promote a "contains" hit above a
/// "word-prefix" hit.
const double _exactScore = 10000;
const double _prefixScore = 9000;
const double _wordPrefixScore = 7500;
const double _containsScore = 6000;
const double _tokenOverlapMax = 5000;

double _scoreName({
  required String name,
  required String query,
  required List<String> queryTokens,
}) {
  if (name.isEmpty || query.isEmpty) return 0;
  if (name == query) return _exactScore;
  if (name.startsWith(query)) {
    // Closer length to the query = stronger prefix hit.
    final lengthBonus = 100 / (1 + (name.length - query.length));
    return _prefixScore + lengthBonus;
  }

  final nameTokens = _tokenize(name);
  if (nameTokens.isEmpty) return 0;

  // Word-prefix: any name token starts with the (single-word) query.
  if (queryTokens.length == 1) {
    final q = queryTokens.first;
    for (final t in nameTokens) {
      if (t.startsWith(q)) {
        final bonus = 100 / (1 + (t.length - q.length));
        return _wordPrefixScore + bonus;
      }
    }
  }

  if (name.contains(query)) {
    return _containsScore;
  }

  // Token overlap: each query token that prefixes some name token counts.
  // Lets "office us" still rank "The Office (US)" highly even though the
  // contiguous string "office us" never appears.
  if (queryTokens.length > 1) {
    var matched = 0;
    for (final q in queryTokens) {
      for (final t in nameTokens) {
        if (t.startsWith(q)) {
          matched++;
          break;
        }
      }
    }
    if (matched > 0) {
      return _tokenOverlapMax * (matched / queryTokens.length);
    }
  }

  return 0;
}

/// Per-item score against [query], based on `item.name`. Returns 0 when
/// nothing matches.
///
/// We deliberately don't fall back to `seriesName`: the search query is
/// already filtered to root kinds (Movie/Series/BoxSet/…) before reaching
/// the ranker, so episode/season fallbacks would only fire for items the
/// caller did not intend to surface anyway.
///
/// Exposed only for unit-testing the scoring tiers — production code should
/// call [rankByRelevance].
@visibleForTesting
double scoreItem(JellyfinItem item, String query) {
  final normalizedQuery = normalizeForSearch(query);
  if (normalizedQuery.isEmpty) return 0;
  final queryTokens = _tokenize(normalizedQuery);
  return _scoreName(
    name: normalizeForSearch(item.name),
    query: normalizedQuery,
    queryTokens: queryTokens,
  );
}

/// Re-orders [items] by descending relevance to [query]. Items with score 0
/// are dropped — they only appear when the server returned a tangentially
/// related item (e.g. matched on overview text we don't surface).
///
/// Ties break on shorter `name` then more recent `productionYear` so that
/// "Friends" beats "Friends Reunion" and "Dune (2021)" beats "Dune (1984)".
List<JellyfinItem> rankByRelevance(List<JellyfinItem> items, String query) {
  final normalizedQuery = normalizeForSearch(query);
  if (normalizedQuery.isEmpty || items.isEmpty) return items;

  final scored = <_ScoredItem>[];
  for (final item in items) {
    final score = scoreItem(item, query);
    if (score > 0) scored.add(_ScoredItem(item, score));
  }

  scored.sort((a, b) {
    final cmp = b.score.compareTo(a.score);
    if (cmp != 0) return cmp;
    final aName = a.item.name?.length ?? 1 << 20;
    final bName = b.item.name?.length ?? 1 << 20;
    if (aName != bName) return aName.compareTo(bName);
    final ay = a.item.productionYear ?? 0;
    final by = b.item.productionYear ?? 0;
    return by.compareTo(ay);
  });

  return scored.map((s) => s.item).toList(growable: false);
}

class _ScoredItem {
  const _ScoredItem(this.item, this.score);
  final JellyfinItem item;
  final double score;
}
