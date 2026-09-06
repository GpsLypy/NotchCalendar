# Activity quality contract

Applies to the compact notch, expanded panel, workspace commands and future activities. New activity kinds remain frozen until the device and resource gates pass.

## Selection and continuity

- `NotchActivityPolicy` is the single selection rule: an enabled, eligible active meeting takes priority; otherwise an enabled unfinished focus/break session explicitly started or resumed during this launch appears; otherwise show the calendar. Pausing keeps that activity visible during the same launch. Hidden or disabled sources never win.
- Cold launch and backup restoration retain saved focus data without claiming the notch. Restored running sessions still finish in the background. `hasUnfinishedSession` protects saved work; `hasNotchActivity` controls presentation. Starting or resuming does not expand the panel or activate the workspace.
- Exclude all-day, cancelled, declined and invalid-duration meetings. Break ties deterministically with occurrence identity. Meeting end returns to the preserved focus session without restarting it.
- Compact width and rendered content use the same decision. Expanded activity changes only through explicit selection during that hover session; a new expansion reevaluates the compact rule.
- A new activity must extend the shared rule and its preference/state matrix tests. Do not implement separate priority rules inside views.

## Interaction and failure

- Hover dwell is 350 ms with an 8-point movement tolerance. Hover does not activate the app or make the panel key. Clicking expanded content enables keyboard interaction; click-only mode remains the fallback when monitoring is unavailable.
- Expanded panel: Command-1 calendar, Command-2 focus, Space start/pause/resume focus, Escape close. Buttons retain accessible names and selected state. Workspace: Command-K, arrows, Return, Escape. Do not install global single-key shortcuts.
- Disabling access, hiding a calendar or removing an event must invalidate affected actions immediately. A failed action gives a readable localized reason and a recovery route; preserve other usable activities.
- Corrupt local focus/notes data must not be silently overwritten. Preserve bytes for backup recovery; disable only the affected write action. A running focus session completes exactly once, including after sleep or restoration.
- Screen or sleep/wake changes discard hover candidates and collapse without activating another window. Actual external-display and wake acceptance is mandatory; geometry tests or synthetic notifications cannot substitute for it.

## Local data and resource use

- Calendar data stays in EventKit; focus and notes stay on the device. QA uses a disposable preference suite and synthetic calendar. It must not request Calendar access, schedule real notifications, reload real widgets, or open meeting URLs.
- Network features remain explicit opt-ins/actions. Do not add telemetry, calendar uploads or background feed polling to an activity. Do not include real event titles, URLs, account names, serial numbers or machine identifiers in reports.
- Hidden views cancel periodic refresh. Static or paused content does not acquire a per-second clock. Compact content shares one clock; focus completion has a separate one-shot deadline so hidden views cannot prevent completion.
- Measure optimized standalone builds, with a warmup and at least two 30-second samples per scenario. One logical CPU core is 100%. CPU counters from `proc_pid_rusage` use Mach time and must be converted with `mach_timebase_info`. Record interrupt and package-idle wakeups separately.
- Budgets fixed before tuning: idle mean CPU <=0.5%, p95 <=2%, interrupt wakeups <=1/s; focus <=2%, <=5%, <=5/s; meeting switching <=3%, <=8%, <=10/s. Keep raw samples and disclose excluded components. Never change a threshold to pass a failed run.

## Release acceptance

`Scripts/quality/verify_release_gate.py` blocks stable 1.x releases with missing device evidence, failed resource measurements or a mismatched runtime source fingerprint. All cases must name concrete evidence. An unavailable device stays **pending**, never passed. Distribution currently retains ad-hoc signatures only, with no Developer ID certificate or notarization.

An owner-authorized publication with pending acceptance must be recorded independently for that version, matching the original owner request, runtime fingerprint and exact outstanding checks. It does not change acceptance status, cannot carry over from another version, and cannot waive an actual hardware failure or invalid/failed measurement. The `--strict` gate always reports all remaining failures regardless of a publication exception.

Apple references: [XNU process resource accounting](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/kern/bsd_kern.c#L1187-L1197), [Apple silicon executable signatures](https://support.apple.com/en-ie/guide/security/secebb113be1/web).
