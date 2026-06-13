import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggles the OS window in/out of fullscreen on desktop.
///
/// Rather than pull in `window_manager` (an extra native plugin to bundle and
/// initialise), this reuses the method channel that `media_kit_video` already
/// registers on macOS/Windows/Linux. Its native plugin is compiled into every
/// desktop build — if the video renders, this channel is live — so it is the
/// most reliable path for the Windows portable build with zero new deps.
///
/// Channel + method names mirror media_kit_video 1.2.x
/// (`defaultEnterNativeFullscreen` / `defaultExitNativeFullscreen`); pinned via
/// pubspec. Calls are best-effort: a missing channel (non-desktop, or a future
/// rename) is swallowed so playback is never affected. There is no native
/// "is fullscreen?" query, so callers track the toggle state themselves.
class NativeFullscreen {
  const NativeFullscreen();

  static const _channel = MethodChannel('com.alexmercerind/media_kit_video');

  Future<void> enter() => _invoke('Utils.EnterNativeFullscreen');

  Future<void> exit() => _invoke('Utils.ExitNativeFullscreen');

  Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on Object {
      // Best-effort: channel absent on this platform or method renamed.
    }
  }
}

/// Injectable so tests can override the toggle with a spy.
final nativeFullscreenProvider = Provider<NativeFullscreen>(
  (_) => const NativeFullscreen(),
);
