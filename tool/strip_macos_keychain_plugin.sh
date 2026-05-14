#!/usr/bin/env bash
# Drops flutter_secure_storage_macos from the macOS plugin registrar so
# the Keychain is never solicited on desktop (we route to SharedPreferences
# via `lib/core/storage/secure_kv.dart`). Re-run after every `flutter pub get`
# because Flutter regenerates GeneratedPluginRegistrant.swift.
set -euo pipefail

FILE="$(cd "$(dirname "$0")/.." && pwd)/macos/Flutter/GeneratedPluginRegistrant.swift"
[[ -f "$FILE" ]] || { echo "Missing $FILE — run flutter pub get first." >&2; exit 1; }

# Remove the import line and the register line, in place.
/usr/bin/sed -i '' \
  -e '/^import flutter_secure_storage_macos$/d' \
  -e '/^  FlutterSecureStoragePlugin\.register(/d' \
  "$FILE"

echo "Stripped flutter_secure_storage_macos from $FILE"
