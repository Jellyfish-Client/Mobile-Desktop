#!/usr/bin/env python3
"""Pre-process the Jellyfin OpenAPI spec before feeding it to dart-dio.

The dart-dio generator chokes on `allOf: [{$ref: X}]` (with optional
description) used as a request/response schema, emitting a parameter of
type `UNKNOWN_BASE_TYPE`. We rewrite those constructs to a plain `$ref`,
which is semantically equivalent and the generator handles correctly.

Usage: patch_spec.py <input.json> <output.json>
"""
from __future__ import annotations

import json
import sys
from typing import Any


def flatten(node: Any) -> Any:
    if isinstance(node, dict):
        # `allOf: [{$ref: X}]` (single-element ref-only allOf, possibly with
        # sibling description/title) → just `{$ref: X}`.
        all_of = node.get("allOf")
        if (
            isinstance(all_of, list)
            and len(all_of) == 1
            and isinstance(all_of[0], dict)
            and "$ref" in all_of[0]
            and len(all_of[0]) == 1
        ):
            return {"$ref": all_of[0]["$ref"]}
        return {k: flatten(v) for k, v in node.items()}
    if isinstance(node, list):
        return [flatten(v) for v in node]
    return node


def main() -> None:
    if len(sys.argv) != 3:
        print("usage: patch_spec.py <input> <output>", file=sys.stderr)
        sys.exit(2)
    src, dst = sys.argv[1], sys.argv[2]
    with open(src) as f:
        spec = json.load(f)
    flattened = flatten(spec)
    with open(dst, "w") as f:
        json.dump(flattened, f, indent=2)
    print(f"==> Wrote patched spec to {dst}")


if __name__ == "__main__":
    main()
