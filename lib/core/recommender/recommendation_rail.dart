import 'package:jellyfin_api/jellyfin_api.dart';

/// Why a rail was surfaced. When [label] is set it is rendered as a subtitle
/// under the section title; for rails that already carry the rationale in
/// their main title (the per-source "Parce que vous avez aimé X" rails)
/// [label] is left null and only [sourceItemId] is set, kept around for
/// analytics / deep linking.
class RailReason {
  const RailReason({this.label, this.sourceItemId});

  final String? label;
  final String? sourceItemId;
}

/// An immutable set of items to display as a horizontal scroll section on the
/// Home screen. The [id] is stable across re-renders so Flutter can key lists.
class RecommendationRail {
  const RecommendationRail({
    required this.id,
    required this.title,
    required this.items,
    this.subtitle,
    this.reason,
    this.showProgress = false,
  });

  /// Stable, unique identifier for this rail (e.g. `'continue'`, `'pour_vous'`).
  final String id;

  /// Localised section heading.
  final String title;

  /// Optional one-liner shown under the title.
  final String? subtitle;

  /// Optional algorithmic reason — rendered under title if present.
  final RailReason? reason;

  /// Items to display. Always non-empty (empty rails are filtered out).
  final List<BaseItemDto> items;

  /// Whether to overlay a playback progress bar on each card.
  final bool showProgress;
}
