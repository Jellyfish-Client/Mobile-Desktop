import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/jellyfin/jellyfin_url_service.dart';
import '../../../core/playback/playback_providers.dart';
import '../../../l10n/l10n_extension.dart';
import '_duration_format.dart';

Future<void> showChaptersSheet(BuildContext context, String itemId) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    isScrollControlled: true,
    builder: (_) => _ChaptersSheet(itemId: itemId),
  );
}

class _ChaptersSheet extends ConsumerWidget {
  const _ChaptersSheet({required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // chapters is an SDK-only field — read the DTO directly instead of the
    // domain model, which intentionally omits it.
    final item = ref.watch(playerItemDtoProvider(itemId)).valueOrNull;
    final chapters = item?.chapters?.toList() ?? const [];
    final urls = ref.watch(jellyfinUrlServiceProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: chapters.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  context.l10n.playerNoChapters,
                  style: const TextStyle(color: AppColors.onSurfaceMuted),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: chapters.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (_, i) {
                  final chapter = chapters[i];
                  final startTicks = chapter.startPositionTicks ?? 0;
                  final start = Duration(microseconds: startTicks ~/ 10);
                  final thumb = (chapter.imageTag != null)
                      ? urls.chapterUrl(
                          itemId: itemId,
                          index: i,
                          tag: chapter.imageTag!,
                          maxWidth: 320,
                        )
                      : null;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    onTap: () async {
                      final backend = ref.read(playerBackendProvider);
                      await backend.seek(start);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: SizedBox(
                              width: 110,
                              height: 62,
                              child: thumb != null
                                  ? CachedNetworkImage(
                                      imageUrl: thumb,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const ColoredBox(
                                        color: AppColors.surface,
                                      ),
                                      errorWidget: (_, __, ___) =>
                                          const ColoredBox(
                                            color: AppColors.surface,
                                          ),
                                    )
                                  : const ColoredBox(color: AppColors.surface),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  chapter.name ?? context.l10n.playerChapterNumber(i + 1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatPlayerDuration(start),
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceMuted,
                                    fontSize: 12,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
