# Notch Calendar

Open your calendar, focus timer, music controls, calculator, files, scratchpad, clipboard history, AI chat, markets, news, translation and AirDrop from the Mac notch. The full workspace offers light and dark appearances with an optional translucent glass material.

[简体中文](README.md) · [Download 2.0.14](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.14) · [Report an issue](https://github.com/GpsLypy/NotchCalendar/issues)

## 2.0.14: Display choice, window resizing and companion gestures

- Choose Automatic, Built-in or External in Settings → General → Notch display.
- On a display without a physical notch, Classic mode keeps the date and time at the top and opens its content in a separate rounded card.
- Reopening restores the last selected tab. Drag either side, the bottom edge or a lower corner to resize and save the window size while preserving editor content and web drafts.
- Rest the companion to the left of the notch. Pointer entry makes it fall and return; double-click to run along the lower edge to the right and back. Single-click still pets it. Enable the optional companion in settings; Reduce Motion is respected.

Frozen-source targeted regression: 265 cases, 264 passed, 1 optional check skipped, zero failures; 21 Python quality checks and universal package validation passed.

Native window events, actual display coordinates and simulated geometry cover display selection, resizing and companion paths. Manual pointer use, VoiceOver, display hotplug/lid close, real sleep/wake, live AI services and stationary CPU/energy remain pending. This is not a full-app regression or strict hardware-gate pass.

macOS 15+, Apple silicon and Intel, build 97. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Keeping local app data preserves existing licenses and Chat API keys.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/NotchCalendar-2.0.14-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/NotchCalendar-2.0.14-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/SHA256SUMS.txt)

## 2.0.13: A little companion beside the notch

- Add an optional Notch companion in Settings → General → Notch companion. Enable it to choose one cream cat or apricot puppy.
- Peek, stroll from left to right and back, click to pet, or settle into a static nap. Secondary click for actions or hide; settings offer Hide for now / Come back and equivalent action buttons.
- Name each animal separately and choose Quiet or Playful. Store the animal, names, personality and automatic activity choice locally, including backup and restore.
- Turn automatic activity off completely. Quiet companions act about every 8–15 minutes and playful companions every 5–10 minutes; animation updates stop at rest.
- Respect Reduce Motion with static expressions and pause automatic activity in Low Power Mode. Yield to notch expansion/collapse, meetings, and music/focus status.
- Scarves, bows and further companion moments are planned for later versions.

Final prepublication targeted regression: 189 cases, 188 passed, 1 optional check skipped, zero failures; 21 Python quality checks and universal package validation passed.

Native automation checks this Mac’s actual notch geometry, window travel, petting without opening Calendar, and expansion/collapse handoff. External-display coordinates, reduced motion, low power and suspension also use injected states or geometry tests. Human menu-bar interactions, VoiceOver speech, physical display hotplug, real sleep/wake, complete full-screen/sharing scenarios and stationary CPU/energy remain pending. No full-app or strict hardware-gate pass is claimed.

macOS 15+, Apple silicon and Intel, build 96. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Keeping local app data preserves existing licenses and Chat API keys.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/NotchCalendar-2.0.13-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/NotchCalendar-2.0.13-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/SHA256SUMS.txt)

## 2.0.12: More room for replies

- Use your DeepSeek website account in AI Chat without an API key; retain the existing API mode and its separate draft and images.
- Fold the website composer into a small “Continue typing” button after a send clears the input, giving replies more room. Click to restore and focus it. IME composition, Shift+Enter and unsent drafts stay expanded.
- Default the notch website to 75% zoom, with 75%, 85%, 100% and 125% choices. Move the same live page between the notch and a separate window while retaining its session and draft.
- Fix translation waiting indefinitely with installed language packs. Default to English → Simplified Chinese, with repeat translation, cancellation and timeout recovery.
- Slow the notch opening motion while retaining continuous closing, quick reversals and native editing state.

Prepublication targeted regression: 182 cases, 180 passed, 2 optional checks skipped, zero failures; 21 Python quality checks and universal package validation passed.

DeepSeek folding, drafts and window transfer were checked with local WebKit pages; authenticated sends, uploads and compatibility with website updates remain unverified. The translation fix has separate local English-to-Chinese acceptance evidence; this run checks system translation only when its language packs are available. macOS 15 hardware, initial downloads and other pairs remain unverified. Physical notches, external displays, sleep/wake, VoiceOver and stationary energy acceptance remain pending; no full-app or strict hardware-gate pass is claimed.

macOS 15+, Apple silicon and Intel, build 95. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Keeping local app data preserves existing licenses and Chat API keys.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/NotchCalendar-2.0.12-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/NotchCalendar-2.0.12-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/SHA256SUMS.txt)

## 2.0.11: Translate, AirDrop and hover switching

- Add Translate (⌥⌘T) with language detection, language selection, swap and copy, plus local image-text recognition through import, paste or drop. Use side-by-side panes in wider windows and stacked panes in narrow windows; retain drafts across tools. Uses macOS Translation and Vision without an API key; the system may need to download language packs.
- Add AirDrop (⇧⌘R): stage up to 50 local files or folders, then choose a recipient in the macOS system window. Remove or clear references and retry after closing the chooser without moving or deleting source files.
- Switch tools after the pointer rests on an icon for about 160 ms, using fixed-width targets. Disable this in Settings → General → Notch toolbar if preferred. Clicks and existing ⌘1–0 shortcuts remain available; system menus and file/sharing dialogs pause hover switching.
- Combine Radar, Discussion Room and Briefing into News (⌘5), with Latest / Popular / Saved, source, language, unread and search filters. Retain saved items, reading state, notes and stances; legacy routes select the corresponding section. Markets remains separate (⌘6).
- Fix hydration and stretch reminders restarting their full interval on repeated screen-parameter changes; reposition visible reminders while retaining due times.
- Combine Classic top navigation and window actions into one row, removing the duplicate title and adding 38 points of content height while retaining window dimensions and native editing state.

Universal build, complete local ZIP/DMG content checks, 3 focused desktop tests and 21 Python quality tests completed successfully. Remaining regression was stopped at the publisher’s request for direct release. The complete selected regression and physical-device acceptance are incomplete; no full-suite pass is claimed.

Translation language packs are not installed on this Mac, so actual translated output and the first-download flow are unverified; layout screenshots use fixture translations. Real image-text recognition and cancellation recovery in the system AirDrop chooser were checked; no cross-device file transfer was attempted. News checks use isolated data. Complete publisher/HN network sessions, physical notches, external displays, sleep/wake, real VoiceOver and stationary CPU/energy remain pending. An existing system WritingToolsUI publishing diagnostic remains unresolved; tested input, save, reopen and navigation passed.

macOS 15+, Apple silicon and Intel, build 94. Ad-hoc signed for manual installation, without Developer ID signing or Apple notarization; automatic application replacement remains disabled. Quit the old app, replace it in Applications using the DMG, and relaunch. Updating does not restart the trial; keeping local app data preserves existing licenses and Chat API keys.

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/NotchCalendar-2.0.11-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/NotchCalendar-2.0.11-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/SHA256SUMS.txt)

## 2.0.10: Market and news glances in the notch

- Add Markets (⌘9) and News (⌘0) to the notch toolbar while retaining ⌘1–⌘8, the shared window size and top/bottom placement. More Tools holds entries when space is limited; optional tools can still be hidden in Settings.
- View prices, changes and source timestamps for the SSE Composite, SZSE Component, ChiNext, CSI 300 and STAR 50, plus up to eight Shanghai/Shenzhen A-share watchlist entries. Manage the watchlist in the full workspace; existing US-market Alpha Vantage settings and quota remain available.
- Draw intraday lines from the minute points returned by the source. The full workspace includes volume bars; turning off its intraday chart hides both the line and bars. The notch mini-chart has its own toggle, and available quotes remain visible when intraday data is missing.
- Use Eastmoney industry classifications for gainers and losers, excluding concept sectors. When the industry source is unavailable, show its status and retain available cached data while quotes update independently.
- News shows up to three headlines with Unread / Latest / Saved filters. Share content language, reading state and saved headlines with the full Briefing page. Local reading filters preserve its search, reading filter and source selection; changing the shared content language still clears an incompatible source under the existing rules. View all opens the complete reading workspace.
- Retain Radar, Markets, Discussion Room and Briefing as four workspace modules with their existing sidebar preferences. The new notch entries support brief checks; full reading and management remain in the main window.

Tencent quotes and intraday data passed this round's actual application network-transport and production-parser checks. Industry requests timed out or returned empty responses, so successful live industry access is not established. Load on entry, instrument changes or manual refresh, without background polling. Public endpoints do not guarantee real-time data or continued availability; the interface shows source times, cached state and errors.

Prepublication validation ran 232 targeted cases serially in separate processes: 226 passed, 6 optional checks skipped, zero failures. All 21 Python quality checks passed. Universal packages passed executable-content, strict-signature, App Intents metadata and complete ZIP/DMG content checks. Four initial native-fixture failures were corrected, then the complete selected set passed again; this is not a full-app regression. Physical notches, external displays, sleep/wake, real VoiceOver and complete stationary CPU/energy acceptance remain pending. macOS 15+, Apple silicon and Intel, build 93; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. Automatic application replacement remains disabled. [2.0.10 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.10).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/NotchCalendar-2.0.10-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/NotchCalendar-2.0.10-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/SHA256SUMS.txt)

## 2.0.9: Arrange files and navigation your way

- Files opens in a split layout by default, with a list option in Settings → Data & Files. Switching layouts preserves the current folder, selected file and scroll position.
- Choose a top or bottom dock in Settings → General → Notch toolbar. Bottom remains the default; changing its position preserves content space and native editing state.
- Choose which optional tools appear in the dock. Calendar always remains available. Hiding an entry keeps its data and ongoing Focus, Music and Chat activity; hiding the current tool returns to Calendar, and showing it again restores access.
- Add SSPai and ITHome RSS feeds to Briefing, with All / Chinese / English filtering and original headlines, dates and links. Language filtering applies before the 20-headline display limit.

Prepublication validation ran 218 targeted cases serially in separate processes: 216 passed, two optional live-network/Finder integration checks skipped, zero failures. All 21 Python quality checks and the local Release product build passed, with separate live downloads and production-parser checks for the Chinese feeds. This is not a full-app regression; physical-device and complete real-service acceptance remain pending. macOS 15+, Apple silicon and Intel, build 92; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. [2.0.9 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.9).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/NotchCalendar-2.0.9-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/NotchCalendar-2.0.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/SHA256SUMS.txt)

## 2.0.8: A steadier window, smoother tool changes

- All eight tools share the Calendar window size. Switching tools keeps the outer frame and navigation in place; the overall size remains adjustable in Settings.
- A smaller, lighter capsule dock sits close to the bottom edge with less unused space. The selected tool keeps its name and color, with ⌘1–⌘8 shortcuts.
- Improve the “More in the next 7 days” layout and the “View all” click target. Scroll longer agendas, keep ongoing events in the complete seven-day list, and return to the month.
- Refine content and navigation transitions while preserving notes, text input, selection and page state. Keep Focus weekdays, Music progress and bottom controls fully visible.
- Present the welcome after Calendar authorization resolves. Resume unfinished startup when the app becomes active or the display becomes available. Remember completion for each installed release; completing or skipping it prevents replay on ordinary restarts.

Targeted validation: 223 cases, 222 passed, one optional Finder integration skip, zero failures; all 21 Python quality checks passed. macOS 15+, Apple silicon and Intel, build 91; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. [2.0.8 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.8).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/NotchCalendar-2.0.8-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/NotchCalendar-2.0.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/SHA256SUMS.txt)

## 2.0.7: A notch that fits each tool

- The panel adapts to the active tool: Scratchpad and Focus stay compact, while Calendar, Chat and Calculator keep the space they need. All eight tools share a bottom capsule dock, with a label for the current tool and ⌘1–⌘8 shortcuts.
- Opening, closing and changing tools coordinate the panel shape, content and navigation. Reentering during an animation continues smoothly. Native text input, selection, undo and page state stay intact, with support for Reduce Motion.
- Store permanent licenses in local app data while preserving the original installation ID and activation code. After migration, restarting no longer reads the licensing Keychain. If macOS blocks the initial migration, choose Retry reading license to allow access once. Trial records and the seven-day limit remain unchanged.
- Open Software Update in an independent window even after trial expiry or a license read failure. Clear an old reminder when the latest successful check finds no update, and use the latest details when a newer version is available.
- Retain the local Chat API key storage introduced in 2.0.6, with reinforced regression checks for persistence, legacy migration recovery, removal and provider isolation.

macOS 15+, Apple silicon and Intel, build 90; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. [2.0.7 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.7).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/NotchCalendar-2.0.7-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/NotchCalendar-2.0.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/SHA256SUMS.txt)

## 2.0.6: Calendar authorization before the welcome

- Store AI Chat API keys in local app data so replacing or reinstalling the app with that data retained keeps them available without repeated Keychain authorization. Silently migrate readable legacy keys; blocked legacy keys need one explicit Save. Keep providers separate and respect key removal; ordinary note backups exclude credentials.
- Resolve Calendar access, present the notch introduction, then enter the workspace. Allow, deny and errors all continue; determined authorization never triggers another initial prompt.
- Re-offer the corrected introduction once on upgrade, then respect explicit completion on later restarts.
- Preserve startup progress and queued destinations during Dock reopens, widget links and screen changes.

macOS 15+, Apple silicon and Intel, build 89; ad-hoc signed for manual installation. [2.0.6 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.6).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/NotchCalendar-2.0.6-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/NotchCalendar-2.0.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/SHA256SUMS.txt)

## 2.0.5: Smoother notch retraction

- Fix the empty shell and wide black bar before the compact islands appear. The card and content fade together, with the compact view retained throughout.
- Keep retraction continuous and reversible. Fix classic-style island clipping while preserving drafts, selection and undo history.
- All 33 targeted animation checks and native compositor inspection passed. Full Swift regression: 822 tests, 790 passed, 32 conditional or environment skips, zero failures; all 21 Python quality checks passed. Physical hover, external displays, sleep/wake and stationary performance remain pending complete acceptance.

macOS 15+, Apple silicon and Intel, build 88; ad-hoc signed for manual installation. [2.0.5 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.5).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/NotchCalendar-2.0.5-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/NotchCalendar-2.0.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/SHA256SUMS.txt)

## 2.0.4: Say hello before getting started

- Fix system reopen events skipping the welcome and requesting calendar access too early. Reopening the app during the introduction brings it forward; calendar access is requested, if needed, only after choosing Skip, Get started or customization.
- Show the corrected welcome once when upgrading from 2.0.3. After an explicit completion, ordinary launches stay quiet.
- Remove the extra 30 pt click targets on each side of the idle, collapsed notch so clicks pass through to the menu bar. By default, the notch expands after the pointer settles nearby; existing activity indicators remain.
- Shorten automatic progression through the first four steps from about 21 seconds to about 14 seconds. The final greeting still waits for you to continue; pause, navigation and replay remain available.
- Reveal welcome headings and introductory text character by character with a typewriter effect. Reduce Motion and VoiceOver show the full text immediately.
- Align the AI Chat placeholder with the text cursor, and prevent the configuration button’s focus indicator and error messages from being clipped or squeezed.

macOS 15+, Apple silicon and Intel, build 87; ad-hoc signed, manual installation. [2.0.4 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.4).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/NotchCalendar-2.0.4-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/NotchCalendar-2.0.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/SHA256SUMS.txt)

## 2.0.3: A welcome from your notch

Starting in 2.0.6, new and upgrading users resolve Calendar authorization before the brief, skippable introduction, then enter the workspace. The default appearance now combines the classic notch, glass panel and translucent workspace; saved choices stay intact. Replay the welcome from Settings or the Window menu.

Includes daily update reminders with release notes and hydration, stretch and end-of-day care reminders. Core checks and universal package verification precede publication; detailed regression continues afterward. macOS 15+, Apple silicon and Intel, build 86; ad-hoc signed, manual installation. [2.0.3 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.3).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/NotchCalendar-2.0.3-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/NotchCalendar-2.0.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/SHA256SUMS.txt)

## 2.0.2: Refine the details you use every day

- Give notch navigation a subtle grouped surface and selected border, with keyboard shortcuts in tooltips.
- Make hover, press and keyboard feedback consistent across dates, month controls, agenda items and meeting notes. Label the notes button in narrow cards for easier recognition and clicking.
- Show overnight events compactly as “23:30 – Next day 00:15” in the displayed time zone. Longer events retain an absolute end date.
- Use short weekday names in the smallest notch calendar to prevent English truncation, while retaining the full spoken weekday for accessibility.

Version 2.0.2 (build 85, 2026-10-15) supports macOS 15+, Apple silicon and Intel. Full Swift regression: 625 tests, 604 passed, 21 conditional skips, zero failures; all 21 Python quality checks passed. Ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. Physical-device, stationary-performance and complete live integration acceptance remain pending. See the [2.0.2 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.2).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/NotchCalendar-2.0.2-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/NotchCalendar-2.0.2-macos.zip) · [SHA-256 checksums](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/SHA256SUMS.txt)

## 2.0.1: Keep chatting after saving your key

- Fix repeated Keychain authorization errors when sending after settings were successfully saved. Your API key remains stored in this Mac's Keychain; the current app session reuses the key after it has been read and verified.
- Startup reads remain silent. If a key has not yet been obtained, the first Send or Retry permits macOS to request access. Cancelling authorization keeps your draft and image attachments ready to send again.
- Credentials stay separate for each service. Removing or replacing a key invalidates its old session cache, and switching services never reuses the previous service's key.
- Keep the light/dark surfaces, sidebar, cards and notch motion introduced in 2.0.

Version 2.0.1 (build 84, 2026-10-15) supports macOS 15+, Apple silicon and Intel, with ad-hoc signing and manual installation, without Developer ID signing or Apple notarization. Upgraded-user Keychain authorization dialogs and live model integration remain pending acceptance. See the [2.0.1 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.1).

[Download DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/NotchCalendar-2.0.1-macos.dmg) · [Download ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/NotchCalendar-2.0.1-macos.zip) · [SHA-256 checksums](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/SHA256SUMS.txt)

## 2.0.0: Save feedback and a visual update

- Fix Keychain authorization during Chat settings Save. Verify the stored key before committing settings; retain failed input with recovery steps and an error code, and confirm success in Chat.
- Refine light/dark surfaces, sidebar selection, native settings segments, cards and button feedback, with blue actions and coral dates.
- Reveal the notch in 280 ms and retract in 210 ms while preserving scroll positions and respecting Reduce Motion. Keep image chat, pointer-exit retraction and conversation cleanup.

Version 2.0.0 (build 83, 2026-10-15) supports macOS 15+, Apple silicon and Intel, with ad-hoc signing and manual installation. Full regression executed 611 Swift tests: 584 passed, 27 optional/environment skips, zero failures. All 21 Python quality checks passed. See the [2.0.0 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.0).

## 1.8.9: Image chat, pointer-exit retraction and conversation cleanup

- Paste screenshots, images and local image files into Chat, with previews, image-only sending and retry. Use a model that supports images.
- Chat, clipboard history and scratchpad retract on pointer exit in hover mode and retain content on reopening.
- Confirm deletion of one exchange, or clear all messages, drafts and attachments to release their memory references.

Version 1.8.9 (build 82, 2026-10-15) supports macOS 15+, Apple silicon and Intel, with ad-hoc signing and manual installation. Full regression executed 604 Swift tests: 578 passed, 26 optional/environment skips, zero failures. All 21 Python quality checks passed. See the [1.8.9 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.9).

## 1.8.8: Fix stuck chat settings and overlapping windows

- Fix an outside click collapsing the notch while Chat settings remained visible, disabling its fields and Cancel button.
- Keep the parent panel active while settings are open. Dismiss settings on activity changes or forced collapse, so they cannot cover the calendar on reopening.
- Verify model input, Cancel, Escape, Save, repeated opening and keyboard focus after delayed parent clicks through the real notch-to-sheet flow.

Version 1.8.8 (build 81, 2026-10-15) supports macOS 15+, Apple silicon and Intel, with ad-hoc signing and manual installation. Full regression executed 590 Swift tests: 565 passed, 25 optional/environment skips, zero failures. All 21 Python quality checks passed. See the [1.8.8 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.8).

## 1.8.7: Standalone clipboard history and AI chat

- Open a standalone clipboard history list with ⌘7, with no calendar alongside it. Opt in to save up to 100 text, image and file copies locally, with search, copy, pin, delete, clear and pause.
- Open AI Chat with ⌘8 for OpenAI Responses and compatible Chat Completions services. Configure the base URL and model; keep the API key in this Mac’s Keychain.
- Stream replies, keep multi-turn context, stop, retry and explicitly attach text files. New configurations default to Responses; existing ones can switch protocols while reusing the same provider key.
- Clipboard recording is off by default. Other tools are never attached automatically. Chat and drafts stay in process memory until the app quits.

Version 1.8.7 (build 80, 2026-10-15) supports macOS 15+, Apple silicon and Intel, with ad-hoc signing and manual installation. All 26 targeted feature tests and native Chinese/English checks at five panel sizes passed. Network checks use controlled responses; no real provider key was used. See the [1.8.7 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.7).

Full regression: 588 Swift tests executed, 563 passed, 25 optional/environment skips, zero failures; all 21 Python quality checks passed.

## 1.8.6: Hear timer completion and see the check-in tick draw

- A short sound plays once when a focus or break timer ends, including background timers. The Focus page provides a sound switch and remembers your choice.
- Pausing, resetting, restarting the app or restoring an already completed timer does not replay its reminder.
- The check-in capsule draws its tick when a reminder appears or the capsule is clicked. Details open immediately; Reduce Motion shows a complete static tick.

Version 1.8.6 (build 79, 2026-10-14) supports macOS 15+, Apple silicon and Intel, with ad-hoc signing and manual installation. 560 Swift tests executed: 535 passed, 25 optional/environment checks skipped, zero failures; all 21 Python quality checks passed. Background reminders, muting, rapid clicks and Chinese/English layouts at two widths have been verified locally. Full physical-device and live integration acceptance remain pending. See the [1.8.6 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.6).

## 1.8.5: Retract the calculator and recover music permission

- Fix calculator retraction after clicking or typing; reopening retains the result and respects click-only preferences.
- Add reinstall recovery instructions for music favorites and “Show this app in Finder” to locate the correct app copy.
- Read fresh favorite state on explicit recheck or return to the music page, preserve pending confirmation, and dismiss recovered help.

Version 1.8.5 (build 78, 2026-10-14) supports macOS 15+, Apple silicon and Intel, with ad-hoc signing and manual installation. 550 Swift tests executed: 526 passed, 24 optional/environment checks skipped, zero failures; all 21 Python quality checks passed. Physical-device and full live acceptance remain pending. See the [1.8.5 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.5) for installation and permission recovery.

## 1.8.4: Quick calculations from the notch

- Open the calculator toolbar icon or press ⌘6 for addition, subtraction, multiplication, division, decimals, sign changes and percentages.
- Use repeated equals, backspace, clear and result copying, with direct keyboard input and ⌘C to copy.
- Tab changes, closing and resizing retain the calculation until the app quits. Division by zero and out-of-range results show a recoverable message; enter a number or clear to continue.
- Operations run in input order. Percentages follow the current operation, such as `200 + 10% = 220`. Narrow panels use navigation icons; wider panels keep labels.

Version 1.8.4 (build 77, 2026-10-14) supports macOS 15+, Apple silicon and Intel. It is ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. The full Swift suite executed 542 tests: 518 passed, 24 optional/environment checks skipped, zero failures; all 21 Python quality checks passed. The 26 calculator checks and Chinese/English size captures passed. See the [1.8.4 release notes](RELEASE_NOTES.md) for validation and pending acceptance.

## 1.8.3: Restore the calendar layout and fix blank content

- Restore the date and daily agenda on the left, with the month on the right, including days with no events.
- Fix invisible but clickable dates and upcoming events after switching from Music or closing and reopening the notch.
- Restore a solid black notch background and keep Chinese tab labels at 520 pt, including Chinese selected through the system language.
- Scroll the month only when space is limited; six-week months and viewport changes keep all dates reachable.

Version 1.8.3 (build 76, 2026-10-13) supports macOS 15+, Apple silicon and Intel. It is ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. 492 Swift tests passed, 24 optional/environment checks skipped, zero failures; 21 Python quality checks, 27 targeted calendar checks and four real-window compositor cases passed. See the [1.8.3 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.3) for validation and pending acceptance.

## 1.8.2: Continuous music controls and a clearer compact agenda

- Add synchronized lyrics, preserving the current line after pausing, reopening and resizing, with lyrics and progress visible together.
- Favorite or unfavorite the current NetEase Cloud Music song from the heart button, using Accessibility permission and confirmed player state.
- Keep the heart visible while confirming a favorite; short commands no longer dim playback buttons and progress together.
- Reduce unused panel space, scroll upcoming events independently, open a complete agenda with full titles, and use a full-width month on empty days.

Version 1.8.2 (build 75, 2026-10-13) supports macOS 15+, Apple silicon and Intel. It is ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. 492 Swift tests passed, 23 optional/environment checks skipped, zero failures; 21 Python quality checks and 31 targeted music checks passed. Final live acceptance is incomplete; see the [1.8.2 release notes](RELEASE_NOTES.md).

## Fixed in 1.8.1: Turning off check-in reminders takes effect immediately

- Turning off “Enable check-in reminders” immediately hides the notch capsule and reminder panel and stops new reminders. Wake, day changes and restarts preserve the disabled state.
- The off state saved by earlier versions is honored. Pending check-ins are retained for when you turn reminders on again; completed check-ins do not repeat.
- The setting explains login and reminder behavior, and time controls are disabled while reminders are off.

Version 1.8.1 (build 74, 2026-10-13) requires macOS 15+ and supports Apple silicon and Intel. It is ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. 473 Swift tests passed, 23 optional/environment checks skipped, zero failures; all 21 Python quality checks and 14 targeted check-in tests passed. See the [1.8.1 release notes](RELEASE_NOTES.md) for downloads, checksums and pending acceptance.

## New in 1.8.0: Adjustable notch size and adaptive content

- The default expanded panel is 520 × 390 pt, about 27% smaller in area. Choose Compact, Standard, Spacious, or custom dimensions.
- Adjust width and height in Settings → General Settings → Notch Window Size, or switch presets with the arrows in the notch toolbar. Changes apply immediately and persist through restarts and local backup restore.
- Calendar switches between one and two columns, prioritizing the date and today's agenda. Files, Focus, Scratchpad and Music adapt to the viewport; switching tabs keeps the selected size.

Version 1.8.0 (build 73, 2026-10-13) requires macOS 15+ and supports Apple silicon and Intel. It is ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. 467 Swift tests passed, 24 optional/environment checks were skipped, and there were zero failures; all 21 Python quality tests passed. See the [1.8.0 release notes](RELEASE_NOTES.md) for downloads, checksums and pending acceptance.

![1.8.0 compact-size preview](images/notch-size-1.8.0-preview.png)

This native SwiftUI capture uses isolated data and a composited background; it is not a photograph of a physical display.

## Fixed in 1.7.5: Central notch hover and compact focus countdown

- Restore hover opening over the central hardware notch during music playback. The artwork and rhythm circles remain click targets, and moving the pointer away closes the browsing panel after the exit grace period.
- Keep the compact focus countdown within the right shoulder, preventing clipped time text and capsule edges after opening and closing the panel.

Version 1.7.5 (build 72, 2026-10-12) requires macOS 15+ and supports Apple silicon and Intel. This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. At the user's explicit request for immediate publication, release regression tests, artifact checks and SHA-256 verification were skipped. Tests were not rerun after the focus layout fix; this release does not claim those checks passed. See the [1.7.5 release notes](RELEASE_NOTES.md).

## New in 1.7.4: Click to open Music, leave to close Calendar

- Compact music artwork and rhythm open only on a click; hovering no longer opens the player.
- Beside a hardware notch, music input is limited to the two visible circles. Transparent shoulders and rounded corners pass clicks through to the menu bar, and the input region updates promptly during fast pointer movement to prevent accidental opening.
- With hover opening enabled, clicking Music and then switching to Calendar allows the panel to close after the exit grace period when the pointer leaves, including when it rests on neighboring menu-bar controls.
- Scratchpad, Files and Focus editing, the global click-only preference, and native popovers, sheets and modal dialogs retain continued interaction sessions.

Version 1.7.4 (build 71, 2026-10-12) requires macOS 15+ and supports Apple silicon and Intel. This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. Physical displays, real desktop frame rate, energy use and stationary performance, live-player compatibility, VoiceOver, Keychain dialogs, live payment/activation and real sleep/wake/login behavior remain pending; see the [1.7.4 release notes](RELEASE_NOTES.md) for the validation scope.

## New in 1.7.3: Keep working after a glance

- A brief pointer exit gets a grace period after hover opening. Clicking the panel keeps the interaction open while the pointer moves away; click outside, press Esc, or use Close to dismiss it.
- Opening takes about 0.32 seconds, closing 0.24 seconds, and pages fade in over 0.14 seconds. Narrow navigation keeps fixed icon widths when switching pages.
- A complete close and reopen retains the scratchpad's selection and independent undo history, plus file selection and scroll position. External note updates invalidate old undo actions while respecting input-method composition.
- File-open, copy, and child-folder failures show a dismissible message while keeping the current directory. Reads made obsolete by a collapsed parent or directory change cannot write back.
- The file list supports arrow navigation, left/right collapse and expansion, Home/End, Return to open, ⌘C to copy, and Tab/Shift-Tab focus navigation. Hidden pages do not intercept keys.

Requires macOS 15+ and supports Apple silicon and Intel. This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. Real desktop frame rate and energy use, physical displays, and live-player compatibility remain pending; see the [1.7.3 release notes](RELEASE_NOTES.md) for the validation scope.

## New in 1.7.2: A more compact and clearer notch panel

- Music fits its content without a large empty area below the player. Artwork, track information and playback controls have balanced spacing, and an album name that repeats the song title is omitted.
- Labeled navigation at the standard panel width and consistent hover, pressed, focus and disabled feedback make controls clearer. The translucent panel reduces desktop color tint for better contrast.
- Tab changes retain calendar and file browsing state, as well as the scratchpad's selection and undo history.

Requires macOS 15+ and supports Apple silicon and Intel. This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. See the [1.7.2 release notes](RELEASE_NOTES.md) for download and validation details.

## New in 1.7.1: Smoother notch opening and closing

- The shell expands first, then content fades in with a slight scale and downward movement. Content fades out before the shell finishes closing.
- Quickly reversing the transition continues from the visible shape. The compact notch no longer squeezes past its final size, and hidden editors release input focus.
- Reduce Motion uses fading without moving or scaling content.

Requires macOS 15+ and supports Apple silicon and Intel. This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. See [release notes](RELEASE_NOTES.md) for the validation scope.

## New in 1.7.0: Music beside the notch

- Album art and a gentle rhythm appear on separate sides of the notch during playback. Meetings and focus take priority; turn off Show music beside the notch in Settings when needed.
- Open Music in the notch to see the system's current track, artist, album, artwork and source player. Previous, play/pause, next and seeking follow the capabilities reported by the player.
- Swipe horizontally across the artwork and track area to change tracks, or use the buttons. Space plays or pauses; Reduce Motion keeps the rhythm still.

The rhythm is a decorative playback animation, not a live audio waveform. This version does not claim unverified Lossless, Dolby Atmos or exclusive audio formats, and it does not add a lock-screen music widget. Actual Apple Music, Spotify and other player compatibility remains pending live playback acceptance; controlled demo playback does not establish full compatibility. See [release notes](RELEASE_NOTES.md).

![Music controls in the notch](images/notch-music.png)

Native window compositor capture at measured content height, with synthetic song metadata and artwork; this does not establish physical-notch or live-player acceptance.

## New in 1.6.22: Clearer daily work and purchase steps

- Today prioritizes the next meeting, focus and note shortcuts, and available focus time. Add optional insights when needed; saved visibility choices are retained.
- Smaller windows keep the month and selected-day agenda side by side. Primary buttons are clearer, and notch meeting titles wrap to two lines with full text on hover.
- Purchase, Claim a code and I have a code each provide a direct path. The CNY 9.90 lifetime price, future updates and manual code delivery are explained before payment.

| Today workspace | Compact calendar |
| --- | --- |
| ![Today prioritizes the next meeting, focus and notes](images/workspace-today.png) | ![Month and selected-day agenda in a compact window](images/workspace-calendar-compact.png) |

### Separate notch-side activity islands

The focus icon and countdown, or meeting title and progress, sit on separate islands beside the camera housing. The centre stays clear instead of becoming one wide black notch.

| Focus timer | Active meeting |
| --- | --- |
| ![Separate focus icon and countdown beside the camera housing](images/compact-focus-islands.png) | ![Separate meeting title and progress beside the camera housing](images/compact-meeting-islands.png) |

Native compact-view captures use isolated demo data; the menu bar and camera housing are composited, not a photo of the display.

![Expanded notch calendar and four activity tabs](images/notch-calendar.png)

## Open from the notch

Hover over or click the top entry to expand the panel, then use the toolbar for Calendar, Focus, Scratchpad, Music, Calculator, Clipboard, AI Chat, Markets and News. Enable the optional file shelf in Settings to add Files. Use More Tools when space is limited. Clipboard recording needs a separate opt-in, and AI Chat requires a configured service. Displays without a notch have a centered top entry.

The feature screenshots below show earlier versions. Version 2.0.10 retains top or bottom placement, defaulting to bottom, and adds Markets and News while tools continue to share the Calendar window size.

| Calendar | Focus |
| --- | --- |
| ![Expanded notch calendar](images/notch-calendar.png) | ![Expanded notch focus timer](images/notch-focus.png) |
| Files (opt in) | Scratchpad |
| ![Expanded notch file shelf with sample files](images/notch-files.png) | ![Expanded notch scratchpad](images/notch-scratchpad.png) |

## Light, dark, and glass

Set the full workspace to light, dark, or system appearance, with optional translucent glass material. The expanded notch follows the selected appearance; the compact notch stays dark to blend with the camera housing.

| Light workspace | Dark workspace |
| --- | --- |
| ![Light calendar workspace with translucent material selected](images/workspace-light-glass.png) | ![Dark calendar workspace with translucent material selected](images/workspace-dark-glass.png) |

These native SwiftUI offscreen captures use isolated demo events, files, and notes. They do not include a physical notch or desktop background and cannot demonstrate actual desktop refraction.

## New in 1.6.21: Symmetric capsules and quiet check-in reminders

- Circular capsules share mirrored sizing, spacing and centered content. Check-ins show a red pending-count badge and gently pulse above two pending items; Reduce Motion keeps the reminder static.
- Details open only when you click the capsule, with no automatic popover on launch, wake or new reminders. Completing all items hides it.

## New in 1.6.20

- The check-in popover now has only Hide reminder and Done. Completion is saved separately, so changing today's time window will not bring a finished check-in back. Editing a window can restore an empty legacy check-in when the new window includes the current time; older versions could not distinguish completion from removal.

## New in 1.6.19

- The check-in reminder fits its pending items instead of showing a large empty panel. Hide reminder keeps the notch capsule and pending item; Remove clears that entry, separately from Done.

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

1. Open License & trial from the workspace sidebar or Settings, choose Purchase, read the manual steps, then reveal the WeChat QR code and pay CNY 9.90.
2. Choose Claim a code to copy request details or prepare an email. Attach your payment receipt and send the email yourself.
3. The author usually replies within 24 hours after receiving a complete receipt and installation ID. Choose I have a code, paste the author-issued code and press Return. Payment does not activate the app automatically.

![Lifetime purchase details and direct purchase, claim and activation paths](images/license-purchase.png)

Email: **498988598@qq.com** · Phone: **13191513539**

We usually reply within **24 hours** after receiving a complete payment receipt and installation ID. Replacement codes for a new Mac or reinstallation are free with proof of purchase, with no annual limit, for your own use only. If your code is missing, reply to the same email with your receipt and current installation ID; do not pay again.

![WeChat payment QR code for lifetime license; manual activation required](images/payment.png)

Codes are verified offline and bound to an installation. Starting in 2.0.7, permanent licenses are stored in local app data, so replacing or reinstalling the app with that data retained keeps activation available. Ordinary settings backups exclude license records. Legacy permanent licenses migrate from Keychain without deleting the original; if macOS blocks access, choose Retry reading license in License & trial to allow access once. Trial records remain in macOS Keychain, and an upgrade does not restart the trial. Contact the author for a replacement when changing Macs or losing the original installation record.

Calendar access uses EventKit. Notes and focus history remain local. Public feeds and update checks use network access. WeChat handles payment; the app does not automatically confirm payment or access payment accounts.

This repository contains public documentation, required images, and license notices. Installers are distributed through Releases. See [LICENSE](LICENSE) and the [historical MIT notice](THIRD_PARTY_NOTICES.md).
