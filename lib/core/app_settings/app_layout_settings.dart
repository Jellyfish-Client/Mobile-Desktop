import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Desktop navigation mode preference.
///
/// - collapsed: rail with icons only (compact, default)
/// - expanded: rail with labels visible (extended)
/// - hidden: navigation hidden (reserved for future use)
enum DesktopNavMode { collapsed, expanded, hidden }

/// Layout preferences for responsive desktop experience.
@immutable
class AppLayoutSettings {
  const AppLayoutSettings({
    required this.desktopNavMode,
    required this.railExtendedOnExpanded,
  });

  /// Preferred desktop navigation mode (collapsed / expanded / hidden).
  final DesktopNavMode desktopNavMode;

  /// When true, the rail extends at expanded window size breakpoint.
  /// When false, rail stays compact at all window sizes.
  final bool railExtendedOnExpanded;

  /// Default settings: rail starts collapsed, stays compact at all sizes.
  static const initial = AppLayoutSettings(
    desktopNavMode: DesktopNavMode.collapsed,
    railExtendedOnExpanded: false,
  );

  AppLayoutSettings copyWith({
    DesktopNavMode? desktopNavMode,
    bool? railExtendedOnExpanded,
  }) => AppLayoutSettings(
    desktopNavMode: desktopNavMode ?? this.desktopNavMode,
    railExtendedOnExpanded:
        railExtendedOnExpanded ?? this.railExtendedOnExpanded,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLayoutSettings &&
          runtimeType == other.runtimeType &&
          desktopNavMode == other.desktopNavMode &&
          railExtendedOnExpanded == other.railExtendedOnExpanded;

  @override
  int get hashCode => desktopNavMode.hashCode ^ railExtendedOnExpanded.hashCode;

  @override
  String toString() =>
      'AppLayoutSettings(desktopNavMode: $desktopNavMode, railExtendedOnExpanded: $railExtendedOnExpanded)';
}

/// Manages app layout preferences with SharedPreferences persistence.
///
/// This controller handles user preferences for desktop navigation layout
/// (rail vs drawer) and rail expansion behavior. Changes are persisted
/// immediately and the state is updated optimistically.
class AppLayoutSettingsController extends AsyncNotifier<AppLayoutSettings> {
  static const _kDesktopNavMode = 'app_layout.desktop_nav_mode';
  static const _kRailExtendedOnExpanded =
      'app_layout.rail_extended_on_expanded';

  late SharedPreferences _prefs;

  @override
  Future<AppLayoutSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    final navModeStr = _prefs.getString(_kDesktopNavMode);
    final navMode = navModeStr != null
        ? DesktopNavMode.values.byName(navModeStr)
        : AppLayoutSettings.initial.desktopNavMode;

    return AppLayoutSettings(
      desktopNavMode: navMode,
      railExtendedOnExpanded:
          _prefs.getBool(_kRailExtendedOnExpanded) ??
          AppLayoutSettings.initial.railExtendedOnExpanded,
    );
  }

  /// Updates the desktop navigation mode and persists it to SharedPreferences.
  Future<void> setDesktopNavMode(DesktopNavMode mode) async {
    await _prefs.setString(_kDesktopNavMode, mode.name);
    state = AsyncData(state.requireValue.copyWith(desktopNavMode: mode));
  }

  /// Updates the rail extended preference at expanded window size.
  Future<void> setRailExtendedOnExpanded({required bool value}) async {
    await _prefs.setBool(_kRailExtendedOnExpanded, value);
    state = AsyncData(
      state.requireValue.copyWith(railExtendedOnExpanded: value),
    );
  }

  /// Cycles the desktop navigation mode: collapsed -> expanded -> collapsed.
  /// Hidden mode is skipped as it's reserved for future use.
  Future<void> toggleDesktopNav() async {
    final current = state.requireValue.desktopNavMode;
    final next = current == DesktopNavMode.collapsed
        ? DesktopNavMode.expanded
        : DesktopNavMode.collapsed;
    await setDesktopNavMode(next);
  }
}

final appLayoutSettingsProvider =
    AsyncNotifierProvider<AppLayoutSettingsController, AppLayoutSettings>(
      AppLayoutSettingsController.new,
    );
