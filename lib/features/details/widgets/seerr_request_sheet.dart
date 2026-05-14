import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/bridge/bridge_error_bus.dart';
import '../../../core/bridge/bridge_errors.dart';
import '../../../core/seerr/models.dart';
import '../../../core/seerr/seerr_client.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';
import '../detail_providers.dart';

/// Bottom sheet that confirms a Seerr request. The visual style matches the
/// home rail's "preview" look (dark surface, display typography, French
/// chips). For TV items, an inline season picker lets the user scope the
/// request — pass [initialSeasons] to override the default "all numbered
/// seasons" selection from a missing-season tap.
class SeerrRequestSheet extends ConsumerStatefulWidget {
  const SeerrRequestSheet({
    required this.media,
    this.initialSeasons,
    super.key,
  });

  final SeerrMedia media;

  /// Pre-selected season numbers (TV only). When null, the sheet auto-selects
  /// every numbered season (specials excluded).
  final List<int>? initialSeasons;

  @override
  ConsumerState<SeerrRequestSheet> createState() => _SeerrRequestSheetState();
}

class _SeerrRequestSheetState extends ConsumerState<SeerrRequestSheet> {
  /// Selected season numbers. `0` is Specials. Only used for TV.
  final Set<int> _selected = <int>{};

  /// Set once seasons load so we seed the default selection only once.
  bool _seededDefault = false;

  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  bool get _isTv => widget.media.type == SeerrMediaType.tv;

  Future<void> _submit() async {
    if (_isTv && _selected.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final seasons = _isTv ? (_selected.toList()..sort()) : null;
      await ref
          .read(seerrClientProvider)
          .createRequest(
            type: widget.media.type,
            tmdbId: widget.media.tmdbId,
            seasons: seasons,
          );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = true;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.seerrRequestSent(widget.media.title)),
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      // Surface plugin-level errors via the global bus so the user sees a
      // proper "no Seerr account linked" toast even if the sheet is dismissed.
      if (e is DioException) {
        final mapped = mapBridgeError(e);
        if (mapped != null) {
          ref.read(bridgeErrorBusProvider.notifier).state = mapped;
        }
      }
      setState(() {
        _submitting = false;
        _error = context.l10n.seerrRequestError(_friendlyError(e));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = widget.media;
    final client = ref.watch(seerrClientProvider);
    final posterUrl = client.posterUrl(m);

    // Seed the default selection (initialSeasons or every numbered season)
    // the first time TMDB seasons resolve.
    if (_isTv) {
      ref.listen<AsyncValue<List<SeerrTvSeason>>>(
        seerrTvSeasonsProvider(m.tmdbId),
        (_, next) {
          if (_seededDefault) return;
          next.whenData((seasons) {
            if (seasons.isEmpty) return;
            final preset = widget.initialSeasons;
            final toSelect = preset != null && preset.isNotEmpty
                ? preset
                : seasons
                      .where((s) => !s.isSpecials)
                      .map((s) => s.seasonNumber)
                      .toList();
            setState(() {
              _selected
                ..clear()
                ..addAll(toSelect);
              _seededDefault = true;
            });
          });
        },
      );
    }

    final alreadyAvailable = m.availability == SeerrAvailability.available;
    final alreadyRequested =
        m.availability == SeerrAvailability.pending ||
        m.availability == SeerrAvailability.processing ||
        m.availability == SeerrAvailability.partiallyAvailable;

    final hasSelection = !_isTv || _selected.isNotEmpty;
    final canRequest =
        !_submitting &&
        !_submitted &&
        !alreadyAvailable &&
        !alreadyRequested &&
        hasSelection;

    final l = context.l10n;
    final buttonLabel = _submitted
        ? l.seerrRequestSentLabel
        : alreadyAvailable
        ? l.seerrAlreadyAvailable
        : alreadyRequested
        ? l.seerrAlreadyRequested
        : _isTv
        ? l.seerrRequestSeasons(_selected.length)
        : l.seerrRequest;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: SizedBox(
                      width: 100,
                      height: 150,
                      child: posterUrl != null
                          ? CachedNetworkImage(
                              imageUrl: posterUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: AppColors.surfaceContainer),
                              errorWidget: (_, __, ___) =>
                                  Container(color: AppColors.surfaceContainer),
                            )
                          : Container(
                              color: AppColors.surfaceContainer,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.movie_outlined,
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.display(
                            size: 22,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            if (m.year != null)
                              JfChip(
                                label: m.year.toString(),
                                tone: JfChipTone.neutral,
                              ),
                            JfChip(
                              label: m.type == SeerrMediaType.movie
                                  ? l.seerrTypeMovie
                                  : l.seerrTypeSeries,
                              tone: JfChipTone.brand,
                            ),
                            JfChip(
                              label: _availabilityLabel(context, m.availability),
                              tone: _availabilityTone(m.availability),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (m.overview != null && m.overview!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  m.overview!,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
              if (_isTv && !alreadyAvailable) ...[
                const SizedBox(height: AppSpacing.lg),
                _SeasonPicker(
                  tmdbId: m.tmdbId,
                  selected: _selected,
                  onToggle: (n) {
                    setState(() {
                      if (!_selected.add(n)) _selected.remove(n);
                    });
                  },
                  onToggleAllNumbered: (numbered) {
                    setState(() {
                      final allSelected =
                          numbered.isNotEmpty &&
                          numbered.every(_selected.contains);
                      if (allSelected) {
                        _selected.removeWhere((n) => n != 0);
                      } else {
                        _selected
                          ..removeWhere((n) => n != 0)
                          ..addAll(numbered);
                      }
                    });
                  },
                  onToggleSpecials: () {
                    setState(() {
                      if (!_selected.add(0)) _selected.remove(0);
                    });
                  },
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              JfButton.primary(
                label: buttonLabel,
                icon: _submitted ? Icons.check_rounded : Icons.add,
                fullWidth: true,
                size: JfButtonSize.lg,
                loading: _submitting,
                onPressed: canRequest ? _submit : null,
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

  static String _availabilityLabel(
    BuildContext context,
    SeerrAvailability availability,
  ) {
    final l = context.l10n;
    return switch (availability) {
      SeerrAvailability.available => l.seerrAvailabilityAvailable,
      SeerrAvailability.partiallyAvailable => l.seerrAvailabilityPartial,
      SeerrAvailability.processing => l.seerrAvailabilityProcessing,
      SeerrAvailability.pending => l.seerrAvailabilityPending,
      SeerrAvailability.unknown => l.seerrAvailabilityUnavailable,
    };
  }

  static JfChipTone _availabilityTone(SeerrAvailability availability) {
    return switch (availability) {
      SeerrAvailability.available => JfChipTone.success,
      SeerrAvailability.partiallyAvailable => JfChipTone.info,
      SeerrAvailability.processing ||
      SeerrAvailability.pending => JfChipTone.warning,
      SeerrAvailability.unknown => JfChipTone.neutral,
    };
  }
}

/// Convenience launcher: dark home-style modal bottom sheet.
Future<void> showSeerrRequestSheet(
  BuildContext context, {
  required SeerrMedia media,
  List<int>? initialSeasons,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceContainerHigh,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) =>
        SeerrRequestSheet(media: media, initialSeasons: initialSeasons),
  );
}

/// Inline season selector for the request sheet. Two-column tile grid plus
/// a dedicated full-width "Specials" tile and a header action that toggles
/// every numbered season at once.
class _SeasonPicker extends ConsumerWidget {
  const _SeasonPicker({
    required this.tmdbId,
    required this.selected,
    required this.onToggle,
    required this.onToggleAllNumbered,
    required this.onToggleSpecials,
  });

  final int tmdbId;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final ValueChanged<List<int>> onToggleAllNumbered;
  final VoidCallback onToggleSpecials;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(seerrTvSeasonsProvider(tmdbId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: JfLoading(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        if (seasons.isEmpty) return const SizedBox.shrink();

        final numberedSeasons = seasons
            .where((s) => !s.isSpecials)
            .toList(growable: false);
        final numbered = numberedSeasons
            .map((s) => s.seasonNumber)
            .toList(growable: false);
        final specials = seasons.where((s) => s.isSpecials).toList();

        final allNumberedSelected =
            numbered.isNotEmpty && numbered.every(selected.contains);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.seerrSeasonsTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onToggleAllNumbered(numbered),
                  icon: Icon(
                    allNumberedSelected
                        ? Icons.deselect_rounded
                        : Icons.done_all_rounded,
                    size: 16,
                  ),
                  label: Text(
                    allNumberedSelected
                        ? context.l10n.seerrDeselectAll
                        : context.l10n.seerrSelectAll,
                  ),
                ),
              ],
            ),
            if (specials.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              _SeasonTile(
                title: context.l10n.seerrBonus,
                subtitle: _episodeSubtitle(specials.first.episodeCount),
                icon: Icons.movie_filter_outlined,
                selected: selected.contains(0),
                onTap: onToggleSpecials,
              ),
              const SizedBox(height: AppSpacing.sm),
            ] else
              const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = AppSpacing.sm;
                final tileWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final s in numberedSeasons)
                      SizedBox(
                        width: tileWidth,
                        child: _SeasonTile(
                          title: context.l10n.seerrSeasonNumber(s.seasonNumber),
                          subtitle: _seasonSubtitle(s),
                          selected: selected.contains(s.seasonNumber),
                          onTap: () => onToggle(s.seasonNumber),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  static String? _episodeSubtitle(int? count) {
    if (count == null || count <= 0) return null;
    return '$count épisode${count == 1 ? '' : 's'}';
  }

  static String? _seasonSubtitle(SeerrTvSeason s) {
    final ep = _episodeSubtitle(s.episodeCount);
    final name = s.name;
    final keepName =
        name != null && name.isNotEmpty && name != 'Saison ${s.seasonNumber}';
    if (keepName && ep != null) return '$name · $ep';
    if (keepName) return name;
    return ep;
  }
}

class _SeasonTile extends StatelessWidget {
  const _SeasonTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bg = selected ? scheme.primaryContainer : AppColors.surfaceContainer;
    final fg = selected ? scheme.onPrimaryContainer : Colors.white;
    final subColor = selected
        ? scheme.onPrimaryContainer.withValues(alpha: 0.75)
        : Colors.white.withValues(alpha: 0.7);

    final shape = RoundedRectangleBorder(
      side: BorderSide(
        color: selected
            ? scheme.primary.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.1),
        width: selected ? 1.5 : 1,
      ),
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    return Material(
      color: bg,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : (icon ?? Icons.radio_button_unchecked_rounded),
                size: 22,
                color: selected ? scheme.primary : subColor,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
