import 'dart:async';

// `NavigationMode` from flutter/material.dart conflicts with the project's own
// enum from breakpoints.dart — we hide the Flutter one since we don't use it.
import 'package:flutter/material.dart' hide NavigationMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_motion.dart';
import '../../app/theme/breakpoints.dart';
import '../../core/app_settings/app_layout_settings.dart';
import '../../core/cast/cast_providers.dart';
import '../../core/sync/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../widgets/cast_mini_player.dart';
import '_drawer_nav.dart';

// Re-export DrawerNav so tests can reference it via app_navigation_shell.dart.
export '_drawer_nav.dart' show DrawerNav;

/// Shell de navigation principal de l'application.
///
/// Dispatche vers le bon sous-widget selon le [NavigationMode] déterminé par
/// la largeur de la fenêtre :
/// - `NavigationMode.burgerFab`   → [_CompactNav]  (burger FAB + bottom sheet)
/// - `NavigationMode.railCompact` → [_RailNav] (rail icônes + labels sous icône)
/// - `NavigationMode.railExtended`  → [_RailNav] extended (labels à droite)
/// - `NavigationMode.drawerPermanent` → [DrawerNav] (drawer permanent 3 états)
class AppNavigationShell extends ConsumerStatefulWidget {
  const AppNavigationShell({required this.navigationShell, super.key});

  /// Fourni par [StatefulShellRoute.indexedStack] ; contient l'IndexedStack des
  /// branches pour conserver le sous-arbre de widgets (et les providers
  /// Riverpod) vivants entre les changements d'onglet.
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppNavigationShell> createState() => _AppNavigationShellState();
}

/// Trios d'icônes pour chaque onglet. Les labels sont résolus depuis
/// [AppLocalizations] au moment du build pour suivre la locale active.
List<DrawerNavTabSpec> _tabsOf(AppLocalizations l10n) => [
  DrawerNavTabSpec(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: l10n.navHome,
  ),
  DrawerNavTabSpec(
    icon: Icons.video_library_outlined,
    selectedIcon: Icons.video_library,
    label: l10n.navLibrary,
  ),
  DrawerNavTabSpec(
    icon: Icons.search_outlined,
    selectedIcon: Icons.search,
    label: l10n.navSearch,
  ),
  DrawerNavTabSpec(
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    label: l10n.navCalendar,
  ),
  DrawerNavTabSpec(
    icon: Icons.download_outlined,
    selectedIcon: Icons.download,
    label: l10n.navDownloads,
  ),
  DrawerNavTabSpec(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: l10n.navSettings,
  ),
];

class _AppNavigationShellState extends ConsumerState<AppNavigationShell> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<SyncFlushEvent>? _syncSub;

  @override
  void initState() {
    super.initState();
    // Initialise le service de sync et s'abonne aux événements pour afficher
    // un SnackBar lors d'un flush réussi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final svc = ref.read(syncServiceProvider);
      _syncSub = svc.events.listen(_onSyncEvent);
    });
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    super.dispose();
  }

  void _onSyncEvent(SyncFlushEvent event) {
    if (event.flushedCount <= 0) return;
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.syncFlushedSnack(event.flushedCount)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final index = shell.currentIndex;
    final l10n = context.l10n;
    final tabs = _tabsOf(l10n);
    final navMode = context.defaultNavigationMode;

    // Tapping the already-selected tab resets that branch to its initial
    // location — same behaviour the official go_router shell sample uses.
    void onSelected(int i) =>
        shell.goBranch(i, initialLocation: i == shell.currentIndex);

    final scaffold = ScaffoldMessenger(
      key: _messengerKey,
      child: Builder(
        builder: (innerContext) {
          return switch (navMode) {
            NavigationMode.burgerFab => _CompactNav(
              shell: shell,
              tabs: tabs,
              currentIndex: index,
              onSelected: onSelected,
              tooltip: l10n.navMenuTooltip,
            ),
            NavigationMode.railCompact => _RailNav(
              shell: shell,
              tabs: tabs,
              currentIndex: index,
              onSelected: onSelected,
              isExtended: false,
            ),
            NavigationMode.railExtended => _RailNav(
              shell: shell,
              tabs: tabs,
              currentIndex: index,
              onSelected: onSelected,
              isExtended: true,
            ),
            // Drawer permanent 3 états (collapsed / expanded / hidden)
            // — géré par DrawerNav avec AnimatedContainer sur la largeur.
            NavigationMode.drawerPermanent => DrawerNav(
              shell: shell,
              tabs: tabs,
              currentIndex: index,
              onSelected: onSelected,
            ),
          };
        },
      ),
    );

    // Le bouton retour sur un onglet non-Home revient à Home au lieu de
    // quitter l'app. Seul l'onglet Home autorise le retour système.
    final body = PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        shell.goBranch(0);
      },
      child: scaffold,
    );

    // Raccourci Cmd/Ctrl+B : toggle drawer uniquement en mode drawerPermanent.
    // Le wrapping Shortcuts > Actions > Focus au-dessus du shell laisse les
    // TextFields plus bas dans l'arbre consommer l'event en premier, donc
    // Cmd+B dans un champ de recherche ne togglera pas la nav.
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyB):
            const _ToggleNavIntent(),
        LogicalKeySet(LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.keyB):
            const _ToggleNavIntent(),
      },
      child: Actions(
        actions: {
          _ToggleNavIntent: CallbackAction<_ToggleNavIntent>(
            onInvoke: (_) {
              // Actif uniquement en mode drawerPermanent.
              if (navMode != NavigationMode.drawerPermanent) return null;
              final settings = ref.read(appLayoutSettingsProvider).valueOrNull;
              if (settings == null) return null;
              final current = settings.desktopNavMode;
              if (current == DesktopNavMode.hidden) {
                // Depuis hidden : revenir à collapsed.
                ref
                    .read(appLayoutSettingsProvider.notifier)
                    .setDesktopNavMode(DesktopNavMode.collapsed);
              } else {
                // collapsed ↔ expanded.
                ref.read(appLayoutSettingsProvider.notifier).toggleDesktopNav();
              }
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: body),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CompactNav — mode téléphone : burger FAB + ModalBottomSheet
// ---------------------------------------------------------------------------

class _CompactNav extends StatelessWidget {
  const _CompactNav({
    required this.shell,
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
    required this.tooltip,
  });

  final StatefulNavigationShell shell;
  final List<DrawerNavTabSpec> tabs;
  final int currentIndex;
  final void Function(int) onSelected;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DrawerNavCastWrapper(drawerWidth: 0, child: shell),
      floatingActionButton: _NavBurgerFab(
        tabs: tabs,
        currentIndex: currentIndex,
        onSelected: onSelected,
        tooltip: tooltip,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RailNav — mode tablette/desktop : NavigationRail
// ---------------------------------------------------------------------------

class _RailNav extends StatelessWidget {
  const _RailNav({
    required this.shell,
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
    required this.isExtended,
  });

  final StatefulNavigationShell shell;
  final List<DrawerNavTabSpec> tabs;
  final int currentIndex;
  final void Function(int) onSelected;
  final bool isExtended;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Material(
              color: scheme.surface,
              child: NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: onSelected,
                extended: isExtended,
                // Quand extended=true, les labels sont affichés inline à
                // droite de l'icône par le NavigationRail lui-même.
                // Quand extended=false (railCompact), on affiche les labels
                // sous l'icône via labelType.all.
                labelType: isExtended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: [
                  for (final tab in tabs)
                    NavigationRailDestination(
                      // Tooltip sur l'icône pour l'accessibilité
                      // (NavigationRailDestination n'a pas de param tooltip).
                      icon: Tooltip(message: tab.label, child: Icon(tab.icon)),
                      selectedIcon: Tooltip(
                        message: tab.label,
                        child: Icon(tab.selectedIcon),
                      ),
                      label: Text(tab.label),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: DrawerNavCastWrapper(drawerWidth: 0, child: shell)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DrawerNavCastWrapper — overlay mini-player Cast avec décalage drawer
// ---------------------------------------------------------------------------

/// Wrappe [child] dans un Stack qui pose le mini-player Cast en bottom-overlay
/// dès qu'une session est active. [drawerWidth] permet de décaler le bord
/// gauche du mini-player pour qu'il ne se superpose pas au drawer permanent.
///
/// En mode compact (téléphone), [drawerWidth] est 0 et le mini-player est
/// positionné à `bottom: 80` pour rester au-dessus du burger FAB.
///
/// Note : ce widget est public (sans underscore) afin d'être accessible
/// depuis `_drawer_nav.dart` qui vit dans le même répertoire. Il ne fait
/// pas partie de l'API publique du package.
class DrawerNavCastWrapper extends ConsumerWidget {
  const DrawerNavCastWrapper({
    required this.child,
    required this.drawerWidth,
    super.key,
  });

  final Widget child;

  /// Largeur courante du drawer (0 si caché ou absent).
  final double drawerWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMini = ref.watch(castNowPlayingProvider) != null;
    return Stack(
      children: [
        child,
        if (showMini)
          AnimatedPositioned(
            // Décale le bord gauche du mini-player pour qu'il ne se superpose
            // pas au drawer permanent. Le drawerWidth reflète l'état courant
            // (collapsed=72, expanded=256, hidden=0, autres modes=0).
            left: drawerWidth + 8,
            right: 8,
            bottom: 80,
            duration: AppMotion.medium,
            curve: AppMotion.emphasized,
            child: const CastMiniPlayer(),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _NavBurgerFab — FAB burger + bottom sheet
// ---------------------------------------------------------------------------

class _NavBurgerFab extends StatelessWidget {
  const _NavBurgerFab({
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
    required this.tooltip,
  });

  final List<DrawerNavTabSpec> tabs;
  final int currentIndex;
  final void Function(int) onSelected;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'nav_burger',
      tooltip: tooltip,
      onPressed: () => _open(context),
      child: const Icon(Icons.menu),
    );
  }

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        final scheme = Theme.of(sheetCtx).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < tabs.length; i++)
                ListTile(
                  leading: Icon(
                    i == currentIndex ? tabs[i].selectedIcon : tabs[i].icon,
                    color: i == currentIndex ? scheme.primary : null,
                  ),
                  title: Text(
                    tabs[i].label,
                    style: TextStyle(
                      color: i == currentIndex ? scheme.primary : null,
                      fontWeight: i == currentIndex ? FontWeight.w600 : null,
                    ),
                  ),
                  selected: i == currentIndex,
                  onTap: () => Navigator.of(sheetCtx).pop(i),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) onSelected(selected);
  }
}

// ---------------------------------------------------------------------------
// DrawerNavTabSpec — données d'un onglet (anciennement _TabSpec)
// ---------------------------------------------------------------------------

/// Spécification d'un onglet de navigation.
///
/// Public (sans underscore) pour être partagé avec `_drawer_nav.dart`.
class DrawerNavTabSpec {
  const DrawerNavTabSpec({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

// ---------------------------------------------------------------------------
// Intents pour les raccourcis clavier
// ---------------------------------------------------------------------------

/// Intent déclenché par Cmd/Ctrl+B pour toggler la navigation.
class _ToggleNavIntent extends Intent {
  const _ToggleNavIntent();
}
