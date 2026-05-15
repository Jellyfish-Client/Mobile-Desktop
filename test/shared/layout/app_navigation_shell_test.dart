import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfish/app/theme/app_theme.dart';
import 'package:jellyfish/core/app_settings/app_layout_settings.dart';
import 'package:jellyfish/l10n/app_localizations.dart';
import 'package:jellyfish/shared/layout/app_navigation_shell.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Enveloppe minimale qui fournit un [StatefulNavigationShell] factice pour
/// tester [AppNavigationShell] de manière isolée.
///
/// On ne peut pas instancier [StatefulNavigationShell] directement (c'est un
/// type interne go_router), donc on passe par un vrai [GoRouter] minimal avec
/// un [StatefulShellRoute.indexedStack] et on laisse go_router construire le
/// shell pour nous.
Widget _buildHarness({
  required double width,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/a',
                builder: (_, __) => const Scaffold(body: Text('A')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/b',
                builder: (_, __) => const Scaffold(body: Text('B')),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: MaterialApp.router(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Fake controller pour les tests (desktop drawer)
// ---------------------------------------------------------------------------

/// Contrôleur factice qui retourne un [AppLayoutSettings] synchrone
/// sans accéder à SharedPreferences.
class _FakeAppLayoutSettingsController extends AsyncNotifier<AppLayoutSettings>
    implements AppLayoutSettingsController {
  _FakeAppLayoutSettingsController({required DesktopNavMode initial})
    : _mode = initial;

  DesktopNavMode _mode;

  @override
  Future<AppLayoutSettings> build() async =>
      AppLayoutSettings(desktopNavMode: _mode, railExtendedOnExpanded: false);

  @override
  Future<void> setDesktopNavMode(DesktopNavMode mode) async {
    _mode = mode;
    state = AsyncData(
      AppLayoutSettings(desktopNavMode: _mode, railExtendedOnExpanded: false),
    );
  }

  @override
  Future<void> setRailExtendedOnExpanded({required bool value}) async {}

  @override
  Future<void> toggleDesktopNav() async {
    final next = _mode == DesktopNavMode.collapsed
        ? DesktopNavMode.expanded
        : DesktopNavMode.collapsed;
    await setDesktopNavMode(next);
  }
}

/// Crée un override de [appLayoutSettingsProvider] avec un mode initial donné.
Override _layoutOverride(DesktopNavMode mode) => appLayoutSettingsProvider
    .overrideWith(() => _FakeAppLayoutSettingsController(initial: mode));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppNavigationShell —', () {
    testWidgets('Test 1 : 400 px → mode compact, FAB burger visible', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildHarness(width: 400));
      await tester.pumpAndSettle();

      // Le FAB avec heroTag 'nav_burger' doit être présent.
      expect(
        find.byWidgetPredicate(
          (w) => w is FloatingActionButton && w.heroTag == 'nav_burger',
        ),
        findsOneWidget,
      );
      // Pas de NavigationRail en mode compact.
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets(
      'Test 2 : 700 px → mode rail compact, NavigationRail non-extended avec labels',
      (tester) async {
        tester.view.physicalSize = const Size(700, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(_buildHarness(width: 700));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);

        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.extended, isFalse);
        expect(rail.labelType, NavigationRailLabelType.all);

        // Pas de FAB burger en mode rail.
        expect(
          find.byWidgetPredicate(
            (w) => w is FloatingActionButton && w.heroTag == 'nav_burger',
          ),
          findsNothing,
        );
      },
    );

    testWidgets('Test 3 : 1000 px → mode rail extended', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildHarness(width: 1000));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
    });

    testWidgets(
      'Test 4 : 1300 px → DrawerNav actif (Phase 3), plus de NavigationRail',
      (tester) async {
        tester.view.physicalSize = const Size(1300, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildHarness(
            width: 1300,
            overrides: [_layoutOverride(DesktopNavMode.collapsed)],
          ),
        );
        await tester.pumpAndSettle();

        // Phase 3 : le DrawerNav remplace le NavigationRail à 1300px.
        expect(find.byType(NavigationRail), findsNothing);
        // DrawerNav doit être présent.
        expect(find.byType(DrawerNav), findsOneWidget);
      },
    );

    testWidgets('Test 5 : tooltips présents sur chaque destination du rail', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildHarness(width: 700));
      await tester.pumpAndSettle();

      // NavigationRailDestination n'a pas de paramètre tooltip — les tooltips
      // sont implémentés via des widgets Tooltip wrappant les icônes.
      // On vérifie qu'au moins un Tooltip correspond au label "Home"
      // (navHome dans AppLocalizations_en).
      final tooltips = tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .where((t) => t.message != null && t.message!.isNotEmpty)
          .toList();
      expect(
        tooltips.length,
        greaterThanOrEqualTo(2),
        reason: 'Au moins un Tooltip par destination du rail doit être présent',
      );
      // Au moins un tooltip doit avoir le message "Home" (navHome en anglais).
      final homeTooltip = tooltips.where(
        (t) => t.message?.toLowerCase() == 'home',
      );
      expect(
        homeTooltip,
        isNotEmpty,
        reason: 'Un Tooltip avec le label "Home" doit être présent sur le rail',
      );
    });

    // -------------------------------------------------------------------------
    // Tests Phase 3 — DrawerNav
    // -------------------------------------------------------------------------

    testWidgets('Test 6 : 1300 px + collapsed → drawer width = 72dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildHarness(
          width: 1300,
          overrides: [_layoutOverride(DesktopNavMode.collapsed)],
        ),
      );
      await tester.pumpAndSettle();

      // Vérifie via le RenderBox que la largeur rendue est 72dp.
      // On cible précisément l'AnimatedContainer racine du drawer via sa key.
      final drawerBox = tester.renderObject<RenderBox>(
        find.byKey(const Key('drawer-animated-width')),
      );
      expect(
        drawerBox.size.width,
        72,
        reason: 'Le drawer en mode collapsed doit avoir une largeur de 72dp',
      );
    });

    testWidgets(
      'Test 7 : 1300 px + expanded → drawer width = 256dp + label "Jellyfish" visible',
      (tester) async {
        tester.view.physicalSize = const Size(1300, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildHarness(
            width: 1300,
            overrides: [_layoutOverride(DesktopNavMode.expanded)],
          ),
        );
        await tester.pumpAndSettle();

        // Drawer à 256dp.
        // On cible précisément l'AnimatedContainer racine du drawer via sa key.
        final drawerBox = tester.renderObject<RenderBox>(
          find.byKey(const Key('drawer-animated-width')),
        );
        expect(
          drawerBox.size.width,
          256,
          reason: 'Le drawer en mode expanded doit avoir une largeur de 256dp',
        );

        // Le texte "Jellyfish" doit être visible dans le header.
        expect(find.text('Jellyfish'), findsOneWidget);
      },
    );

    testWidgets(
      'Test 8 : 1300 px + hidden → drawer width = 0dp + edge handle visible',
      (tester) async {
        tester.view.physicalSize = const Size(1300, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildHarness(
            width: 1300,
            overrides: [_layoutOverride(DesktopNavMode.hidden)],
          ),
        );
        await tester.pumpAndSettle();

        // Drawer à 0dp.
        // On cible précisément l'AnimatedContainer racine du drawer via sa key.
        final drawerBox = tester.renderObject<RenderBox>(
          find.byKey(const Key('drawer-animated-width')),
        );
        expect(
          drawerBox.size.width,
          0,
          reason: 'Le drawer en mode hidden doit avoir une largeur de 0dp',
        );

        // L'edge-handle (bouton chevron_right) doit être visible.
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      },
    );

    testWidgets(
      'Test 9 : toggleDesktopNav() via tap sur le bouton toggle → collapsed → expanded',
      (tester) async {
        tester.view.physicalSize = const Size(1300, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildHarness(
            width: 1300,
            overrides: [_layoutOverride(DesktopNavMode.collapsed)],
          ),
        );
        await tester.pumpAndSettle();

        // En mode collapsed, le bouton toggle affiche Icons.menu.
        expect(find.byIcon(Icons.menu), findsOneWidget);

        // Tap sur le bouton toggle (icône menu).
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        // Après toggle : mode expanded → Icons.menu_open affiché.
        expect(find.byIcon(Icons.menu_open), findsOneWidget);
        // Et le label "Jellyfish" apparaît dans le header.
        expect(find.text('Jellyfish'), findsOneWidget);
      },
    );

    testWidgets(
      'Test 10 : Cmd+B (metaLeft + keyB) → cycle collapsed → expanded',
      (tester) async {
        tester.view.physicalSize = const Size(1300, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildHarness(
            width: 1300,
            overrides: [_layoutOverride(DesktopNavMode.collapsed)],
          ),
        );
        await tester.pumpAndSettle();

        // État initial : collapsed, bouton menu visible.
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.text('Jellyfish'), findsNothing);

        // Simule Cmd+B (metaLeft + keyB).
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyB);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyB);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pumpAndSettle();

        // Après Cmd+B : mode expanded → label "Jellyfish" visible.
        expect(find.text('Jellyfish'), findsOneWidget);
      },
    );

    testWidgets(
      'Test 11 : toggle ne fait rien à 800px (mode _RailNav, pas DrawerNav)',
      (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildHarness(
            width: 800,
            overrides: [_layoutOverride(DesktopNavMode.collapsed)],
          ),
        );
        await tester.pumpAndSettle();

        // À 800px on est en mode railCompact → NavigationRail visible.
        expect(find.byType(NavigationRail), findsOneWidget);
        // Pas de DrawerNav.
        expect(find.byType(DrawerNav), findsNothing);
        // Pas de bouton menu drawer.
        expect(find.byIcon(Icons.menu_open), findsNothing);

        // Cmd+B ne doit pas provoquer d'erreur ni changer l'état.
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyB);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyB);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pumpAndSettle();

        // Le rail est toujours là, rien n'a changé.
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(DrawerNav), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // Tests boundary 1199/1200 px — transition rail→drawer
    // -------------------------------------------------------------------------

    testWidgets(
      'Test 12 : 1199 px → mode rail extended (juste sous la limite drawer)',
      (tester) async {
        tester.view.physicalSize = const Size(1199, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(_buildHarness(width: 1199));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(DrawerNav), findsNothing);
        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.extended, isTrue);
      },
    );

    testWidgets(
      'Test 13 : 1200 px → mode drawerPermanent (exactement à la limite)',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildHarness(
            width: 1200,
            overrides: [_layoutOverride(DesktopNavMode.collapsed)],
          ),
        );
        await tester.pumpAndSettle();

        // À exactement 1200px on passe en drawerPermanent.
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(DrawerNav), findsOneWidget);
      },
    );
  });
}
