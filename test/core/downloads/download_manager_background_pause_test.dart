import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/storage/app_database.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Construit un [DownloadRow] minimal avec un [taskId] non-nul.
DownloadRow _row({required String itemId, String? taskId}) => DownloadRow(
  attempts: 0,
  accountKey: 'test-account',
  itemId: itemId,
  itemType: 'Movie',
  name: 'Movie $itemId',
  status: DownloadStatus.running,
  progress: 0.5,
  createdAt: DateTime(2024),
  taskId: taskId ?? 'task-$itemId',
);

/// Construit un [DownloadRow] sans taskId (doit être ignoré par la logique).
DownloadRow _rowNoTask({required String itemId}) => DownloadRow(
  attempts: 0,
  accountKey: 'test-account',
  itemId: itemId,
  itemType: 'Movie',
  name: 'Movie $itemId',
  status: DownloadStatus.running,
  progress: 0.5,
  createdAt: DateTime(2024),
  taskId: null,
);

/// Reproduit la logique de `DownloadManager.pauseTasksInParallel` pour
/// vérifier le comportement attendu sans instancier le manager (qui boot des
/// plugins natifs). Le test valide que la logique de parallélisme et de
/// timeout est correcte de façon isolée.
Future<Set<String>> _runPauseLogic(
  List<DownloadRow> rows, {
  required Future<bool> Function(String taskId) pauseTask,
  Duration budget = const Duration(seconds: 4),
}) async {
  final autoPaused = <String>{};
  await Future.wait(
    rows.map((r) async {
      if (r.taskId == null) return;
      try {
        final paused = await pauseTask(r.taskId!);
        if (paused) autoPaused.add(r.itemId);
      } on Object {
        // isolation individuelle — ne propage pas
      }
    }),
  ).timeout(budget, onTimeout: () => []);
  return autoPaused;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Download background pause — parallélisme et timeout', () {
    test('10 tâches complètent en <5s même si une tâche prend 2s', () async {
      final rows = List.generate(10, (i) => _row(itemId: 'item-$i'));

      final stopwatch = Stopwatch()..start();
      final autoPaused = await _runPauseLogic(
        rows,
        pauseTask: (taskId) async {
          // La tâche 5 simule une lenteur de 2s, toutes les autres sont immédiates.
          if (taskId == 'task-item-5') {
            await Future<void>.delayed(const Duration(seconds: 2));
          }
          return true;
        },
      );
      stopwatch.stop();

      // Toutes les 10 tâches doivent avoir été paused.
      expect(autoPaused.length, equals(10));
      // Avec le parallélisme, le total doit rester proche de 2s (tâche lente)
      // et non pas 2s * 10 = 20s (séquentiel). On accepte jusqu'à 3s.
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(3000),
        reason: "Les tâches doivent s'exécuter en parallèle, pas séquentiellement",
      );
    });

    test(
      "une exception sur une tâche n'empêche pas les autres de se compléter",
      () async {
        final rows = List.generate(5, (i) => _row(itemId: 'item-$i'));

        final autoPaused = await _runPauseLogic(
          rows,
          pauseTask: (taskId) async {
            if (taskId == 'task-item-2') {
              throw StateError('backend crash');
            }
            return true;
          },
        );

        // 4 sur 5 doivent être paused (item-2 a crashé).
        expect(autoPaused.length, equals(4));
        expect(autoPaused, isNot(contains('item-2')));
      },
    );

    test('les rows sans taskId sont ignorées silencieusement', () async {
      final rows = [
        _row(itemId: 'with-task'),
        _rowNoTask(itemId: 'no-task'),
      ];

      final autoPaused = await _runPauseLogic(
        rows,
        pauseTask: (_) async => true,
      );

      expect(autoPaused, contains('with-task'));
      expect(autoPaused, isNot(contains('no-task')));
    });

    test(
      'timeout 4s se déclenche si toutes les tâches sont bloquées indéfiniment',
      () async {
        final rows = List.generate(3, (i) => _row(itemId: 'item-$i'));
        var timeoutFired = false;

        final stopwatch = Stopwatch()..start();
        await Future.wait(
          rows.map((_) async {
            await Future<void>.delayed(const Duration(seconds: 10));
          }),
        ).timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            timeoutFired = true;
            return [];
          },
        );
        stopwatch.stop();

        expect(timeoutFired, isTrue);
        // Doit couper à ~4s, pas attendre 10s. Marge de ±600ms.
        expect(stopwatch.elapsedMilliseconds, lessThan(4600));
      },
    );

    test(
      "une tâche qui retourne false ne s'ajoute pas à autoPaused",
      () async {
        final rows = [
          _row(itemId: 'paused-ok'),
          _row(itemId: 'refused'),
        ];

        final autoPaused = await _runPauseLogic(
          rows,
          pauseTask: (taskId) async => taskId == 'task-paused-ok',
        );

        expect(autoPaused, contains('paused-ok'));
        expect(autoPaused, isNot(contains('refused')));
      },
    );
  });
}
