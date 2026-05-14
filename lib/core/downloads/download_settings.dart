import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadSettings {
  const DownloadSettings({
    required this.backgroundEnabled,
    required this.wifiOnly,
    required this.autoDeleteWatched,
  });

  final bool backgroundEnabled;
  final bool wifiOnly;
  final bool autoDeleteWatched;

  static const defaults = DownloadSettings(
    backgroundEnabled: true,
    wifiOnly: false,
    autoDeleteWatched: false,
  );

  DownloadSettings copyWith({
    bool? backgroundEnabled,
    bool? wifiOnly,
    bool? autoDeleteWatched,
  }) => DownloadSettings(
    backgroundEnabled: backgroundEnabled ?? this.backgroundEnabled,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    autoDeleteWatched: autoDeleteWatched ?? this.autoDeleteWatched,
  );
}

class DownloadSettingsController extends AsyncNotifier<DownloadSettings> {
  static const _kBackground = 'downloads.backgroundEnabled';
  static const _kWifi = 'downloads.wifiOnly';
  static const _kAutoDelete = 'downloads.autoDeleteWatched';

  late SharedPreferences _prefs;

  @override
  Future<DownloadSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    return DownloadSettings(
      backgroundEnabled:
          _prefs.getBool(_kBackground) ??
          DownloadSettings.defaults.backgroundEnabled,
      wifiOnly: _prefs.getBool(_kWifi) ?? DownloadSettings.defaults.wifiOnly,
      autoDeleteWatched:
          _prefs.getBool(_kAutoDelete) ??
          DownloadSettings.defaults.autoDeleteWatched,
    );
  }

  Future<void> setBackgroundEnabled({required bool value}) async {
    await _prefs.setBool(_kBackground, value);
    state = AsyncData(state.requireValue.copyWith(backgroundEnabled: value));
  }

  Future<void> setWifiOnly({required bool value}) async {
    await _prefs.setBool(_kWifi, value);
    state = AsyncData(state.requireValue.copyWith(wifiOnly: value));
  }

  Future<void> setAutoDeleteWatched({required bool value}) async {
    await _prefs.setBool(_kAutoDelete, value);
    state = AsyncData(state.requireValue.copyWith(autoDeleteWatched: value));
  }
}

final downloadSettingsProvider =
    AsyncNotifierProvider<DownloadSettingsController, DownloadSettings>(
      DownloadSettingsController.new,
    );
