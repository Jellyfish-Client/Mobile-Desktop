/// One persisted Jellyfin account (server + user + token + metadata).
///
/// The list of `SavedAccount` is the source of truth for which servers and
/// users the app knows about. The currently-active session is derived from
/// this list by picking the entry with the most recent [lastUsedAt].
class SavedAccount {
  const SavedAccount({
    required this.serverId,
    required this.serverUrl,
    required this.serverName,
    required this.userId,
    required this.userName,
    required this.accessToken,
    required this.lastUsedAt,
    this.proxyAuth,
    this.primaryImageTag,
    this.isAdmin = false,
  });

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
    serverId: json['serverId'] as String,
    serverUrl: json['serverUrl'] as String,
    serverName: json['serverName'] as String? ?? 'Jellyfin',
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    accessToken: json['accessToken'] as String,
    proxyAuth: json['proxyAuth'] as String?,
    primaryImageTag: json['primaryImageTag'] as String?,
    isAdmin: json['isAdmin'] as bool? ?? false,
    lastUsedAt: DateTime.fromMillisecondsSinceEpoch(
      json['lastUsedAt'] as int? ?? 0,
      isUtc: true,
    ),
  );

  final String serverId;
  final String serverUrl;
  final String serverName;
  final String userId;
  final String userName;
  final String accessToken;
  final String? proxyAuth;
  final String? primaryImageTag;
  final bool isAdmin;
  final DateTime lastUsedAt;

  /// Composite identity. Two accounts collide iff they refer to the same
  /// (server, user) pair — re-logging the same user replaces the entry rather
  /// than duplicating it.
  String get key => '$serverId|$userId';

  SavedAccount copyWith({
    String? serverId,
    String? serverUrl,
    String? serverName,
    String? userId,
    String? userName,
    String? accessToken,
    String? proxyAuth,
    String? primaryImageTag,
    bool? isAdmin,
    DateTime? lastUsedAt,
  }) {
    return SavedAccount(
      serverId: serverId ?? this.serverId,
      serverUrl: serverUrl ?? this.serverUrl,
      serverName: serverName ?? this.serverName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      accessToken: accessToken ?? this.accessToken,
      proxyAuth: proxyAuth ?? this.proxyAuth,
      primaryImageTag: primaryImageTag ?? this.primaryImageTag,
      isAdmin: isAdmin ?? this.isAdmin,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'serverId': serverId,
    'serverUrl': serverUrl,
    'serverName': serverName,
    'userId': userId,
    'userName': userName,
    'accessToken': accessToken,
    'proxyAuth': proxyAuth,
    'primaryImageTag': primaryImageTag,
    'isAdmin': isAdmin,
    'lastUsedAt': lastUsedAt.toUtc().millisecondsSinceEpoch,
  };
}
