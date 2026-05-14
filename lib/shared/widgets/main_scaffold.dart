import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/breakpoints.dart';
import '../../core/sync/sync_service.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({required this.navigationShell, super.key});

  /// Provided by [StatefulShellRoute.indexedStack]; holds the IndexedStack of
  /// branches so each tab keeps its widget subtree (and Riverpod providers)
  /// alive across tab switches.
  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _TabSpec(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    _TabSpec(
      icon: Icons.video_library_outlined,
      selectedIcon: Icons.video_library,
      label: 'Library',
    ),
    _TabSpec(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      label: 'Recherche',
    ),
    _TabSpec(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      label: 'Calendrier',
    ),
    _TabSpec(
      icon: Icons.download_outlined,
      selectedIcon: Icons.download,
      label: 'Downloads',
    ),
    _TabSpec(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<SyncFlushEvent>? _syncSub;

  @override
  void initState() {
    super.initState();
    // Touch the provider once so the service is created and starts listening
    // to connectivity. We subscribe to its `events` stream to surface a
    // SnackBar each time a flush succeeds with at least one entry.
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
    final n = event.flushedCount;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$n action${n > 1 ? 's' : ''} synchronisée${n > 1 ? 's' : ''} avec Jellyfin',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final index = shell.currentIndex;
    final width = MediaQuery.sizeOf(context).width;

    // Tapping the already-selected tab resets that branch to its initial
    // location — same behaviour the official go_router shell sample uses.
    void onSelected(int i) =>
        shell.goBranch(i, initialLocation: i == shell.currentIndex);

    // Back button on a non-home tab returns to Home instead of exiting the
    // app. Only the Home tab allows the system back to close the app — this
    // matches the standard Android pattern and avoids the surprise of
    // ejecting users to the launcher mid-session.
    final scaffold = ScaffoldMessenger(
      key: _messengerKey,
      child: Builder(
        builder: (innerContext) {
          if (Breakpoints.isPhone(width)) {
            // Phone: full-bleed body with a floating burger FAB in the
            // bottom-right corner. Tapping opens a bottom sheet listing
            // every destination — replaces the legacy NavigationBar.
            return Scaffold(
              body: shell,
              floatingActionButton: _NavBurgerFab(
                tabs: MainScaffold._tabs,
                currentIndex: index,
                onSelected: onSelected,
              ),
            );
          }

          final extended = width >= 900;
          final scheme = Theme.of(innerContext).colorScheme;
          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Material(
                    color: scheme.surface,
                    child: NavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: onSelected,
                      extended: extended,
                      labelType: extended
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      destinations: [
                        for (final tab in MainScaffold._tabs)
                          NavigationRailDestination(
                            icon: Icon(tab.icon),
                            selectedIcon: Icon(tab.selectedIcon),
                            label: Text(tab.label),
                          ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: shell),
                ],
              ),
            ),
          );
        },
      ),
    );

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        shell.goBranch(0);
      },
      child: scaffold,
    );
  }
}

class _NavBurgerFab extends StatelessWidget {
  const _NavBurgerFab({
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<_TabSpec> tabs;
  final int currentIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'nav_burger',
      tooltip: 'Menu',
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

class _TabSpec {
  const _TabSpec({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
