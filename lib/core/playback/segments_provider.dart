import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../jellyfin/jellyfin_client.dart';

enum SkipSegmentKind { intro, outro }

class SkipSegment {
  const SkipSegment({
    required this.start,
    required this.end,
    required this.kind,
  });

  final Duration start;
  final Duration end;
  final SkipSegmentKind kind;

  String get actionLabel =>
      kind == SkipSegmentKind.intro ? 'Skip Intro' : 'Skip Credits';

  bool contains(Duration position) => position >= start && position <= end;
}

final playerSegmentsProvider = FutureProvider.autoDispose
    .family<List<SkipSegment>, String>((ref, itemId) async {
      final client = ref.watch(jellyfinClientProvider);
      final List<MediaSegmentDto> raw;
      try {
        raw = await client.mediaSegments(
          itemId,
          types: BuiltList<MediaSegmentType>([
            MediaSegmentType.intro,
            MediaSegmentType.outro,
          ]),
        );
      } on Object catch (_) {
        return const [];
      }

      return raw
          .where((s) => s.startTicks != null && s.endTicks != null)
          .map((s) {
            final kind = s.type == MediaSegmentType.outro
                ? SkipSegmentKind.outro
                : SkipSegmentKind.intro;
            return SkipSegment(
              start: Duration(microseconds: s.startTicks! ~/ 10),
              end: Duration(microseconds: s.endTicks! ~/ 10),
              kind: kind,
            );
          })
          .toList(growable: false);
    });
