#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Checks that the configuration of the applet is consistent.

Errors (the check fails):
  - metadata.json is not valid JSON or has no KPlugin.Version.
  - contents/config/main.xml is not valid XML, or repeats an entry name.
  - A QML file reads Plasmoid.configuration.<name> and <name> is not in main.xml.
  - The Configuration window has a cfg_<name> and <name> is not in main.xml.
  - A page listed in contents/config/config.qml does not exist.

Warnings (the check does not fail):
  - An entry of main.xml is never read nor edited by any QML file.
  - An entry of main.xml is read by the applet, but the Configuration window
    has no cfg_<name> to change it.

Usage: python3 .github/scripts/check_config.py [repository root]
"""
import collections
import glob
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
APPLET = os.path.join(ROOT, "Another.Plasma6.Coin")
UI = os.path.join(APPLET, "contents", "ui")
ON_GITHUB = os.environ.get("GITHUB_ACTIONS") == "true"

errors = 0


def report(level, message, path=None):
    """Prints a message; on GitHub it becomes an annotation in the pull request."""
    global errors
    if level == "error":
        errors += 1
    rel = os.path.relpath(path, ROOT) if path else None
    if ON_GITHUB:
        print(f"::{level}{' file=' + rel if rel else ''}::{message}")
    else:
        print(f"{level.upper()}: {message}" + (f"  [{rel}]" if rel else ""))


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def strip_comments(text):
    """Removes /* */ and // comments (without touching URLs such as https://...)."""
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    return re.sub(r"(?<![:\\])//.*$", "", text, flags=re.MULTILINE)


def check_metadata():
    path = os.path.join(APPLET, "metadata.json")
    try:
        data = json.loads(read(path))
    except (OSError, ValueError) as e:
        report("error", f"metadata.json is not valid JSON: {e}", path)
        return
    if not data.get("KPlugin", {}).get("Version"):
        report("error", "metadata.json has no KPlugin.Version", path)


def check_main_xml():
    """Returns the list of entry names of main.xml (empty if it cannot be read)."""
    path = os.path.join(APPLET, "contents", "config", "main.xml")
    try:
        tree = ET.parse(path)
    except (OSError, ET.ParseError) as e:
        report("error", f"main.xml is not valid XML: {e}", path)
        return []
    names = [
        el.get("name")
        for el in tree.iter()
        if el.tag.rsplit("}", 1)[-1] == "entry" and el.get("name")
    ]
    for name, count in collections.Counter(names).items():
        if count > 1:
            report("error", f"entry '{name}' is repeated in main.xml", path)
    return names


def check_config_pages():
    path = os.path.join(APPLET, "contents", "config", "config.qml")
    try:
        text = strip_comments(read(path))
    except OSError as e:
        report("error", f"config.qml cannot be read: {e}", path)
        return
    for page in re.findall(r'\bsource\s*:\s*"([^"]+)"', text):
        if not os.path.isfile(os.path.join(UI, page)):
            report("error", f"page '{page}' listed in config.qml does not exist in contents/ui", path)


def main():
    check_metadata()
    entries = check_main_xml()
    check_config_pages()

    qml_files = sorted(glob.glob(os.path.join(APPLET, "contents", "**", "*.qml"), recursive=True))
    used = collections.defaultdict(set)  # name -> files that read Plasmoid.configuration.<name>
    ui_fields = collections.defaultdict(set)  # name -> files that declare cfg_<name>
    for path in qml_files:
        text = strip_comments(read(path))
        for name in re.findall(r"\b[Pp]lasmoid\.configuration\.([A-Za-z_]\w*)", text):
            used[name].add(path)
        for name in re.findall(r"\bproperty\s+\w+\s+cfg_([A-Za-z_]\w*)\s*:", text):
            if not name.endswith("Default"):
                ui_fields[name].add(path)

    known = set(entries)
    for name in sorted(used):
        if name not in known:
            for path in sorted(used[name]):
                report("error", f"Plasmoid.configuration.{name} is read, but '{name}' is not in main.xml", path)
    for name in sorted(ui_fields):
        if name not in known:
            for path in sorted(ui_fields[name]):
                report("error", f"cfg_{name} is declared, but '{name}' is not in main.xml", path)
    for name in sorted(known):
        if name not in used and name not in ui_fields:
            report("warning", f"entry '{name}' of main.xml is not used by any QML file")
        elif name not in ui_fields:
            report("warning", f"entry '{name}' of main.xml has no cfg_{name} in the Configuration window")

    print(f"Checked {len(entries)} entries of main.xml and {len(qml_files)} QML files: "
          f"{'FAILED' if errors else 'OK'}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
