#!/usr/bin/env bash
# Generate Dart clients for Jellyfin (and optionally Seerr) from their
# OpenAPI specs.
#
# Usage:
#   ./tool/generate_apis.sh                     # use default upstream specs
#   JELLYFIN_SPEC=path/to/spec.json ./tool/...  # override Jellyfin spec
#   SEERR_SPEC=path/to/spec.json ./tool/...     # override Seerr spec
#
# NOTE: The upstream project rebranded from "Jellyseerr" to "Seerr"
# (seerr-team/seerr, spec title "Seerr API"). SEERR_SPEC is the canonical
# env var going forward; JELLYSEERR_SPEC is accepted as a deprecated fallback.
#
# Requires: Java (for openapi-generator) + npx (Node 18+).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$ROOT/.openapi"
mkdir -p "$TMP"

JELLYFIN_SPEC="${JELLYFIN_SPEC:-https://api.jellyfin.org/openapi/jellyfin-openapi-stable.json}"
# SEERR_SPEC wins over the deprecated JELLYSEERR_SPEC fallback.
SEERR_SPEC="${SEERR_SPEC:-${JELLYSEERR_SPEC:-}}"

# Download + patch the Jellyfin spec (flatten allOf-ref wrappers that confuse
# dart-dio). Result lands in $TMP/jellyfin-patched.json.
RAW_SPEC="$TMP/jellyfin.json"
PATCHED_SPEC="$TMP/jellyfin-patched.json"
if [[ "$JELLYFIN_SPEC" =~ ^https?:// ]]; then
  echo "==> Fetching $JELLYFIN_SPEC"
  curl -fSL "$JELLYFIN_SPEC" -o "$RAW_SPEC"
else
  cp "$JELLYFIN_SPEC" "$RAW_SPEC"
fi
python3 "$ROOT/tool/patch_spec.py" "$RAW_SPEC" "$PATCHED_SPEC"
JELLYFIN_SPEC="$PATCHED_SPEC"

OPENAPI_GENERATOR_VERSION="${OPENAPI_GENERATOR_VERSION:-7.0.1}"

generate() {
  local name="$1"
  local spec="$2"
  local out="$ROOT/packages/$name"

  echo "==> Generating $name from $spec"
  rm -rf "$out"
  mkdir -p "$out"

  npx --yes "@openapitools/openapi-generator-cli@2.13.4" \
    version-manager set "$OPENAPI_GENERATOR_VERSION" >/dev/null

  npx --yes "@openapitools/openapi-generator-cli@2.13.4" generate \
    -i "$spec" \
    -g dart-dio \
    -o "$out" \
    --additional-properties="pubName=$name,pubAuthor=Jellyfish,pubVersion=0.1.0,nullableFields=true"
}

generate "jellyfin_api" "$JELLYFIN_SPEC"

# Fix broken `const ._('value')` initialisers emitted by the generator.
python3 "$ROOT/tool/patch_generated.py"

if [[ -n "$SEERR_SPEC" ]]; then
  generate "jellyseerr_api" "$SEERR_SPEC"
else
  echo "==> Skipping jellyseerr_api: set SEERR_SPEC=<url|path> to generate."
fi

echo "==> Bumping generated package SDK constraints to '^3.11.0'"
for pkg in jellyfin_api jellyseerr_api; do
  ps="$ROOT/packages/$pkg/pubspec.yaml"
  if [[ -f "$ps" ]]; then
    sed -i '' "s|sdk: '>=2.15.0 <4.0.0'|sdk: '^3.11.0'|" "$ps" || true
  fi
done

echo "==> pub get + build_runner inside the generated package(s)"
for pkg in jellyfin_api jellyseerr_api; do
  if [[ -d "$ROOT/packages/$pkg" ]]; then
    (
      cd "$ROOT/packages/$pkg"
      dart pub get
      dart run build_runner build --delete-conflicting-outputs
    )
  fi
done

echo "==> Done. Run 'flutter pub get' at the repo root to wire the packages."
