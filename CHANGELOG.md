# Changelog

All notable changes to Notch Calendar are documented here.

## [Unreleased]

## [0.8.0] - 2026-09-05

macOS 15+ · Apple Silicon and Intel. This free manual-install build is ad-hoc signed and is not Developer ID notarized. / 支持 macOS 15 及以上、Apple 芯片及 Intel；继续免费，采用 ad-hoc 签名及手动安装，尚未进行 Developer ID 公证。

### Added / 新增功能

- Added opt-in local meeting reminders, 5/10-minute snooze, occurrence dismissal, and a configurable global join shortcut with visible registration conflicts. / 新增可选会议提醒、延后 5/10 分钟、忽略本次，以及可配置且能提示占用冲突的全局快捷入会。
- Added bounded calendar search, quick event creation, daily/weekly/monthly recurrence, non-destructive duplicate display, and a second time zone. / 新增日程搜索、快速创建、每日/每周/每月重复日程、重复来源合并显示和第二时区。
- Added occurrence-linked meeting notes, local note search, Markdown export, validated backup preview and restore, and undo of the last restore. / 新增按单次日程关联的会议笔记、本地搜索、Markdown 导出、校验后的备份预览与恢复，以及撤销上次恢复。
- Added four native Shortcuts actions, focus task labels, weekly day/task breakdowns, and Markdown weekly-review export. / 新增四个原生快捷指令操作、专注任务标签、按日期和任务统计的周回顾，以及 Markdown 周回顾导出。

### Improved / 功能优化

- Meeting actions re-query the current selected calendars; reminders reconcile on calendar changes and wake without replaying expired deadlines. / 入会时重新查询当前选中的日历，日历变化和唤醒后重排提醒，跳过过期的提醒时间。
- Backups exclude account secrets and system permissions, show their contents before replacement, and pause restored timers. Shortcuts share the live app stores and preserve unfinished focus work. / 备份不含账户密钥和系统权限，覆盖前展示内容，恢复后的计时器暂停；快捷指令共用应用实时状态并保护未完成的专注。

### Fixed / 问题修复

- Preserved unreadable local notes/focus bytes instead of silently overwriting them, protected Chinese input composition from external note updates, and reloaded restored state synchronously before a timer tick can write old data back. / 无法读取的本地笔记和专注数据会保留原始内容，外部便笺更新不打断中文输入，恢复后同步载入状态，防止旧计时状态覆盖导入数据。
- Release packaging now extracts and verifies App Intents metadata so Shortcuts actions are included in the distributed app. / 打包时生成并验证 App Intents 元数据，确保交付的应用包含快捷指令操作。

## [0.7.0] - 2026-09-05

macOS 15+ · Apple Silicon and Intel. This free manual-install build is ad-hoc signed and is not Developer ID notarized. / 支持 macOS 15 及以上、Apple 芯片及 Intel；本版继续免费，采用 ad-hoc 签名及手动安装，尚未进行 Developer ID 公证。

### Added / 新增功能

- Added persistent calendar source selection, with account names, calendar colors, and explicit recovery for no access, no calendars, or all calendars hidden. The selection applies to Today, the notch, month calendar, and widgets. / 新增持久化日历来源选择，显示账户名与日历颜色，区分无权限、无日历和全部隐藏状态，统一用于今日、刘海、月历与小组件。
- Added a local daily planning timeline with configurable hours and meeting buffers, remaining openings, real event conflicts, and an explicit action to prepare a suitable focus session. / 新增本地今日时间规划，支持自定义时段、日程前后缓冲、剩余空档、真实日程冲突与准备合适专注时长的明确操作。
- Added custom 5–180 minute focus sessions, separate breaks, daily/weekly completed focus minutes, a bounded local completion journal, and CSV export with visible failures. / 新增 5–180 分钟自定义专注、独立休息类型、今日与本周已完成专注时长、有限本地完成记录和带失败反馈的 CSV 导出。

### Improved / 功能优化

- Calendar suggestions respect busy status and never replace a running or paused timer. Completion records preserve their scheduled finish time across sleep and relaunch; earlier cumulative totals remain without fabricated historical entries. / 日历建议遵循忙碌状态，不覆盖运行或暂停的计时器；休眠和重启后按原定完成时间记录，更早的累计次数保留但不伪造历史明细。

### Fixed / 问题修复

- Calendar changes outside today now invalidate month and widget snapshots. Empty calendar selections perform no event query. Planning covers adjacent-day meeting buffers, daylight-saving boundaries, and expired suggestions. / 非当日日程变化现会更新月历与小组件快照；全不选时不查询事件；时间规划覆盖相邻日期缓冲、夏令时与已过期建议。
- Focus widgets now distinguish breaks from custom five-minute focus sessions and correctly show timers paused immediately after starting, while remaining compatible with older saved snapshots. / 专注小组件现在能区分休息与自定义五分钟专注，并正确显示刚开始就暂停的计时器，同时兼容旧版保存状态。

## [0.6.0] - 2026-09-05

macOS 15+ · Apple Silicon and Intel. This manual-install build is ad-hoc signed and is not Developer ID notarized. / 支持 macOS 15 及以上、Apple 芯片及 Intel；本版为 ad-hoc 签名的手动安装包，尚未进行 Developer ID 公证。

### Added / 新增功能

- Added Markets with up to eight US stock/ETF symbols, watchlist ordering, personal Alpha Vantage credentials in macOS Keychain, explicit manual refresh, closing quotes, trade dates and per-symbol failures. / 新增自选行情，支持最多八个美股/ETF代码、调整顺序、系统钥匙串保存个人 Alpha Vantage 密钥、手动刷新、收盘行情、交易日期和逐项失败提示。
- Added a Discussion Room with real Hacker News topics and attributed comments, original-source links, locally saved perspectives, private notes and retained threads. / 新增舆论室，提供真实 Hacker News 话题及署名评论、原帖链接、本机立场、私人笔记及留存话题。
- Added Briefing with GitHub Blog, Swift.org and NASA primary-source feeds, source and keyword filters, a finite twenty-headline list, bookmarks and read state. / 新增信息差简报，汇集 GitHub Blog、Swift.org 与 NASA 一手资讯，提供来源及关键词筛选、最多二十条的阅读列表、收藏与已读记录。

### Improved / 功能优化

- Added direct sidebar entries and ⌘6 / ⌘7 / ⌘8 shortcuts. Navigation scrolls in smaller windows while Settings remains accessible. / 新增三个同级侧栏入口与快捷键，小窗口内导航可滚动，设置入口仍保持可访问。
- External content retains source, time and cache context. Bounded requests and local persistence keep network failures independent of calendar, focus and notes. / 外部内容标注来源、时间和缓存状态；请求有边界，联网失败不会影响日历、专注和私人笔记。

### Fixed / 问题修复

- Added deterministic coverage for malformed and partial external responses, request cancellation, rate limits, corrupted caches and persisted local reading state. / 为畸形及部分响应、任务取消、限流、损坏缓存及本地阅读状态恢复补齐确定性测试。

## [0.5.0] - 2026-09-05

### Added / 新增功能

- Added a finite Radar workspace with ten Hot, Ask, or Show Hacker News signals, source and update metadata, explicit browser links, and the `⌘5` shortcut. Radar loads only when opened or manually refreshed, uses a 30-minute local cache, and keeps saved results visible when the network fails. / 新增有限信息流的 Radar 情报台，每次展示十条 Hacker News 热门、Ask 或 Show 信号，包含来源、更新时间、明确的浏览器链接及 `⌘5` 快捷键；仅在打开页面或手动刷新时联网，使用 30 分钟本地缓存，并在断网时继续展示已保存结果。
- Added Notch interaction settings for intentional hover or click-only opening, plus an opt-in switch for live meeting shoulders. If global hover monitoring is unavailable, the app visibly falls back to a clickable compact target. / 新增刘海交互设置，可选择停稳悬停或仅点击打开，并可单独开启实时会议肩区；全局悬停监听不可用时，应用会明确降级为可点击的紧凑入口。
- Added an evidence-based product roadmap for bounded market watchlists, contextual weather, a privacy-first local assistant, daily briefs, and focus recovery. / 新增基于稳定性与隐私门槛的产品路线，规划有限自选行情、情境天气、本地咨询助手、日程简报与专注恢复。

### Improved / 功能优化

- Notch opening now requires a 350 ms settled pointer inside a narrow top-edge target. Compact meeting-driven resizing is disabled by default, the inactive compact clock updates once per minute, and click-only mode keeps a small visible target on both sides of the physical camera housing. / 刘海展开现要求指针在缩窄的顶部目标区停稳 350 毫秒；会议驱动的紧凑区伸展默认关闭，非会议状态的紧凑时钟降为每分钟更新一次，仅点击模式则在实体摄像头两侧保留小型可见入口。
- Calendar refresh is event-driven instead of polling every 30 seconds, with explicit repair after day changes, clock or time-zone changes, and wake from sleep. Duplicate time-context refreshes are coalesced. / 日历刷新由每 30 秒轮询改为事件驱动，并在跨日、系统时钟或时区变化及睡眠唤醒后主动校正；相邻的时间环境刷新会自动合并。
- Radar requests use an 8-second per-request timeout, a 12-second whole-feed deadline, four-request concurrency limit, bounded response sizes, malformed-item filtering, cancellation, and generation checks that prevent old requests from overwriting newer results. / Radar 请求采用单项 8 秒超时、整次 12 秒截止、最多四路并发、响应大小上限、畸形条目过滤、任务取消及请求代次校验，避免旧请求覆盖较新的结果。
- Release packages now contain verified universal2 App, updater, and widget binaries for Apple Silicon and Intel Macs. The release workflow mounts the final DMG and verifies architectures, nested signatures, version alignment, and the Applications shortcut before publishing. / 发布包现包含经过校验的 universal2 主程序、更新器和小组件，支持 Apple 芯片与 Intel Mac；发布流程会挂载最终 DMG，并在发布前检查架构、嵌套签名、版本一致性及 Applications 快捷方式。

### Fixed / 问题修复

- Prevented passive cold starts, session restoration, update handoffs, and provenance-free open events from raising the desktop window or activating the app. Only a Dock reopen or an explicit widget deep link may present the workspace, with presentation diagnostics recorded for verification. / 修复被动冷启动、会话恢复、更新接力及来源不明的打开事件自动弹出桌面窗口并抢占焦点的问题；现在只有 Dock 再次点击或小组件明确深链可以显示工作区，并记录呈现诊断以便验证。
- Prevented accidental notch expansion while crossing nearby menu-bar controls, eliminated automatic width changes at meeting boundaries unless opted in, and made monitor failure fall back to click-only instead of leaving the notch unreachable. / 修复指针经过相邻菜单栏控件时误展开刘海、会议边界自动改变宽度的问题；会议肩区需主动开启，悬停监听失败时则降级为仅点击，避免入口失效。
- Explicit click and accessibility expansion can now receive keyboard focus, while hover expansion remains non-activating and collapsing the notch immediately releases any panel focus. Screen changes synchronously collapse the panel before replacing its content. / 明确点击或辅助功能触发展开后可获得键盘焦点，悬停展开仍不激活应用，收起时会立即释放面板焦点；屏幕参数变化时也会先同步收起面板再替换内容。
- Desktop widgets now use a small explicit open control instead of making the entire widget a launch target, preserving nearby interactions and exposing the link as a separate VoiceOver action. / 桌面小组件改为使用小型明确打开按钮，不再把整张组件作为启动目标，从而减少误触并将链接作为独立的 VoiceOver 操作呈现。

## [0.4.0] - 2026-09-04

### Added / 新增功能

- Three WidgetKit desktop widgets now provide a month calendar with event markers, a live focus progress ring, and today's next three agenda items. Each widget opens the matching page in Notch Calendar and includes clear bilingual setup, empty, and permission states. / 新增三个 WidgetKit 桌面组件，分别显示带日程标记的月历、实时专注进度环，以及今天接下来的三项日程；点击组件可打开 Notch Calendar 对应页面，并提供清晰的双语同步、空日程和权限提示。

### Improved / 功能优化

- The compact view on notched Macs now keeps the calendar icon and meeting title on the left shoulder, with a live progress ring on the right, so no status content sits behind the camera housing or crowds nearby menu-bar items. Displays without a notch retain the original centered pill. / 刘海屏上的紧凑视图现将日历图标与会议标题放在左侧安全区、实时进度环放在右侧安全区，避免状态内容被摄像头外壳遮挡或挤占相邻菜单栏项目；无刘海外接屏继续保留原有居中胶囊。
- The compact window now matches the hardware notch width while idle. Only when a timed meeting starts does it expand into the left and right shoulders to show the title and progress ring, then shrink back immediately when the event ends; the ring also respects Reduce Motion. / 空闲时收起窗口现在严格贴合实体刘海宽度；仅在定时会议开始后才向左右两侧展开并显示标题与进度环，日程结束时立即缩回，同时进度环支持“减少动态效果”。
- The compact surface now follows the exact notch depth reported for each MacBook model, eliminating the visible seam between the black surface and the hardware housing. / 收起态现在会跟随不同 MacBook 型号由系统报告的实际刘海深度，消除黑色区域与实体刘海边缘之间的可见缝隙。
- Widget data is prepared by the main app from its existing calendar permission and saved focus state, so the desktop surfaces stay read-only and never show a blank card while waiting for data. / 桌面组件的数据由主应用使用既有日历权限和专注状态准备，组件本身保持只读，并在等待数据时始终显示明确提示而非空白卡片。

### Fixed / 问题修复

- Fixed the widget extension launch entry point so Month, Focus, and Today appear correctly in the macOS desktop widget gallery. / 修复小组件扩展的启动入口，使月历、专注和今日日程能够正常出现在 macOS 桌面小组件图库中。
- Prevented active meeting details and remaining time from being hidden behind the camera housing, and allowed nearby menu-bar controls to remain clickable while the notch view is collapsed. / 修复活动会议信息和剩余时间被摄像头外壳遮挡的问题，并让刘海视图收起时相邻菜单栏控件保持可点击。

## [0.3.1] - 2026-09-04

### Added / 新增功能

- No new features in this maintenance release. / 本次维护版本无新增功能。

### Fixed / 问题修复

- Reduced the compact notch height from 34 to 30 points and tightened its lower corners, removing the remaining excess chin while preserving the notch width, typography, and 10-point hover buffer. / 将紧凑刘海高度从 34 点进一步缩短到 30 点并收紧底部圆角，在保留原有宽度、字体和 10 点悬停容错边距的同时去除剩余的下巴。

## [0.3.0] - 2026-09-04

### Added / 新增功能

- A Codex-inspired desktop workspace sidebar with Today, Calendar, Focus, and Scratchpad destinations plus keyboard shortcuts. / 新增 Codex 风格桌面工作区侧边栏，包含今日、日历、专注和随手记及快捷键。
- A drift-resistant focus timer with 5, 25, and 50 minute presets, pause/resume, session progress, and calendar guardrails. / 新增 5、25、50 分钟预设的抗漂移专注计时器，支持暂停、继续、进度显示和日历冲突提醒。
- An auto-saved local scratchpad with timestamp insertion, copy, and confirmed clearing. / 新增本地自动保存的随手记，支持插入时间、复制和确认清空。
- A Today overview with the next event, Smart Join action, daily schedule, and a live day-progress pulse. / 新增今日总览，可查看下一日程、智能入会、全天安排和实时日进度。
- App-wide Simplified Chinese and English localization with an immediate, persistent language selector in Settings. / 新增全应用简体中文与英文切换，设置即时生效并持久保存。
- Update checks now run automatically at launch; when a newer release is available, a green circular-arrow shortcut appears above Settings in the sidebar. / 启动时自动检查更新；发现新版本后，在侧边栏设置上方显示绿色圆形箭头更新入口。
- Settings now presents the release date and structured Added, Improved, and Fixed notes from GitHub Releases. / 设置页新增版本发布日期及来自 GitHub Release 的“新增、优化、修复”分类更新内容。
- The GitHub README now includes a WeChat Pay QR code for readers who want to buy the author a coffee. / GitHub README 新增“请作者喝杯咖啡”的微信收款二维码。

### Improved / 功能优化

- The desktop window now uses a full-height translucent titlebar layout and a larger, resizable canvas while the expanded notch calendar keeps its existing behavior. / 桌面窗口改为全高透明标题栏与更大的可缩放画布，同时保留刘海展开日历的原有行为。
- Calendar browsing state is preserved when switching between workspace tools. / 在不同工作区工具间切换时保留日历浏览位置。
- Dates, weekdays, month labels, meeting actions, accessibility text, and update status now follow the selected app language. / 日期、星期、月份、会议操作、辅助功能文本和更新状态均跟随应用语言。
- GitHub Releases now use curated bilingual notes extracted from this changelog, with explicit Added, Improved, and Fixed groups instead of an autogenerated version-comparison footer. / GitHub Release 改为从本日志提取双语说明，明确列出新增、优化和修复，不再生成版本对比尾注。

### Fixed / 问题修复

- Scratchpad editing now preserves marked-text composition so Chinese and other input methods can commit text normally while auto-save remains enabled. / 修复随手记自动保存期间中文及其他输入法无法正常完成候选文字输入的问题。
- The compact notch surface is two points shorter with tighter lower corners, reducing how far it extends beneath the menu bar. / 缩短紧凑刘海区域并收紧底部圆角，修复其向菜单栏下方凸出过多的问题。

## [0.2.2] - 2026-09-03

### Added

- A full desktop calendar window that opens at launch and serves as the Dock icon's primary destination.

### Improved

- Closing the desktop window leaves the notch calendar running, while clicking the Dock icon restores and focuses the same window without creating duplicates.
- The desktop window shares live calendar data with the notch while keeping its browsed date independent.
- The release workflow now uses a Node 24-based checkout action to avoid the Node 20 deprecation warning.

## [0.2.1] - 2026-09-03

### Added

- A signed update-helper foundation for future automatic replacement; automatic app replacement remains disabled in this release until interrupted transactions can be recovered durably.
- Clear recovery actions when the app is launched from a read-only disk image, including opening the installed Applications copy after quitting.

### Improved

- Ad-hoc builds now make the safe manual path explicit: open the downloaded DMG and quit the running copy before installation.
- Update downloads require the exact GitHub release asset and verify GitHub's published SHA-256 digest; missing or mismatched digests never enable automatic installation.

### Fixed

- Expanded calendar controls now stay below the camera housing and menu bar even when macOS does not report auxiliary notch rectangles.
- Update relaunch handoff now uses the correct application lock and avoids reopening an older copy from a mounted DMG.

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
