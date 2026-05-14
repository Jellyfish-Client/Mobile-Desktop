import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Semantic feature flags derived from the host platform.
///
/// Centralises all `Platform.isXxx` checks so the rest of the codebase asks
/// questions like "do we support PiP?" instead of "are we on Android?".
/// Inject via [platformCapabilitiesProvider]; override in tests with a
/// const subclass to exercise both code paths.
@immutable
class PlatformCapabilities {
  const PlatformCapabilities();

  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isLinux => !kIsWeb && Platform.isLinux;

  bool get isMobile => isAndroid || isIOS;
  bool get isDesktop => isMacOS || isWindows || isLinux;

  /// True on platforms where the `floating` plugin can host system PiP.
  bool get supportsPip => isAndroid;

  /// True on platforms where `screen_brightness` is implemented and useful
  /// (mobile only — desktop brightness is owned by the OS).
  bool get supportsScreenBrightness => isMobile;

  /// True on platforms where `SystemChrome.setEnabledSystemUIMode` /
  /// `setPreferredOrientations` are implemented.
  bool get supportsImmersiveMode => isMobile;

  /// True on platforms where forcing landscape during playback is a thing.
  bool get supportsOrientationLock => isMobile;

  /// True on platforms where the vertical-drag brightness/volume gesture
  /// (and the matching `volume_controller` listener) makes sense. Desktop
  /// users control volume via the OS, not via a fullscreen gesture.
  bool get supportsVolumeGesture => isMobile;

  /// True on platforms that have a background scheduler we expose
  /// (Workmanager-style). Desktop background work would need a different
  /// abstraction and is out of scope for the MVP.
  bool get supportsBackgroundWork => isMobile;
}

final platformCapabilitiesProvider = Provider<PlatformCapabilities>(
  (_) => const PlatformCapabilities(),
);
