import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/downloads/download_manager.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_confirm_dialog.dart';

/// Horizontal inset that pulls AppBar leading/actions and the hero breadcrumb
/// in line with the centered content column (~1100px max) on wide windows.
/// Returns 0 on narrow screens so we don't fight the standard edge placement.
double detailAppBarInset(BuildContext context, {double contentMax = 1100}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= contentMax + 80) return 0;
  return (width - contentMax) / 2;
}

/// Single-line metadata strip — "2014 · 2h 18min · PG-13 · 8.3 ★ · Drame".
///
/// Replaces the previous Wrap of identical JfChips with a denser, JustWatch /
/// Apple TV+ style typographic line. The first three genres are kept; extras
/// are dropped to avoid wrapping into a second cluttered line.
class MetadataStrip extends StatelessWidget {
  const MetadataStrip({
    this.year,
    this.runtime,
    this.officialRating,
    this.communityRating,
    this.airDate,
    this.genres = const [],
    this.episodeCode,
    super.key,
  });

  final int? year;
  final String? runtime;
  final String? officialRating;
  final double? communityRating;
  final String? airDate;
  final List<String> genres;

  /// Bold-emphasis "S5 · E14" prefix, used on the episode detail page.
  final String? episodeCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final separator = TextSpan(
      text: '  ·  ',
      style: base?.copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
    );

    final parts = <InlineSpan>[];

    void add(InlineSpan span) {
      if (parts.isNotEmpty) parts.add(separator);
      parts.add(span);
    }

    if (episodeCode != null && episodeCode!.isNotEmpty) {
      add(
        TextSpan(
          text: episodeCode,
          style: base?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (year != null) {
      add(TextSpan(text: '$year', style: base));
    }
    if (runtime != null && runtime!.isNotEmpty) {
      add(TextSpan(text: runtime, style: base));
    }
    if (airDate != null && airDate!.isNotEmpty) {
      add(TextSpan(text: airDate, style: base));
    }
    if (officialRating != null && officialRating!.isNotEmpty) {
      add(
        TextSpan(
          text: officialRating,
          style: base?.copyWith(color: scheme.onSurface),
        ),
      );
    }
    if (communityRating != null) {
      add(
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(
              Icons.star_rounded,
              size: 14,
              color: Color(0xFFD97706),
            ),
          ),
        ),
      );
      parts.add(
        TextSpan(
          text: communityRating!.toStringAsFixed(1),
          style: base?.copyWith(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    final shownGenres = genres.take(3);
    for (final g in shownGenres) {
      add(TextSpan(text: g, style: base));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text.rich(
      TextSpan(children: parts),
      textAlign: TextAlign.center,
      style: base,
    );
  }
}

/// Spec for one secondary action rendered as a round glass icon-button with
/// a label underneath.
class ActionChipSpec {
  ActionChipSpec({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  }) : builder = null;

  ActionChipSpec.custom({required this.builder, required this.label})
    : icon = null,
      onTap = null,
      active = false;

  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final WidgetBuilder? builder;
}

/// Primary play pill + cluster of round glass icon-buttons.
///
/// On wide layouts the pill sits to the left and the secondary icons row to
/// the right on the same line. On narrow layouts the pill stacks above the
/// icon row, both full-width. The progress hint (resume bar + caption) sits
/// directly under the pill in both layouts.
class ActionCluster extends StatelessWidget {
  const ActionCluster({
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    this.secondaries = const [],
    this.progress,
    this.resumeCaption,
    super.key,
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onPrimary;
  final List<ActionChipSpec> secondaries;
  final double? progress;
  final String? resumeCaption;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 520;
        final pill = _PrimaryPill(
          label: primaryLabel,
          icon: primaryIcon,
          onPressed: onPrimary,
          progress: progress,
          resumeCaption: resumeCaption,
          expand: !wide,
        );
        final chips = Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: [for (final s in secondaries) _IconAction(spec: s)],
        );
        if (wide) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pill,
              const SizedBox(width: AppSpacing.xl),
              Flexible(child: chips),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            pill,
            const SizedBox(height: AppSpacing.lg),
            chips,
          ],
        );
      },
    );
  }
}

class _PrimaryPill extends StatelessWidget {
  const _PrimaryPill({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.progress,
    this.resumeCaption,
    this.expand = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final double? progress;
  final String? resumeCaption;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final disabled = onPressed == null;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
    );

    final pill = Material(
      color: disabled
          ? scheme.onSurface.withValues(alpha: 0.35)
          : scheme.onSurface,
      shape: shape,
      child: InkWell(
        onTap: onPressed,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md + 2,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: scheme.surface, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final stack = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        pill,
        if (progress != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: scheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(scheme.onSurface),
            ),
          ),
        ],
        if (resumeCaption != null && resumeCaption!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            resumeCaption!,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (expand) return stack;
    // In wide mode the cluster places us directly inside a `Row`, which hands
    // down unbounded width. A `Column(crossAxisAlignment: stretch)` cannot
    // expand under unbounded constraints, so we bound it here.
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: stack,
    );
  }
}

class _IconAction extends StatefulWidget {
  const _IconAction({required this.spec});

  final ActionChipSpec spec;

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final spec = widget.spec;
    final tint = spec.active ? scheme.onSurface : scheme.onSurfaceVariant;

    Widget button;
    if (spec.builder != null) {
      button = spec.builder!(context);
    } else {
      button = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _hovering
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainer.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outline.withValues(alpha: 0.7)),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: spec.onTap,
                customBorder: const CircleBorder(),
                child: Center(child: Icon(spec.icon, size: 20, color: tint)),
              ),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button,
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round-icon variant of the full DownloadButton for the action cluster.
/// Mirrors the state-aware logic (notDownloaded -> enqueue, running -> pause,
/// completed -> long-press delete) but renders as a 48dp glass disc that
/// matches the rest of the secondary actions.
class DownloadIconButton extends ConsumerStatefulWidget {
  const DownloadIconButton({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<DownloadIconButton> createState() =>
      _DownloadIconButtonState();
}

class _DownloadIconButtonState extends ConsumerState<DownloadIconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = ref.watch(itemDownloadStatusProvider(widget.itemId));
    final mgr = ref.read(downloadManagerProvider);

    final spec = switch (status.state) {
      ItemDownloadState.notDownloaded ||
      ItemDownloadState.failed ||
      ItemDownloadState.cancelled => (
        icon: Icons.download_outlined,
        action: () => _enqueue(context, mgr),
        ring: null,
      ),
      ItemDownloadState.queued => (
        icon: Icons.schedule_rounded,
        action: () => mgr.cancel(widget.itemId),
        ring: null,
      ),
      ItemDownloadState.running => (
        icon: Icons.pause_rounded,
        action: () => mgr.pause(widget.itemId),
        ring: status.progress.clamp(0.0, 1.0),
      ),
      ItemDownloadState.paused => (
        icon: Icons.play_arrow_rounded,
        action: () => mgr.resume(widget.itemId),
        ring: status.progress.clamp(0.0, 1.0),
      ),
      ItemDownloadState.completed => (
        icon: Icons.check_rounded,
        action: () => _confirmDelete(context, mgr),
        ring: null,
      ),
    };

    final completed = status.state == ItemDownloadState.completed;
    final tint = completed ? const Color(0xFF16A34A) : scheme.onSurfaceVariant;

    final disc = ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _hovering
                ? scheme.surfaceContainerHigh
                : scheme.surfaceContainer.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: scheme.outline.withValues(alpha: 0.7)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (spec.ring != null)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: spec.ring,
                    strokeWidth: 2,
                    backgroundColor: scheme.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(scheme.onSurface),
                  ),
                ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: spec.action,
                  onLongPress: completed
                      ? () => _confirmDelete(context, mgr)
                      : null,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(child: Icon(spec.icon, size: 20, color: tint)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: disc,
    );
  }

  Future<void> _enqueue(BuildContext context, DownloadManager mgr) async {
    try {
      await mgr.enqueueItemById(widget.itemId);
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.downloadButtonFailedSnack(e.toString())),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, DownloadManager mgr) async {
    final l = context.l10n;
    final ok = await showJfConfirm(
      context,
      title: l.downloadButtonDeleteTitle,
      message: l.downloadButtonDeleteMessage,
      confirmLabel: l.downloadButtonDeleteConfirm,
      cancelLabel: l.downloadButtonDeleteCancel,
      destructive: true,
    );
    if (!context.mounted || !ok) return;
    try {
      await mgr.deleteDownload(widget.itemId);
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.downloadButtonDeleteFailedSnack(e.toString()),
          ),
        ),
      );
    }
  }
}

/// Synopsis with inline "Plus / Réduire" toggle. Truncates to [maxLines] when
/// collapsed and animates the height transition.
class SynopsisExpander extends StatefulWidget {
  const SynopsisExpander({required this.text, this.maxLines = 4, super.key});

  final String text;
  final int maxLines;

  @override
  State<SynopsisExpander> createState() => _SynopsisExpanderState();
}

class _SynopsisExpanderState extends State<SynopsisExpander> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final body = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.6,
    );

    final hasOverflow = _hasOverflow(context, body);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            maxLines: _expanded ? null : widget.maxLines,
            overflow: _expanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: body,
          ),
        ),
        if (hasOverflow) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _expanded ? l.detailsReadLess : l.detailsReadMore,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _hasOverflow(BuildContext context, TextStyle? style) {
    final width = MediaQuery.sizeOf(context).width;
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    return tp.didExceedMaxLines;
  }
}

/// Label / value list — `Réalisateur     Christopher Nolan`. Two columns on
/// wide layouts, stacked on narrow.
class FactList extends StatelessWidget {
  const FactList({required this.rows, super.key});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: scheme.outline.withValues(alpha: 0.4)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
            child: LayoutBuilder(
              builder: (context, c) {
                final label = SizedBox(
                  width: 140,
                  child: Text(
                    rows[i].$1,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
                final value = Text(
                  rows[i].$2,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                );
                if (c.maxWidth >= 480) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [label, Expanded(child: value)],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [label, const SizedBox(height: 2), value],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
