import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cast/cast_providers.dart';
import '../../core/downloads/download_manager.dart';
import '../../l10n/l10n_extension.dart';
import 'cast_device_sheet.dart';

/// Bouton standardisé qui ouvre la liste d'appareils Cast.
///
/// Se masque automatiquement quand :
///   - le SDK Cast n'est pas supporté (émulateur, plateforme desktop) ;
///   - l'item courant est entièrement téléchargé en local (V1 ne supporte
///     pas le cast hors-ligne).
class CastButton extends ConsumerWidget {
  const CastButton({
    super.key,
    this.itemId,
    this.color,
    this.tooltip,
  });

  /// Si non-null, le bouton se masque pour les items téléchargés en local.
  final String? itemId;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(castSupportedProvider)) return const SizedBox.shrink();

    if (itemId != null) {
      final isLocal =
          ref.watch(_isItemLocalProvider(itemId!)).valueOrNull ?? false;
      if (isLocal) return const SizedBox.shrink();
    }

    final connected = ref.watch(isCastConnectedProvider);
    return IconButton(
      tooltip: tooltip ?? context.l10n.castButton,
      icon: Icon(
        connected ? Icons.cast_connected : Icons.cast,
        color: color,
      ),
      // Quand on est sur une page Détail (`itemId != null`), connecter le
      // Cast lance automatiquement la lecture du film. Ailleurs (Library,
      // Home, …), on se contente d'établir la session.
      onPressed: () =>
          showCastDeviceSheet(context, autoPlayItemId: itemId),
    );
  }
}

/// Provider interne au module Cast — pas exposé via cast_providers.dart car
/// il ne sert qu'à griser le bouton.
final _isItemLocalProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final path = await ref.read(downloadManagerProvider).localPathFor(id);
  return path != null;
});
