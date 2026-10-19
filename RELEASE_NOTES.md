# Notch Calendar 2.0.11

- 刘海新增「翻译」（⌥⌘T）：自动检测原文语言、选择目标语言、交换语言、复制译文；支持图片导入、粘贴和拖入文字识别。宽窗口双栏、窄窗口上下排列，切页保留草稿。使用 macOS Translation 与 Vision，无需配置 API Key；首次翻译可能需要系统下载语言包。
- 新增「隔空投送」（⇧⌘R）：拖入或选择本机文件／文件夹，再在 macOS 系统窗口选择接收设备。最多暂存 50 项，支持移除、清空和取消后重试，不移动或删除原文件。
- 默认鼠标在功能图标上停留约 160 毫秒即可切换，快速经过不触发；图标保持固定宽度。可在「设置 → 通用设置 → 刘海功能栏」关闭，继续使用点击和原有 ⌘1–0。系统菜单、文件选择与分享期间暂停悬停切换。
- 主窗口将情报台、舆论室和信息差简报整合为「资讯」（⌘5），提供最新／热门／收藏，以及来源、语言、未读和搜索筛选；保留已有收藏、已读、笔记与立场，旧入口进入对应分段。自选行情仍独立保留（⌘6）。
- 修复屏幕参数频繁变化时喝水、舒展提醒反复重新计时的问题；重新定位窗口时保留到期时间和正在展示的提醒。
- 经典模式顶部功能栏与窗口操作合并为一行，移除重复标题，给正文增加 38 点高度；保持窗口尺寸及原生编辑状态。

## 验证与安装

已完成通用构建、本地 ZIP／DMG 完整内容核验、3 项桌面集中复验及 21 项 Python 质量测试。按发布者要求停止其余回归并直接发布，未完成整组回归或实体硬件验收；不宣称全量测试通过。

本机尚未安装翻译语言包，实际译文与首次下载流程未完成实测；布局截图中的译文为测试数据。真实图片文字识别和系统隔空投送窗口取消恢复已验证，未向其他设备发送文件。资讯使用隔离数据验证，完整发布者／HN 联网、实体刘海、外接屏、休眠唤醒、真实 VoiceOver 与静置 CPU／能耗仍待验收。原生编辑中已有系统 WritingToolsUI 状态发布诊断尚未消除，已测输入、保存、重开与切页通过。

macOS 15+，Apple 芯片与 Intel，build 94。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证，自动替换安装仍禁用。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动。更新不会重置试用；保留本机应用数据时继续使用已有授权与聊天 API Key。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/NotchCalendar-2.0.11-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/NotchCalendar-2.0.11-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/SHA256SUMS.txt)

## English

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

Previous release: [2.0.10](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.10).
