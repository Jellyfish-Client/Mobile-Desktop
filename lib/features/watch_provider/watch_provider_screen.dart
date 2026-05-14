import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';
import '../details/widgets/seerr_request_sheet.dart';
import '../home/home_providers.dart';

/// Browse Movies (or TV) available on a given streaming/rental service in the
/// user's region. Fed by Seerr's `/discover/{movies|tv}?watchProviders=`.
class WatchProviderScreen extends ConsumerWidget {
  const WatchProviderScreen({
    required this.providerId,
    required this.isTv,
    required this.providerName,
    super.key,
  });

  final int providerId;
  final bool isTv;
  final String providerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      seerrDiscoverByProviderProvider((providerId: providerId, isTv: isTv)),
    );
    final client = ref.watch(seerrClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(providerName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Impossible de charger le contenu de $providerName.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Aucun ${isTv ? "série" : "film"} trouvé pour $providerName '
                  'dans votre région.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 2 / 3.4,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) =>
                _PosterCell(media: items[i], client: client),
          );
        },
      ),
    );
  }
}

class _PosterCell extends StatelessWidget {
  const _PosterCell({required this.media, required this.client});

  final SeerrMedia media;
  final SeerrClient client;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = client.posterUrl(media);
    return InkWell(
      onTap: () => showSeerrRequestSheet(context, media: media),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: url == null
                  ? Container(color: scheme.surfaceContainerHigh)
                  : CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: scheme.surfaceContainerHigh),
                      errorWidget: (_, __, ___) =>
                          Container(color: scheme.surfaceContainerHigh),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            media.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
