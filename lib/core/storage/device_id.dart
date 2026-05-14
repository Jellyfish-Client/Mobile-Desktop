import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_kv.dart';

const _kDeviceIdKey = 'device_id_v1';

/// Cached, lazily-initialised per-install device id. Generated on first read
/// and persisted via [SecureKv]. Used in the Jellyfin
/// `Authorization: MediaBrowser …` header so the server can identify and
/// track this install in its `Devices` table.
///
/// IMPORTANT: never share or hardcode this id across installs. Doing so
/// triggers Jellyfin issue #16353 (DbUpdateConcurrencyException) because the
/// server races to update the same `Devices` row from multiple clients.
final deviceIdProvider = FutureProvider<String>((ref) async {
  final kv = ref.watch(secureKvProvider);
  final existing = await kv.read(_kDeviceIdKey);
  if (existing != null && existing.isNotEmpty) return existing;

  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  final id = base64Url.encode(bytes).replaceAll('=', '');
  await kv.write(_kDeviceIdKey, id);
  return id;
});
