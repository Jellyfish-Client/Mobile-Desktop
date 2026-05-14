import '../auth/session.dart';
import '../network/jellyfin_auth_header.dart';

class DownloadEndpoint {
  const DownloadEndpoint({required this.url, required this.headers});

  final String url;
  final Map<String, String> headers;
}

DownloadEndpoint buildDownloadEndpoint({
  required Session session,
  required String deviceId,
  required String itemId,
}) {
  final base = session.serverUrl.replaceAll(RegExp(r'/+$'), '');
  final url = '$base/Items/$itemId/Download';
  final mediaBrowser = mediaBrowserHeader(
    accessToken: session.accessToken,
    deviceId: deviceId,
  );
  final headers = <String, String>{};
  if (session.proxyAuth != null) {
    headers['Authorization'] = session.proxyAuth!;
    headers['X-Emby-Authorization'] = mediaBrowser;
  } else {
    headers['Authorization'] = mediaBrowser;
  }
  return DownloadEndpoint(url: url, headers: headers);
}
