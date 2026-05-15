import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/cast/cast_device.dart';
import '../../core/cast/cast_providers.dart';
import '../../core/cast/cast_session_state.dart';
import '../../l10n/l10n_extension.dart';

/// Bottom sheet qui présente les appareils Cast découverts. Tap sur une
/// ligne déclenche `connectTo`. Si une session est déjà active, l'appareil
/// connecté est mis en évidence et un bouton "Disconnect" apparaît.
///
/// Quand [autoPlayItemId] est fourni (typiquement depuis le bouton Cast
/// d'une page Détail), une connexion réussie déclenche immédiatement la
/// lecture de cet item via `/play/:id` — ce qui passe par `_initOnCast`
/// et envoie le média au Chromecast. Comportement attendu de l'utilisateur :
/// "je suis sur un film, je tape Cast, ça démarre sur la TV".
Future<void> showCastDeviceSheet(
  BuildContext context, {
  String? autoPlayItemId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => CastDeviceSheet(autoPlayItemId: autoPlayItemId),
  );
}

class CastDeviceSheet extends ConsumerWidget {
  const CastDeviceSheet({super.key, this.autoPlayItemId});

  final String? autoPlayItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final devicesAsync = ref.watch(castDevicesProvider);
    final session =
        ref.watch(castSessionProvider).valueOrNull ?? CastSessionSnapshot.idle;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.castSheetTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (session.isConnected && session.device != null)
              _ConnectedHeader(device: session.device!),
            devicesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(e.toString(),
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (devices) {
                if (devices.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.cast, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          l10n.castSheetSearching,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.castSheetEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (_, i) => _DeviceTile(
                    device: devices[i],
                    isActive: session.device?.id == devices[i].id,
                    autoPlayItemId: autoPlayItemId,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedHeader extends ConsumerWidget {
  const _ConnectedHeader({required this.device});
  final CastDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.castSheetConnectedTo(device.friendlyName),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(castServiceProvider).disconnect();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.castSheetDisconnect),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  const _DeviceTile({
    required this.device,
    required this.isActive,
    this.autoPlayItemId,
  });
  final CastDevice device;
  final bool isActive;
  final String? autoPlayItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ListTile(
      leading: Icon(isActive ? Icons.cast_connected : Icons.cast),
      title: Text(device.friendlyName),
      subtitle: device.modelName == null ? null : Text(device.modelName!),
      onTap: isActive
          ? null
          : () async {
              final messenger = ScaffoldMessenger.of(context)
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.castConnecting(device.friendlyName)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              navigator.pop();
              final svc = ref.read(castServiceProvider);
              final ok = await svc.connectTo(device.id);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? l10n.castStartedSnack(device.friendlyName)
                        : l10n.castConnectionFailed(device.friendlyName),
                  ),
                ),
              );
              if (!ok || autoPlayItemId == null) return;

              // Auto-play: wait for the session to fully propagate to
              // `isCastConnectedProvider` before pushing /play, otherwise
              // PlayerScreen reads `false` and falls back to the local flow.
              try {
                await svc.sessionStream
                    .firstWhere((s) => s.isConnected)
                    .timeout(const Duration(seconds: 3));
              } on Object {
                // Session never confirmed within 3s — bail out silently.
                return;
              }
              unawaited(router.push('/play/$autoPlayItemId'));
            },
    );
  }
}
