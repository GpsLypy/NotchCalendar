"""Stable fingerprint of runtime code/resources and build configuration."""
import hashlib
import plistlib
from pathlib import Path


def source_fingerprint(root: Path) -> str:
    paths = [root / "Package.swift"]
    for folder in ["Sources", "Support"]:
        paths.extend(p for p in (root / folder).rglob("*") if p.is_file() and p.name != ".DS_Store")
    digest = hashlib.sha256()
    for path in sorted(paths):
        digest.update(path.relative_to(root).as_posix().encode() + b"\0")
        data = path.read_bytes()
        # Release labels are verified separately against the packaged app/widget.
        # Bumping a label must not invalidate otherwise identical runtime code.
        if path.relative_to(root).as_posix() in ["Support/Info.plist", "Support/NotchCalendarWidgets-Info.plist"]:
            info = plistlib.loads(data)
            info.pop("CFBundleShortVersionString", None)
            info.pop("CFBundleVersion", None)
            data = plistlib.dumps(info, sort_keys=True)
        digest.update(data)
        digest.update(b"\0")
    return digest.hexdigest()
