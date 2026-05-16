import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/sync_play_providers.dart';
import '../domain/sync_play_session.dart';

/// Panneau latéral SyncPlay — liste des membres, file d'attente, contrôles.
///
/// Peut être ouvert via un Drawer end ou un ModalBottomSheet.
/// [onClose] est appelé quand l'utilisateur clique sur le bouton fermer.
class SyncPlayPanel extends ConsumerWidget {
  const SyncPlayPanel({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sessionAsync = ref.watch(syncPlaySessionProvider);

    return sessionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.commonErrorTitle)),
      data: (session) {
        final group = session.group;
        if (group == null) {
          // Plus dans un groupe — fermer le panneau automatiquement.
          WidgetsBinding.instance.addPostFrameCallback((_) => onClose());
          return const SizedBox.shrink();
        }
        return _PanelContent(
          group: group,
          session: session,
          onClose: onClose,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _PanelContent — contenu du panneau avec membres et contrôles
// ---------------------------------------------------------------------------

class _PanelContent extends ConsumerStatefulWidget {
  const _PanelContent({
    required this.group,
    required this.session,
    required this.onClose,
  });

  final SyncPlayGroup group;
  final SyncPlaySession session;
  final VoidCallback onClose;

  @override
  ConsumerState<_PanelContent> createState() => _PanelContentState();
}

class _PanelContentState extends ConsumerState<_PanelContent> {
  bool _isLeaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final group = widget.group;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle de drag (bottom sheet)
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.syncPlayPanelTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        group.name,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.lg),

          // Section membres
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.syncPlayPanelMembersHeading,
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...group.members.map(
                    (member) => _MemberTile(
                      key: ValueKey(member.id),
                      member: member,
                      session: widget.session,
                    ),
                  ),

                  // Section file d'attente — vide dans le MVP (queue non
                  // remontée par les frames WS, voir TODO dans
                  // sync_play_session_controller.dart)
                  // TODO(syncplay): afficher la queue partagée quand PlayQueueUpdate
                  // sera complètement mappé dans le controller.
                ],
              ),
            ),
          ),

          // Footer : contrôles + quitter
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contrôles repeat/shuffle
                Row(
                  children: [
                    Tooltip(
                      message: l10n.syncPlayPanelControlsRepeat,
                      child: IconButton(
                        icon: const Icon(Icons.repeat),
                        onPressed: () {
                          // TODO(syncplay): setRepeatMode — nécessite un
                          // sélecteur de mode (off/one/all).
                        },
                      ),
                    ),
                    Tooltip(
                      message: l10n.syncPlayPanelControlsShuffle,
                      child: IconButton(
                        icon: const Icon(Icons.shuffle),
                        onPressed: () {
                          // TODO(syncplay): setShuffleMode — nécessite un
                          // toggle sorted/shuffle.
                        },
                      ),
                    ),
                  ],
                ),
                // Bouton quitter
                JfButton.destructive(
                  label: l10n.syncPlayLeaveButton,
                  icon: Icons.exit_to_app,
                  size: JfButtonSize.sm,
                  loading: _isLeaving,
                  onPressed: _isLeaving ? null : () => _leave(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _leave(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showJfConfirm(
      context,
      title: l10n.syncPlayLeaveConfirmTitle,
      message: l10n.syncPlayLeaveConfirmBody,
      confirmLabel: l10n.syncPlayLeaveButton,
      destructive: true,
      confirmIcon: Icons.exit_to_app,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isLeaving = true);
    try {
      await ref.read(syncPlaySessionProvider.notifier).leave();
      if (mounted) widget.onClose();
    } finally {
      if (mounted) setState(() => _isLeaving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// _MemberTile — tuile pour un membre du groupe
// ---------------------------------------------------------------------------

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.session, super.key});

  final SyncPlayMember member;
  final SyncPlaySession session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Calcule les initiales (max 2 caractères) pour l'avatar.
    final initials = _initialsFor(member.displayName);

    // Le buffering est indiqué dans SyncPlaySessionWaiting.bufferingMemberIds.
    final isBuffering = switch (session) {
      SyncPlaySessionWaiting(:final bufferingMemberIds) =>
        bufferingMemberIds.contains(member.id),
      _ => false,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: scheme.secondaryContainer,
            child: Text(
              initials,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              member.displayName,
              style: textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _MemberStatusIcon(session: session, isBuffering: isBuffering),
        ],
      ),
    );
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(1, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// _MemberStatusIcon — icône d'état d'un membre
// ---------------------------------------------------------------------------

class _MemberStatusIcon extends StatelessWidget {
  const _MemberStatusIcon({
    required this.session,
    required this.isBuffering,
  });

  final SyncPlaySession session;
  final bool isBuffering;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (isBuffering) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: scheme.tertiary,
        ),
      );
    }

    final (icon, color) = switch (session) {
      SyncPlaySessionPlaying() => (Icons.play_arrow, scheme.primary),
      SyncPlaySessionPaused() => (Icons.pause, scheme.secondary),
      SyncPlaySessionIdle() => (Icons.hourglass_empty, scheme.outline),
      _ => (Icons.hourglass_empty, scheme.outline),
    };

    return Icon(icon, size: 16, color: color);
  }
}
