#!/usr/bin/env python3
"""Package real App Intents metadata from the compiler's release output.

SwiftPM builds the executable, but does not run the app-bundle metadata phase.
Fail the release instead of shipping actions that Shortcuts cannot discover.
"""
import json
from pathlib import Path
import subprocess
import sys

EXPECTED_ACTIONS = {
    "OpenNotchTodayIntent", "StartNotchFocusIntent",
    "AppendNotchScratchpadIntent", "JoinNotchMeetingIntent",
}


def command(*args):
    return subprocess.check_output(args, text=True).strip()


def verify(resources):
    metadata = resources / "Metadata.appintents" / "extract.actionsdata"
    document = json.loads(metadata.read_text())
    actions = set(document.get("actions", {}))
    shortcuts = {item["actionIdentifier"] for item in document.get("autoShortcuts", [])}
    if not EXPECTED_ACTIONS.issubset(actions & shortcuts):
        raise RuntimeError("App Intents metadata must contain all four actions and App Shortcuts.")
    for name in EXPECTED_ACTIONS:
        if document["actions"][name].get("openAppWhenRun") is not True:
            raise RuntimeError(f"{name} must execute in the shared foreground app runtime.")
    for name, expected in {
        "StartNotchFocusIntent": {"minutes", "taskLabel"},
        "AppendNotchScratchpadIntent": {"text"},
    }.items():
        actual = {parameter["name"] for parameter in document["actions"][name].get("parameters", [])}
        if not expected.issubset(actual):
            raise RuntimeError(f"{name} is missing its Shortcuts input parameters.")
    print("Verified four native Shortcuts actions and their parameters.")


def main():
    if len(sys.argv) != 3 or sys.argv[1] not in {"build", "verify"}:
        raise SystemExit("Usage: python3 Scripts/extract_app_intents.py build|verify <app/Contents/Resources>")
    resources = Path(sys.argv[2]).resolve()
    if sys.argv[1] == "verify":
        verify(resources)
        return
    root = Path(__file__).resolve().parent.parent
    objects = root / ".build/apple/Intermediates.noindex/NotchCalendar.build/Release/NotchCalendar.build/Objects-normal/arm64"
    values = sorted(objects.glob("*.swiftconstvalues"))
    if not values or not (objects / "NotchCalendar.SwiftFileList").is_file():
        raise RuntimeError("Missing compiler metadata. Build the universal release with Xcode first.")
    compiled_types = {item["typeName"].split(".")[-1] for path in values for item in json.loads(path.read_text())}
    if not EXPECTED_ACTIONS.issubset(compiled_types):
        raise RuntimeError("The compiler output is missing App Intent types; refusing a stale release.")
    file_list = objects / "NotchCalendar.AppIntentConstValuesFileList"
    file_list.write_text("".join(str(path) + "\n" for path in values))
    processor = Path(command("xcrun", "--find", "appintentsmetadataprocessor"))
    xcode_version = command("xcodebuild", "-version").split("Build version ")[-1].strip()
    resources.mkdir(parents=True, exist_ok=True)
    subprocess.run([
        str(processor), "--output", str(resources),
        "--toolchain-dir", str(processor.parent.parent.parent),
        "--module-name", "NotchCalendar", "--sdk-root", command("xcrun", "--show-sdk-path"),
        "--xcode-version", xcode_version, "--platform-family", "macOS",
        "--deployment-target", "15.0", "--target-triple", "arm64-apple-macos15.0",
        "--source-file-list", str(objects / "NotchCalendar.SwiftFileList"),
        "--swift-const-vals-list", str(file_list),
    ], check=True)
    verify(resources)


if __name__ == "__main__":
    main()
