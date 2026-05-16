import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/platform_capabilities.dart';
import '../../features/syncplay/data/sync_play_providers.dart';
import '../../features/syncplay/domain/sync_play_session.dart';
import '../../features/syncplay/ui/create_group_dialog.dart';
import '../../features/syncplay/ui/sync_play_panel.dart';
import '../../l10n/l10n_extension.dart';

/// Bouton standardisé "Watch Together" affiché dans les AppBar / SliverAppBar.
///
/// Affiché uniquement sur desktop (gated sur [platformCapabilitiesProvider]).
/// Adapte son apparence selon l'état SyncPlay :
/// - **Hors groupe** : icône `Icons.groups_outlined` → ouvre un popup menu
///   ancré sur le bouton, listant les groupes disponibles + entrée création.
/// - **Dans un groupe** : icône `Icons.groups` (remplie) + badge point coloré
///   → ouvre le [SyncPlayPanel] en bottom sheet.
/// - **État Waiting** : pulse discrète sur l'icône pour signaler le buffering.
///
/// Param [color] optionnel pour adapter la couleur de l'icône aux AppBar
/// transparentes (utiliser `Colors.white` sur les écrans détail).
class SyncPlayButton extends ConsumerWidget {
  const SyncPlayButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caps = ref.watch(platformCapabilitiesProvider);
    if (!caps.isDesktop) return const SizedBox.shrink();

    final inGroup = ref.watch(syncPlayInGroupProvider);
    final sessionAsync = ref.watch(syncPlaySessionProvider);
    final session = sessionAsync.valueOrNull;
    final isWaiting = session is SyncPlaySessionWaiting;
    final l10n = context.l10n;

    if (!inGroup) {
      return IconButton(
        tooltip: l10n.syncPlayTabLabel,
        icon: Icon(Icons.groups_outlined, color: color),
        onPressed: () => _openGroupMenu(context, ref),
      );
    }

    // Dans un groupe : badge + pulse si buffering.
    return Tooltip(
      message: isWaiting
          ? l10n.syncPlayStateWaiting
          : l10n.syncPlayIndicatorTooltip,
      child: _SyncPlayBadgeButton(
        isWaiting: isWaiting,
        color: color,
        onTap: () => _openPanel(context),
      ),
    );
  }

  /// Ouvre un popup menu ancré sous le bouton courant, listant les groupes
  /// disponibles et proposant la création d'un nouveau groupe.
  ///
  /// On attend d'abord la résolution du [availableSyncPlayGroupsProvider] pour
  /// construire les items de manière synchrone — cela évite de placer un
  /// [CircularProgressIndicator] animé dans le menu (qui serait non-settleable
  /// en test et déconcertant en prod).
  Future<void> _openGroupMenu(BuildContext context, WidgetRef ref) async {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Résoudre le future avant d'ouvrir le menu pour construire les items
    // de façon synchrone.
    AsyncValue<List<SyncPlayGroup>> groupsAsync;
    try {
      final data = await ref.read(availableSyncPlayGroupsProvider.future);
      groupsAsync = AsyncValue<List<SyncPlayGroup>>.data(data);
    } on Object catch (e, s) {
      groupsAsync = AsyncValue<List<SyncPlayGroup>>.error(e, s);
    }

    if (!context.mounted) return;

    // Le menu est aligné sous le bouton, ancré à droite pour ne pas déborder.
    final menuRight = screenWidth - offset.dx - size.width;

    final action = await showMenu<_SyncPlayMenuAction>(
      context: context,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        menuRight,
        offset.dy + size.height + 8,
      ),
      items: _buildMenuItems(context, groupsAsync),
    );

    if (!context.mounted) return;
    await _handleMenuResult(action, context, ref);
  }

  List<PopupMenuEntry<_SyncPlayMenuAction>> _buildMenuItems(
    BuildContext context,
    AsyncValue<List<SyncPlayGroup>> groupsAsync,
  ) {
    final l10n = context.l10n;

    final items = <PopupMenuEntry<_SyncPlayMenuAction>>[
      // En-tête non sélectionnable.
      PopupMenuItem<_SyncPlayMenuAction>(
        enabled: false,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(
          l10n.syncPlayJoinDialogTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Corps : error / liste de groupes.
      ...groupsAsync.when(
        loading: () => <PopupMenuEntry<_SyncPlayMenuAction>>[],
        error: (_, __) => [
          PopupMenuItem<_SyncPlayMenuAction>(
            enabled: false,
            child: Text(
              l10n.syncPlayErrTransport,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
        data: (groups) {
          if (groups.isEmpty) return <PopupMenuEntry<_SyncPlayMenuAction>>[];

          return [
            for (final group in groups)
              PopupMenuItem<_SyncPlayMenuAction>(
                value: _SyncPlayMenuAction.joinGroup(group.id),
                child: _GroupMenuItemContent(group: group),
              ),
            const PopupMenuDivider(),
          ];
        },
      ),

      // Entrée "Nouveau groupe" toujours présente en bas.
      PopupMenuItem<_SyncPlayMenuAction>(
        value: const _SyncPlayMenuAction.createGroup(),
        child: _CreateGroupMenuItemContent(
          label: l10n.syncPlayCreateButton,
          subtitle: l10n.syncPlayCreateGroupSubtitle,
        ),
      ),
    ];

    return items;
  }

  void _openPanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SyncPlayPanel(
        // On capture le `sheetContext` du builder du ModalBottomSheet plutôt
        // que le `context` du parent. Sans ça, `Navigator.of(context)` remonte
        // au navigator racine de GoRouter et pop la route courante de l'app
        // (crash : « popped the last page off of the stack »).
        // `canPop` protège contre les invocations multiples du callback :
        // le panel rappelle `onClose` en post-frame quand `group == null`,
        // ce qui peut se produire plusieurs fois lors de re-builds Riverpod.
        onClose: () {
          final navigator = Navigator.of(sheetContext);
          if (navigator.canPop()) navigator.pop();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sealed discriminant pour les actions du menu popup
// ---------------------------------------------------------------------------

sealed class _SyncPlayMenuAction {
  const _SyncPlayMenuAction();

  const factory _SyncPlayMenuAction.joinGroup(String groupId) =
      _JoinGroupAction;
  const factory _SyncPlayMenuAction.createGroup() = _CreateGroupAction;
}

class _JoinGroupAction extends _SyncPlayMenuAction {
  const _JoinGroupAction(this.groupId);

  final String groupId;
}

class _CreateGroupAction extends _SyncPlayMenuAction {
  const _CreateGroupAction();
}

// ---------------------------------------------------------------------------
// Widgets enfants des items du menu popup
// ---------------------------------------------------------------------------

/// Contenu d'un item de groupe disponible dans le popup menu.
class _GroupMenuItemContent extends StatelessWidget {
  const _GroupMenuItemContent({required this.group});

  final SyncPlayGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(Icons.groups_outlined, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                group.name,
                style: textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                l10n.syncPlayMembersCount(group.members.length),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Contenu de l'item "Créer un nouveau groupe".
class _CreateGroupMenuItemContent extends StatelessWidget {
  const _CreateGroupMenuItemContent({
    required this.label,
    required this.subtitle,
  });

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(Icons.add, size: 20, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Gestion des actions du menu — widget séparé pour accéder aux providers
// ---------------------------------------------------------------------------

/// Wrapper Riverpod utilisé par [SyncPlayButton._openGroupMenu] pour
/// déclencher les actions retournées par [showMenu] — join ou create.
///
/// Implémenté comme fonction libre (pas de widget public) pour garder
/// l'encapsulation dans ce fichier.
Future<void> _handleMenuResult(
  _SyncPlayMenuAction? action,
  BuildContext context,
  WidgetRef ref,
) async {
  if (action == null) return;
  switch (action) {
    case _JoinGroupAction(:final groupId):
      final l10n = context.l10n;
      try {
        await ref.read(syncPlaySessionProvider.notifier).join(groupId);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncPlayIndicatorTooltip),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } on Object {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncPlayJoinError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    case _CreateGroupAction():
      if (!context.mounted) return;
      await showCreateGroupDialog(context);
  }
}

// ---------------------------------------------------------------------------
// _SyncPlayBadgeButton — icône remplie + badge point + animation pulse
// ---------------------------------------------------------------------------

/// Icône `groups` avec un badge coloré et une animation pulse quand [isWaiting].
class _SyncPlayBadgeButton extends StatefulWidget {
  const _SyncPlayBadgeButton({
    required this.isWaiting,
    required this.onTap,
    this.color,
  });

  final bool isWaiting;
  final Color? color;
  final VoidCallback onTap;

  @override
  State<_SyncPlayBadgeButton> createState() => _SyncPlayBadgeButtonState();
}

class _SyncPlayBadgeButtonState extends State<_SyncPlayBadgeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 0.45, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant _SyncPlayBadgeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWaiting != widget.isWaiting) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isWaiting) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = widget.color ?? scheme.onSurface;

    return IconButton(
      onPressed: widget.onTap,
      icon: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: widget.isWaiting ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.groups, color: iconColor),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
