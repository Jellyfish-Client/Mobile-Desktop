import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/platform/platform_capabilities.dart';

class _DesktopCaps extends PlatformCapabilities {
  const _DesktopCaps();
  @override
  bool get isMacOS => true;
  @override
  bool get isAndroid => false;
  @override
  bool get isIOS => false;
  @override
  bool get isWindows => false;
  @override
  bool get isLinux => false;
}

class _AndroidCaps extends PlatformCapabilities {
  const _AndroidCaps();
  @override
  bool get isAndroid => true;
  @override
  bool get isIOS => false;
  @override
  bool get isMacOS => false;
  @override
  bool get isWindows => false;
  @override
  bool get isLinux => false;
}

void main() {
  group('PlatformCapabilities', () {
    test('desktop turns off mobile-only gestures and immersive mode', () {
      const caps = _DesktopCaps();
      expect(caps.isDesktop, isTrue);
      expect(caps.isMobile, isFalse);
      expect(caps.supportsPip, isFalse);
      expect(caps.supportsScreenBrightness, isFalse);
      expect(caps.supportsImmersiveMode, isFalse);
      expect(caps.supportsOrientationLock, isFalse);
      expect(caps.supportsVolumeGesture, isFalse);
      expect(caps.supportsBackgroundWork, isFalse);
    });

    test('android keeps full mobile feature set', () {
      const caps = _AndroidCaps();
      expect(caps.isMobile, isTrue);
      expect(caps.isDesktop, isFalse);
      expect(caps.supportsPip, isTrue);
      expect(caps.supportsScreenBrightness, isTrue);
      expect(caps.supportsImmersiveMode, isTrue);
      expect(caps.supportsOrientationLock, isTrue);
      expect(caps.supportsVolumeGesture, isTrue);
      expect(caps.supportsBackgroundWork, isTrue);
    });

    test('provider override resolves to injected instance', () {
      final container = ProviderContainer(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(const _DesktopCaps()),
        ],
      );
      addTearDown(container.dispose);
      final caps = container.read(platformCapabilitiesProvider);
      expect(caps.isDesktop, isTrue);
      expect(caps.supportsPip, isFalse);
    });
  });
}
