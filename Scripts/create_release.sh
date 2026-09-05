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
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/Notch Calendar.app"
APP_EXECUTABLE="$APP_DIR/Contents/MacOS/NotchCalendar"
UPDATER_EXECUTABLE="$APP_DIR/Contents/Helpers/NotchCalendarUpdater"
WIDGET_DIR="$APP_DIR/Contents/PlugIns/NotchCalendarWidgets.appex"
WIDGET_EXECUTABLE="$WIDGET_DIR/Contents/MacOS/NotchCalendarWidgets"
ARCHIVE_PATH="$DIST_DIR/NotchCalendar-${VERSION}-macos.zip"
DMG_PATH="$DIST_DIR/NotchCalendar-${VERSION}-macos.dmg"
DMG_STAGE_DIR="$DIST_DIR/dmg-stage"
INFO_PLIST="$APP_DIR/Contents/Info.plist"
WIDGET_INFO_PLIST="$WIDGET_DIR/Contents/Info.plist"
WIDGET_INFO_SOURCE="$ROOT_DIR/Support/NotchCalendarWidgets-Info.plist"
WIDGET_ENTITLEMENTS="$ROOT_DIR/Support/NotchCalendarWidgets.entitlements"
SIGNING_IDENTITY="${DEVELOPER_ID_APPLICATION:--}"
ALLOW_ADHOC_RELEASE="${ALLOW_ADHOC_RELEASE:-0}"
SOURCE_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/Support/Info.plist")"
SOURCE_BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$ROOT_DIR/Support/Info.plist")"
WIDGET_SOURCE_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$WIDGET_INFO_SOURCE")"
WIDGET_SOURCE_BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$WIDGET_INFO_SOURCE")"
BUILD_NUMBER="${BUILD_NUMBER:-$SOURCE_BUILD_NUMBER}"
NOTARY_PROFILE="${NOTARYTOOL_PROFILE:-}"
REQUIRED_ARCHITECTURES=(arm64 x86_64)
SWIFT_BUILD_ARGUMENTS=(-c release)
for ARCHITECTURE in "${REQUIRED_ARCHITECTURES[@]}"; do
  SWIFT_BUILD_ARGUMENTS+=(--arch "$ARCHITECTURE")
done

verify_universal_binary() {
  local executable_path="$1"
  local display_name="$2"
  local required_architecture
  local -a actual_architectures

  if [[ ! -f "$executable_path" ]]; then
    print "$display_name executable is missing at $executable_path."
    exit 65
  fi
  if ! /usr/bin/lipo "$executable_path" -verify_arch "${REQUIRED_ARCHITECTURES[@]}" >/dev/null; then
    print "$display_name is not a universal2 binary."
    /usr/bin/lipo -archs "$executable_path" 2>/dev/null || true
    exit 65
  fi

  actual_architectures=("${(@s: :)$(/usr/bin/lipo -archs "$executable_path")}")
  if (( ${#actual_architectures[@]} != ${#REQUIRED_ARCHITECTURES[@]} )); then
    print "$display_name has unexpected architectures: ${(j:, :)actual_architectures}."
    exit 65
  fi
  for required_architecture in "${REQUIRED_ARCHITECTURES[@]}"; do
    if (( ${actual_architectures[(Ie)$required_architecture]} == 0 )); then
      print "$display_name is missing required architecture $required_architecture."
      exit 65
    fi
  done
  print "$display_name architectures: ${(j:, :)actual_architectures}"
}

if [[ "$VERSION" != "$SOURCE_VERSION" ]]; then
  print "Release version $VERSION does not match Support/Info.plist version $SOURCE_VERSION."
  exit 64
fi
if [[ "$WIDGET_SOURCE_VERSION" != "$SOURCE_VERSION" || "$WIDGET_SOURCE_BUILD_NUMBER" != "$SOURCE_BUILD_NUMBER" ]]; then
  print "Widget version $WIDGET_SOURCE_VERSION ($WIDGET_SOURCE_BUILD_NUMBER) does not match app version $SOURCE_VERSION ($SOURCE_BUILD_NUMBER)."
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
swift build "${SWIFT_BUILD_ARGUMENTS[@]}"
BUILD_DIR="$(swift build "${SWIFT_BUILD_ARGUMENTS[@]}" --show-bin-path)"
if [[ ! -d "$BUILD_DIR" ]]; then
  print "Swift build output directory does not exist: $BUILD_DIR"
  exit 65
fi

rm -rf "$APP_DIR"
mkdir -p \
  "$APP_DIR/Contents/MacOS" \
  "$APP_DIR/Contents/Resources" \
  "$APP_DIR/Contents/Helpers" \
  "$WIDGET_DIR/Contents/MacOS"
cp "$BUILD_DIR/NotchCalendar" "$APP_EXECUTABLE"
cp "$BUILD_DIR/NotchCalendarUpdater" "$UPDATER_EXECUTABLE"
cp "$BUILD_DIR/NotchCalendarWidgets" "$WIDGET_EXECUTABLE"
cp "$ROOT_DIR/Support/Info.plist" "$INFO_PLIST"
cp "$WIDGET_INFO_SOURCE" "$WIDGET_INFO_PLIST"
cp "$ROOT_DIR/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/"
verify_universal_binary "$APP_EXECUTABLE" "Notch Calendar"
verify_universal_binary "$UPDATER_EXECUTABLE" "Notch Calendar Updater"
verify_universal_binary "$WIDGET_EXECUTABLE" "Notch Calendar Widgets"
for ARCHITECTURE in "${REQUIRED_ARCHITECTURES[@]}"; do
  if ! /usr/bin/nm -arch "$ARCHITECTURE" -u "$WIDGET_EXECUTABLE" \
      | /usr/bin/grep '_NSExtensionMain' >/dev/null; then
    print "Widget $ARCHITECTURE slice is missing the macOS app-extension entry point."
    exit 65
  fi
  if ! /usr/bin/nm -arch "$ARCHITECTURE" -g "$WIDGET_EXECUTABLE" \
      | /usr/bin/grep ' _main$' >/dev/null; then
    print "Widget $ARCHITECTURE slice is missing its retained Swift registration entry point."
    exit 65
  fi
  WIDGET_TEXT_VMADDR="$(
    /usr/bin/otool -arch "$ARCHITECTURE" -l "$WIDGET_EXECUTABLE" \
      | /usr/bin/awk '
          $1 == "segname" && $2 == "__TEXT" && !found { in_text = 1; next }
          in_text && $1 == "vmaddr" && !found { print $2; found = 1 }
        '
  )"
  WIDGET_ENTRY_OFFSET="$(
    /usr/bin/otool -arch "$ARCHITECTURE" -l "$WIDGET_EXECUTABLE" \
      | /usr/bin/awk '
          $1 == "cmd" && $2 == "LC_MAIN" && !found { in_main = 1; next }
          in_main && $1 == "entryoff" && !found { print $2; found = 1 }
        '
  )"
  if [[ -z "$WIDGET_TEXT_VMADDR" || -z "$WIDGET_ENTRY_OFFSET" ]]; then
    print "Widget $ARCHITECTURE slice is missing __TEXT or LC_MAIN metadata."
    exit 65
  fi
  WIDGET_ENTRY_ADDRESS="$(printf '0x%016x' $(( WIDGET_TEXT_VMADDR + WIDGET_ENTRY_OFFSET )))"
  WIDGET_ENTRY_SYMBOL="$(
    /usr/bin/otool -arch "$ARCHITECTURE" -Iv "$WIDGET_EXECUTABLE" \
      | /usr/bin/awk -v address="$WIDGET_ENTRY_ADDRESS" '
          tolower($1) == tolower(address) && !found { print $3; found = 1 }
        '
  )"
  if [[ "$WIDGET_ENTRY_SYMBOL" != _NSExtensionMain ]]; then
    print "Widget $ARCHITECTURE LC_MAIN resolves to ${WIDGET_ENTRY_SYMBOL:-unknown}, not _NSExtensionMain."
    exit 65
  fi
done
ditto "$ROOT_DIR/Sources/NotchCalendar/Resources/en.lproj" \
  "$APP_DIR/Contents/Resources/en.lproj"
ditto "$ROOT_DIR/Sources/NotchCalendar/Resources/zh-Hans.lproj" \
  "$APP_DIR/Contents/Resources/zh-Hans.lproj"
python3 "$ROOT_DIR/Scripts/extract_app_intents.py" build "$APP_DIR/Contents/Resources"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$WIDGET_INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$WIDGET_INFO_PLIST"

if [[ "$SIGNING_IDENTITY" == "-" ]]; then
  print "Warning: no Developer ID certificate found; creating an ad-hoc signed development build."
  print "Automatic update installation will stay disabled for this build."
  print "Developer ID signing and notarization prepare future secure distribution;"
  print "automatic replacement remains disabled in this release."
  codesign --force --sign - --entitlements "$WIDGET_ENTITLEMENTS" \
    --identifier com.codex.notch-calendar.widgets "$WIDGET_DIR"
  codesign --force --sign - --identifier com.codex.notch-calendar.updater \
    "$UPDATER_EXECUTABLE"
  codesign --force --sign - "$APP_DIR"
else
  codesign --force --sign "$SIGNING_IDENTITY" --options runtime --timestamp \
    --entitlements "$WIDGET_ENTITLEMENTS" \
    --identifier com.codex.notch-calendar.widgets "$WIDGET_DIR"
  codesign --force --sign "$SIGNING_IDENTITY" --options runtime --timestamp \
    --identifier com.codex.notch-calendar.updater \
    "$UPDATER_EXECUTABLE"
  codesign --force --sign "$SIGNING_IDENTITY" --options runtime --timestamp "$APP_DIR"
fi
codesign --verify --deep --strict --all-architectures --verbose=2 "$APP_DIR"

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
