# Notch Calendar 3.0.2

## 3.0.2：收纳栏系统配色与外屏歌词交互

- 收纳栏图标和设置齿轮跟随系统前景色：浅色外观为黑色、深色外观为白色，修复整排图标变蓝的问题。
- 无刘海屏幕的紧凑播放条默认显示当前逐句歌词；保留手动关闭的选择，没有同步歌词时显示歌名。
- 长歌词横向滚动，换行时回到行首；暂停、隐藏或开启系统“减少动态效果”后停止滚动。
- 外接无刘海显示器上的音乐／歌词胶囊支持悬停展开，移开后收起；保留点击打开。
- 便捷工具在未固定时随鼠标离开收起，已启动的倒计时和秒表继续运行。

macOS 15+，Apple 芯片与 Intel 通用包，build 125。状态栏收纳需要 macOS 27、安装到“应用程序”并授予辅助功能权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后用 DMG 手动替换安装。

按所有者最新要求，本次停止追加验证，直接构建发布；未执行最终回归或独立安装包验收，也未进行性能采样。开发阶段分别完成收纳栏原生点击／排序与明暗显示、紧凑歌词同步、便捷工具收起后计时保留、实际外屏悬停及歌词合成层滚动检查；不将这些过程记录表述为完整发行回归通过。完整第三方播放、全屏、真实休眠唤醒、VoiceOver 和 Intel 实机流程未验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/NotchCalendar-3.0.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/NotchCalendar-3.0.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/SHA256SUMS.txt)

## 3.0.2: System tray colors and external-display lyric interactions

- Keep tray glyphs and the settings gear black in light appearance and white in dark appearance, fixing inherited blue button tint.
- Enable timed lyrics by default in the compact player on displays without a notch. Preserve an explicit off preference and fall back to the track title when timed lyrics are unavailable.
- Scroll overflowing lyric lines horizontally and restart at each new line. Stop scrolling when paused, hidden or Reduce Motion is enabled.
- Reveal external-display music and lyric capsules on hover and retract after pointer exit; click opening remains available.
- Retract unpinned Quick Tools after pointer exit while keeping started countdowns and stopwatches running.

macOS 15+, universal Apple silicon and Intel, build 125. Tray organization requires macOS 27, installation in Applications and Accessibility permission. Ad-hoc signed; not Developer ID signed or Apple notarized. Quit the old app and replace it manually using the DMG.

At the owner’s latest request, additional validation was stopped and this version was built for direct publication. Final regression, independent package acceptance and performance sampling were not run. Development checks separately covered native tray controls and appearances, lyric synchronization, Quick Tools dismissal with a retained countdown, hover on a physical external display and actual compositor lyric movement. These development results are not a complete frozen-release regression pass. Full third-party playback, full-screen, real sleep/wake, VoiceOver and Intel hardware workflows remain unaccepted.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/NotchCalendar-3.0.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/NotchCalendar-3.0.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/SHA256SUMS.txt)

## 3.0.1：便捷工具与原生交互打磨

- 新增便捷工具：独立倒计时、秒表、保持唤醒和只读电池状态，可从功能库或 `⌥⌘K` 打开。保持唤醒默认关闭，支持定时结束。
- 无刘海屏幕的紧凑播放条可显示当前逐句歌词。在「设置 → 刘海 → 交互」开启；默认关闭，无可用歌词时显示歌名，保留原有胶囊尺寸。
- 刘海玻璃内卡与外壳采用一致的材质层次，顶栏左右控件靠两侧对齐，保留摄像头中央留白；展开与收起更利落，阅读内容保持稳定。
- 日历工具栏在窄窗口下自动分行，保持时区、新建日程等操作可见；调整窗口时保留当前控件与时区弹出面板。
- 专注页切换横向和纵向布局时保留任务输入框、选区和尚未完成的输入法组合。
- 补齐快捷搜索、关闭和更多工具按钮的悬停、按下与键盘焦点反馈；侧栏显示快捷键时不再挤动文字。状态栏收纳采用单色图标并改善明暗外观下的可读性。

macOS 15+，Apple 芯片与 Intel 通用包，build 124。状态栏收纳需要 macOS 27、安装到“应用程序”并授予辅助功能权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

最终源码完成 67 项定向功能检查：66 通过、1 项可选截图跳过、0 失败，包含原生鼠标与键盘交互、调整窗口时输入法状态保留，以及真实窗口合成与动效检查。未执行全应用回归；按所有者要求不进行性能采样。外接屏完整流程、全屏、真实睡眠唤醒、VoiceOver、Intel 实机和持续能耗未验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/NotchCalendar-3.0.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/NotchCalendar-3.0.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/SHA256SUMS.txt)

## 3.0.1: Quick tools and refined native interactions

- Add Quick Tools with an independent countdown, stopwatch, Keep Awake and read-only battery status. Open it from the Tool Library or `⌥⌘K`. Keep Awake is off by default and supports timed sessions.
- Optionally show the current timed lyric in the compact music capsule on displays without a notch. Enable it in Settings → Notch → Interaction. The option is off by default, falls back to the track title and preserves the capsule size.
- Give the glass shell and inset cards consistent material depth, align the top controls to both sides and preserve the camera's clear center. Refine opening and closing motion while keeping reading content stable.
- Reflow the calendar toolbar in narrow windows so time-zone and event actions remain visible. Preserve the existing controls and time-zone popover during resizing.
- Preserve the focus task field, selection and unfinished input method composition when switching between horizontal and vertical layouts.
- Add consistent hover, press and keyboard-focus feedback to command search, close and More Tools buttons. Keep sidebar labels steady when shortcuts appear. Use monochrome organizer icons with clearer light and dark appearances.

macOS 15+, universal Apple silicon/Intel, build 124. The menu bar organizer requires macOS 27, installation in Applications and Accessibility permission. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

The final runtime source completed 67 targeted functional checks: 66 passed, one optional capture skipped and zero failed. Coverage includes native mouse and keyboard interaction, input method state during resizing, and real WindowServer composition and motion. A full application regression was not run. Performance sampling was omitted at the owner's request. Complete external-display workflows, full screen, real sleep/wake, VoiceOver, Intel runtime and sustained energy remain unvalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/NotchCalendar-3.0.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/NotchCalendar-3.0.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/SHA256SUMS.txt)

## 3.0.0：主窗口展开更稳定，通知中心单击打开

- 修复从刘海打开主窗口时出现首帧空白和跳闪：显示前完成目标页面布局，保持已保存的窗口尺寸。
- 修复收纳开启时，第一次点击日期时间只闪现图标、需要重复点击才能打开通知中心的问题；关闭后恢复收纳，再次单击仍可打开。
- 包含当前代码中的完整日历、专注、音乐、文件、便笺、AI 对话、开发工具和系统监控功能。检查更新继续使用本仓库的 GitHub 官方 Release API。

macOS 15+，Apple 芯片与 Intel 通用包，build 123。状态栏收纳需要 macOS 27、安装到“应用程序”并授予辅助功能权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。若更新后辅助功能授权未沿用，请重新添加并开启当前应用。

本次发布按所有者要求停止性能采样，不追加回归或独立安装包验收。停止指令前已完成 109 项主窗口、菜单栏及更新逻辑相关测试：108 通过、1 项可选截图跳过、0 失败。未将中断或不完整的性能样本记为通过。完整应用回归、多屏、全屏、真实睡眠唤醒、VoiceOver、Intel 实机运行及持续能耗仍未验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/NotchCalendar-3.0.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/NotchCalendar-3.0.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/SHA256SUMS.txt)

## 3.0.0: Stable workspace opening and one-click Notification Center

- Fix the empty first frame and flicker when opening the main window from the notch. Lay out the requested page before presentation and preserve the saved window size.
- Fix the first date/time click only flashing collected icons. Open Notification Center with one click, restore collection after closing, and allow the next single click to reopen it.
- Include the current calendar, focus, music, files, notes, AI chat, developer tools and system monitor. Update checks continue to use this repository's official GitHub Release API.

macOS 15+, universal Apple silicon/Intel, build 123. The menu bar organizer requires macOS 27, installation in Applications and Accessibility permission. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG. Re-add Accessibility permission if macOS does not retain it after updating.

At the owner's request, performance sampling was stopped and no additional regression or independent package acceptance was performed. Before that instruction, 109 targeted window, menu-bar and update tests completed: 108 passed, one optional capture skipped, zero failures. Interrupted or incomplete performance samples are not counted as passed. Full application regression, multiple displays, full screen, real sleep/wake, VoiceOver, Intel runtime and sustained energy remain unvalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/NotchCalendar-3.0.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/NotchCalendar-3.0.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/SHA256SUMS.txt)

## 2.0.37：修复收纳开启后无法打开通知中心

- 修复开启状态栏收纳后，点击右上角日期时间无法打开通知中心的问题。
- 点击日期时间时暂时显示已收纳图标，通知中心关闭后恢复收纳；保留原有收纳选择和顺序。
- 普通鼠标经过和新通知不会主动展开已收纳图标。

菜单栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限；其他功能支持 macOS 15+。Apple 芯片与 Intel，build 120。ad-hoc 签名，未进行 Apple 公证；退出旧版后使用 DMG 手动替换安装。

验证：53 项菜单栏相关定向检查通过，1 项可选截图测试跳过，0 失败；本机同一修复源码的通知中心打开行为已由用户确认。未重复全应用回归，多显示器、全屏、真实睡眠唤醒及关闭通知中心后的现场恢复仍待验；Intel 仅验证通用包结构。十二轮独立 Release 探针采样通过原定 CPU、p95 和唤醒预算；821 项源码、架构、签名及归档检查通过。探针使用隔离数据和空 AX 菜单夹具，不代表真实跨应用收纳或系统总能耗验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/NotchCalendar-2.0.37-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/NotchCalendar-2.0.37-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/SHA256SUMS.txt)

## 2.0.37: Fix Notification Center with the menu bar organizer enabled

- Fix unresponsive date/time clicks when the menu bar organizer is enabled.
- Temporarily show collected icons while opening Notification Center and restore collection after it closes, preserving saved choices and order.
- Hovering over the clock and incoming notifications do not expand collected icons.

The organizer requires macOS 27, installation in Applications and Accessibility permission; other features support macOS 15+. Apple silicon and Intel, build 120. Ad-hoc signed without Apple notarization; quit the old app and replace it manually using the DMG.

Validation: 53 targeted menu-bar-related checks passed, one optional screenshot test skipped, zero failures. The owner manually confirmed Notification Center opening on the same fix source. The full application regression was not repeated. Multiple displays, full screen, real sleep/wake and live recollection after panel dismissal remain unvalidated; Intel receives static package checks only. All 12 independent Release probe runs met the original CPU, p95 and wakeup budgets; 821 source, architecture, signature and archive checks passed. The probe uses isolated data and an empty AX menu fixture; this is not live cross-app collection or total-system energy acceptance.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/NotchCalendar-2.0.37-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/NotchCalendar-2.0.37-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/SHA256SUMS.txt)

## 2.0.36：安装包瘦身与后台资源优化

- 精简分发程序中的调试与本地符号，保留 Apple 芯片和 Intel 通用支持，并在安装包外保留匹配的崩溃调试符号。
- 主工作台改为首次打开时创建；关闭剪贴板记录或菜单栏收纳后，停止相应后台轮询与自动扫描。
- AI 用量改为增量读取日志并限制内存中保留的历史记录，兼顾会话分支、回退和异常恢复；重复模型的价格解析复用结果。
- 剪贴板图片独立保存，历史记录在后台串行写入，减少重复图片编码与主线程磁盘操作，并保留迁移及故障恢复。
- 修复调整窗口宽度时今日节奏输入框的输入法组合文本和选区丢失。
- 优化音乐唱片和节奏动画的持续刷新开销，保持旋转速度与相位，暂停、隐藏或减少动态效果时停止相应动画。
- 修复刘海收起或切页时原生编辑器与输入法的交接顺序，保留剪贴板搜索、便笺与聊天草稿。
- 在通用设置中提供独立的“开机自启动”开关，并显示系统授权状态。

macOS 15+，Apple 芯片与 Intel，build 119。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

完整 Swift 回归执行 1,337 项：1,281 通过、56 跳过、0 失败。Release 隔离探针的六种场景各采样两轮，每轮至少 30 秒，十二轮均通过原 CPU、p95 与唤醒预算。物理内置刘海屏上的自动原生输入验证共 114 项检查通过；通用候选包的 295 项静态与归档检查通过，本地候选 app / DMG / ZIP 分别为 24.65 / 11.68 / 10.51 MB。

探针使用合成数据与空 AX 菜单夹具，未覆盖已安装应用的全部服务或系统总能耗；原生输入检查属于自动化，非人工或正式安装包全流程验收，Intel 仅作静态验证。六项硬件检查仍待验收：内置屏真实睡眠 / 唤醒、外屏悬停 / 点击 / 活动 / 键盘，以及跨屏唤醒。实际重启 / 登录后的自启动、跨设备 AirDrop、VoiceOver、真实服务与持续能耗也未标记通过，WindowServer / GPU 未单独测量。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/NotchCalendar-2.0.36-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/NotchCalendar-2.0.36-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/SHA256SUMS.txt)

## 2.0.36: Smaller packages and less background work

- Strip debug and local symbols from distributed binaries while preserving universal Apple silicon/Intel support and matching crash debugging symbols outside the app.
- Create the main workspace on first presentation. Stop clipboard polling and automatic menu-bar scans when their features are disabled.
- Read AI usage logs incrementally, bound historical records kept in memory, and reuse model price lookups while preserving session branches, rewinds and error recovery.
- Store clipboard images separately and serialize history writes in the background, reducing repeated image encoding and main-thread disk work with migration and recovery safeguards.
- Preserve input method composition and selection in the daily rhythm editor when resizing the window.
- Reduce continuous refresh work in record and rhythm animations, preserving rotation speed and phase while stopping motion when paused, hidden or reduced motion is requested.
- Fix native editor and input method handoff when collapsing the notch or changing pages, retaining clipboard search, notes and chat drafts.
- Add an independent launch-at-login switch in General settings with system approval status.

macOS 15+, Apple silicon and Intel, build 119. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

The full Swift regression executed 1,337 tests: 1,281 passed, 56 skipped and zero failed. The isolated Release probe measured six scenarios twice, at least 30 seconds per run; all 12 runs met the original CPU, p95 and wakeup budgets. Automated native input on a physical built-in notched display passed 114 checks. The universal candidate passed 295 static/archive checks; local candidate app / DMG / ZIP sizes are 24.65 / 11.68 / 10.51 MB.

The probe uses synthetic data and an empty AX menu fixture; it does not cover all installed-app services or total system energy. Native input checks are automated, not manual or end-to-end installed-release acceptance; Intel checks are static only. Six hardware checks remain pending: real built-in-display sleep/wake, external-display hover/click/activity/keyboard and cross-screen wake. Actual reboot/login for launch at login, cross-device AirDrop, VoiceOver, live services and sustained energy use are also unvalidated. WindowServer/GPU work is not measured separately.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/NotchCalendar-2.0.36-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/NotchCalendar-2.0.36-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/SHA256SUMS.txt)

## 2.0.35：全部刘海面板视觉统一

- 统一全部 14 个刘海工具及工具库、隔空投送等子面板的圆角、字体、留白和背景层级，暗色内容更清楚，浅色图标更易辨认。
- 改进底部 Dock 的激活状态、按钮悬停反馈和面板过渡，保留减少动态效果、高对比度和减少透明度支持。
- 优化日历日期与日程布局、文件列表与投送区、翻译双栏和语言菜单、计算器轻字重结果及实心等号按钮。
- 同步打磨专注、速记、音乐、剪贴板、AI 对话、行情、资讯、开发工具、系统监控与 AI 用量。
- 修复窄窗下深层文件名被挤压、DeepSeek 工具栏超宽，以及 AI 用量卡片和保存按钮越界。

macOS 15+，Apple 芯片与 Intel，build 118。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试。此前开发阶段 108 项回归通过、1 项真实 AirDrop 拖动测试跳过，另有 7 项外观测试通过及 28 张原生面板截图复查。实际跨设备 AirDrop、多屏、睡眠唤醒、VoiceOver、真实服务与持续能耗仍待验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/SHA256SUMS.txt)

## 2.0.35: A consistent finish across every notch panel

- Unify all 14 notch tools, the tool library and supporting panels with consistent corners, system typography, spacing and surface depth. Improve dark-mode clarity and light-mode symbol contrast.
- Refine active Dock items, button hover feedback and panel transitions while preserving reduced motion, increased contrast and reduced transparency.
- Improve calendar hierarchy, file lists and AirDrop, translation columns and language menus, and the calculator's light result digits and filled equals button.
- Polish Focus, Scratchpad, Music, Clipboard, AI Chat, Markets, News, Developer Tools, System Monitor and AI Usage.
- Fix narrow-window clipping of deeply nested filenames, the DeepSeek toolbar, AI Usage cards and the credential save button.

macOS 15+, Apple silicon and Intel, build 118. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

No additional release regression was run at the owner's request. Prior development work passed 108 regression tests, skipped one live AirDrop drag test, and passed seven appearance tests with 28 native panel screenshots reviewed. Cross-device AirDrop, multiple displays, sleep/wake, VoiceOver, live services and sustained resource use remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/SHA256SUMS.txt)

## 2.0.34：通知期间保持收纳，改善菜单兼容

- 通知弹出、经过时钟或打开系统面板时，不再主动把已收纳图标恢复到系统菜单栏。
- 原生菜单在对应收纳图标下方打开，改善点击无响应和菜单出现在屏幕左上角的问题；保留菜单勾选、快捷键、分隔线与子菜单。
- 对无法直接打开自定义弹窗的应用，提供明确标注的「应用菜单」入口。豆包使用此入口，暂不提供原自定义快捷面板。
- 新增输入法图标收纳。电池、时钟、控制中心和天气暂不支持收纳，继续保留在系统菜单栏。
- 保留原有收纳选择与排列；关闭收纳、退出或权限失效时恢复图标。

状态栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限。应用其他功能支持 macOS 15+。

Apple 芯片与 Intel，build 117。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试或现场验收。此前开发阶段完成 31 项定向测试，以及同程管家、sftpty、豆包应用菜单和输入法的本机集成检查。这些记录不等同于新发布回归；通知点击与完整收纳栏鼠标、截图验收仍未完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/SHA256SUMS.txt)

## 2.0.34: Keep icons collected during notifications and improve menu compatibility

- Notifications, clock-area interaction and system panels no longer deliberately return collected icons to the system menu bar.
- Native menus open below the corresponding tray button, improving unresponsive clicks and menus appearing at the upper-left corner. Checkmarks, shortcuts, separators and submenus are preserved.
- Apps whose custom popups cannot open directly offer an explicitly labelled application-menu fallback. Doubao uses this fallback; its original custom quick panel is not provided.
- Added collection for Input Sources. Battery, clock, Control Center and Weather remain in the system menu bar and cannot currently be collected.
- Preserve collection choices and ordering. Disabling the organizer, quitting or losing permission restores icons.

The organizer requires macOS 27, installation in Applications and Accessibility permission. Other features support macOS 15+.

Apple silicon and Intel, build 117. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

No additional release regression tests or live acceptance were run, as requested by the owner. Prior development work passed 31 targeted tests and checked native integration for Tongcheng, sftpty, Doubao application menus and Input Sources. This is separate from frozen-release regression; notification-click, full tray mouse-click and screenshot acceptance remain incomplete.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/SHA256SUMS.txt)

## 2.0.33：收纳图标留在收纳栏

- 点击收纳图标直接打开原应用菜单，图标继续保留在收纳栏，不再临时移回系统菜单栏。
- 修复隐藏状态切换后点击没有反应的问题；原生菜单关闭后可以再次打开，常驻悬浮窗不会阻塞后续操作。
- 鼠标悬停或经过右上角时钟区域时保持收纳；真实系统面板交互仍保留临时暂停。
- 修复刘海小伴侣的小狗头被系统菜单栏遮挡的问题。
- 保留已有收纳应用选择与排列；系统菜单栏项目暂不支持收纳。

状态栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限。应用其他功能支持 macOS 15+。

Apple 芯片与 Intel，build 116。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试或现场验收。此前开发阶段的 27 项定向测试通过，并完成 Pulse、Docker 原生菜单的两轮打开与关闭检查；收纳栏完整鼠标点击和截图验收受系统捕捉限制，未标记为通过。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/SHA256SUMS.txt)

## 2.0.33: Keep collected icons in the tray

- Open the original app menu directly while keeping its icon collected, without temporarily returning it to the system menu bar.
- Fixed unresponsive clicks after visibility changes. Menus can open again after closing, and persistent floating panels no longer hold the menu session open.
- Keep icons collected when hovering over or passing the clock area, while preserving temporary suspension during actual system panel interaction.
- Fixed the notch companion's dog head being covered by the system menu bar.
- Preserve saved collection choices and ordering. Collecting macOS system items is not yet supported.

The organizer requires macOS 27, installation in Applications and Accessibility permission. Other features support macOS 15+.

Apple silicon and Intel, build 116. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

No additional release regression tests or live acceptance were run, as requested by the owner. Prior development work passed 27 targeted tests and checked two open/close cycles of the real Pulse and Docker menus. Full shelf mouse-click and screenshot acceptance was blocked by system capture and is not marked as passed.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/SHA256SUMS.txt)
