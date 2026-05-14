import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../shared/widgets/widgets.dart';
import '../home_providers.dart';
import '../home_section.dart';

/// Rail of streaming services available in the user's region (Netflix,
/// Disney+, …). Each tile shows the provider's TMDB logo and routes to a
/// browse screen filtered to that provider.
class SeerrWatchProvidersRail extends ConsumerWidget {
  const SeerrWatchProvidersRail({required this.section, super.key});

  final HomeSeerWatchProviders section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = section.kind == HomeSeerWatchProvidersKind.movies
        ? ref.watch(seerrWatchProvidersMoviesProvider)
        : ref.watch(seerrWatchProvidersTvProvider);
    final client = ref.watch(seerrClientProvider);
    final isTv = section.kind == HomeSeerWatchProvidersKind.tv;

    return async.when(
      loading: () => const SizedBox(height: 120),
      error: (_, __) => const SizedBox.shrink(),
      data: (providers) {
        if (providers.isEmpty) return const SizedBox.shrink();
        // Cap at 20 to keep the rail tight — TMDB returns 50+ in most regions.
        final top = providers.take(20).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JfRailHeader(eyebrow: section.eyebrow, title: section.title),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: top.length,
                itemBuilder: (context, i) {
                  final p = top[i];
                  final url = client.providerLogoUrl(p);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _ProviderTile(
                      name: p.name,
                      logoUrl: url,
                      onTap: () => context.push(
                        '/watch-provider/${isTv ? 'tv' : 'movies'}/${p.id}',
                        extra: p.name,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.name,
    required this.logoUrl,
    required this.onTap,
  });

  final String name;
  final String? logoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: scheme.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: logoUrl == null
                ? Center(
                    child: Text(
                      _initials(name),
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: logoUrl!,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => Center(
                      child: Text(
                        _initials(name),
                        style: TextStyle(color: scheme.onSurface),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _initials(String n) {
    final parts = n.split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}
