import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sync_play_session.dart';
import 'sync_play_service.dart';

// Re-exports : on garde un point d'entrée unique pour l'UI/bridge.
export 'sync_play_clock_offset.dart' show syncPlayClockOffsetProvider;
export 'sync_play_service.dart' show syncPlayServiceProvider;
export 'sync_play_session_controller.dart'
    show syncPlayInGroupProvider, syncPlaySessionProvider;

/// Liste des groupes ouverts visibles côté serveur. Le `family` (vide ici)
/// est laissé pour permettre demain un filtre éventuel (lib, owner) sans
/// casser les call-sites.
final availableSyncPlayGroupsProvider =
    FutureProvider.autoDispose<List<SyncPlayGroup>>((ref) async {
      final service = ref.watch(syncPlayServiceProvider);
      return service.listOpenGroups();
    });
