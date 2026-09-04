# Changelog v0.4.0 → v0.5.0

Comparison scope: `v0.4.0` to the v0.5.0 release working tree. Test and
documentation changes are excluded from the change analysis; untracked Radar
source files are included as part of the target working tree.

## Features

- Add a top-level Radar workspace and `⌘5` navigation shortcut with three
  finite Hacker News feeds:
  - Hot stories from `topstories`.
  - Community questions from `askstories`.
  - Recently shared projects from `showstories`.
- Fetch at most ten ranked stories with four concurrent item requests, an
  8-second request timeout, a 12-second whole-feed deadline, bounded response
  sizes, malformed-item filtering, and safe HTTP/HTTPS destinations.
- Cache each Radar feed atomically in Application Support for 30 minutes, keep
  expired content visible during refresh failures, and expose source, freshness,
  points, comments, author, and publication age without background polling.
- Add persisted Notch interaction preferences for intentional hover or
  click-only opening and an opt-in live meeting-status shoulder.

## Bug Fixes

- Remove unconditional main-window presentation at process launch. Passive cold
  starts, updater handoffs, activation changes, and provenance-free untitled-file
  opens remain quiet; only Dock reopens and validated widget deep links reveal
  and activate the workspace.
- Require a 350 ms settled pointer inside a narrow top-edge trigger before hover
  expansion, preventing ordinary movement across nearby menu-bar controls from
  opening the Notch panel.
- Keep meeting-driven compact resizing disabled by default. Click-only mode and
  monitor-unavailable fallback retain a visible 30-point shoulder on each side
  of a hardware notch so the compact entry remains reachable.
- Distinguish hover expansion from explicit button or accessibility activation:
  hover stays non-activating, explicit interaction can make the panel key, and
  collapse releases panel focus.
- Collapse the panel synchronously when screen geometry changes, cancel pending
  hover/collapse tasks when interaction preferences change, and ignore stale
  animation requests.
- Replace 30-second calendar polling with EventKit change notifications plus
  midnight, system-clock, time-zone, and wake repair; coalesce adjacent time
  events and avoid publishing an unchanged event array.
- Replace whole-widget launch URLs with small explicit links for Month, Today,
  and Focus widgets, keeping each link as an independent accessibility action.
- Isolate malformed or failed Hacker News item requests, propagate task
  cancellation, and use request generations so a late same-feed response cannot
  overwrite a newer result or cache entry.
- Bind manual Radar refreshes and retries to the SwiftUI task lifecycle so
  leaving the page cancels outstanding work.

## Chore

- Build App, updater, and widget executables as exact `arm64 + x86_64`
  universal2 binaries and sign all architectures.
- Pin the checkout action by commit and mount the completed DMG read-only in CI
  to verify architectures, nested signatures, app/widget versions, build
  numbers, and the `/Applications` shortcut before publishing.
- Bump the app and widget extension from 0.4.0 (build 15) to 0.5.0 (build 16).
