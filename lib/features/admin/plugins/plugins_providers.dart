import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Lists the plugins installed on the server. The notifier exposes
/// enable/disable and uninstall instance methods so callers can `await
/// ref.read(adminPluginsProvider.notifier).setEnabled(...)` and let the
/// returned state refresh drive the UI.
///
/// Plugin configuration pages are served as HTML by the Jellyfin server and
/// are out of scope for the client — only lifecycle controls (enable, disable,
/// uninstall) are surfaced here.
class AdminPluginsNotifier
    extends AutoDisposeAsyncNotifier<List<PluginInfo>> {
  @override
  Future<List<PluginInfo>> build() => _fetch();

  Future<List<PluginInfo>> _fetch() async {
    final api = ref.read(jellyfinApiProvider);
    final res = await api.getPluginsApi().getPlugins();
    final list = (res.data?.toList() ?? <PluginInfo>[])
      ..sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
              (b.name ?? '').toLowerCase(),
            ),
      );
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Flips a plugin's enabled state. `version` is required by the Jellyfin
  /// enable/disable endpoints because a single pluginId can have multiple
  /// installed versions side-by-side.
  Future<void> setEnabled(
    String pluginId,
    String version, {
    required bool value,
  }) async {
    final api = ref.read(jellyfinApiProvider);
    if (value) {
      await api.getPluginsApi().enablePlugin(
            pluginId: pluginId,
            version: version,
          );
    } else {
      await api.getPluginsApi().disablePlugin(
            pluginId: pluginId,
            version: version,
          );
    }
    await refresh();
  }

  /// Removes a plugin entirely. The Jellyfin server typically requires a
  /// restart for the change to take full effect — surfaced to the user via
  /// the `Restart` plugin status the next time the list refreshes.
  Future<void> uninstall(String pluginId) async {
    final api = ref.read(jellyfinApiProvider);
    // `uninstallPlugin(pluginId)` is marked deprecated by the generated SDK
    // in favour of `uninstallPluginByVersion`, but the by-version variant
    // requires a `version` argument we don't have when the user just wants
    // to remove the plugin outright (independent of which version is
    // currently active). The endpoint itself is still served by Jellyfin
    // and is the closer match to the contract we expose here.
    // ignore: deprecated_member_use
    await api.getPluginsApi().uninstallPlugin(pluginId: pluginId);
    await refresh();
  }
}

final adminPluginsProvider =
    AutoDisposeAsyncNotifierProvider<AdminPluginsNotifier, List<PluginInfo>>(
  AdminPluginsNotifier.new,
);
