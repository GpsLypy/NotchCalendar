# Notch Calendar

A native macOS 15+ calendar that lives beside the notch. It shows today’s agenda, a browsable month view, and a live countdown for your next meeting or the one currently in progress.

## Features

- Compact notch view with a live `MM:SS` / `H:MM:SS` meeting countdown.
- Expanded agenda and month calendar on hover.
- A full desktop calendar window on launch, restored by clicking the Dock icon after it is closed or minimized.
- One-click Smart Join for Zoom, Google Meet, Microsoft Teams, Webex, Around, and Whereby, plus an Open link action for other structured event URLs.
- Previous and next month navigation with locale-aware weekday ordering.
- Calendar access via EventKit; data stays on the device.
- Optional update checks through GitHub Releases.

Smart Join resolves the event’s structured URL first, then looks for known conferencing domains in its location and notes. Link detection happens locally, and ordinary links in free-form text are ignored to reduce accidental opens.

## Run from source

Open the folder in Xcode and run the `NotchCalendar` executable scheme, or run:

```sh
swift run
```

On first launch, allow Calendar access in the system prompt. The app falls back to the top-centre position on displays without a camera housing.

## Publish on GitHub

1. Create a GitHub repository and push this project to it.
2. If you fork the project, replace `GpsLypy/NotchCalendar` in `Support/Info.plist` with the fork’s `owner/name` value.
3. Create and push a version tag, for example `v0.1.3`.

The included GitHub Actions workflow creates both a macOS DMG installer and ZIP archive, then publishes them as a GitHub Release. It can be triggered by pushing a version tag or manually from the **Actions** tab. The app’s **Check for Updates** button reads that release feed, selects the exact versioned DMG, and verifies GitHub’s published SHA-256 digest. The DMG includes an Applications shortcut for standard drag-to-install behavior.

Version 0.2.2 keeps automatic app replacement disabled while retaining the signed-helper and validation foundation for a future crash-recoverable installer. The update screen uses the manual path instead: **Open DMG & Quit** closes the running version before you drag the replacement into Applications. For Developer ID-signed builds, Settings can also verify and open an equal or newer Applications copy when the app is running from a mounted disk image.

Release archives without a signing certificate are ad-hoc signed for local development only. For Developer ID distribution, set `DEVELOPER_ID_APPLICATION` to a valid Apple Developer ID Application certificate and `NOTARYTOOL_PROFILE` to a configured `notarytool` keychain profile before running the release script. This allows the script to enable hardened runtime, notarize the app, and staple the result before packaging it.

## License

Released under the [MIT License](LICENSE).
