import '../../core/jellyfin/models/jellyfin_item.dart';

/// Shared formatting helpers used by the per-type detail views.

/// 1 second = 10,000,000 .NET "ticks" (100-nanosecond units).
const int _ticksPerMinute = 60 * 10000000;

/// Formats a Jellyfin tick count as "1h 23min", "47min", etc. Returns an
/// empty string for null / non-positive durations.
String formatRuntime(int? ticks) {
  if (ticks == null || ticks <= 0) return '';
  final totalMinutes = ticks ~/ _ticksPerMinute;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0 && minutes > 0) return '${hours}h ${minutes}min';
  if (hours > 0) return '${hours}h';
  return '${minutes}min';
}

/// "S2 · E3" style label. Falls back to "E3" when the season number is
/// missing. The padded middle-dot matches the home rail subtitle convention
/// (see `features/home/widgets/jellyfin_rail.dart`).
String formatEpisodeCode(JellyfinItem episode) {
  final season = episode.parentIndexNumber;
  final ep = episode.indexNumber;
  if (season != null && ep != null) return 'S$season · E$ep';
  if (ep != null) return 'E$ep';
  return '';
}

const List<String> _monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Short, locale-agnostic air date — "Sep 19, 2020". Returns an empty
/// string when [date] is null so callers can render the chip conditionally.
String formatAirDate(DateTime? date) {
  if (date == null) return '';
  return '${_monthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';
}

/// "Play" or "Resume from 47min" depending on the playback state.
String playButtonLabel(JellyfinItem item) {
  if (!item.hasResumePosition) return 'Play';
  return 'Resume from ${formatRuntime(item.playbackPositionTicks)}';
}
