# superNotch 4.2.9

## 4.2.9：待办添加按钮更清晰

- 修复列表滚动时后方复选框透过绿色“＋”、造成图标重叠的问题。
- 按钮底色随深浅色切换，保留原有位置、大小、草稿恢复与点击反馈。

macOS 15+，Apple 芯片与 Intel，build 189，2026-11-11。ad-hoc 签名，未公证，需手动安装。退出旧版后拖入“应用程序”替换；保留应用数据时沿用已有授权、待办和设置。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.9/NotchCalendar-4.2.9-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.9/NotchCalendar-4.2.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.9/SHA256SUMS.txt)

## 4.2.9: A clearer Todo add button

- Fix checkboxes showing through the floating green plus as task rows scroll behind it.
- Adapt the opaque button background to light and dark appearances while preserving its position, size, draft restoration and interaction feedback.

macOS 15+, Apple silicon and Intel, build 189, 2026-11-11. Ad-hoc signed and not notarized; install manually by quitting the old app and replacing it from the DMG. Retain application data to preserve your license, tasks and settings.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.9/NotchCalendar-4.2.9-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.9/NotchCalendar-4.2.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.9/SHA256SUMS.txt)

## 4.2.8：待办滚动与胶囊优化

- 大分类按需加载待办，优化小分类滚动时的行复用与提示处理；切换加载方式保留子任务状态及草稿。
- 改善外接显示器音乐胶囊中的转盘、歌词与律动展示，并调整编程状态胶囊布局。

根据发布要求，本版未进行新的完整回归；真实触控板及外接显示器仍需实际验收。macOS 15+，Apple 芯片与 Intel，build 188；ad-hoc 签名，未公证，需手动安装。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.8/NotchCalendar-4.2.8-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.8/NotchCalendar-4.2.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.8/SHA256SUMS.txt)

## 4.2.8: Todo scrolling and compact activities

- Load large Todo categories on demand, reuse rows in small categories, and preserve subtask state and drafts when the loading strategy changes.
- Improve the external-display music capsule and the compact coding activity layout.

A new full regression was skipped at the owner's request. Physical trackpad and external-display acceptance remain pending. macOS 15+, Apple silicon and Intel, build 188; ad-hoc signed and not notarized, with manual installation.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.8/NotchCalendar-4.2.8-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.8/NotchCalendar-4.2.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.8/SHA256SUMS.txt)

## 4.2.7：性能与稳定性修复

- 优化 AI 流式回复处理并限制会话和请求体大小，减少长对话卡顿；截断响应正确显示为未完成。
- 减少大待办列表保存时的重复编码；达到容量后仍可完成重复任务，腾出空间后补建下一次。
- 修复授权恢复后的待办提醒、损坏笔记与收藏被后续操作覆盖的问题，保留原数据以便恢复。
- 合并文件目录与日历的连续刷新，取消不再需要的扫描；空闲时停止编码胶囊外层的周期刷新。
- 修复待办菜单边角点击、窗口缩放期间底部导航，以及聊天清空确认期间意外收起；补齐 JSON 编辑器的 Cmd-Return 操作。

本次完成代码审计、边界回归和原生交互复查。受控短时资源测量不能证明长期无泄漏，历史间歇性持续高 CPU 的原始触发仍未复现。

macOS 15+，Apple 芯片与 Intel，build 187，2026-11-11。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入“应用程序”替换并重新启动；保留应用数据时沿用已有授权、待办和设置。

## 4.2.7: Performance and stability fixes

- Process streamed AI replies in bounded chunks and cap conversations and request bodies; truncated replies remain incomplete.
- Reduce repeated serialization for large Todo lists. Complete recurring tasks at capacity and create the next occurrence when space becomes available.
- Restore Todo reminders after access resumes; preserve unreadable notes and saved articles instead of overwriting their original data.
- Coalesce file and calendar refreshes, cancel unused scans, and stop periodic compact coding updates while idle.
- Fix Todo menu corner clicks, navigation during window resizing, premature collapse during chat cleanup confirmation, and Cmd-Return in the JSON editor.

Validated with code review, boundary regression and native interaction checks. Controlled short resource samples do not establish long-term leak freedom. The original intermittent sustained high-CPU hang has not been reproduced.

macOS 15+, universal Apple silicon/Intel, build 187, 2026-11-11. Ad-hoc signed; no Developer ID signature or Apple notarization. Quit the old app and replace it manually using the DMG; retain application data to keep your license, tasks and settings.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.7/NotchCalendar-4.2.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.7/NotchCalendar-4.2.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.7/SHA256SUMS.txt)

## 4.2.6：待办列表计算优化

- 同一轮渲染只生成一次可见待办并按分类分组，减少列表布局时反复过滤和排序。
- 一次计算窄窗口的四象限数量，减少切换窗口尺寸时的重复工作。
- 增加默认关闭、按需启用的性能诊断，便于排查间歇性录入卡顿；不记录待办内容。

持续高 CPU 卡死的原始触发条件仍未复现，本次优化不等同于已解决所有卡死。

macOS 15+，Apple 芯片与 Intel，build 186，2026-11-10。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入“应用程序”替换并重新启动；保留应用数据时沿用已有授权、待办和设置。

## 4.2.6: Reduce repeated Todo list calculations

- Filter and sort visible tasks once per render, then group them by category for list layout.
- Calculate narrow-window quadrant counts together to reduce repeated work during resizing.
- Add optional performance diagnostics, disabled by default, to investigate intermittent input stalls without recording task content.

The original sustained high-CPU hang has not been reproduced. These optimizations do not establish that all hangs are resolved.

macOS 15+, universal Apple silicon/Intel, build 186, 2026-11-10. Ad-hoc signed; no Developer ID signature or Apple notarization. Quit the old app and replace it manually using the DMG; retain application data to keep your license, tasks and settings.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.6/NotchCalendar-4.2.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.6/NotchCalendar-4.2.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.6/SHA256SUMS.txt)

## 4.2.5：待办标题弹窗与性能优化

- 任务和子任务标题统一使用编辑弹窗，修复双击标题及“编辑标题”仍进入行内编辑的问题。
- 居中显示任务行的更多操作图标；未判断重要性或不紧急时隐藏对应标识，减少空白占用。
- 缩小录入草稿的界面订阅范围并缓存解析结果，减少输入时对任务列表的重复刷新。
- 避免重复发布相同的待办窗口可见状态，缓存语言资源查询，减少任务行和菜单构建开销。

已捕获旧版持续高 CPU 与内存增长，但触发条件尚未稳定复现；本次为针对性性能优化，不能视为已彻底修复所有卡死情况。

macOS 15+，Apple 芯片与 Intel，build 185，2026-11-10。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入“应用程序”替换并重新启动；保留应用数据时沿用已有授权、待办和设置。

## 4.2.5: Todo title dialogs and performance improvements

- Use edit dialogs for task and subtask titles, resolving competing inline editing when double-clicking titles or choosing Edit title.
- Center the task action icon and hide unset importance and nonurgent badges to save space.
- Limit draft observation to the composer and cache parsed input, reducing task-list refreshes while typing.
- Avoid publishing unchanged Todo window visibility and cache language bundles to reduce row and menu construction work.

A sustained high-CPU and memory-growth issue was captured in the previous version, but its trigger has not been reproduced reliably. These targeted optimizations do not establish that every hang is resolved.

macOS 15+, universal Apple silicon/Intel, build 185, 2026-11-10. Ad-hoc signed; no Developer ID signature or Apple notarization. Quit the old app and replace it manually using the DMG; retain application data to keep your license, tasks and settings.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.5/NotchCalendar-4.2.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.5/NotchCalendar-4.2.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.5/SHA256SUMS.txt)

## 4.2.4：待办编辑与规划标识

- 列表和四象限任务行显示重要性与紧急程度，支持直接修改；自动判断带“自动”标识，红旗优先级保持独立。
- 分类标题可双击弹窗改名；移到分类菜单可新建分类。截止时间展示完整年月日和时间，并支持直接弹窗修改。
- 新增任务支持多行备注，标签与备注相邻放在选项末尾；切换视图保留草稿，编辑弹窗更紧凑。
- 恢复分类与任务的悬停加号，改善子任务创建、菜单文案与按钮对齐；修复从刘海常驻切回桌面入口后图标不显示。
- 系统监视器中间可添加最多 3 个应用快捷入口，点击打开活动监视器、Wireshark 等本机软件。

macOS 15+，Apple 芯片与 Intel，build 184，2026-11-10。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入“应用程序”替换并重新启动；保留应用数据时沿用已有授权、待办和设置。

## 4.2.4: Clear Todo planning and compact editing

- Show importance and urgency on task rows in lists and quadrants, with direct editing and an Auto label for due-date inference. Flag priority stays independent.
- Double-click category headings to rename them in a dialog, create categories while moving tasks, and display/edit complete due dates including the year.
- Add multiline notes to task creation, place tags and notes last, preserve drafts across view switches, and use more compact edit dialogs.
- Restore hover add controls for tasks and subtasks, improve menu wording and row alignment, and restore the desktop entry after leaving notch residency.
- Add up to three application shortcuts in System Monitor to open installed apps such as Activity Monitor or Wireshark.

macOS 15+, universal Apple silicon/Intel, build 184, 2026-11-10. Ad-hoc signed; no Developer ID signature or Apple notarization. Quit the old app and replace it manually using the DMG; retain application data to keep your license, tasks and settings.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.4/NotchCalendar-4.2.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.4/NotchCalendar-4.2.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.4/SHA256SUMS.txt)

## 4.2.3：待办菜单栏入口与统一入口设置

- 新增菜单栏待办入口，与桌面共用所选的对号、小伴侣或自定义图片，无需重复选择外观。
- 在「更多 → 入口设置」统一选择刘海常驻、菜单栏和桌面。桌面与菜单栏可同时显示；开启刘海常驻会关闭另外两处入口，开启桌面或菜单栏会退出刘海常驻。
- 切换入口保留任务、草稿、提醒与图片；入口位置选择支持重启保存及本地备份恢复。

macOS 15+，Apple 芯片与 Intel，build 183，2026-11-10。¥9.9 一次买断，含未来更新，无订阅。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动；保留应用数据时沿用已有授权、待办和设置。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.3/NotchCalendar-4.2.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.3/NotchCalendar-4.2.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.3/SHA256SUMS.txt)

## 4.2.3: Todo menu bar entry and unified entry settings

- Add a Todo menu bar entry that shares the selected checkmark, companion, or custom image with the desktop. Choose the appearance once.
- Group notch residency, menu bar and desktop visibility in More → Entry settings. Desktop and menu bar can appear together; notch residency turns both off, and enabling either exits notch residency.
- Preserve tasks, drafts, reminders and custom images when switching entries. Save location choices across restarts and local backup restoration.

macOS 15+, universal Apple silicon/Intel, build 183, 2026-11-10. ¥9.9 one-time purchase including future updates, without a subscription. Ad-hoc signed; no Developer ID signature or Apple notarization. Quit the old app and replace it manually using the DMG; retain application data to keep your license, tasks and settings.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.3/NotchCalendar-4.2.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.3/NotchCalendar-4.2.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.3/SHA256SUMS.txt)

## 4.2.2：编程完成自动收起与日历提醒事项

- 编程任务完成后，刘海胶囊保留 5 秒再自动收起；进行中和待回复任务继续显示，完成记录可回到编程动态页查看。空闲时额度不再单独占用刘海。
- 日历可在授权后显示系统提醒事项，并选择提醒列表；只读取带日期的未完成提醒，不修改系统提醒事项。
- 改善待办菜单、弹出面板的开关与 Escape 关闭行为，统一按钮点击反馈和悬停说明。
- 简体中文界面下改善中文歌词显示，保留歌词原文、时间轴及日文和韩文内容。

macOS 15+，Apple 芯片与 Intel，build 180，2026-11-10。¥9.9 一次买断，含未来更新，无订阅。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动；保留应用数据时沿用已有授权、待办和设置。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.2/NotchCalendar-4.2.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.2/NotchCalendar-4.2.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.2/SHA256SUMS.txt)

## 4.2.2: Coding completion dismissal and calendar reminders

- Dismiss the coding capsule automatically five seconds after completion. Running tasks and tasks awaiting input remain visible; completion history stays in Coding Activity. Quotas no longer occupy the notch on their own while idle.
- Show scheduled, incomplete Apple Reminders alongside calendar events after permission is granted, with reminder-list selection. Reminders are read only and remain on this Mac.
- Improve To-Do menu feedback, popover toggling, Escape dismissal and hover help.
- Improve Chinese lyrics in the Simplified Chinese interface while preserving original text, timing, Japanese and Korean content.

macOS 15+, universal Apple silicon/Intel, build 180, 2026-11-10. ¥9.9 one-time purchase including future updates, without a subscription. Ad-hoc signed; no Developer ID signature or Apple notarization. Quit the old app and replace it manually using the DMG; retain application data to keep your license, tasks and settings.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.2/NotchCalendar-4.2.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.2/NotchCalendar-4.2.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.2/SHA256SUMS.txt)

## 4.2.1：待办界面自定义与抽屉添加

- 新增待办界面自定义，可选择显示的工具、内容模块和状态，并调整顺序；桌面、刘海和工作台分别保存。
- 默认使用列表视图，可随时切换四象限；日历和统计增加返回待办入口，保留当前筛选。
- 快速添加改为底部抽屉，点击加号展开或收起，也可用红色取消按钮和 Escape 关闭；保留未提交草稿。
- 顶部工具采用圆角按钮与紫色点击反馈；新增图标悬停说明，添加选项排列更紧凑，分类入口更清晰。
- 修正汇总提醒首次点击响应和弹出箭头位置；更多菜单只补充当前隐藏的入口，分组加号在悬停时显示。

macOS 15+，Apple 芯片与 Intel，build 179，2026-11-09。¥9.9 一次买断，含未来更新，无订阅。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动；保留应用数据时沿用原有授权、待办和设置。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.1/NotchCalendar-4.2.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.1/NotchCalendar-4.2.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.1/SHA256SUMS.txt)

## 4.2.1: Custom Todo layouts and drawer entry

- Customize visible tools, content modules and statuses, including their order, independently for the desktop, notch and workspace.
- Start in list view and switch to quadrants when needed. Calendar and statistics now return to tasks while retaining the current filters.
- Add tasks in a bottom drawer. Click the plus again, the red cancel control or Escape to close it without losing the draft.
- Use rounded toolbar buttons with violet feedback and hover descriptions. Compact option icons and a clearer category selector simplify quick entry.
- Improve first-click summary-reminder response and popover alignment. More only lists hidden actions, and group add buttons appear on hover.

macOS 15+, Apple silicon and Intel, build 179, 2026-11-09. CNY 9.90 once, lifetime updates, no subscription. Ad-hoc signed, not Developer ID signed or notarized. Quit the previous app, drag the app from the DMG into Applications and restart. Existing licenses, tasks and settings remain when app data is kept.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.1/NotchCalendar-4.2.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.1/NotchCalendar-4.2.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.1/SHA256SUMS.txt)

## 4.2.0：待办四象限与下一件事

- 新增待办四象限，按重要性与紧急程度整理任务；未设置重要性的任务保留在「待整理」，支持自动或手动判断紧急程度。
- 象限内可按分类分组、折叠和直接新增；支持拖动任务切换分类与象限，或通过菜单移动，并可撤销。
- 新增独立标签管理：保留空标签，支持置顶、排序、重命名和删除；分类与标签可组合筛选。
- 将一项任务设为「下一件事」，在桌面、工作台和刘海同步查看；常驻入口可直接完成或打开任务。
- 优化小尺寸待办排布和隐藏标题时的隐私展示，保留已有任务、分类、提醒与备份兼容性。

macOS 15+，Apple 芯片与 Intel，build 178，2026-11-09。¥9.9 一次买断，含未来更新，无订阅。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动；保留应用数据时沿用原有授权、待办和设置。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.0/NotchCalendar-4.2.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.0/NotchCalendar-4.2.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.0/SHA256SUMS.txt)

## 4.2.0: Todo quadrants and the next task

- Organize tasks by importance and urgency in four quadrants. Tasks without importance stay in Unsorted; urgency can follow the due date or be set manually.
- Group and collapse categories within each quadrant, add tasks directly, and move tasks by dragging or using the menu, with undo.
- Manage a persistent tag library including empty tags, pinning, ordering, renaming and deletion; combine a category with a tag filter.
- Choose one next task shared by the desktop, workspace and notch. The resident entry can open or complete it directly.
- Improve compact Todo layouts and hidden-title privacy while preserving existing tasks, categories, reminders and backup compatibility.

macOS 15+, Apple silicon and Intel, build 178, 2026-11-09. CNY 9.90 once, lifetime updates, no subscription. Ad-hoc signed, not Developer ID signed or notarized. Quit the previous app, drag the app from the DMG into Applications and restart. Existing licenses, tasks and settings remain when app data is kept.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.0/NotchCalendar-4.2.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.0/NotchCalendar-4.2.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.2.0/SHA256SUMS.txt)

## 4.1.2：切页亮度一致与授权指引

- 双指切换刘海页面时，预览与切换到位后的亮度保持一致，减少按钮、图标和内容突然变亮。
- 页面来回切换时保留文件图标、图片缩略图与助理标识，减少重复加载和入场闪动。
- 授权购买页在价格旁直接展示微信付款码，付款入口更容易找到。
- 授权读取失败时提供钥匙串访问、解锁、重启及本机文件恢复指引，并保留作者求助入口。

macOS 15+，Apple 芯片与 Intel，build 177，2026-11-08。¥9.9 一次买断，含未来更新，无订阅。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动；保留应用数据时沿用原有授权、便签和设置。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.2/NotchCalendar-4.1.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.2/NotchCalendar-4.1.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.2/SHA256SUMS.txt)

## 4.1.2: Consistent swipe appearance and activation guidance

- Keep notch page previews and settled pages at a consistent brightness, reducing sudden brightening of controls, icons and content.
- Retain file icons, image thumbnails and the assistant mark when switching pages, reducing repeated loading and entrance flashes.
- Show the WeChat payment code beside the purchase price so it is easier to find.
- Add clearer Keychain access, unlock, restart and local license recovery guidance, with a direct route to contact the author.

macOS 15+, Apple silicon and Intel, build 177, 2026-11-08. CNY 9.90 once, lifetime updates, no subscription. Ad-hoc signed, not Developer ID signed or notarized. Quit the previous app, drag the app from the DMG into Applications and restart. Existing licenses, notes and settings remain when app data is kept.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.2/NotchCalendar-4.1.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.2/NotchCalendar-4.1.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.2/SHA256SUMS.txt)

## 4.1.1：贴边暂存抽屉与可移动入口

- 文件暂存默认在屏幕右上侧露出细边，鼠标移上去滑出托盘图标、「暂存」标签和文件数量；移开后自动收回，点击才打开暂存窗。
- 设置支持「横条 / 侧边标签」两种桌面入口。横条缩短为原来的三分之一；两种入口均支持拖动并记住位置，保留之前选定的位置。
- 侧边入口打开暂存窗时优先向左展开；关闭、Escape 或摇晃唤出后的收起保留文件与选择。空置时隐藏数量角标，减少动态效果时关闭滑动动画。
- 入口适配浅色和深色外观，完善中英文设置、使用说明、键盘与辅助功能操作；不再为了定位入口轮询菜单栏电池位置。

macOS 15+，Apple 芯片与 Intel，build 176。¥9.9 一次买断，含未来更新，无订阅。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动；保留应用数据时沿用原有授权、便签和设置。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.1/NotchCalendar-4.1.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.1/NotchCalendar-4.1.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.1/SHA256SUMS.txt)

## 4.1.1: Edge drawer and movable File Tray entry

- File Tray rests as a thin edge at the upper-right of the screen. Hover to slide out the tray icon, label and file count; move away to retract it, or click to open the tray.
- Choose a horizontal bar or side tab in settings. The bar is one third of its previous width; both entries can be dragged and remember their position, including existing custom placement.
- A side entry opens the tray beside it, preferring the left. Closing, Escape and minimizing after shake reveal preserve files and selection. Empty trays omit the count badge; Reduce Motion disables sliding.
- Refines light/dark appearance, Chinese/English guidance, keyboard and accessibility actions. Positioning no longer polls the menu bar battery.

macOS 15+, Apple silicon and Intel, build 176. CNY 9.90 once, lifetime updates, no subscription. Ad-hoc signed, not Developer ID signed or notarized. Quit the previous app, drag the app from the DMG into Applications and restart. Existing licenses, notes and settings remain when app data is kept.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.1/NotchCalendar-4.1.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.1/NotchCalendar-4.1.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.1/SHA256SUMS.txt)

## 4.1.0：授权指引与桌面文件暂存

- 授权页新增显眼的「本机安装标识」卡片：购买、领码和激活页均可直接复制，并提示连同付款凭证发给作者；读取失败时提供重试和求助资料入口。
- 文件暂存新增桌面收起入口与独立工作区页面，改善打开、收起及定位体验；保留拖住文件摇晃唤出、批量拖出和本次会话暂存。
- 更新后首次进入「今天」可查看本机版本更新卡片，关闭后可从「近期更新」重新打开。
- 改善提醒交互与布局、显示器恢复和刘海窗口状态衔接。

macOS 15+，Apple 芯片与 Intel，build 175。¥9.9 一次买断，含未来更新，无订阅。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动；保留应用数据时沿用原有授权、便签和设置。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.0/NotchCalendar-4.1.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.0/NotchCalendar-4.1.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.0/SHA256SUMS.txt)

## 4.1.0: Clearer activation guidance and desktop File Tray

- A visible installation ID card offers direct copying in every purchase, code-request and activation journey, with receipt instructions and recovery help when the ID is unavailable.
- File Tray gains a desktop handle and a dedicated workspace page, with improved open, minimize and placement behavior. Shake to reveal, batch dragging and session-only collection remain available.
- The Today workspace shows the installed version's release card after an update, with a Recent updates entry to reopen it.
- Refines reminder interactions and layout, display recovery and notch window transitions.

macOS 15+, Apple silicon and Intel, build 175. CNY 9.90 once, lifetime updates, no subscription. Ad-hoc signed, not Developer ID signed or notarized. Quit the previous app, drag the app from the DMG into Applications and restart. Existing licenses, notes and settings remain when app data is kept.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.0/NotchCalendar-4.1.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.0/NotchCalendar-4.1.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.1.0/SHA256SUMS.txt)

## 4.0.5：文件暂存摇晃唤出与使用引导

- 拖住 Finder 中的文件或文件夹并快速来回晃动鼠标，暂存窗会出现在指针旁；保持按住，将文件拖进窗口后松手即可收集。
- 摇晃唤出保留当前应用与键盘焦点；仅识别当前文件拖动，一次拖动只唤出一次，避免普通移动鼠标、拖动窗口或文字时误弹出。
- 「设置 → 数据与文件 → 文件暂存」新增默认开启的摇晃开关、直接打开按钮和收集、选择、批量拖出的三步说明；设置搜索支持「暂存」「摇晃」「悬浮」。
- 「窗口」菜单新增打开悬浮暂存窗入口；原有刘海文件页入口、添加、粘贴、网格和列表操作继续可用。
- 关闭浮窗保留本次暂存，退出应用清空暂存引用；移出与清空不会删除原文件。

macOS 15+，Apple 芯片与 Intel 通用主应用，build 174。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证。DMG 内附中英文安装说明；可选 AI 助理执行组件当前适用于 Apple 芯片。

本版验证手势判定、拖拽会话边界、浮窗定位与焦点、设置说明及现有暂存行为，并核验通用安装包。真实 Finder 连续摇晃拖放、物理触控板、多显示器、VoiceOver、Intel 实机及持续性能仍待人工验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.5/NotchCalendar-4.0.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.5/NotchCalendar-4.0.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.5/SHA256SUMS.txt)

## 4.0.5: Shake to reveal File Tray, with a discoverable guide

- Hold files or folders in Finder and shake the pointer back and forth to reveal a tray beside it. Keep holding, drag into the tray, then release to collect them.
- Reveal the tray without activating superNotch or taking keyboard focus. Only a fresh file drag can trigger it, once per drag; ordinary pointer motion, window dragging and text dragging are ignored.
- Add a default-on shake preference, a direct Open action and a three-step collection, selection and batch-drag guide under Settings → Data & Files → File Tray. Settings search now finds File Tray and shake.
- Add Open floating File Tray to the Window menu. Keep the existing Files page, add, paste, grid and list controls.
- Closing the panel retains this session's references; quitting clears them. Original files stay in place.

macOS 15+, universal Apple silicon/Intel main app, build 174. Ad-hoc signed, without Developer ID signing or Apple notarization. The DMG includes a bilingual installation guide. The optional AI execution component currently supports Apple silicon.

This release validates gesture decisions, drag-session boundaries, panel placement and focus, settings guidance, existing tray behavior and universal packaging. End-to-end physical Finder shake-and-drop, physical trackpad, multiple displays, VoiceOver, physical Intel and sustained performance still need manual acceptance.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.5/NotchCalendar-4.0.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.5/NotchCalendar-4.0.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.5/SHA256SUMS.txt)

## 4.0.4：文件托盘、音乐快捷入口与交互细节打磨

- 新增本次会话的文件托盘，可跨文件夹收集文件引用，使用网格或列表多选、批量复制与拖出，并通过独立浮窗继续操作；移除或清空托盘不会删除原文件。
- 音乐空闲页支持配置常用音乐应用与快捷指令入口，保留已保存的顺序和空列表；点击入口打开应用或运行指定快捷指令，不会自动开启摄像头。
- 编程动态采用单个紧凑胶囊并内嵌额度；低额度提示与详情页统一为黄色／红色，区分未知与已用完，修正活跃任务数量显示。
- 专注建议和签到提醒增加轻微悬停、按压及键盘焦点反馈，按钮保持原位；减少动态效果时关闭按钮过渡。
- 软件更新下载支持取消与重新下载，清理未完成文件；AI 用量页优化窄面板排布，刷新等待不再挤动工具按钮。
- 改善设置搜索和 Return 操作、置顶剪贴板顺序、复制与音乐操作反馈；待办删除、专注重置和托盘清空增加确认，长书签操作自动定位，便签新增后立即进入编辑。

macOS 15+，Apple 芯片与 Intel 通用主应用，build 173。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换。DMG 内附中英文安装说明。可选 AI 助理执行组件当前适用于 Apple 芯片。

本版针对冻结源码重新执行相关回归与通用安装包核验。物理触控板、多显示器、VoiceOver、Intel 实机及持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.4/NotchCalendar-4.0.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.4/NotchCalendar-4.0.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.4/SHA256SUMS.txt)

## 4.0.4: File Tray, music shortcuts and interaction refinements

- Add a session-only File Tray for collecting file references across folders, selecting in grid or list, copying or dragging batches, and continuing in a shared floating panel. Removing or clearing references keeps the original files intact.
- Configure favorite music apps and a Shortcuts entry on the idle music page, preserving saved order and an intentionally empty list. Entries explicitly open an app or run the selected shortcut; they never start the camera automatically.
- Show coding activity and quota in one compact capsule. Low quota uses the same amber/red warnings as details, exhausted and unavailable remain distinct, and active task counts are corrected.
- Add subtle hover, press and keyboard-focus feedback to focus suggestions and check-in reminders without moving buttons. Reduce Motion disables button transitions.
- Cancel and retry update downloads with unfinished-file cleanup. AI usage adapts to narrow panels, and refreshing keeps toolbar controls in place.
- Improve settings search and Return navigation, pinned clipboard ordering, copy and music-command feedback. Confirm task deletion, focus reset and tray clearing; reveal bookmark actions in long lists and start editing newly created timestamp notes.

macOS 15+, universal Apple silicon/Intel main app, build 173. Ad-hoc signed, without Developer ID signing or Apple notarization. Quit the previous app and replace it manually using the DMG; a bilingual installation guide is included. The optional AI assistant execution component currently supports Apple silicon.

Related regression tests and universal-package checks are rerun against this release's frozen source. Physical trackpad, multiple displays, VoiceOver, physical Intel and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.4/NotchCalendar-4.0.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.4/NotchCalendar-4.0.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.4/SHA256SUMS.txt)

## 4.0.3：双指切换稳定性与独立便签

- 修正双指横向切换时邻页偶闪、快速反向跳位和面板整体漂移，重点改善系统监控与便签之间的切换。
- 便签支持独立卡片的新增、编辑、复制、删除与撤销，列表和方格共用内容；保留旧便签文本、自动保存与备份恢复。
- 系统监控重新显示时保留内存和磁盘读数，减少内容跳变。
- 项目报告支持使用已配置模型整理中文提交说明、单独查看历史报告，并改善长内容与 PDF 分页。

macOS 15+，Apple 芯片与 Intel 通用主应用，build 172。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换。DMG 内附中英文安装说明。可选 AI 助理执行组件当前适用于 Apple 芯片。

本版针对冻结源码重新执行相关回归与通用安装包核验。物理触控板、多显示器、VoiceOver、Intel 实机及持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.3/NotchCalendar-4.0.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.3/NotchCalendar-4.0.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.3/SHA256SUMS.txt)

## 4.0.3: Stable two-finger switching and independent scratchpad cards

- Fix intermittent adjacent-page flashes, jumps on rapid reversal and panel drift during horizontal two-finger switching, particularly between System Monitor and Scratchpad.
- Add independent scratchpad cards with creation, editing, copying, deletion and undo. List and grid share the same content, preserving legacy text, autosave and backup restoration.
- Retain memory and disk readings when System Monitor becomes visible again to reduce content jumps.
- Let project reports use your configured model to write commit descriptions in Chinese, provide a dedicated report-history view, and improve long-content and PDF pagination.

macOS 15+, universal Apple silicon/Intel main app, build 172. Ad-hoc signed, without Developer ID signing or Apple notarization. Quit the previous app and replace it manually using the DMG; a bilingual installation guide is included. The optional AI assistant execution component currently supports Apple silicon.

Related regression tests and universal-package checks are rerun against this release's frozen source. Physical trackpad, multiple displays, VoiceOver, physical Intel and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.3/NotchCalendar-4.0.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.3/NotchCalendar-4.0.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.3/SHA256SUMS.txt)

## 4.0.2：待办常驻、图片缩放与提醒默认值修正

- 待办隐藏任务或分类标题时统一显示 `****`，保留原始内容。
- 从桌面开启刘海常驻后，待办卡片立即定位到常驻入口下方；常驻图标仅点击展开，鼠标移过不再自动打开。
- 自定义桌面图片移除蓝色矩形底框，保留图片透明区域；缩放范围扩大到 100%–1000%。
- 喝水提醒默认每 10 分钟一次，舒展提醒默认每 30 分钟一次，保留已保存的有效用户设置。

macOS 15+，Apple 芯片与 Intel 通用主应用，build 171。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换。DMG 内附中英文安装说明。可选 AI 助理执行组件当前适用于 Apple 芯片。

按项目所有者要求，本次跳过回归测试，直接构建打包；仅执行安装包完整性及发布下载核验，不声明功能、界面、硬件或性能回归通过。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.2/NotchCalendar-4.0.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.2/NotchCalendar-4.0.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.2/SHA256SUMS.txt)

## 4.0.2: Todo residency, image scaling and reminder defaults

- Hidden Todo task and category titles consistently display `****` while preserving stored content.
- Enabling notch residency from the desktop immediately positions the Todo card below its resident entry. The entry opens only on click; hovering no longer opens it.
- Remove the blue rectangular backdrop from custom desktop images and preserve transparency. Expand image scaling to 100%–1000%.
- Default water reminders to 10 minutes and movement reminders to 30 minutes, preserving valid saved preferences.

macOS 15+, universal Apple silicon/Intel main app, build 171. Ad-hoc signed, without Developer ID signing or Apple notarization. Quit the previous app and replace it manually using the DMG; a bilingual installation guide is included. The optional AI assistant execution component currently supports Apple silicon.

Regression tests were skipped at the project owner's explicit request. This release performs build, package-integrity and publication/download verification only; no functional, UI, hardware or performance regression pass is claimed.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.2/NotchCalendar-4.0.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.2/NotchCalendar-4.0.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.2/SHA256SUMS.txt)

## 4.0.1：便笺方格可复制编辑，待办和紧凑布局更新

- 便笺支持列表与方格切换，每张方格提供复制和编辑按钮；编辑直接定位原文并取得键盘焦点，保留中文、Emoji、重复内容、多行命令、自动保存和撤销，完成后返回方格。
- 待办新增按需搜索与筛选、同步的常驻开关，以及任务标题和分类标题的独立显示设置；隐藏标题时保留原始数据。
- 优化小伴侣自定义图片尺寸、桌面待办入口与刘海入口的展示和连续操作。
- 调整活动胶囊的多活动溢出、按压反馈、点击区域与编程额度布局；修复溢出菜单关闭时的状态更新时机。
- 改进日历、剪贴板、开发工具、系统监控与助理在紧凑窗口中的排版，保留完整共享工具栏与原有编辑状态。
- 同步当前 SuperNotch 图标、设置分组、卡片和按钮视觉；默认灯光采用双色，保留已保存的用户选择。

macOS 15+，Apple 芯片与 Intel 通用主应用，build 170。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换。DMG 内附中英文安装说明。AI 助理执行组件按需安装，当前适用于 Apple 芯片；模型需要自行配置，待办和日程草稿需确认后写入。

本版执行最新冻结源码的定向回归与通用安装包核验；完整界面回归、硬件、多显示器、VoiceOver、Intel 实机、在线服务和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.1/NotchCalendar-4.0.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.1/NotchCalendar-4.0.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.1/SHA256SUMS.txt)

## 4.0.1: Copy and edit note cards, refined Todo and compact layouts

- Switch Scratchpad between list and grid layouts. Every card has Copy and Edit actions; Edit selects the exact source text and takes keyboard focus. Preserve Unicode, duplicate text, multiline commands, autosave and undo, and return to the grid when done.
- Add on-demand Todo search and filters, synchronized pinning controls, and independent task/category title visibility while preserving stored content.
- Refine custom companion image sizing, desktop and notch Todo entries, and repeated interactions.
- Improve activity overflow, press feedback, hit areas and compact coding usage. Fix state updates when the overflow menu closes.
- Refine compact Calendar, Clipboard, Developer Tools, System Monitor and assistant layouts, retaining the shared toolbar and native editor state.
- Include the current SuperNotch icon, grouped settings, cards and controls. Default lighting uses two colors while preserving saved preferences.

macOS 15+, universal Apple silicon/Intel main app, build 170. Ad-hoc signed, without Developer ID signing or Apple notarization. Quit the previous app and replace it manually using the DMG; a bilingual installation guide is included. The optional assistant execution component currently supports Apple silicon; configure your own model and confirm Todo/calendar drafts before saving.

Fresh targeted regressions and universal package verification are recorded separately. Complete UI, hardware, multiple displays, VoiceOver, physical Intel, live services and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.1/NotchCalendar-4.0.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.1/NotchCalendar-4.0.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.1/SHA256SUMS.txt)

## 4.0.0：统一圆角与更清爽的刘海工具栏

- 收纳最新 superNotch 功能，包括个人助理、会后跟进、项目报告与可选 AI 组件；保留已有日历、待办、便笺、授权数据与更新通道。
- 重新调整刘海顶栏：图标尺寸更轻巧，统一深灰圆形按钮与标题胶囊，便笺采用柔和暖色标识，主页改为线框图标；适配浅色、深色与高对比度。
- 统一待办、剪贴板、文件、编程动态、书签、诗词与助理等操作按钮的圆角、背景与悬停反馈。
- 修复「编程与用量」更多菜单点击区域偏小的问题，让完整按钮区域接受单击，保留原生菜单和键盘操作。
- 调整待办刘海入口的位置与尺寸，让两侧布局更对称；顶栏按钮保留完整点击区域及待办连续开合行为。
- 保留双指切页、原生编辑器状态与紧凑内容布局；DMG 内附中英文安装说明。

macOS 15+，Apple 芯片与 Intel 通用主应用，build 169。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换。AI 助理执行组件按需安装，当前适用于 Apple 芯片；模型需要自行配置，待办和日程草稿需确认后写入。

本版执行冻结源码定向回归与通用安装包核验；完整硬件、多显示器、VoiceOver、Intel 实机、在线服务与持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.0/NotchCalendar-4.0.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.0/NotchCalendar-4.0.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.0/SHA256SUMS.txt)

## 4.0.0: Rounded controls and a refined notch toolbar

- Include the latest superNotch features: personal assistant, meeting follow-ups, project reports and optional AI components, preserving calendar, Todo, notes, licenses and update compatibility.
- Refine the notch toolbar with smaller, lighter symbols, circular dark controls and a capsule title. Notes use a warm accent and Home uses an outline, with light, dark and increased-contrast appearances.
- Unify rounded controls and hover feedback across Todos, Clipboard, Files, coding activity, bookmarks, poetry and assistant tools.
- Fix the small click target of the Coding and Usage options menu so the complete button accepts a single click while preserving native menus and keyboard interaction.
- Align the Todo notch entry for more balanced shoulders; retain complete toolbar click targets and repeated Todo opening and closing.
- Retain swipe navigation, native editor state and compact page sizing. The DMG includes a bilingual installation guide.

macOS 15+, universal Apple silicon/Intel main app, build 169. Ad-hoc signed, without Developer ID signing or Apple notarization. Quit the previous app and replace it manually using the DMG. The optional assistant execution component currently supports Apple silicon; configure your own model and confirm Todo/calendar drafts before saving.

Frozen-source targeted regressions and universal package verification are recorded separately. Full hardware, multiple displays, VoiceOver, physical Intel, live services and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.0/NotchCalendar-4.0.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.0/NotchCalendar-4.0.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.0.0/SHA256SUMS.txt)

## 3.6.0：superNotch、个人助理与安装引导

- 应用名称、图标、工作台和设置统一为 superNotch，保留已有日历、待办、授权和更新通道。
- 新增个人助理、会后跟进与项目报告，可导入材料、生成待办草稿，并在确认后添加待办或日程；支持文件与关注任务，能力按需开启。
- AI 助理组件独立下载、校验和安装，主应用保持轻量；当前执行组件适用于 Apple 芯片，Intel 可使用原生日历、待办和普通模型聊天。
- 优化 AI 用量与编程动态的紧凑展示、助理活动提示、悬停描边和灯光设置，保留用户已有选择。
- 调整待办面板、专注、音乐歌词、行情、剪贴板、开发工具与设置的排版和操作反馈，改进切页与编辑状态保留。
- 优化授权恢复与领码入口、首次默认配置；待办支持自定义标题，打卡提醒采用刘海通知胶囊。
- DMG 新增中英文「安装说明.txt」，说明首次打开、系统拦截、隔离属性命令及旧版应用路径。

macOS 15+，Apple 芯片与 Intel 通用主应用，build 168。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；请退出旧应用后使用 DMG 手动替换。助理需要配置可用模型及安装配套组件，写入待办或日程需要用户确认。

本版执行冻结源码定向回归与通用安装包核验；完整硬件、多显示器、VoiceOver、Intel 实机、在线模型质量与持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.6.0/NotchCalendar-3.6.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.6.0/NotchCalendar-3.6.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.6.0/SHA256SUMS.txt)

## 3.6.0: superNotch, personal assistant and installation guide

- Adopt the superNotch name and icon across the app, workspace and Settings while retaining existing data, licenses and update compatibility.
- Add a personal assistant, meeting follow-ups and project reports, with imported materials, Todo drafts and calendar drafts confirmed before saving. Enable file and watch capabilities as needed.
- Download, verify and install the optional AI assistant component separately. Its current execution component supports Apple silicon; Intel retains the native calendar, Todos and regular model chat.
- Refine compact AI usage, coding activity, assistant status, hover outlines and lighting settings while respecting saved preferences.
- Improve Todo panels, focus, lyrics, markets, clipboard, developer tools and Settings, including navigation and retained editing state.
- Improve license recovery and claim access, initial defaults, custom Todo headings and notch check-in notifications.
- Include a bilingual installation guide in the DMG with first-launch help, quarantine commands and legacy app paths.

macOS 15+, universal Apple silicon/Intel main app, build 168. Ad-hoc signed, without Developer ID signing or Apple notarization. Quit the previous app and replace it manually through the DMG. Assistant execution requires a configured model and its optional component; Todo and calendar writes require confirmation.

Frozen-source targeted regressions and universal package verification are recorded for this release. Full hardware, multiple displays, VoiceOver, physical Intel, online-model quality and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.6.0/NotchCalendar-3.6.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.6.0/NotchCalendar-3.6.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.6.0/SHA256SUMS.txt)

## 3.3.10：待办日历与统计、自定义入口和切换优化

- 待办新增任务、日历与统计视图：搜索标题、分类、标签、备注和子任务，可按截止时间、优先级或创建时间排序。
- 日历支持周/月切换，按完成日期或截止日期回看任务；统计展示本周、本月和分类完成进度。旧任务保留未知的历史时间，不补造记录。
- 设置合并为「待办与小伴侣」，可选对号、小伴侣、自定义图片或隐藏桌面入口；图片本机导入，支持替换、移除和备份恢复。
- 优化双指切换与页面保留：切回便笺保留编辑内容、选区和撤销，隐藏编辑器停止接收输入；截屏等紧凑页面按内容调整高度。
- 修复切换工具后重新展开刘海时的动画衔接，首次展开过程中的高度更新不再打断当前动画。

macOS 15+，Apple 芯片与 Intel 通用包，build 160。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

定向回归与通用安装包核验单独记录。真实触控板手感、完整硬件、多屏、VoiceOver、Intel 实机与持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.10/NotchCalendar-3.3.10-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.10/NotchCalendar-3.3.10-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.10/SHA256SUMS.txt)

## 3.3.10: Todo calendar and statistics, custom entry images, smoother navigation

- Todo gains task, calendar and statistics views, search across task details and subtasks, and sorting by due date, priority or creation time.
- Browse weekly/monthly calendars by completion or due date, with weekly, monthly and category progress. Legacy tasks keep unknown historical timestamps.
- Unified Todo & Companion settings offer checkmark, companion, custom image or hidden desktop entries. Import, replace, remove and back up images locally.
- Retained pages preserve scratchpad text, selection and undo when switching back; hidden editors stop accepting input. Compact command pages fit their content.
- Fix reopening animation continuity after tool changes; height updates during the initial reveal preserve the running animation.

macOS 15+, universal Apple silicon and Intel package, build 160. Ad-hoc signed, without Developer ID signing or Apple notarization. Quit the old app and replace it manually using the DMG.

Targeted regressions and package checks are recorded separately. Physical trackpad, full hardware, multiple displays, VoiceOver, Intel device and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.10/NotchCalendar-3.3.10-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.10/NotchCalendar-3.3.10-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.10/SHA256SUMS.txt)

## 3.3.9：双指切换、待办排序与工作台新入口

- 在展开的刘海面板双指左右滑动，按自定义菜单顺序切换功能；首次展开显示一次手势提示。保留内容滚动优先级，避免惯性连跳和悬停抢切。
- 待办分类支持拖拽或上下移动排序，桌面、刘海与工作台共用并保存顺序；未分类也可参与排序。
- 待办时间选择改为紧凑的原生滚动列表，小时和分钟可直接点选，避免过长的下拉菜单。
- 待办桌面入口单击立即开关，快速连续点击也能响应；拖动入口不会误触开关。
- 主工作台新增待办和截屏/录屏入口，支持侧边栏与 ⌘7 / ⌘8 快捷键，复用现有任务、截图历史与录屏状态。

macOS 15+，Apple 芯片与 Intel 通用包，build 159。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

定向回归与通用安装包核验单独记录。真实触控板手感、完整硬件、多屏、VoiceOver、Intel 实机与持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.9/NotchCalendar-3.3.9-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.9/NotchCalendar-3.3.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.9/SHA256SUMS.txt)

## 3.3.9: Two-finger navigation, Todo sorting and workspace tools

- Swipe horizontally with two fingers across the expanded notch to switch tools in your custom order. Show a one-time hint on first opening, preserve content scrolling, and prevent momentum or hover from changing the selection again.
- Reorder Todo categories by dragging or moving them up and down. Persist one order across the desktop panel, notch and workspace, including Unsorted.
- Choose Todo hours and minutes from compact native scrolling lists instead of long menus.
- Toggle the desktop Todo entry immediately with a click, including rapid successive clicks, while keeping dragging separate from activation.
- Open Todo and screenshot/recording tools from the workspace sidebar or ⌘7 / ⌘8, sharing the existing tasks, capture history and recording state.

macOS 15+, universal Apple silicon/Intel, build 159. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Targeted regression and universal package verification are recorded separately. Physical trackpad feel, full hardware, multi-display, VoiceOver, physical Intel and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.9/NotchCalendar-3.3.9-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.9/NotchCalendar-3.3.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.9/SHA256SUMS.txt)

## 3.3.8：待办分类、截图历史与菜单栏优化

- 待办支持删除整个分类及其中所有状态的任务和子任务，操作前展示数量并二次确认；未分类可单独清空，空分类也可从分类菜单删除。
- 截图与录屏历史自动移除已删除或移走的文件，打开历史时同步刷新；隐藏后停止监听，多个窗口分别管理可见状态。
- 编程动态与 AI 用量在未保存开关设置时默认启用，保留用户手动关闭的选择。
- 菜单栏收纳条缩小图标与按钮间距，隐藏横向滚动条，保留键盘导航和溢出访问。

macOS 15+，Apple 芯片与 Intel 通用包，build 158。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

删除分类会永久删除其中的任务和子任务，无法撤销。定向回归与通用安装包核验单独记录；完整硬件、多屏、VoiceOver、Intel 实机及持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.8/NotchCalendar-3.3.8-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.8/NotchCalendar-3.3.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.8/SHA256SUMS.txt)

## 3.3.8: Todo categories, capture history and menu bar refinements

- Delete a Todo category and its tasks and subtasks across all statuses after reviewing the count and confirming. Clear unsorted tasks separately and delete empty categories from the category menu.
- Remove deleted or moved screenshots and recordings from history automatically. Reconcile on opening, stop monitoring while hidden, and track visibility separately for each window.
- Enable coding activity and AI usage by default when no toggle preference exists, while retaining explicit opt-outs.
- Make the menu bar shelf more compact with smaller icons and spacing. Hide horizontal scroll bars while keeping keyboard navigation and overflow access.

macOS 15+, universal Apple silicon/Intel, build 158. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Deleting a category permanently removes its tasks and subtasks and cannot be undone. Targeted regression and universal package verification are recorded separately. Full hardware, multi-display, VoiceOver, physical Intel and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.8/NotchCalendar-3.3.8-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.8/NotchCalendar-3.3.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.8/SHA256SUMS.txt)

## 3.3.7：待办准时提醒与汇总修复

- 设定截止时间默认准点提醒，手动关闭后保存；旧版仅设日期的任务也采用准点默认。
- 修复专注计时、待处理打卡导致待办不提醒的问题；刘海两侧被占用时，在摄像头下方显示提醒胶囊。
- 同一时刻到期的多项任务合并提醒，其他时刻依次展示；汇总默认每天，包含所有未完成任务并显示逾期数量。
- 汇总按设定时刻触发，修改时间后重新排期；刘海内对号正确开关桌面待办浮窗，保留刘海与草稿。

macOS 15+，Apple 芯片与 Intel 通用包，build 157。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

提醒需要应用保持运行；展开面板、睡眠或锁屏时最多延迟 30 分钟，超时不补发。旧汇总设置迁移为每天，保留开关与时间，之后可手动选择仅工作日或关闭。旧版空提醒列表无法区分默认未开启与手动关闭；升级后按准点默认，今后的手动关闭会保存。

定向验证覆盖待办计划、持久化、原生提醒队列与占位布局，并核验通用安装包。完整硬件、多屏、VoiceOver、Intel 实机和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.7/NotchCalendar-3.3.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.7/NotchCalendar-3.3.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.7/SHA256SUMS.txt)

## 3.3.7: Reliable Todo deadlines and daily summaries

- Enable on-time reminders when a deadline is set, including older dated tasks without a reminder selection. Save explicit opt-outs.
- Deliver Todo reminders during focus sessions and pending check-ins. Use a capsule below the camera when the notch shoulders are occupied.
- Combine tasks with the same reminder time and queue other times. Default summaries to every day, including all unfinished tasks and an overdue count.
- Trigger summaries at the selected time and reschedule after time edits. Make the notch checkmark toggle desktop Todos while preserving the notch and draft.

macOS 15+, universal Apple silicon/Intel, build 157. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Reminders require the app to remain running. Expanded panels, sleep or screen lock can delay delivery for up to 30 minutes. Older summaries migrate to daily while retaining their enabled state and time; weekdays and off remain selectable. Older empty reminder selections cannot distinguish an implicit default from an intentional opt-out; they adopt on-time reminders, and future opt-outs are saved.

Targeted validation covers Todo scheduling, persistence, native reminder queues and occupied-notch placement, plus universal packaging. Full hardware, multi-display, VoiceOver, physical Intel and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.7/NotchCalendar-3.3.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.7/NotchCalendar-3.3.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.7/SHA256SUMS.txt)

## 3.3.6：待办界面与提醒优化

- 收紧任务详情与汇总提醒面板，日期和小时、分钟可直接选择；新增截止时间默认当天 17:00。
- 修复提醒预览被收起动画取消的问题；新设置截止时间时默认准点提醒，可手动关闭。
- 桌面与刘海待办同步优化日期、四状态导航、按钮与输入提示；分类默认「工作」，移除重复详情入口、多余箭头和撤销功能。
- 输入提示按空间调整字号，窄窗口可完整显示两行；收起后保留未发送草稿。

macOS 15+，Apple 芯片与 Intel 通用包，build 156。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版验证待办状态与保存、时间选择、任务与汇总提醒、桌面及真实刘海原生交互，并核验通用安装包。提醒需要应用保持运行；休眠、锁屏或其他功能占用时可能延迟。完整硬件、多屏、VoiceOver、Intel 实机和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.6/NotchCalendar-3.3.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.6/NotchCalendar-3.3.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.6/SHA256SUMS.txt)

## 3.3.6: Refined Todo controls and reminders

- Compact task details and summary settings, with calendar and hour/minute selection. A new deadline defaults to today at 5 pm.
- Fix reminder previews being cancelled by the notch collapse animation. New deadlines enable an on-time reminder by default, which can be turned off.
- Refine dates, status tabs, buttons and input guidance in both desktop and notch Todo views. Default to Work and remove duplicate detail actions, extra arrows and Todo undo.
- Adapt hint text to available space, with two lines in narrow windows. Keep unfinished drafts when collapsed.

macOS 15+, universal Apple silicon/Intel, build 156. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Validation covers Todo state and persistence, time selection, individual and summary reminders, native desktop/notch interactions and universal packaging. Reminders require the app to remain running and may be delayed during sleep, screen lock or other activity. Full hardware, multi-display, VoiceOver, physical Intel and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.6/NotchCalendar-3.3.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.6/NotchCalendar-3.3.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.6/SHA256SUMS.txt)

## 3.3.5：剪贴板内存与收起态性能优化

- 图片历史恢复只加载索引，列表按显示尺寸生成缩略图，收起后释放图片缓存。
- 预览与复制时按需读取原图；复制保留原始图片质量，原图不可用时保留剪贴板现有内容。
- 优化编程动态彩色描边的动画驱动，降低刘海收起时的 CPU 消耗，并在不可见时停止动画。

macOS 15+，Apple 芯片与 Intel 通用包，build 155。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

验证覆盖剪贴板迁移、持久化、原图复制、缩略图与原生展开/收起，以及描边和音乐动画的定向回归与通用安装包。剪贴板独立模块的 16.8 MiB 图片历史样本中，恢复内存增量中位数由 17.83 MiB 降至 0.70 MiB；不代表整机应用总内存降幅。已知旧基线两项交互测试仍失败，一次编程动态诊断唤醒率超出预算；完整硬件、多屏、休眠唤醒、VoiceOver、Intel 实机和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.5/NotchCalendar-3.3.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.5/NotchCalendar-3.3.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.5/SHA256SUMS.txt)

## 3.3.5: Clipboard memory and compact-mode performance

- Restore image-history metadata without retaining all original images. Load display-sized thumbnails and release image caches when collapsed.
- Read original images for preview or copying. Preserve original copy quality and keep the existing pasteboard when an original is unavailable.
- Move the coding activity spectral rim to compositor animation, reduce CPU work while collapsed and stop motion when hidden.

macOS 15+, universal Apple silicon/Intel, build 155. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Validation covers clipboard migration, persistence, original copying, thumbnails, native expansion/collapse, selected rim/music regressions and universal packaging. An isolated clipboard fixture with 16.8 MiB of images reduced median restore memory growth from 17.83 MiB to 0.70 MiB; this is not a whole-app memory claim. Two interaction tests also fail on the old baseline, and one coding diagnostic exceeded its wakeup budget. Full hardware, multi-display, sleep/wake, VoiceOver, physical Intel and sustained performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.5/NotchCalendar-3.3.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.5/NotchCalendar-3.3.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.5/SHA256SUMS.txt)

## 3.3.4：优化版重新发行

- 重新构建当前优化版的 Apple 芯片与 Intel 通用安装包。
- 保留约 1.48 MB 的无损欢迎演示素材、全部原生操作帧与原始播放时间。
- 保留后台内存位图预解码，让星空、彩色文字、转场与真实功能演示流畅播放。

运行功能代码与 3.3.3 一致，本次更新版本号、构建号及发行资料。

macOS 15+，Apple 芯片与 Intel 通用包，build 154。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本次重新验证版本升级引导、原生素材解码及通用安装包。相同运行代码的中英文欢迎、完整原生录屏及像素核对沿用最近一次已验证证据。安装后实机、多屏、睡眠唤醒、VoiceOver 语音、Intel 实机与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.4/NotchCalendar-3.3.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.4/NotchCalendar-3.3.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.4/SHA256SUMS.txt)

## 3.3.4: Optimized package reissue

- Rebuild the current optimized universal package for Apple silicon and Intel.
- Keep approximately 1.48 MB of lossless welcome media, all native operation frames and original playback timestamps.
- Keep background decoding into memory bitmaps for smooth starfield, text, transitions and native feature demos.

Runtime feature code matches 3.3.3; this release updates version labels, build labels and distribution documents.

macOS 15+, universal Apple silicon/Intel, build 154. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Version-upgrade onboarding, native media decoding and universal packaging are verified again. Recent Chinese/English welcome, full native recording and pixel-equality evidence is reused for identical runtime code. Installed-device, multi-display, sleep/wake, VoiceOver speech, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.4/NotchCalendar-3.3.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.4/NotchCalendar-3.3.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.4/SHA256SUMS.txt)

## 3.3.3：欢迎动画安装包瘦身

- 欢迎演示素材从 13.1 MB 缩小至 1.48 MB，使用系统原生支持的无损 WebP 动画保存重复区域。
- 保留全部原生操作帧、播放时间与 Retina 显示精度；逐帧核对 macOS 原生解码后的像素一致性。
- 动画仍按屏幕刷新节奏推进，后台提前解码，保持星空、彩色文案与真实功能演示。

macOS 15+，Apple 芯片与 Intel 通用包，build 153。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版验证中英文原生欢迎窗口、全部压缩帧的原生解码、完整窗口录屏及通用安装包。安装后实机、多屏、睡眠唤醒、VoiceOver 语音、Intel 实机与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.3/NotchCalendar-3.3.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.3/NotchCalendar-3.3.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.3/SHA256SUMS.txt)

## 3.3.3: A smaller welcome download

- Reduce welcome media from 13.1 MB to 1.48 MB by storing repeated image regions in native lossless WebP animations.
- Keep every native operation frame, original playback timestamp and Retina display resolution. Verify pixel equality for every frame decoded by macOS ImageIO.
- Keep display-synchronized playback and background predecoding for the starfield, colorful text and real feature demos.

macOS 15+, universal Apple silicon/Intel, build 153. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Validation covers Chinese and English native welcome windows, native decoding of all packed frames, a complete WindowServer recording and universal packaging. Installed-device, multi-display, sleep/wake, VoiceOver speech, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.3/NotchCalendar-3.3.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.3/NotchCalendar-3.3.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.3/SHA256SUMS.txt)

## 3.3.2：全新刘海欢迎动画

- 欢迎介绍直接从屏幕顶部的真实贴边刘海展开，外部透明，内部使用星空、彩色文字与光幕揭开效果。
- 通过当前原生界面介绍日历、待办、小镜子、截屏、菜单栏收纳、窗口分屏与文件功能。
- 场景动画按屏幕刷新节奏推进；提前解码演示图片，重新连续采集原生操作，让转场与待办补位更流畅。
- 保留暂停、上一幕、章节跳转和跳过，支持键盘与减少动态效果。最后一幕为「欢迎试用，祝你开心每一天」。

macOS 15+，Apple 芯片与 Intel 通用包，build 152。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版验证中英文原生欢迎窗口、键盘与暂停交互、完整窗口录屏及通用安装包。录屏为本机验证，不代表所有设备帧率保证；安装后实机、多屏、睡眠唤醒、VoiceOver 语音、Intel 实机与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.2/NotchCalendar-3.3.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.2/NotchCalendar-3.3.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.2/SHA256SUMS.txt)

## 3.3.2: A new welcome inside the notch

- Open the welcome from the actual screen edge, with transparent surroundings, a starfield, colorful text and a light reveal inside the notch.
- Introduce Calendar, Todo, Mirror, Capture, menu bar organization, window layouts and Files using current native interfaces.
- Drive scene motion with the display refresh, decode demo images in advance and recapture native interactions continuously for smoother transitions and task movement.
- Pause, revisit chapters or skip; keyboard navigation and Reduce Motion remain available. Finish with “Welcome to your trial. Wishing you joy every day.”

macOS 15+, universal Apple silicon/Intel, build 152. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Validation covers Chinese and English native welcome windows, keyboard and pause interactions, a complete WindowServer recording and universal packaging. Local recording does not guarantee every device's frame rate. Installed-device, multi-display, sleep/wake, VoiceOver speech, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.2/NotchCalendar-3.3.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.2/NotchCalendar-3.3.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.2/SHA256SUMS.txt)

## 3.3.1：修复刘海待办详情与点击响应

- 待办详情改为按钮旁的原生浮层，打开时刘海窗口保持原位，避免大弹窗造成错位。
- 修复关闭详情后下一次点击失效，详情与「···」完整按钮区域均可点击；支持取消、Esc、显式保存和切换页面时关闭。
- 同步最新文件页面紧凑布局与路径控件尺寸，并保留 3.3.0 的隔空投送接收层修复。

macOS 15+，Apple 芯片与 Intel 通用包，build 151。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版从当前完整工作区冻结构建输入，执行真实刘海窗口、待办详情与原生菜单、文件拖放和通用安装包定向验证。安装后实机、多屏、睡眠唤醒、VoiceOver、Intel 实机、跨设备接收与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.1/NotchCalendar-3.3.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.1/NotchCalendar-3.3.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.1/SHA256SUMS.txt)

## 3.3.1: Fix notch Todo details and click response

- Open task details in a native popover beside its button, keeping the notch window in place.
- Fix the next click becoming unresponsive after closing details. The entire details and more-action buttons accept clicks; Cancel, Escape, explicit Save and page changes dismiss the editor correctly.
- Include the latest compact Files layout and path controls, while retaining the 3.3.0 AirDrop receiver fix.

macOS 15+, universal Apple silicon/Intel, build 151. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release freezes all current workspace build inputs and runs targeted real-notch, Todo editor/native-menu, file-drag and universal-package validation. Installed-device, multi-display, sleep/wake, VoiceOver, physical Intel, cross-device reception and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.1/NotchCalendar-3.3.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.1/NotchCalendar-3.3.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.1/SHA256SUMS.txt)

## 3.3.0：修复隔空投送拖放无响应

- 修复文件拖到隔空投送浮层后松手无响应的问题，接收区域覆盖整个浮层。
- 悬停时显示「松开以隔空投送」，松手后打开 macOS 系统接收人窗口；原文件保留在原位置。
- 补回 3.2.9 正式包遗漏的接收层修复，并将修复源码与本版安装包绑定，保留日历直达待办、连续开关和紧凑布局等既有改进。

macOS 15+，Apple 芯片与 Intel 通用包，build 150。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行完整刘海窗口的原生拖放、文件与待办定向回归，并独立核验通用安装包。相同接收层修复已在本机安装的 3.2.9 本地修复版确认可打开系统接收人窗口；该实测不等同于 3.3.0 安装后验收。跨设备接收、多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.0/NotchCalendar-3.3.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.0/NotchCalendar-3.3.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.0/SHA256SUMS.txt)

## 3.3.0: Restore responsive AirDrop dragging

- Fix dropping a file onto the floating AirDrop target producing no response. The native receiver covers the entire floating target.
- Show Release to AirDrop while hovering, then open the macOS recipient chooser after release. Original files stay in place.
- Restore the receiver fix omitted from the 3.2.9 package and bind it to this release's frozen inputs. Retain Calendar-to-Todo navigation, repeated toggling and compact layouts.

macOS 15+, universal Apple silicon/Intel, build 150. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release runs full-notch native drag, Files and Todo regressions plus independent universal-package verification. The same receiver fix opened the real macOS chooser in the installed 3.2.9 local repair; that check is not installed 3.3.0 acceptance. Cross-device reception, multi-display, sleep/wake, VoiceOver, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.0/NotchCalendar-3.3.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.0/NotchCalendar-3.3.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.3.0/SHA256SUMS.txt)

## 3.2.9：日历直达待办与按钮开关修复

- 日历「查看全部」左侧新增「待办」入口，在刘海内查看、添加和编辑同一份待办；切换日历和待办保留未发送草稿。
- 修复刘海对号再次点击无法收起待办的问题，固定与未固定状态均可连续开关；通知与显式打开操作继续保持打开。
- 刘海待办采用紧凑布局，更多完整任务保持可见；对齐任务行的详情与更多操作图标。

macOS 15+，Apple 芯片与 Intel 通用包，build 149。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行待办开关、日历导航、编辑与草稿保留的定向回归及原生布局检查，并独立核验通用安装包。多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.9/NotchCalendar-3.2.9-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.9/NotchCalendar-3.2.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.9/SHA256SUMS.txt)

## 3.2.9: Calendar-to-Todo navigation and reliable toggling

- Add a Todo entry beside View all in Calendar. View, add and edit the shared tasks inside the notch, retaining unsent drafts when switching pages.
- Fix repeated clicks on the notch checkmark failing to close Todo, including pinned panels. Notifications and explicit Open actions keep their existing open behavior.
- Use a compact notch Todo layout to show more complete tasks, and align the task details and more-actions icons.

macOS 15+, universal Apple silicon/Intel, build 149. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release runs targeted Todo toggle, Calendar navigation, editing, draft-retention and native layout checks plus independent universal-package verification. Multi-display, sleep/wake, VoiceOver, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.9/NotchCalendar-3.2.9-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.9/NotchCalendar-3.2.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.9/SHA256SUMS.txt)

## 3.2.8：翻译栏对称与专注页留白

- 翻译语言选择器改为等宽胶囊，围绕交换按钮紧凑居中，修复间隔过大和左右不对称。
- 拉开专注统计、时长选项和开始按钮之间的距离，随窗口高度调整留白，操作按钮完整可见。
- 小尺寸计时圆环调整文字留白，完整显示倒计时和准备状态。

macOS 15+，Apple 芯片与 Intel 通用包，build 148。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行翻译与专注页的定向回归及原生布局检查，并独立核验通用安装包。多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.8/NotchCalendar-3.2.8-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.8/NotchCalendar-3.2.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.8/SHA256SUMS.txt)

## 3.2.8: Balanced translation controls and more room for Focus

- Center equal-width language capsules around the swap button, fixing excessive gaps and uneven alignment.
- Add space between Focus totals, duration choices and Start, adapting to window height while keeping actions visible.
- Adjust text padding in small timer rings to show the complete countdown and ready state.

macOS 15+, universal Apple silicon/Intel, build 148. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release runs targeted translation and Focus regressions, native layout checks and independent universal-package verification. Multi-display, sleep/wake, VoiceOver, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.8/NotchCalendar-3.2.8-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.8/NotchCalendar-3.2.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.8/SHA256SUMS.txt)

## 3.2.7：独立待办与刘海胶囊提醒

- 新增独立待办入口，默认显示在桌面右上角，也可选择小猫、小狗或隐藏入口。
- 新建待办可直接填写时间、优先级、重复、提醒、标签与备注；回车保存，一句话识别日期后仍可调整。
- 新增定时汇总未完成待办；汇总和单条到点提醒共用刘海胶囊。刘海两侧被占用时，胶囊显示在刘海下方。
- 点击汇总打开未完成列表，点击单条提醒打开任务详情；完成、暂缓、取消或删除后同步收起提醒。

待办与提醒设置保存在本机，支持备份。刘海胶囊需要应用保持运行，无需系统通知权限；休眠或退出期间无法保证准时提醒。

macOS 15+，Apple 芯片与 Intel 通用包，build 147。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行待办存储、入口、添加、汇总、单条提醒与原生胶囊回归，并检查通用安装包。当前 Mac 已实测两种胶囊提醒；多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/NotchCalendar-3.2.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/NotchCalendar-3.2.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/SHA256SUMS.txt)

## 3.2.7: Independent To-Dos and notch capsule reminders

- Open To-Dos from a standalone checkmark at the top right of the desktop, or choose a cat, dog, or hidden entry.
- Set dates, priority, recurrence, reminders, tags and notes while adding a task; press Return to save and adjust dates detected from natural language.
- Schedule unfinished-task summaries. Both summaries and individual reminders use notch capsules, moving below the notch when its sides are occupied.
- Click a summary to open unfinished tasks or an individual capsule to open task details. Completing, deferring, cancelling or deleting a task dismisses its reminder.

Tasks and reminder preferences stay on this Mac and support local backup. Capsules require the app to remain running and do not require system notification permission; punctual delivery during sleep or while the app is closed is not guaranteed.

macOS 15+, universal Apple silicon/Intel, build 147. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release runs To-Do persistence, entry, composer, summary, individual reminder and native capsule regressions plus independent package checks. Both capsule types were exercised on the current Mac; multi-display, sleep/wake, VoiceOver, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/NotchCalendar-3.2.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/NotchCalendar-3.2.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/SHA256SUMS.txt)

## 3.2.6：修复重复的菜单栏入口

- 修复收纳开启时同时出现两个「…」入口：原生按钮可见时立即撤下悬浮兜底按钮。
- 收纳面板跟随实际点击的按钮；原生入口恢复时同步交接，不再指向另一个「…」。
- 仅在确认原生入口被隐藏后显示兜底按钮，沿用菜单栏的实际高度与原位置中心。

macOS 15+，Apple 芯片与 Intel 通用包，build 146。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版检查当前系统的原生入口可见性，并执行真实 AppKit 控制器交接、点击锚点、关闭与图标像素回归及独立安装包检查。系统隐藏动作使用隔离测试替身；完整第三方隐藏兼容性、多屏、睡眠唤醒、VoiceOver、Intel 实机和持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/NotchCalendar-3.2.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/NotchCalendar-3.2.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/SHA256SUMS.txt)

## 3.2.6: Fix duplicate menu bar entries

- Remove the floating fallback immediately when the native organizer entry is visible, preventing two ellipsis buttons.
- Anchor the shelf to the button actually clicked and hand it back when the native entry returns.
- Show a fallback only after confirming the native entry is hidden; preserve the rendered menu bar height and slot center.

macOS 15+, universal Apple silicon/Intel, build 146. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release checks native entry visibility on the current system and runs AppKit controller handoff, click-anchor, dismissal, glyph pixel and independent package checks. Hiding actions use isolated test doubles; full third-party hiding compatibility, multi-display, sleep/wake, VoiceOver, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/NotchCalendar-3.2.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/NotchCalendar-3.2.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/SHA256SUMS.txt)

## 3.2.5：分屏边界与菜单栏入口修复

- 修复分屏面板两侧选区溢出，选区和文字按外壳边界留出一致间距。
- 修复从宽面板进入分屏时残留缩放、拖放位置不一致的问题，切换后恢复正确尺寸与落点。
- 修复菜单栏「…」点击后跳到刘海旁的问题，优先保持原位置，临时被占用后可回到原位。
- 修复菜单栏「…」偏上，三个圆点在不同菜单栏高度下保持水平、垂直居中，并保留原生入口图标。

macOS 15+，Apple 芯片与 Intel 通用包，build 145。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行分屏几何、原生面板切换、落点和图标像素居中测试及独立安装包检查。完整多屏拖窗、系统菜单栏隐藏兼容性、睡眠唤醒、VoiceOver、Intel 实机和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/NotchCalendar-3.2.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/NotchCalendar-3.2.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/SHA256SUMS.txt)

## 3.2.5: Window arrangement and menu bar fixes

- Keep window arrangement zones and labels inside the panel edges with consistent padding.
- Reset retained scaling when switching from a wide panel, keeping visible zones and drop targets aligned.
- Keep the menu bar organizer entry in its original slot and return after a temporary obstruction.
- Center the three dots horizontally and vertically at different menu bar heights, and preserve the native entry icon.

macOS 15+, universal Apple silicon/Intel, build 145. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release runs focused geometry, native panel transitions, drop target and icon pixel checks plus independent package verification. Full physical multi-display dragging, system menu bar hiding compatibility, sleep/wake, VoiceOver, physical Intel and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/NotchCalendar-3.2.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/NotchCalendar-3.2.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/SHA256SUMS.txt)

## 3.2.4：更舒展的界面，更平稳的收起

- 统一行情、计算器、便签、工具库及设置等页面的安全边距，内容与操作按钮不再紧贴外缘。
- 缩小底部导航的视觉占用，保留点击区域，让底部间隙和外壳圆角完整显露。
- 修复收起时导航闪现与材质残影，主面板、内容和背景按同一提交时钟完成过渡，快速反向操作仍然连贯。
- 修复空白便签输入首字后意外切换阅读模式，编辑、草稿和选择范围可持续保留。
- 提供语音日程输入、化妆镜与天气陪伴，以及整合 DeepSeek 网页、API、编程动态和额度的 AI 工作台。日程在确认后才写入日历，摄像头按需授权，镜面画面不保存、不上传。

macOS 15+，Apple 芯片与 Intel 通用包，build 144。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版对冻结输入执行原生界面、收起动效、草稿保留及安装包检查。完整多屏、睡眠唤醒、VoiceOver、Intel 实机、真实麦克风与摄像头和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/NotchCalendar-3.2.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/NotchCalendar-3.2.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/SHA256SUMS.txt)

## 3.2.4: More breathing room and smoother retraction

- Apply safe insets across markets, calculator, notes, the tool library and settings.
- Reduce the bottom navigation's visual footprint while retaining click targets, exposing the shell corners and a clear bottom gap.
- Fix navigation flashes and material remnants during collapse. Shell, content and surface transitions share the commit clock, including rapid reversals.
- Keep new blank notes editable after the first character and preserve drafts and selections.
- Include voice scheduling, a mirror with weather, and an AI workbench combining DeepSeek Web, API chat, coding activity and quotas. Calendar writes require confirmation; camera access is optional and mirror frames are neither saved nor uploaded.

macOS 15+, universal Apple silicon/Intel, build 144. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Native UI, retraction, draft retention and package checks use frozen inputs. Full multi-display, sleep/wake, VoiceOver, physical Intel, real microphone/camera and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/NotchCalendar-3.2.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/NotchCalendar-3.2.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/SHA256SUMS.txt)

## 3.2.3：小伴侣悬停更稳定

- 移除“掉下来”动画及设置、右键菜单中的入口，鼠标悬停时保持原位。
- 展开功能面板、打开待办或鼠标停在小伴侣上时暂停自动活动，避免准备点击时突然绕圈或下沉。
- 自动计时器触发前再次检查交互状态；鼠标移开后重新等待完整空闲间隔。
- 保留主动双击跑一圈、拖拽留位或回家、滑滑梯、召唤及刘海避让，更新中英文行为说明。

macOS 15+，Apple 芯片与 Intel 通用包，build 143。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版对冻结输入执行小伴侣交互、原生设置与安装包检查。完整多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/NotchCalendar-3.2.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/NotchCalendar-3.2.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/SHA256SUMS.txt)

## 3.2.3: A steadier companion on hover

- Remove the drop-down animation and its settings and context-menu entries. Hovering now keeps the companion in place.
- Pause automatic activities while expanded panels or tasks are open, or while the pointer is over the companion, preventing surprise walks or downward motion before a click.
- Recheck interaction state when the automatic timer fires. Leaving the companion starts a fresh idle interval.
- Keep explicit double-click walks, drag placement or return, rope slides, summons and notch avoidance. Update the Chinese and English behavior help.

macOS 15+, universal Apple silicon/Intel, build 143. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Companion interaction, native settings and package checks use frozen inputs. Full multi-display, sleep/wake, VoiceOver, physical Intel and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/NotchCalendar-3.2.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/NotchCalendar-3.2.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/SHA256SUMS.txt)
