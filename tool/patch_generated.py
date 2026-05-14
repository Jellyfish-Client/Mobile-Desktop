#!/usr/bin/env python3
"""Post-process the openapi-generator dart-dio output for jellyfin_api.

The generator emits broken default initialisers like
    ..messageType = const ._('UserDeleted');
where the enum class qualifier is missing. We infer it from the field type
declared just above (`SessionMessageType? get messageType;`) and rewrite to
    ..messageType = const SessionMessageType._('UserDeleted');
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Optional

PATTERN = re.compile(
    r"\.\.(?P<field>\w+)\s*=\s*const\s*\._\((?P<value>'[^']+')\s*\)"
)


def find_enum_class_owning_value(models_dir: Path, value: str) -> Optional[str]:
    """Find the enum class declaring `static const X y = _$xyValue;` for value."""
    needle = re.compile(
        rf"static const (\w+) \w+\s*=\s*_\$\w+;.*//\s*'{re.escape(value)}'",
        re.MULTILINE,
    )
    # Fallback: search for the constant name pattern derived from value.
    for dart in models_dir.glob("*.dart"):
        text = dart.read_text()
        m = needle.search(text)
        if m:
            return m.group(1)
        # Look for `static const <Class> <name> = _$xValue;` paired with the value
        # appearing as a JSON discriminator string nearby.
        if f"'{value}'" in text:
            class_match = re.search(
                r"abstract class (\w+) implements Built<\1, \1Builder>",
                text,
            )
            if class_match:
                return class_match.group(1)
    return None


def patch_file(path: Path, models_dir: Path) -> int:
    text = path.read_text()
    matches = list(PATTERN.finditer(text))
    if not matches:
        return 0
    new_text = text
    fixed = 0
    for m in matches:
        field = m.group("field")
        value = m.group("value")
        type_name: Optional[str] = None

        type_match = re.search(
            rf"(\w+)\?\s+get\s+{re.escape(field)}\s*;",
            text,
        )
        if type_match:
            type_name = type_match.group(1)
        else:
            # Fallback 1: field name capitalised matches a known enum file.
            candidate = field[0].upper() + field[1:]
            if (models_dir / f"{re.sub(r'(?<!^)(?=[A-Z])', '_', candidate).lower()}.dart").exists():
                type_name = candidate

        if type_name is None:
            print(f"  ! no type for field {field} ({value}) in {path.name}", file=sys.stderr)
            continue

        replacement = f"..{field} = const {type_name}._({value})"
        new_text = new_text.replace(m.group(0), replacement)
        fixed += 1
    if fixed:
        path.write_text(new_text)
    return fixed


def fix_name_clash(models_dir: Path) -> int:
    """Rename `name` enum constants that clash with EnumClass.name getter.

    OpenAPI specs that declare an enum value `Name` cause built_value to emit
    `static const X name = _$name;` which conflicts with the inherited
    `EnumClass.name` getter. We rename the Dart-side constant to `name_`
    everywhere; the JSON wire name (annotated via @BuiltValueEnumConst) is
    untouched.
    """
    # Per-enum surgical renames. The clash is between `EnumClass.name` (an
    # inherited getter) and the generator-emitted `static const X name = _$name;`.
    # We rename the public Dart constant `name` → `name_` AND its private
    # backing `_$name` → `_$<uniqueStem>Name` (unique to avoid export
    # collisions across enum files). Constructors / `valueOf(String name)` /
    # JSON wire string literals are explicitly preserved.
    targets = [
        ("channel_item_sort_field", "ChannelItemSortField"),
        ("item_sort_by", "ItemSortBy"),
        ("metadata_field", "MetadataField"),
    ]
    fixed = 0
    for stem, cls in targets:
        unique_priv = f"_${stem.replace('_', '')}Name"
        for ext in (".dart", ".g.dart"):
            path = models_dir / f"{stem}{ext}"
            if not path.exists():
                continue
            text = path.read_text()
            new_text = text

            # 1. Rename the private constant `_$name` (whole-identifier).
            new_text = re.sub(r"\b_\$name\b", unique_priv, new_text)

            # 2. Rename the public constant `static const <Class> name`.
            new_text = re.sub(
                rf"(static const {cls}\s+)name(\s*=)",
                rf"\1name_\2",
                new_text,
            )

            # 3. Rename the iterable export entry in .g.dart values list:
            #    `_$name` was already done by step 1; nothing else needed.

            # 4. In the .g.dart `_fromWire`/`_toWire` switch maps, the symbol
            #    `_$name` was renamed by step 1; the case-string keys (e.g.
            #    `case 'name':` for valueOf) must NOT be renamed because
            #    `valueOf` is called by Dart with the raw string `'name'`.
            #    But the generator-emitted `_$valueOf(String name)` switch is
            #    over the actual `name` Dart constant identifier — we kept
            #    that as `name` (we only renamed step 2's `static const`).
            #    HOWEVER the .g.dart writes `case 'name':` to look up the
            #    runtime EnumClass.name string, which depends on what was
            #    passed to `super(name)` in the constructor — i.e. the value
            #    as serialized to its EnumClass identifier. The generator
            #    reads the Dart constant identifier, so when we rename the
            #    declaration to `name_`, the runtime EnumClass.name becomes
            #    `'name_'` and the case must match. Update:
            new_text = re.sub(
                r"const " + re.escape(cls) + r" " + re.escape(unique_priv) + r" = const " + re.escape(cls) + r"\._\('name'\)",
                f"const {cls} {unique_priv} = const {cls}._('name_')",
                new_text,
            )
            new_text = re.sub(r"case 'name':", "case 'name_':", new_text)

            # 5. The toWire/fromWire maps in .g.dart map `'name': 'Name'` and
            #    `'Name': 'name'`. The `'name'` key must follow what the
            #    enum's runtime `name` getter returns (i.e. now 'name_').
            new_text = re.sub(
                r"'name': 'Name'",
                "'name_': 'Name'",
                new_text,
            )
            new_text = re.sub(
                r"'Name': 'name'",
                "'Name': 'name_'",
                new_text,
            )

            # 6. References in .g.dart like `object.name` → `object.name_`
            #    when name is preceded by `.` (member access on the enum).
            new_text = re.sub(
                rf"({re.escape(cls)} get )name\b",
                r"\1name_",
                new_text,
            )
            # `object.name` access in toWire uses the renamed constant
            new_text = re.sub(r"object\.name\b", "object.name_", new_text)

            if new_text != text:
                path.write_text(new_text)
                fixed += 1
    return fixed


def main(root: Path) -> None:
    models_dir = root / "packages" / "jellyfin_api" / "lib" / "src" / "model"
    if not models_dir.exists():
        print(f"models dir not found: {models_dir}", file=sys.stderr)
        sys.exit(1)
    total = 0
    for dart in sorted(models_dir.glob("*.dart")):
        total += patch_file(dart, models_dir)
    print(f"==> Patched {total} broken default initialisers")
    name_fixes = fix_name_clash(models_dir)
    print(f"==> Renamed clashing `name` constant in {name_fixes} files")


if __name__ == "__main__":
    repo_root = Path(__file__).resolve().parent.parent
    main(repo_root)
