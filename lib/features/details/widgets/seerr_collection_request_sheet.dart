import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/seerr/models.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';

/// Bottom sheet shown when the user taps a TMDB collection (e.g. "Saw
/// Collection") in Seerr search results. Fetches the collection, lists each
/// movie with its current availability, and lets the user multi-select the
/// ones they want to request. One `createRequest` call is fired per selected
/// movie when the user confirms.
class SeerrCollectionRequestSheet extends ConsumerStatefulWidget {
  const SeerrCollectionRequestSheet({required this.stub, super.key});

  /// The thin collection stub returned by `/search` — has id, name, and
  /// usually a poster but no parts. The sheet fetches parts on open.
  final SeerrCollection stub;

  @override
  ConsumerState<SeerrCollectionRequestSheet> createState() =>
      _SeerrCollectionRequestSheetState();
}

class _SeerrCollectionRequestSheetState
    extends ConsumerState<SeerrCollectionRequestSheet> {
  final Set<int> _selected = <int>{};
  bool _seededDefault = false;
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  bool _isRequestable(SeerrAvailability a) {
    return a == SeerrAvailability.unknown;
  }

  Future<void> _submit(List<SeerrMedia> parts) async {
    if (_selected.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });

    final client = ref.read(seerrClientProvider);
    final targets = parts.where((p) => _selected.contains(p.tmdbId)).toList();

    // Each request is awaited independently so a single failure doesn't
    // strand the rest. We report a partial-success summary back to the user.
    final outcomes = await Future.wait(
      targets.map((p) async {
        try {
          await client.createRequest(
            type: SeerrMediaType.movie,
            tmdbId: p.tmdbId,
          );
          return (media: p, error: null as Object?);
        } on Object catch (e) {
          return (media: p, error: e as Object?);
        }
      }),
    );
    if (!mounted) return;

    final failures = outcomes.where((o) => o.error != null).toList();
    final successes = outcomes.length - failures.length;

    setState(() {
      _submitting = false;
      _submitted = failures.isEmpty;
      _error = failures.isEmpty
          ? null
          : (successes == 0
                ? 'Aucune demande n’a pu être envoyée. ${_friendlyError(failures.first.error!)}'
                : '$successes demande${successes == 1 ? '' : 's'} envoyée${successes == 1 ? '' : 's'}, ${failures.length} échec${failures.length == 1 ? '' : 's'}.');
      // Un-select the items that failed so the user can retry just those.
      _selected
        ..clear()
        ..addAll(failures.map((f) => f.media.tmdbId));
    });

    if (successes > 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Demandé $successes film${successes == 1 ? '' : 's'} de « ${widget.stub.name} »',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final async = ref.watch(_seerrCollectionProvider(widget.stub.tmdbId));

    // Auto-select every requestable movie when the collection first resolves.
    // Using ref.listen keeps the mutation off the build hot-path — mirrors
    // the pattern in seerr_request_sheet.dart's TV season seed.
    ref.listen<AsyncValue<SeerrCollection?>>(
      _seerrCollectionProvider(widget.stub.tmdbId),
      (_, next) {
        if (_seededDefault) return;
        next.whenData((collection) {
          if (collection == null || collection.parts.isEmpty) return;
          setState(() {
            _selected
              ..clear()
              ..addAll(
                collection.parts
                    .where((p) => _isRequestable(p.availability))
                    .map((p) => p.tmdbId),
              );
            _seededDefault = true;
          });
        });
      },
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 36,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              _Header(stub: widget.stub),
              const SizedBox(height: AppSpacing.lg),
              async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: JfLoading(),
                ),
                error: (e, __) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Impossible de charger la collection',
                  message: e.toString(),
                ),
                data: (collection) {
                  if (collection == null || collection.parts.isEmpty) {
                    return const EmptyState(
                      icon: Icons.movie_filter_outlined,
                      title: 'Collection vide',
                      message: 'Aucun film trouvé dans cette collection.',
                    );
                  }
                  return _MovieList(
                    parts: collection.parts,
                    selected: _selected,
                    isRequestable: _isRequestable,
                    onToggle: (tmdbId) {
                      setState(() {
                        if (!_selected.add(tmdbId)) _selected.remove(tmdbId);
                      });
                    },
                    onToggleAll: () {
                      setState(() {
                        final requestable = collection.parts
                            .where((p) => _isRequestable(p.availability))
                            .map((p) => p.tmdbId)
                            .toList();
                        final allSelected =
                            requestable.isNotEmpty &&
                            requestable.every(_selected.contains);
                        if (allSelected) {
                          _selected.removeAll(requestable);
                        } else {
                          _selected.addAll(requestable);
                        }
                      });
                    },
                  );
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              JfButton.primary(
                label: _submitted
                    ? context.l10n.seerrCollectionRequested
                    : _selected.isEmpty
                    ? context.l10n.seerrCollectionSelectAtLeastOne
                    : context.l10n.seerrCollectionRequestMovies(_selected.length),
                icon: _submitted ? Icons.check_rounded : Icons.send_rounded,
                fullWidth: true,
                size: JfButtonSize.lg,
                loading: _submitting,
                onPressed: (_selected.isEmpty || _submitted || _submitting)
                    ? null
                    : () => _submit(async.valueOrNull?.parts ?? const []),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _friendlyError(Object e) {
    final s = e.toString();
    if (s.length > 200) return '${s.substring(0, 197)}…';
    return s;
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.stub});

  final SeerrCollection stub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final client = ref.watch(seerrClientProvider);
    final imageUrl = client.collectionImageUrl(stub);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            width: 96,
            height: 144,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: scheme.surfaceContainerHigh),
                    errorWidget: (_, __, ___) =>
                        Container(color: scheme.surfaceContainerHigh),
                  )
                : Container(color: scheme.surfaceContainerHigh),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stub.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              JfChip(
                label: context.l10n.seerrCollectionChip,
                tone: JfChipTone.info,
              ),
              if (stub.overview != null && stub.overview!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  stub.overview!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MovieList extends StatelessWidget {
  const _MovieList({
    required this.parts,
    required this.selected,
    required this.isRequestable,
    required this.onToggle,
    required this.onToggleAll,
  });

  final List<SeerrMedia> parts;
  final Set<int> selected;
  final bool Function(SeerrAvailability) isRequestable;
  final ValueChanged<int> onToggle;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final requestableIds = parts
        .where((p) => isRequestable(p.availability))
        .map((p) => p.tmdbId)
        .toList();
    final allRequestableSelected =
        requestableIds.isNotEmpty && requestableIds.every(selected.contains);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.seerrCollectionMovies,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            if (requestableIds.isNotEmpty)
              TextButton.icon(
                onPressed: onToggleAll,
                icon: Icon(
                  allRequestableSelected
                      ? Icons.deselect_rounded
                      : Icons.done_all_rounded,
                  size: 16,
                ),
                label: Text(
                  allRequestableSelected
                      ? context.l10n.seerrCollectionDeselectAll
                      : context.l10n.seerrCollectionSelectAll,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final part in parts) ...[
          _MovieTile(
            title: part.title,
            subtitle: part.year?.toString(),
            availability: part.availability,
            selected: selected.contains(part.tmdbId),
            disabled: !isRequestable(part.availability),
            onTap: () => onToggle(part.tmdbId),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _MovieTile extends StatelessWidget {
  const _MovieTile({
    required this.title,
    required this.subtitle,
    required this.availability,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final SeerrAvailability availability;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bg = disabled
        ? scheme.surfaceContainer
        : selected
        ? scheme.primaryContainer
        : scheme.surfaceContainerHigh;
    final fg = disabled
        ? scheme.onSurfaceVariant
        : selected
        ? scheme.onPrimaryContainer
        : scheme.onSurface;

    final shape = RoundedRectangleBorder(
      side: BorderSide(
        color: selected
            ? scheme.primary.withValues(alpha: 0.6)
            : scheme.outlineVariant,
        width: selected ? 1.5 : 1,
      ),
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    return Material(
      color: bg,
      shape: shape,
      child: InkWell(
        onTap: disabled ? null : onTap,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                disabled
                    ? _disabledIcon(availability)
                    : selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: disabled
                    ? scheme.onSurfaceVariant
                    : selected
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: disabled
                              ? scheme.onSurfaceVariant
                              : selected
                              ? scheme.onPrimaryContainer.withValues(
                                  alpha: 0.75,
                                )
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (disabled) ...[
                const SizedBox(width: AppSpacing.sm),
                _AvailabilityChip(availability: availability),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _disabledIcon(SeerrAvailability a) {
    return switch (a) {
      SeerrAvailability.available => Icons.check_rounded,
      SeerrAvailability.pending ||
      SeerrAvailability.processing ||
      SeerrAvailability.partiallyAvailable => Icons.hourglass_top_rounded,
      _ => Icons.block_rounded,
    };
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.availability});

  final SeerrAvailability availability;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return switch (availability) {
      SeerrAvailability.available => JfChip(
        icon: Icons.check_rounded,
        label: l.seerrAvailabilityAvailable,
        tone: JfChipTone.success,
      ),
      SeerrAvailability.partiallyAvailable => JfChip(
        icon: Icons.incomplete_circle_rounded,
        label: l.seerrAvailabilityPartial,
        tone: JfChipTone.info,
      ),
      SeerrAvailability.pending || SeerrAvailability.processing => JfChip(
        icon: Icons.hourglass_top_rounded,
        label: l.seerrAvailabilityPending,
        tone: JfChipTone.warning,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Cached fetch of a Seerr collection by TMDB id. Auto-disposed so two
/// successive openings of the same collection don't accumulate state. We
/// `ref.read` the client because we only need it for the initial call and
/// don't want a session-refresh to re-trigger the network request while
/// the sheet is open.
final _seerrCollectionProvider = FutureProvider.autoDispose
    .family<SeerrCollection?, int>((ref, tmdbId) {
      return ref.read(seerrClientProvider).collection(tmdbId);
    });

/// Convenience launcher — same modal config as `showSeerrRequestSheet`.
Future<void> showSeerrCollectionRequestSheet(
  BuildContext context, {
  required SeerrCollection stub,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => SeerrCollectionRequestSheet(stub: stub),
  );
}
