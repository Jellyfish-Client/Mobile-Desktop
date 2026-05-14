import 'dart:io';

const jellyfinAppName = 'Jellyfish';
const jellyfinAppVersion = '0.1.0';

/// Builds the Jellyfin `Authorization: MediaBrowser …` header value, matching
/// the official @jellyfin/sdk implementation: every value URL-encoded,
/// `Token=""` always present (empty string when no session yet).
String mediaBrowserHeader({
  required String accessToken,
  required String deviceId,
}) {
  String enc(String s) => Uri.encodeComponent(s);
  final deviceName = Platform.isIOS
      ? 'iOS Device'
      : Platform.isAndroid
      ? 'Android Device'
      : Platform.isMacOS
      ? 'macOS Desktop'
      : Platform.isWindows
      ? 'Windows Desktop'
      : Platform.isLinux
      ? 'Linux Desktop'
      : Platform.operatingSystem;
  return [
    'MediaBrowser Client="${enc(jellyfinAppName)}"',
    'Device="${enc(deviceName)}"',
    'DeviceId="${enc(deviceId)}"',
    'Version="${enc(jellyfinAppVersion)}"',
    'Token="${enc(accessToken)}"',
  ].join(', ');
}
