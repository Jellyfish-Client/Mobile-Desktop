/// One entry returned by `GET /jellyfish/upcoming`. Discriminated by a
/// `kind` field at the wire level; on the Dart side use pattern matching on
/// this sealed hierarchy instead of inspecting the enum.
sealed class UpcomingItem {
  const UpcomingItem({
    required this.releaseDate,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.hasFile,
    required this.sourceId,
  });

  /// When the item is expected to be released. Local timezone — the plugin
  /// emits ISO 8601 UTC and we parse to local for display.
  final DateTime releaseDate;
  final String title;
  final String overview;

  /// Pre-built poster URL (the plugin already resolves Radarr/Sonarr image
  /// paths to absolute URLs). Empty string when none is available.
  final String posterUrl;

  /// `true` when the upstream library already has the file (i.e. it landed
  /// before the release window ended). The UI uses this to dim items.
  final bool hasFile;

  /// Radarr movie id or Sonarr series id. Stable across requests, useful for
  /// deep-linking back into the queue / management UIs later.
  final int sourceId;
}

final class UpcomingMovie extends UpcomingItem {
  const UpcomingMovie({
    required super.releaseDate,
    required super.title,
    required super.overview,
    required super.posterUrl,
    required super.hasFile,
    required super.sourceId,
    this.year,
  });

  final int? year;
}

final class UpcomingEpisode extends UpcomingItem {
  const UpcomingEpisode({
    required super.releaseDate,
    required super.title,
    required super.overview,
    required super.posterUrl,
    required super.hasFile,
    required super.sourceId,
    required this.seriesTitle,
    required this.seasonNumber,
    required this.episodeNumber,
  });

  final String seriesTitle;
  final int seasonNumber;
  final int episodeNumber;
}

enum UpcomingKind {
  movies('movies'),
  episodes('episodes');

  const UpcomingKind(this.wire);

  /// String value sent in the `kinds` query parameter.
  final String wire;
}
