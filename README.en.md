# Notch Calendar

A native macOS notch calendar and personal workspace for events, meetings, notes, focus sessions, and files.

[简体中文](README.md) · [Download](https://github.com/GpsLypy/NotchCalendar/releases/latest) · [Report an issue](https://github.com/GpsLypy/NotchCalendar/issues)

![Calendar workspace](images/calendar.png)

## New in 1.6.1

- Settings uses six top navigation categories, with direct links to update, calendar and meeting preferences.
- Startup and background license checks no longer repeatedly show Keychain password dialogs. Use Retry reading license when authorization is needed.

## Personal workspace

- Offline daily classical Chinese poetry, with saved verses and a collapsible card.
- Encrypted private website bookmarks, protected by system authentication and automatic locking.
- A skippable first-use guide for Calendar, Focus, or saving a poem.
- Optional insight modules that can be hidden from navigation, shortcuts, and quick search.
- Copyable activation requests and prefilled email drafts, plus voluntary author support.

Private bookmarks are excluded from app JSON backups: keep the encrypted file and its Keychain key backed up together. Links open in your default browser and may appear in browser history. See [release notes](RELEASE_NOTES.md).

Requires macOS 15 or later. Supports Apple silicon and Intel Macs. Download the DMG, move the app to Applications, and launch it.

The new licensed distribution is closed source. At first launch, choose a **7-day free trial** or activate a permanent license. A **one-time CNY 9.90 payment** grants perpetual use, with no subscription. Activated users no longer receive automatic payment prompts. Historical MIT releases retain their original terms; check the release notes for the downloaded version.

## Permanent activation

1. Scan the WeChat payment QR code in the launch window or Settings → General → License & trial, and pay CNY 9.90.
2. Send your payment receipt and the installation ID copied from the app to the author.
3. After manually confirming payment, the author sends an activation code. Paste it into the app to activate.

Email: **498988598@qq.com** · Phone: **13191513539**

We usually reply within **24 hours** after receiving a complete payment receipt and installation ID. Replacement codes for a new Mac or reinstallation are free with proof of purchase, with no annual limit, for your own use only. If your code is missing, reply to the same email with your receipt and current installation ID; do not pay again.

![WeChat payment QR code](images/payment.png)

Codes are verified offline and bound to an installation. Contact the author for a replacement when changing Macs or losing the installation's Keychain record. License records are stored in macOS Keychain and excluded from ordinary settings backups.

Calendar access uses EventKit. Notes and focus history remain local. Public feeds and update checks use network access. WeChat handles payment; the app does not automatically confirm payment or access payment accounts.

This repository contains public documentation, required images, and license notices. Installers are distributed through Releases. See [LICENSE](LICENSE) and the [historical MIT notice](THIRD_PARTY_NOTICES.md).
