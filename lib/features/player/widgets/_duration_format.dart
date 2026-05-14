/// "h:mm:ss" or "m:ss" depending on whether the value exceeds one hour.
String formatPlayerDuration(Duration d) {
  final clamped = d.isNegative ? Duration.zero : d;
  final h = clamped.inHours;
  final m = clamped.inMinutes.remainder(60);
  final s = clamped.inSeconds.remainder(60);
  String two(int n) => n.toString().padLeft(2, '0');
  if (h > 0) return '$h:${two(m)}:${two(s)}';
  return '$m:${two(s)}';
}
