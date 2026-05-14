import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/saved_account.dart';

/// Round profile image for a [SavedAccount]. Loads the Jellyfin
/// `/Users/{id}/Images/Primary` endpoint when a tag is known; falls back to a
/// deterministically-coloured initial otherwise (also used while the network
/// image is loading or on error).
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({required this.account, this.size = 40, super.key});

  final SavedAccount account;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initialWidget = _Initial(
      letter: _initialOf(account.userName),
      seed: account.userId,
      size: size,
    );

    final tag = account.primaryImageTag;
    if (tag == null) return initialWidget;

    final base = account.serverUrl.endsWith('/')
        ? account.serverUrl.substring(0, account.serverUrl.length - 1)
        : account.serverUrl;
    // Pass the access token as `ApiKey=` query param rather than building a
    // full MediaBrowser header: image endpoints on Jellyfin accept both, and
    // `CachedNetworkImage` only lets us inject HTTP headers, which would also
    // need the device id (async to read). Reverse-proxy Basic Auth still
    // needs to go in headers though.
    final url =
        '$base/Users/${account.userId}/Images/Primary?tag=$tag'
        '&maxWidth=${(size * 2).round()}&quality=85'
        '&ApiKey=${account.accessToken}';

    final headers = <String, String>{
      if (account.proxyAuth != null) 'Authorization': account.proxyAuth!,
    };

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        // Explicit cache key keyed on (user, tag): some Jellyfin servers keep
        // the same primaryImageTag across a replace, in which case the URL
        // wouldn't change and CachedNetworkImage would serve a stale image
        // forever. The cacheKey lets us evict / refresh deterministically.
        cacheKey: '${account.userId}_$tag',
        width: size,
        height: size,
        fit: BoxFit.cover,
        httpHeaders: headers.isEmpty ? null : headers,
        placeholder: (_, __) => initialWidget,
        errorWidget: (_, __, ___) => initialWidget,
      ),
    );
  }

  String _initialOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}

class _Initial extends StatelessWidget {
  const _Initial({
    required this.letter,
    required this.seed,
    required this.size,
  });

  final String letter;
  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = _colorFromSeed(seed);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Hash the seed (userId) into the HSL space so identical users always get
  /// the same colour and different users get visually distinct hues. Saturation
  /// and lightness are kept fixed to stay legible against white text.
  Color _colorFromSeed(String seed) {
    var hash = 0;
    for (final code in seed.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor();
  }
}
