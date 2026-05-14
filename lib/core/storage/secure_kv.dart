import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../platform/platform_capabilities.dart';

/// String-keyed storage abstraction with a Keychain-backed implementation on
/// mobile and a [SharedPreferences] fallback on desktop.
///
/// On mobile we route to `flutter_secure_storage` (Keychain / EncryptedShared-
/// Preferences). On desktop the Keychain is unusable for unsigned builds
/// (errSecMissingEntitlement / `-34018`) because access requires a Team-ID
/// signature, so we fall back to plain [SharedPreferences] inside the user's
/// macOS / Windows profile directory — already protected by the OS account.
/// Values are kept in clear: the only thing we persist is a random device id
/// and a Jellyfin session token. Both are recoverable by re-logging in, so an
/// at-rest plaintext copy on a trusted machine is the right MVP trade-off.
abstract class SecureKv {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _KeychainKv implements SecureKv {
  _KeychainKv()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class _PrefsKv implements SecureKv {
  static const _prefix = 'secure_kv.';

  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key');
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', value);
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }
}

final secureKvProvider = Provider<SecureKv>((ref) {
  final caps = ref.watch(platformCapabilitiesProvider);
  return caps.isDesktop ? _PrefsKv() : _KeychainKv();
});
