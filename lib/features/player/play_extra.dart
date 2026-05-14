/// Optional payload passed via `GoRouter.extra` when pushing `/play/:id`.
/// All existing call sites (`context.push('/play/$id')`) keep working — when
/// `extra` is null defaults are used.
class PlayExtra {
  const PlayExtra({
    this.mediaSourceId,
    this.audioStreamIndex,
    this.subtitleStreamIndex,
  });

  final String? mediaSourceId;
  final int? audioStreamIndex;
  final int? subtitleStreamIndex;
}
