# Changelog

All notable changes to Notch Calendar are documented here.

## [0.2.0] - 2026-09-03

### Added

- Smart Join buttons for current, upcoming, and agenda events using Zoom, Google Meet, Microsoft Teams, Webex, Around, or Whereby, plus an Open link action for other structured event URLs.
- Previous and next month navigation in the expanded calendar.
- Unit coverage for safe meeting-link resolution and locale-aware month layouts.

### Improved

- The agenda now prioritizes remaining events, avoids duplicating the highlighted meeting, and uses each calendar's source color.
- Calendar queries are cached while the second-by-second meeting countdown updates.
- Calendar permission errors are surfaced in the expanded view, and the compact view has proper button semantics.

### Fixed

- Weekday headings now respect the locale's first weekday and no longer collapse English labels to seven identical letters.
- The hover panel now collapses when the pointer leaves the visible card instead of lingering over transparent reserved space.

## [0.1.8] - 2026-09-02

### Added

- Live download percentage, transferred size, total size, and a determinate progress bar for in-app DMG updates.

## [0.1.7] - 2026-09-02

### Fixed

- A first-launch crash when EventKit returns the Calendar permission result from its background XPC queue.

## [0.1.6] - 2026-09-02

### Added

- Direct DMG downloads from the in-app update screen, saved to Downloads and revealed in Finder.
- An Applications shortcut in the DMG for standard drag-to-install behavior.

## [0.1.5] - 2026-09-02

### Fixed

- Explicit actor-isolated state access for compatibility with Xcode 16 release builds.

## [0.1.4] - 2026-09-02

### Fixed

- Calendar authorization now builds cleanly with the Swift 6 toolchain used by GitHub Actions.

## [0.1.3] - 2026-09-02

### Added

- A live meeting progress ring in the compact notch and expanded event card.

## [0.1.2] - 2026-09-02

### Added

- Live meeting countdown in the compact notch and expanded agenda.
- In-app version information and GitHub Release update checking.
- Open-source release assets and GitHub Actions release workflow.
- DMG and ZIP archives for every GitHub Release.
