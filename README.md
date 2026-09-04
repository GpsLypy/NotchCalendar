# Notch Calendar

A local-first macOS 15+ personal workspace built around the calendar beside your notch. It combines a glanceable agenda with a full desktop calendar, focus timer, and auto-saved scratchpad.

## Features

- Compact notch view that stays clean when idle, then shows live progress only while a meeting is active.
- Expanded agenda and month calendar on hover.
- A Codex-inspired desktop workspace with a persistent sidebar, Today overview, calendar, focus timer, and scratchpad.
- Three matching desktop widgets for the month calendar, live focus progress, and today's agenda. Control-click the desktop, choose **Edit Widgets**, then search for **Notch Calendar**.
- A full desktop calendar window on launch, restored by clicking the Dock icon after it is closed or minimized.
- Drift-resistant 5, 25, and 50 minute timers that keep their place while you switch tools or the Mac sleeps.
- A local scratchpad with automatic saving, timestamps, and one-click copy.
- In-app language selection for Simplified Chinese, English, or the current system language, applied without restarting.
- One-click Smart Join for Zoom, Google Meet, Microsoft Teams, Webex, Around, and Whereby, plus an Open link action for other structured event URLs.
- Previous and next month navigation with locale-aware weekday ordering.
- Calendar access via EventKit; data stays on the device.
- Automatic update checks at launch, a manual refresh action, structured release notes in Settings, and a green sidebar update shortcut whenever a newer GitHub Release is available.

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

The included GitHub Actions workflow creates both a macOS DMG installer and ZIP archive, then publishes them as a GitHub Release with curated Added, Improved, and Fixed notes from `CHANGELOG.md`. It can be triggered by pushing a version tag or manually from the **Actions** tab. The app checks that release feed automatically at launch, can also refresh it from Settings, displays the release’s structured update notes, selects the exact versioned DMG, and verifies GitHub’s published SHA-256 digest. When an update is available, a green circular-arrow shortcut appears above Settings in the sidebar. The DMG includes an Applications shortcut for standard drag-to-install behavior.

Version 0.3.0 keeps automatic app replacement disabled while retaining the signed-helper and validation foundation for a future crash-recoverable installer. The update screen uses the manual path instead: **Open DMG & Quit** closes the running version before you drag the replacement into Applications. For Developer ID-signed builds, Settings can also verify and open an equal or newer Applications copy when the app is running from a mounted disk image.

Release archives without a signing certificate are ad-hoc signed for local development only. For Developer ID distribution, set `DEVELOPER_ID_APPLICATION` to a valid Apple Developer ID Application certificate and `NOTARYTOOL_PROFILE` to a configured `notarytool` keychain profile before running the release script. This allows the script to enable hardened runtime, notarize the app, and staple the result before packaging it.

## Buy me a coffee / 请作者喝杯咖啡

If Notch Calendar makes your day a little easier, you can support its continued development with a coffee. Thank you for every bit of encouragement.

如果 Notch Calendar 让你的一天轻松了一点，欢迎请作者喝杯咖啡，感谢每一份支持与鼓励。

<p align="center">
  <img src=".github/assets/wechat-pay.jpg" alt="WeChat Pay donation QR code / 微信支付赞助二维码" width="320">
</p>

## License

Released under the [MIT License](LICENSE).
