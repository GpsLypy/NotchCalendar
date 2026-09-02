#!/bin/zsh
set -euo pipefail

if [[ $# -ne 1 ]]; then
  print "Usage: Scripts/create_release.sh <version>"
  exit 64
fi

VERSION="$1"
ROOT_DIR="${0:A:h:h}"
BUILD_DIR="$ROOT_DIR/.build/release"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/Notch Calendar.app"
ARCHIVE_PATH="$DIST_DIR/NotchCalendar-${VERSION}-macos.zip"
DMG_PATH="$DIST_DIR/NotchCalendar-${VERSION}-macos.dmg"
INFO_PLIST="$APP_DIR/Contents/Info.plist"

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BUILD_DIR/NotchCalendar" "$APP_DIR/Contents/MacOS/"
cp "$ROOT_DIR/Support/Info.plist" "$INFO_PLIST"
cp "$ROOT_DIR/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$INFO_PLIST"
codesign --force --sign - "$APP_DIR"

rm -f "$ARCHIVE_PATH"
ditto -c -k --keepParent "$APP_DIR" "$ARCHIVE_PATH"
rm -f "$DMG_PATH"
hdiutil create -volname "Notch Calendar" -srcfolder "$APP_DIR" -ov -format UDZO "$DMG_PATH"

print "Created $ARCHIVE_PATH"
print "Created $DMG_PATH"
