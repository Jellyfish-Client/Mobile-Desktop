import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/network/offline_mode_provider.dart';
import '../../core/seerr/models.dart';
import '../../core/seerr/seerr_client.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import 'requests_providers.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(offlineModeProvider)) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.requestsTitle)),
        body: EmptyState(
          icon: Icons.cloud_off,
          title: context.l10n.requestsOfflineUnavailable,
          message: context.l10n.requestsOfflineUnavailableMessage,
        ),
      );
    }
    final filteredAsync = ref.watch(filteredRequestsProvider);
    final filter = ref.watch(requestFilterProvider);
    final sort = ref.watch(requestSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.requestsTitle),
        actions: [
          _SortMenu(
            current: sort,
            onSelect: (s) => ref.read(requestSortProvider.notifier).state = s,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterBar(
            selected: filter,
            onSelect: (f) => ref.read(requestFilterProvider.notifier).state = f,
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const _SkeletonList(),
              error: (err, _) =>
                  _ErrorView(onRetry: () => ref.invalidate(myRequestsProvider)),
              data: (requests) {
                if (requests.isEmpty) {
                  final rawAsync = ref.watch(myRequestsProvider);
                  final hasAny = rawAsync.valueOrNull?.isNotEmpty ?? false;
                  if (!hasAny) {
                    return EmptyState(
                      icon: Icons.inbox_outlined,
                      title: context.l10n.requestsNoRequests,
                      message: context.l10n.requestsNoRequestsMessage,
                    );
                  }
                  return EmptyState(
                    icon: Icons.filter_list_off,
                    title: context.l10n.requestsNoMatching,
                    message: context.l10n.requestsNoMatchingMessage(
                      _filterLabel(context, filter),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(myRequestsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final req = requests[i];
                      final client = ref.read(seerrClientProvider);
                      return _RequestRow(
                        request: req,
                        posterUrl: client.requestPosterUrl(req),
                        onTap: () => context.push('/items/${req.tmdbId}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(BuildContext context, RequestFilter filter) {
    final l10n = context.l10n;
    return switch (filter) {
      RequestFilter.all => l10n.requestsAll,
      RequestFilter.pending => l10n.requestsPending,
      RequestFilter.processing => l10n.requestsProcessing,
      RequestFilter.available => l10n.requestsAvailable,
    };
  }
}

// ---------------------------------------------------------------------------
// Filter chip bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});

  final RequestFilter selected;
  final ValueChanged<RequestFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [
      (RequestFilter.all, l10n.requestsAll),
      (RequestFilter.pending, l10n.requestsPending),
      (RequestFilter.processing, l10n.requestsProcessing),
      (RequestFilter.available, l10n.requestsAvailable),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final (filter, label) in filters) ...[
            JfChip(
              label: label,
              tone: selected == filter ? JfChipTone.brand : JfChipTone.neutral,
              onTap: () => onSelect(filter),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sort popup menu
// ---------------------------------------------------------------------------

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.current, required this.onSelect});

  final RequestSort current;
  final ValueChanged<RequestSort> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<RequestSort>(
      icon: const Icon(Icons.sort),
      tooltip: l10n.requestsSort,
      initialValue: current,
      onSelected: onSelect,
      itemBuilder: (_) => [
        PopupMenuItem(value: RequestSort.recent, child: Text(l10n.requestsSortRecent)),
        PopupMenuItem(value: RequestSort.oldest, child: Text(l10n.requestsSortOldest)),
        PopupMenuItem(value: RequestSort.status, child: Text(l10n.requestsSortStatus)),
        PopupMenuItem(value: RequestSort.title, child: Text(l10n.requestsSortTitle)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Request row card
// ---------------------------------------------------------------------------

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.onTap,
    this.posterUrl,
  });

  final SeerrRequest request;
  final String? posterUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 60,
                  height: 90,
                  child: posterUrl != null
                      ? CachedNetworkImage(
                          imageUrl: posterUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              _PosterPlaceholder(scheme: scheme),
                          errorWidget: (_, __, ___) =>
                              _PosterPlaceholder(scheme: scheme),
                        )
                      : _PosterPlaceholder(scheme: scheme),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status chip row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            request.title ?? '#${request.tmdbId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatusChip(availability: request.availability),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Subtitle: type + year
                    Text(
                      _subtitle(context, request),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Relative date
                    Text(
                      _relativeDate(context, request.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context, SeerrRequest r) {
    final l10n = context.l10n;
    final type =
        r.type == SeerrMediaType.movie ? l10n.requestsTypeMovie : l10n.requestsTypeShow;
    if (r.year != null) return '$type · ${r.year}';
    return type;
  }

  String _relativeDate(BuildContext context, DateTime? dt) {
    if (dt == null) return '';
    final l10n = context.l10n;
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return l10n.requestsJustNow;
    if (diff.inMinutes < 60) {
      return l10n.requestsMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return l10n.requestsHoursAgo(diff.inHours);
    }
    if (diff.inDays == 1) return l10n.requestsYesterday;
    if (diff.inDays < 7) return l10n.requestsDaysAgo(diff.inDays);
    if (diff.inDays < 14) return l10n.requestsLastWeek;
    if (diff.inDays < 30) {
      return l10n.requestsWeeksAgo((diff.inDays / 7).floor());
    }
    if (diff.inDays < 365) {
      return l10n.requestsMonthsAgo((diff.inDays / 30).floor());
    }
    return l10n.requestsYearsAgo((diff.inDays / 365).floor());
  }
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.availability});

  final SeerrAvailability availability;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, tone) = switch (availability) {
      SeerrAvailability.available => (l10n.requestsStatusAvailable, JfChipTone.success),
      SeerrAvailability.processing => (l10n.requestsStatusDownloading, JfChipTone.info),
      SeerrAvailability.partiallyAvailable => (l10n.requestsStatusPartial, JfChipTone.info),
      SeerrAvailability.pending => (l10n.requestsStatusPending, JfChipTone.warning),
      SeerrAvailability.unknown => (l10n.requestsStatusUnknown, JfChipTone.neutral),
    };
    return JfChip(label: label, tone: tone);
  }
}

// ---------------------------------------------------------------------------
// Poster placeholder
// ---------------------------------------------------------------------------

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_outlined,
        color: scheme.onSurfaceVariant,
        size: 24,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading list (4 placeholder cards)
// ---------------------------------------------------------------------------

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => const _SkeletonRow(),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster skeleton
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(width: 60, height: 90, color: base),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Chip skeleton
                  Container(
                    height: 22,
                    width: 80,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: scheme.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load requests',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          JfButton.secondary(
            label: context.l10n.retryButton,
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
