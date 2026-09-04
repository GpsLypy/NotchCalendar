# Changelog v0.3.1 → v0.4.0

Comparison scope: `v0.3.1` to the v0.4.0 release working tree. Test and documentation changes are excluded from the change analysis.

## Features

- Add three independent WidgetKit desktop widgets, all limited to the small desktop family:
  - Month calendar with today highlighting and event-date markers.
  - Focus timer with an absolute-time countdown and circular progress track.
  - Today's agenda with a compact timeline for up to three events.
- Publish minimal calendar and focus snapshots from the main app to the read-only widget extension, including explicit bilingual setup, permission, and empty states.
- Open the matching Today, Calendar, or Focus workspace page when a widget is clicked.

## Bug Fixes

- Launch the widget binary through macOS's app-extension entry point so all three widgets are discoverable and render timelines in the desktop widget gallery.
- Reserve the hardware camera housing as a content-free center, placing the calendar icon and meeting title on its left shoulder and the active progress ring on its right shoulder.
- Keep the idle compact window exactly as wide as the hardware notch; expand both shoulders only while a timed meeting is active, then clear the content and shrink immediately at its end.
- Keep adjacent menu-bar controls clickable while the compact notch view is collapsed, with click-to-expand retained as a fallback if hover monitoring is unavailable.
- Preserve the centered compact pill on displays without a notch and refresh the layout when screen geometry changes.
- Match the compact black surface to AppKit's model-specific camera-housing depth instead of a fixed height, removing the menu-bar seam beneath the notch.
- Make the progress-ring track adapt to the menu-bar appearance and respect Reduce Motion.

## Chore

- Link the WidgetKit binary through macOS's required app-extension entry point, then package and sign it inside the app before signing the enclosing app bundle.
- Keep the host app and widget extension versions aligned at 0.4.0 (build 15).
