# Notch Calendar

A native macOS 15+ calendar that lives beside the notch. It shows today’s agenda, a month view, and a live countdown for your next meeting or the one currently in progress.

## Features

- Compact notch view with a live `MM:SS` / `H:MM:SS` meeting countdown.
- Expanded agenda and month calendar on hover.
- Calendar access via EventKit; data stays on the device.
- Optional update checks through GitHub Releases.

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

The included GitHub Actions workflow creates both a macOS DMG installer and ZIP archive, then publishes them as a GitHub Release. It can be triggered by pushing a version tag or manually from the **Actions** tab. The app’s **Check for Updates** button reads that release feed and downloads the latest DMG directly to the Downloads folder when a newer version exists. The DMG includes an Applications shortcut for standard drag-to-install behavior.

Release archives without a signing certificate are ad-hoc signed for local development only. To distribute outside your own Mac, set `DEVELOPER_ID_APPLICATION` to a valid Apple Developer ID Application certificate and notarize the DMG before uploading it. This prevents macOS Gatekeeper from treating the download as untrusted or damaged.

## License

Released under the [MIT License](LICENSE).
