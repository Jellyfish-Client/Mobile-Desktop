import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/platform/platform_capabilities.dart';
import 'package:jellyfish/features/syncplay/data/sync_play_providers.dart';
import 'package:jellyfish/features/syncplay/data/sync_play_session_controller.dart';
import 'package:jellyfish/features/syncplay/domain/sync_play_session.dart';
import 'package:jellyfish/l10n/app_localizations.dart';
import 'package:jellyfish/shared/widgets/sync_play_button.dart';

// ---------------------------------------------------------------------------
// Fake platform capabilities — simule un desktop (macOS)
// ---------------------------------------------------------------------------

class _DesktopCaps extends PlatformCapabilities {
  const _DesktopCaps();

  @override
  bool get isMacOS => true;

  @override
  bool get isAndroid => false;

  @override
  bool get isIOS => false;

  @override
  bool get isWindows => false;

  @override
  bool get isLinux => false;
}

// ---------------------------------------------------------------------------
// Fake session controller — évite d'instancier les vrais services réseau
// ---------------------------------------------------------------------------

class _FakeSessionController extends SyncPlaySessionController {
  _FakeSessionController(this._session);

  final SyncPlaySession _session;

  @override
  Future<SyncPlaySession> build() async => _session;
}

// ---------------------------------------------------------------------------
// Helper de pompage
// ---------------------------------------------------------------------------

/// Pompe le [SyncPlayButton] dans un harness Material + l10n FR + Riverpod.
///
/// [inGroup] : si `true`, la session est `SyncPlaySession.idle` avec un groupe
/// factice ; sinon `SyncPlaySession.disconnected`.
/// [availableGroups] : groupes retournés par [availableSyncPlayGroupsProvider].
Future<void> _pumpButton(
  WidgetTester tester, {
  bool inGroup = false,
  List<SyncPlayGroup> availableGroups = const [],
}) async {
  final session = inGroup
      ? const SyncPlaySession.idle(
          group: SyncPlayGroup(
            id: 'g0',
            name: 'Soirée ciné',
            members: [SyncPlayMember(id: 'u0', displayName: 'Alice')],
          ),
        )
      : const SyncPlaySession.disconnected();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        platformCapabilitiesProvider.overrideWithValue(const _DesktopCaps()),
        syncPlaySessionProvider.overrideWith(
          () => _FakeSessionController(session),
        ),
        availableSyncPlayGroupsProvider.overrideWith(
          (_) async => availableGroups,
        ),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(
            actions: const [SyncPlayButton()],
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    ),
  );
  // Laisser les providers FutureProvider se résoudre avant de retourner.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SyncPlayButton', () {
    testWidgets(
      'hors groupe — affiche un IconButton (desktop gated)',
      (tester) async {
        await _pumpButton(tester);

        expect(find.byType(IconButton), findsOneWidget);
      },
    );

    testWidgets(
      'hors groupe — tap ouvre le popup menu avec entrée « Créer un groupe »',
      (tester) async {
        await _pumpButton(tester);

        await tester.tap(find.byType(IconButton));
        // pump pour ouvrir le menu (showMenu est async mais s'ouvre sur le
        // premier frame). On ne peut pas pumpAndSettle car le menu peut
        // contenir des animations continues.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // L'en-tête « Rejoindre un groupe » doit être présent
        expect(find.text('Rejoindre un groupe'), findsOneWidget);

        // L'entrée « Créer un groupe » (syncPlayCreateButton) doit être présente
        expect(find.text('Créer un groupe'), findsOneWidget);

        // Le sous-titre « Créer un nouveau groupe » (syncPlayCreateGroupSubtitle)
        expect(find.text('Créer un nouveau groupe'), findsOneWidget);
      },
    );

    testWidgets(
      'hors groupe, 0 groupe disponible — menu sans items de groupe, uniquement « Créer »',
      (tester) async {
        await _pumpButton(tester, availableGroups: const []);

        await tester.tap(find.byType(IconButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Pas de groupe dans le menu
        expect(find.text('Soirée ciné'), findsNothing);

        // Mais l'entrée créer est bien là
        expect(find.text('Créer un groupe'), findsOneWidget);
      },
    );

    testWidgets(
      'hors groupe, 2 groupes disponibles — menu affiche les deux groupes',
      (tester) async {
        const groups = [
          SyncPlayGroup(
            id: 'g1',
            name: 'Groupe Alpha',
            members: [SyncPlayMember(id: 'u1', displayName: 'Alice')],
          ),
          SyncPlayGroup(
            id: 'g2',
            name: 'Groupe Beta',
            members: [
              SyncPlayMember(id: 'u2', displayName: 'Bob'),
              SyncPlayMember(id: 'u3', displayName: 'Charlie'),
            ],
          ),
        ];

        await _pumpButton(tester, availableGroups: groups);

        await tester.tap(find.byType(IconButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Groupe Alpha'), findsOneWidget);
        expect(find.text('Groupe Beta'), findsOneWidget);
        // Nombres de membres (pluriel)
        expect(find.text('1 membre'), findsOneWidget);
        expect(find.text('2 membres'), findsOneWidget);
        // Entrée créer toujours présente en bas
        expect(find.text('Créer un groupe'), findsOneWidget);
      },
    );

    testWidgets(
      'dans un groupe — affiche un bouton avec icône groups (pleine)',
      (tester) async {
        await _pumpButton(tester, inGroup: true);

        // Le bouton badge (icône groups pleine) doit être présent
        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.groups), findsOneWidget);
      },
    );
  });
}
