#!/bin/zsh
set -euo pipefail

if [[ $# -ne 1 ]]; then
  print "Usage: Scripts/create_release.sh <version>"
  exit 64
fi

VERSION="$1"
if [[ ! "$VERSION" =~ '^[0-9]+(\.[0-9]+){1,3}$' ]]; then
  print "Version must contain 2 to 4 dot-separated numeric components (for example, 0.3.0)."
  exit 64
fi
VERSION_COMPONENTS=("${(@s:.:)VERSION}")
for COMPONENT in "${VERSION_COMPONENTS[@]}"; do
  if (( ${#COMPONENT} > 18 )) || [[ ${#COMPONENT} -gt 1 && ${COMPONENT[1]} == "0" ]]; then
    print "Version components cannot have leading zeroes and must fit in a signed 64-bit integer."
    exit 64
  fi
done
ROOT_DIR="${0:A:h:h}"
BUILD_DIR="$ROOT_DIR/.build/release"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/Notch Calendar.app"
ARCHIVE_PATH="$DIST_DIR/NotchCalendar-${VERSION}-macos.zip"
DMG_PATH="$DIST_DIR/NotchCalendar-${VERSION}-macos.dmg"
DMG_STAGE_DIR="$DIST_DIR/dmg-stage"
INFO_PLIST="$APP_DIR/Contents/Info.plist"
SIGNING_IDENTITY="${DEVELOPER_ID_APPLICATION:--}"
ALLOW_ADHOC_RELEASE="${ALLOW_ADHOC_RELEASE:-0}"
SOURCE_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/Support/Info.plist")"
SOURCE_BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$ROOT_DIR/Support/Info.plist")"
BUILD_NUMBER="${BUILD_NUMBER:-$SOURCE_BUILD_NUMBER}"
NOTARY_PROFILE="${NOTARYTOOL_PROFILE:-}"
if [[ "$VERSION" != "$SOURCE_VERSION" ]]; then
  print "Release version $VERSION does not match Support/Info.plist version $SOURCE_VERSION."
  exit 64
fi
if [[ ! "$BUILD_NUMBER" =~ '^[0-9]+$' ]]; then
  print "BUILD_NUMBER must contain digits only."
  exit 64
fi
if [[ "$SIGNING_IDENTITY" == "-" && "$ALLOW_ADHOC_RELEASE" != "1" ]]; then
  print "Refusing to create an ad-hoc public release."
  print "Set ALLOW_ADHOC_RELEASE=1 only for a clearly labeled manual-install build."
  exit 78
fi
if [[ "$SIGNING_IDENTITY" != "-" && -z "$NOTARY_PROFILE" ]]; then
  print "NOTARYTOOL_PROFILE is required for a Developer ID release."
  exit 78
fi

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources" "$APP_DIR/Contents/Helpers"
cp "$BUILD_DIR/NotchCalendar" "$APP_DIR/Contents/MacOS/"
cp "$BUILD_DIR/NotchCalendarUpdater" "$APP_DIR/Contents/Helpers/"
cp "$ROOT_DIR/Support/Info.plist" "$INFO_PLIST"
cp "$ROOT_DIR/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$INFO_PLIST"

if [[ "$SIGNING_IDENTITY" == "-" ]]; then
  print "Warning: no Developer ID certificate found; creating an ad-hoc signed development build."
  print "Automatic update installation will stay disabled for this build."
  print "Developer ID signing and notarization prepare future secure distribution;"
  print "automatic replacement remains disabled in 0.2.1."
  codesign --force --sign - --identifier com.codex.notch-calendar.updater \
    "$APP_DIR/Contents/Helpers/NotchCalendarUpdater"
  codesign --force --sign - "$APP_DIR"
else
  codesign --force --sign "$SIGNING_IDENTITY" --options runtime --timestamp \
    --identifier com.codex.notch-calendar.updater \
    "$APP_DIR/Contents/Helpers/NotchCalendarUpdater"
  codesign --force --sign "$SIGNING_IDENTITY" --options runtime --timestamp "$APP_DIR"
fi
codesign --verify --deep --strict --verbose=2 "$APP_DIR"

if [[ "$SIGNING_IDENTITY" != "-" ]]; then
  NOTARY_UPLOAD="$DIST_DIR/.NotchCalendar-notary-upload.zip"
  rm -f "$NOTARY_UPLOAD"
  ditto -c -k --keepParent "$APP_DIR" "$NOTARY_UPLOAD"
  xcrun notarytool submit "$NOTARY_UPLOAD" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$APP_DIR"
  xcrun stapler validate "$APP_DIR"
  rm -f "$NOTARY_UPLOAD"
fi

rm -f "$ARCHIVE_PATH"
ditto -c -k --keepParent "$APP_DIR" "$ARCHIVE_PATH"
rm -f "$DMG_PATH"
rm -rf "$DMG_STAGE_DIR"
mkdir -p "$DMG_STAGE_DIR"
ditto "$APP_DIR" "$DMG_STAGE_DIR/Notch Calendar.app"
ln -s /Applications "$DMG_STAGE_DIR/Applications"
hdiutil create -volname "Notch Calendar $VERSION" -srcfolder "$DMG_STAGE_DIR" -ov -format UDZO "$DMG_PATH"
hdiutil verify "$DMG_PATH"
rm -rf "$DMG_STAGE_DIR"

print "Created $ARCHIVE_PATH"
print "Created $DMG_PATH"
