#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Checks that the version is the same everywhere.

  - Another.Plasma6.Coin/metadata.json   -> KPlugin.Version
  - ChangeLog                            -> first line: "Version X.Y - YYYY-MM-DD"
  - Another.Plasma6.Coin/contents/ui/GeneralConfig.qml
                                         -> i18n("X.Y    (YYYY-MM-DD)")

The versions must be equal, and the date of the ChangeLog must be equal to the
date shown in the Configuration window.

Usage: python3 .github/scripts/check_version.py [repository root]
"""
import json
import os
import re
import sys

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
APPLET = os.path.join(ROOT, "Another.Plasma6.Coin")
ON_GITHUB = os.environ.get("GITHUB_ACTIONS") == "true"

problems = 0


def error(message, path=None):
    global problems
    problems += 1
    rel = os.path.relpath(path, ROOT) if path else None
    if ON_GITHUB:
        print(f"::error{' file=' + rel if rel else ''}::{message}")
    else:
        print(f"ERROR: {message}" + (f"  [{rel}]" if rel else ""))


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def main():
    found = {}  # label -> (version, date or None)

    path = os.path.join(APPLET, "metadata.json")
    try:
        version = json.loads(read(path)).get("KPlugin", {}).get("Version")
        if version:
            found["metadata.json"] = (str(version), None)
        else:
            error("KPlugin.Version not found", path)
    except (OSError, ValueError) as e:
        error(f"cannot read metadata.json: {e}", path)

    path = os.path.join(ROOT, "ChangeLog")
    try:
        first = next((l for l in read(path).splitlines() if l.strip()), "")
        m = re.match(r"^Version\s+(\S+)\s+-\s+(\d{4}-\d{2}-\d{2})\s*$", first)
        if m:
            found["ChangeLog"] = (m.group(1), m.group(2))
        else:
            error(f"first line of ChangeLog is not 'Version X.Y - YYYY-MM-DD': {first!r}", path)
    except OSError as e:
        error(f"cannot read ChangeLog: {e}", path)

    path = os.path.join(APPLET, "contents", "ui", "GeneralConfig.qml")
    try:
        m = re.search(r'i18n\(\s*"(\d+(?:\.\d+)+)\s+\((\d{4}-\d{2}-\d{2})\)"\s*\)', read(path))
        if m:
            found["Configuration window"] = (m.group(1), m.group(2))
        else:
            error("version label i18n(\"X.Y    (YYYY-MM-DD)\") not found", path)
    except OSError as e:
        error(f"cannot read GeneralConfig.qml: {e}", path)

    for label, (version, date) in found.items():
        print(f"  {label:22} {version}" + (f"  ({date})" if date else ""))

    if len({v for v, _ in found.values()}) > 1:
        error("the version is not the same in all places: "
              + ", ".join(f"{k}={v}" for k, (v, _) in found.items()))
    dates = {d for _, d in found.values() if d}
    if len(dates) > 1:
        error("the date is not the same in the ChangeLog and in the Configuration window: "
              + ", ".join(sorted(dates)))

    print("Version check:", "FAILED" if problems else "OK")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
