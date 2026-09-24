# Notch Calendar

Open your calendar, focus timer, files, and scratchpad from the Mac notch. The full workspace offers light and dark appearances with an optional translucent glass material.

[简体中文](README.md) · [Download](https://github.com/GpsLypy/NotchCalendar/releases/latest) · [Report an issue](https://github.com/GpsLypy/NotchCalendar/issues)

### Separate notch-side activity islands

The focus icon and countdown, or meeting title and progress, sit on separate islands beside the camera housing. The centre stays clear instead of becoming one wide black notch.

| Focus timer | Active meeting |
| --- | --- |
| ![Separate focus icon and countdown beside the camera housing](images/compact-focus-islands.png) | ![Separate meeting title and progress beside the camera housing](images/compact-meeting-islands.png) |

Native compact-view captures use isolated demo data; the menu bar and camera housing are composited, not a photo of the display.

![Expanded notch calendar and four activity tabs](images/notch-calendar.png)

## Open from the notch

Hover over or click the top entry for Calendar, Focus, and Scratchpad. Enable the optional file shelf in Settings to add Files; displays without a notch have a centered top entry.

| Calendar | Focus |
| --- | --- |
| ![Expanded notch calendar](images/notch-calendar.png) | ![Expanded notch focus timer](images/notch-focus.png) |
| Files (opt in) | Scratchpad |
| ![Expanded notch file shelf with sample files](images/notch-files.png) | ![Expanded notch scratchpad](images/notch-scratchpad.png) |

## Light, dark, and glass

Set the full workspace to light, dark, or system appearance, with optional translucent glass material. The notch panel remains dark.

| Light workspace | Dark workspace |
| --- | --- |
| ![Light calendar workspace with translucent material selected](images/workspace-light-glass.png) | ![Dark calendar workspace with translucent material selected](images/workspace-dark-glass.png) |

These native SwiftUI offscreen captures use isolated demo events, files, and notes. They do not include a physical notch or desktop background and cannot demonstrate actual desktop refraction.

## Fixed in 1.6.18

- Fix a crash in v1.6.17 when macOS posts the calendar-day change from a background thread. Check-in and meeting wake notifications now enter their main-thread handlers safely.

## New in 1.6.17

- A check-in capsule appears to the left of the notch. Morning (08:00–10:00) and evening (18:00–20:00) reminders appear on launch, wake, or when the running app enters either window. Check-ins remain until completed or removed; click the capsule to reopen a closed reminder.
- Set both time windows in Settings > General > Check-in reminders. The installed app requests launch at login by default; this can be disabled, and macOS may require approval in Login Items.

## New in 1.6.15

- Cancel a running or paused focus session from the notch panel to dismiss its capsule without counting it as completed.
- Click to expand while focus or meeting islands are visible; idle behavior follows your hover or click preference.

## New in 1.6.14

- Compact activities occupy separate islands on either side of the notch; choose light, dark, or glass styling in the full workspace.
- Refined Calendar, Focus, Files, and workspace interactions, with offline poetry and private bookmarks.

## New in 1.6.13

- Calendar updates no longer resize the notch panel in the middle of its opening reveal. Closing or reopening cancels an older height adjustment.
- On short displays, expanded content scrolls vertically; narrow displays can scroll horizontally while keeping the top controls available.
- The following trial, purchase, and data-access features continue from 1.6.12:

- Use the seven-day trial without repeated purchase prompts; a dismissible reminder appears only in the final 48 hours.
- CNY 9.90 buys lifetime use including all future versions, with no subscription. Purchase details and manual code delivery are explained before you choose to reveal the QR code; payment does not activate automatically.
- After expiry, My data remains available for read-only notes, focus history and file locations, ordinary backup export, and separately authenticated private-bookmark export.
- Hide or show the workspace sidebar without losing navigation shortcuts. Optional tips do not purchase a license.

## Personal workspace

- Offline daily classical Chinese poetry, with saved verses and a collapsible card.
- Encrypted private website bookmarks, protected by system authentication and automatic locking.
- An optional guide in Settings for Calendar, Focus, or saving a poem.
- Optional insight modules that can be hidden from navigation, shortcuts, and quick search.
- Copyable activation requests and prefilled email drafts, plus voluntary author support.

Private bookmarks are excluded from ordinary JSON backups. After expiry, export them separately only after system authentication; the resulting file is not encrypted, so store it securely. Keep the encrypted vault and its Keychain key backed up together. Links open in your default browser and may appear in browser history. See [release notes](RELEASE_NOTES.md).

Requires macOS 15 or later. Supports Apple silicon and Intel Macs. Download the DMG, move the app to Applications, and launch it.

The new licensed distribution is closed source. First launch automatically starts a **7-day free trial** without opening a payment window. A **one-time CNY 9.90 payment** grants lifetime use **including all future versions**, with no subscription. After expiry, your local data remains readable and exportable. Activated users no longer receive automatic payment prompts. Historical MIT releases retain their original terms; check the release notes for the downloaded version.

## Permanent activation

1. Open License & trial from the workspace sidebar or Settings, read the manual purchase steps, then reveal the WeChat QR code and pay CNY 9.90.
2. Send your payment receipt and the installation ID copied from the app to the author.
3. The author usually replies within 24 hours after receiving a complete receipt and installation ID. Paste the author-issued code into the app; payment does not activate the app automatically.

Email: **498988598@qq.com** · Phone: **13191513539**

We usually reply within **24 hours** after receiving a complete payment receipt and installation ID. Replacement codes for a new Mac or reinstallation are free with proof of purchase, with no annual limit, for your own use only. If your code is missing, reply to the same email with your receipt and current installation ID; do not pay again.

![WeChat payment QR code for lifetime license; manual activation required](images/payment.png)

Codes are verified offline and bound to an installation. Contact the author for a replacement when changing Macs or losing the installation's Keychain record. License records are stored in macOS Keychain and excluded from ordinary settings backups.

Calendar access uses EventKit. Notes and focus history remain local. Public feeds and update checks use network access. WeChat handles payment; the app does not automatically confirm payment or access payment accounts.

This repository contains public documentation, required images, and license notices. Installers are distributed through Releases. See [LICENSE](LICENSE) and the [historical MIT notice](THIRD_PARTY_NOTICES.md).
