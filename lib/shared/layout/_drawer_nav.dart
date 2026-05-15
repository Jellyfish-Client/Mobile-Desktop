// `NavigationMode` from flutter/material.dart conflicts with the project's own
// enum from breakpoints.dart — we hide the Flutter one since we don't use it.
import 'package:flutter/material.dart' hide NavigationMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_state_colors.dart';
import '../../core/app_settings/app_layout_settings.dart';
import '../../core/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/jf_logo.dart';
import 'app_navigation_shell.dart' show DrawerNavCastWrapper, DrawerNavTabSpec;

// ---------------------------------------------------------------------------
// Constantes
// ---------------------------------------------------------------------------

/// Largeur du drawer en mode collapsed (rail 72dp).
const double _kDrawerCollapsedWidth = 72;

/// Largeur du drawer en mode expanded (256dp).
const double _kDrawerExpandedWidth = 256;

/// Largeur du drawer en mode hidden (0dp — slide-out complet).
const double _kDrawerHiddenWidth = 0;

/// Hauteur du header (logo + nom serveur).
const double _kHeaderHeight = 72;

/// Taille du edge-handle (bouton flottant quand hidden).
const double _kEdgeHandleSize = 32;

// ---------------------------------------------------------------------------
// DrawerNav — drawer permanent Material 3 pour desktop (≥1200px)
// ---------------------------------------------------------------------------

/// Drawer de navigation permanent pour les fenêtres larges (large / extraLarge).
///
/// Trois états selon [DesktopNavMode] :
/// - [DesktopNavMode.collapsed] → rail 72dp, icônes + tooltip, logo seul en header
/// - [DesktopNavMode.expanded]  → drawer 256dp, icônes + labels + header complet
/// - [DesktopNavMode.hidden]    → 0dp, body plein écran + edge-handle à gauche
///
/// La transition entre états utilise [AnimatedContainer] à 220ms + courbe
/// emphasized ([AppMotion.medium] + [AppMotion.emphasized]).
///
/// Décision UX : le bouton toggle (collapsed ↔ expanded) est intégré dans le
/// header du drawer, à côté du logo. Cela évite d'ajouter une mini-barre
/// au-dessus du body. Le mode [DesktopNavMode.hidden] est accessible via un
/// long-press sur ce même bouton toggle (menu contextuel "Masquer la navigation").
class DrawerNav extends ConsumerWidget {
  const DrawerNav({
    required this.shell,
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final StatefulNavigationShell shell;
  final List<DrawerNavTabSpec> tabs;
  final int currentIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appLayoutSettingsProvider);
    final navMode =
        settingsAsync.valueOrNull?.desktopNavMode ?? DesktopNavMode.collapsed;

    final drawerWidth = switch (navMode) {
      DesktopNavMode.collapsed => _kDrawerCollapsedWidth,
      DesktopNavMode.expanded => _kDrawerExpandedWidth,
      DesktopNavMode.hidden => _kDrawerHiddenWidth,
    };

    final isExpanded = navMode == DesktopNavMode.expanded;
    final isHidden = navMode == DesktopNavMode.hidden;

    // Le body est wrappé par DrawerNavCastWrapper pour la gestion du
    // mini-player cast avec décalage selon la largeur du drawer.
    final body = DrawerNavCastWrapper(drawerWidth: drawerWidth, child: shell);

    return Stack(
      children: [
        Row(
          children: [
            // --- Drawer animé --------------------------------------------
            // ClipRect évite les overflows de rendu pendant la transition
            // (le contenu est rendu à sa taille cible pendant l'animation).
            ClipRect(
              child: AnimatedContainer(
                key: const Key('drawer-animated-width'),
                duration: AppMotion.medium,
                curve: AppMotion.emphasized,
                width: drawerWidth,
                child: isHidden
                    ? const SizedBox.shrink()
                    : _DrawerContent(
                        tabs: tabs,
                        currentIndex: currentIndex,
                        onSelected: onSelected,
                        isExpanded: isExpanded,
                        navMode: navMode,
                      ),
              ),
            ),
            // --- Body principal ------------------------------------------
            Expanded(child: body),
          ],
        ),
        // --- Edge-handle (mode hidden uniquement) -------------------------
        if (isHidden)
          _EdgeHandle(
            onOpen: () => ref
                .read(appLayoutSettingsProvider.notifier)
                .setDesktopNavMode(DesktopNavMode.collapsed),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _DrawerContent — contenu interne du drawer
// ---------------------------------------------------------------------------

class _DrawerContent extends ConsumerWidget {
  const _DrawerContent({
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
    required this.isExpanded,
    required this.navMode,
  });

  final List<DrawerNavTabSpec> tabs;
  final int currentIndex;
  final void Function(int) onSelected;
  final bool isExpanded;
  final DesktopNavMode navMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _DrawerHeader(isExpanded: isExpanded, navMode: navMode),
          const Divider(height: 1, thickness: 1),
          // Destinations
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.sm,
              ),
              children: [
                for (var i = 0; i < tabs.length; i++)
                  _DrawerDestination(
                    tab: tabs[i],
                    index: i,
                    isSelected: i == currentIndex,
                    isExpanded: isExpanded,
                    onTap: () => onSelected(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DrawerHeader — logo + nom serveur + bouton toggle
// ---------------------------------------------------------------------------

class _DrawerHeader extends ConsumerWidget {
  const _DrawerHeader({required this.isExpanded, required this.navMode});

  final bool isExpanded;
  final DesktopNavMode navMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Récupère l'URL du serveur actif depuis la session auth.
    final session = ref.watch(authControllerProvider).valueOrNull?.session;
    final serverUrl = session?.serverUrl ?? '';
    // Affiche juste le host sans protocole pour garder ça compact.
    final serverLabel = _hostFromUrl(serverUrl);

    final toggleIcon = isExpanded ? Icons.menu_open : Icons.menu;
    final l10n = AppLocalizations.of(context);

    // En mode collapsed (72dp), le header affiche uniquement le bouton toggle
    // centré dans la largeur — il tient dans les 48dp d'un IconButton.
    // En mode expanded (256dp), affiche logo 24dp + textes + bouton toggle.
    if (!isExpanded) {
      return SizedBox(
        height: _kHeaderHeight,
        child: Center(
          child: GestureDetector(
            onLongPress: () => _showHideMenu(context, ref),
            child: IconButton(
              icon: Icon(toggleIcon),
              tooltip: l10n.drawerExpandTooltip,
              onPressed: () => ref
                  .read(appLayoutSettingsProvider.notifier)
                  .toggleDesktopNav(),
            ),
          ),
        ),
      );
    }

    // En mode expanded, le header utilise un LayoutBuilder pour s'adapter à
    // la largeur disponible pendant la transition AnimatedContainer.
    // Quand la largeur < 100dp (en cours d'animation vers collapsed), on
    // affiche seulement le toggle centré pour éviter un overflow.
    return SizedBox(
      height: _kHeaderHeight,
      child: LayoutBuilder(
        builder: (_, constraints) {
          // Seuil : si moins de 100dp, afficher seulement le toggle centré.
          if (constraints.maxWidth < 100) {
            return Center(
              child: GestureDetector(
                onLongPress: () => _showHideMenu(context, ref),
                child: IconButton(
                  icon: Icon(toggleIcon),
                  tooltip: l10n.drawerCollapseTooltip,
                  onPressed: () => ref
                      .read(appLayoutSettingsProvider.notifier)
                      .toggleDesktopNav(),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                // Logo 24dp en mode expanded
                const JfLogo(size: 24),
                const SizedBox(width: AppSpacing.sm),
                // Textes nom de l'app + adresse serveur
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jellyfish',
                        style: textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (serverLabel.isNotEmpty)
                        Text(
                          serverLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Bouton toggle — long-press pour accéder au mode hidden.
                GestureDetector(
                  onLongPress: () => _showHideMenu(context, ref),
                  child: IconButton(
                    icon: Icon(toggleIcon),
                    tooltip: l10n.drawerCollapseTooltip,
                    onPressed: () => ref
                        .read(appLayoutSettingsProvider.notifier)
                        .toggleDesktopNav(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Extrait le host d'une URL
  /// (ex: "https://jellyfin.example.com:8096" → "jellyfin.example.com:8096").
  String _hostFromUrl(String url) {
    if (url.isEmpty) return '';
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.isEmpty) return url;
      final port = uri.hasPort ? ':${uri.port}' : '';
      return '$host$port';
    } on FormatException {
      return url;
    }
  }

  /// Menu contextuel pour accéder au mode hidden (long-press sur le toggle).
  Future<void> _showHideMenu(BuildContext context, WidgetRef ref) async {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final result = await showMenu<_DrawerMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 8,
      ),
      items: [
        PopupMenuItem(
          value: _DrawerMenuAction.hide,
          child: Row(
            children: [
              const Icon(Icons.visibility_off_outlined, size: 20),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).drawerHideAction),
            ],
          ),
        ),
      ],
    );
    if (result == _DrawerMenuAction.hide && context.mounted) {
      await ref
          .read(appLayoutSettingsProvider.notifier)
          .setDesktopNavMode(DesktopNavMode.hidden);
    }
  }
}

enum _DrawerMenuAction { hide }

// ---------------------------------------------------------------------------
// _DrawerDestination — une entrée de navigation dans le drawer
// ---------------------------------------------------------------------------

class _DrawerDestination extends StatefulWidget {
  const _DrawerDestination({
    required this.tab,
    required this.index,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  final DrawerNavTabSpec tab;
  final int index;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<_DrawerDestination> createState() => _DrawerDestinationState();
}

class _DrawerDestinationState extends State<_DrawerDestination> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final iconData = widget.isSelected
        ? widget.tab.selectedIcon
        : widget.tab.icon;

    // Couleur de fond : selected > hover > transparent
    final Color bgColor;
    if (widget.isSelected) {
      bgColor = scheme.secondaryContainer;
    } else if (_hovered) {
      bgColor = scheme.onSurface.withValues(alpha: AppStateColors.hover);
    } else {
      bgColor = Colors.transparent;
    }

    final border = _focused && !widget.isSelected
        ? Border.all(color: scheme.primary, width: 2)
        : null;

    final iconColor = widget.isSelected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;

    const itemHeight = 48.0;

    final item = GestureDetector(
      onTap: widget.onTap,
      child: FocusableActionDetector(
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        child: Tooltip(
          // En mode expanded le label est visible à côté : tooltip vide pour
          // éviter le bruit visuel. En mode collapsed il est utile.
          message: widget.isExpanded ? '' : widget.tab.label,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            height: itemHeight,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: border,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: _kDrawerCollapsedWidth - AppSpacing.sm * 2,
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                // Le Text est toujours dans l'arbre (même en collapsed) pour
                // que l'AnimatedOpacity puisse animer la transition 0→1.
                // Le ClipRect parent du drawer empêche tout débordement
                // horizontal pendant la transition de largeur.
                Expanded(
                  child: AnimatedOpacity(
                    // Délai d'apparition du label en mode expanded (+60ms).
                    // L'Interval [0.27, 1.0] sur 220ms ≈ 60ms de délai
                    // avant que l'opacité commence à monter.
                    opacity: widget.isExpanded ? 1.0 : 0.0,
                    duration: AppMotion.medium,
                    curve: const Interval(
                      0.27,
                      1,
                      curve: Cubic(0.05, 0.7, 0.1, 1),
                    ),
                    child: Text(
                      widget.tab.label,
                      style: textTheme.labelLarge?.copyWith(
                        color: iconColor,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Centrer en mode collapsed, aligner à gauche en mode expanded.
    if (!widget.isExpanded) {
      return Center(child: item);
    }
    return item;
  }
}

// ---------------------------------------------------------------------------
// _EdgeHandle — bouton flottant pour rouvrir le drawer caché
// ---------------------------------------------------------------------------

class _EdgeHandle extends StatelessWidget {
  const _EdgeHandle({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Opacity(
          opacity: 0.6,
          child: SizedBox(
            width: _kEdgeHandleSize,
            height: _kEdgeHandleSize,
            child: Material(
              color: scheme.surfaceContainerHigh,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_right, size: 20),
                tooltip: AppLocalizations.of(context).drawerShowTooltip,
                onPressed: onOpen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
