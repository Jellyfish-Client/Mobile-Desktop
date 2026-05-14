import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Pulls the full `ServerConfiguration` from `/System/Configuration`. We hand
/// out the raw built_value object so the form layer can rebuild it via
/// `current.rebuild(...)` and post it back unchanged save for the edited
/// fields — that preserves every knob we don't expose (metadata options,
/// path substitutions, trickplay options, …) without having to mirror the
/// full schema in our domain layer.
final adminServerConfigProvider =
    FutureProvider.autoDispose<ServerConfiguration>((ref) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getConfigurationApi().getConfiguration();
  return res.data!;
});

/// Branding options — the dedicated `/Branding/Configuration` endpoint
/// returns the same payload `ConfigurationApi.updateBrandingConfiguration`
/// expects, which makes it easy to round-trip via the built_value builder.
final adminBrandingProvider =
    FutureProvider.autoDispose<BrandingOptionsDto>((ref) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getBrandingApi().getBrandingOptions();
  return res.data!;
});

/// Thin controller exposing the two POST endpoints. Kept as a plain Provider
/// (not an AsyncNotifier) because the cached state lives in the two
/// FutureProvider.autoDispose above — the controller is just a method bag
/// that mutates server state and then invalidates the relevant cache.
class AdminServerConfigController {
  AdminServerConfigController(this.ref);

  final Ref ref;

  Future<void> save(ServerConfiguration config) async {
    final api = ref.read(jellyfinApiProvider);
    await api
        .getConfigurationApi()
        .updateConfiguration(serverConfiguration: config);
    ref.invalidate(adminServerConfigProvider);
  }

  Future<void> saveBranding({
    required String? loginDisclaimer,
    required String? customCss,
    required bool splashscreenEnabled,
  }) async {
    final api = ref.read(jellyfinApiProvider);
    final body = BrandingOptionsDto(
      (b) => b
        ..loginDisclaimer = loginDisclaimer
        ..customCss = customCss
        ..splashscreenEnabled = splashscreenEnabled,
    );
    await api
        .getConfigurationApi()
        .updateBrandingConfiguration(brandingOptionsDto: body);
    ref.invalidate(adminBrandingProvider);
  }
}

final adminServerConfigControllerProvider =
    Provider<AdminServerConfigController>((ref) {
  return AdminServerConfigController(ref);
});
