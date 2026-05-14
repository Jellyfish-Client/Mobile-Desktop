import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_providers.dart';
import 'home_section.dart';

class HomeSectionsState {
  const HomeSectionsState({required this.visible});

  final List<HomeSection> visible;
}

final homeSectionsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      HomeSectionsController,
      HomeSectionsState
    >(HomeSectionsController.new);

/// Thin wrapper over [homeCatalogProvider]. Kept as a separate notifier so
/// future Home behaviour (per-section dismissal, A/B-tested reorderings…) has
/// somewhere to live without bleeding into the catalog builder. For now it
/// just surfaces the catalog as-is — there's no pagination/batching anymore
/// since every rail is itself lazy via its own SWR provider.
class HomeSectionsController
    extends AutoDisposeAsyncNotifier<HomeSectionsState> {
  @override
  Future<HomeSectionsState> build() async {
    ref.keepAlive();
    final sections = await ref.watch(homeCatalogProvider.future);
    return HomeSectionsState(visible: sections);
  }
}
