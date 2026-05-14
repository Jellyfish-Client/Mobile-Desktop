class Session {
  const Session({
    required this.serverUrl,
    required this.serverId,
    required this.userId,
    required this.userName,
    required this.accessToken,
    this.proxyAuth,
    this.isAdmin = false,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    serverUrl: json['serverUrl'] as String,
    serverId: json['serverId'] as String,
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    accessToken: json['accessToken'] as String,
    proxyAuth: json['proxyAuth'] as String?,
    isAdmin: json['isAdmin'] as bool? ?? false,
    // Legacy keys (`seerrUrl`, `seerrCookie`, `jellyseerrUrl`,
    // `jellyseerrCookie`) from older app versions are intentionally ignored
    // here: Seerr now rides on the Jellyfin auth via the Jellyfish.Bridge
    // plugin, so no separate Seerr session state is persisted.
  );

  final String serverUrl;
  final String serverId;
  final String userId;
  final String userName;
  final String accessToken;

  /// Optional reverse-proxy Basic Auth header value (e.g. `Basic dXNlcjpwYXNz`).
  /// Sent on every request before reaching Jellyfin.
  final String? proxyAuth;

  /// Whether the active user has Policy.IsAdministrator on the server.
  /// Drives visibility of the /settings/admin section.
  final bool isAdmin;

  Session copyWith({
    String? serverUrl,
    String? serverId,
    String? userId,
    String? userName,
    String? accessToken,
    String? proxyAuth,
    bool? isAdmin,
  }) {
    return Session(
      serverUrl: serverUrl ?? this.serverUrl,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      accessToken: accessToken ?? this.accessToken,
      proxyAuth: proxyAuth ?? this.proxyAuth,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toJson() => {
    'serverUrl': serverUrl,
    'serverId': serverId,
    'userId': userId,
    'userName': userName,
    'accessToken': accessToken,
    'proxyAuth': proxyAuth,
    'isAdmin': isAdmin,
  };
}

class SessionState {
  const SessionState({this.session});

  final Session? session;

  bool get hasSession => session != null;

  static const empty = SessionState();
}
