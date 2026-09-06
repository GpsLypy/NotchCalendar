#!/usr/bin/env python3
"""Build an isolated ad-hoc app; the probe is compiled out of normal releases."""
import os
import json
import hashlib
from fingerprint import source_fingerprint
from pathlib import Path
import plistlib
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]

def build(source=ROOT, scratch=None):
    scratch = scratch or ROOT / ".build/quality-app"
    env = dict(os.environ, DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer")
    subprocess.run(["swift", "build", "-c", "release", "--product", "NotchCalendar", "--scratch-path", str(scratch),
                    "-Xswiftc", "-DNOTCH_QUALITY_PROBE"], cwd=source, env=env, check=True)
    binary_dir = scratch / "arm64-apple-macosx/release"
    app = scratch / "Notch Quality.app"
    contents = app / "Contents"
    (contents / "MacOS").mkdir(parents=True, exist_ok=True)
    (contents / "Resources").mkdir(exist_ok=True)
    shutil.copy2(binary_dir / "NotchCalendar", contents / "MacOS/NotchCalendar")
    for bundle in binary_dir.glob("*.bundle"):
        shutil.copytree(bundle, contents / "Resources" / bundle.name, dirs_exist_ok=True)
    info = plistlib.loads((source / "Support/Info.plist").read_bytes())
    info.update(CFBundleIdentifier="com.codex.notch-calendar.quality", CFBundleName="Notch Quality",
                CFBundleDisplayName="Notch Quality", LSUIElement=True)
    (contents / "Info.plist").write_bytes(plistlib.dumps(info))
    subprocess.run(["codesign", "--force", "--sign", "-", str(app)], check=True)
    (scratch / "build.json").write_text(json.dumps({"source_fingerprint": source_fingerprint(source),
        "binary_sha256": hashlib.sha256((contents / "MacOS/NotchCalendar").read_bytes()).hexdigest(),
        "configuration": "release", "probe": True}, indent=2) + "\n")
    print(app)
    return app

if __name__ == "__main__":
    build()
