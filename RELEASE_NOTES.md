# Notch Calendar 2.0.9

macOS 15+ · Apple Silicon and Intel · build 92 · 2026-10-18

## 文件左右分栏与列表

- 文件浮窗默认使用左右分栏：左侧显示个人收藏与添加文件夹，右侧显示文件列表。紧凑尺寸下仍保留侧栏，并根据可用宽度收起次要列。
- 在「设置 → 数据与文件 → 文件浮窗 → 文件布局」选择分栏或列表。列表模式通过个人收藏按钮切换目录、添加或管理收藏。
- 切换保留当前目录、选中文件与滚动位置，不移动或删除原文件；文件布局随本地备份恢复，目录访问授权仍仅在本机保存。

## 功能栏位置与可见工具

- 在「设置 → 通用设置 → 刘海功能栏」选择顶部或底部，默认保留底部。顶部位于头部控制栏下方，避开实体摄像头区域；切换不改变正文可用空间，保留原生编辑器、草稿与选区。
- 自选是否显示专注、文件、便笺、音乐、计算器、剪贴板和 AI 聊天入口。日历始终显示；文件仍需先启用文件浮窗。
- 隐藏入口不删除数据、不停止计时或音乐，也不取消进行中的聊天请求。当前工具被隐藏时回到日历，重新启用入口后可继续访问。
- 文件布局、功能栏位置与可见入口立即保存，并支持本地备份的导出、恢复和撤销；旧备份缺少这些设置时使用分栏、底部和全部可用入口。

## 中文简报

- 信息差简报新增少数派与 IT之家公开 RSS，保留 GitHub Blog、Swift.org 与 NASA。选择全部／中文／英文查看对应来源，语言选择保存在本机。
- 先筛选语言，再应用最多 20 条的展示上限。切换到不兼容的语言时清空当前来源选择，来源按钮与状态也随语言更新。
- 保留发布者原文标题、原始日期和原文链接；中文内容来自发布者订阅源，不依赖英文机器翻译。继续提供本地搜索、阅读状态、收藏、30 分钟缓存与单源失败降级，不加载远端全文或图片。

## 验证与安装

发布前 218 项定向测试以独立进程串行执行：216 项通过、2 项可选联网／Finder 集成检查跳过、零失败；21 项 Python 质量检查通过，本地 Release 产品构建通过。覆盖文件布局切换后的目录、选择与滚动位置，功能栏位置与工具可见性，原生设置保存，备份恢复与撤销，以及中英文简报筛选。原生窗口使用隔离数据，包含中英文与紧凑尺寸交互；本轮通过的是独立进程运行模式，同进程原生测试仍存在状态干扰。

少数派和 IT之家实际 RSS 请求均返回 HTTP 200，生产解析器分别接受 10 条和最新 20 条文章。这是独立下载与生产解析验证，不等同于应用内完整联网会话；常规测试中的联网检查仍按默认跳过。本轮不是整应用全量回归，也不构成硬件帧率或长期性能结论。实体刘海屏、外接屏、休眠唤醒、真实 VoiceOver、完整简报联网会话、真实模型与播放器、旧用户钥匙串迁移和完整付款发码仍待完整验收。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/NotchCalendar-2.0.9-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/NotchCalendar-2.0.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/SHA256SUMS.txt)

退出旧版，将 DMG 中的应用拖入「应用程序」替换并重新启动。通用安装包支持 Apple 芯片与 Intel，最低 macOS 15；沿用 ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。独立更新窗口不代表本版支持自动替换安装。

沿用 7 天试用、¥9.9 一次买断与人工领码流程。更新不会重新开始试用或授予永久授权；保留本机应用数据时，永久授权与聊天 API Key 继续使用原有保存方式。

## English

- Files defaults to a split layout with favorites and Add folder on the left and files on the right. Compact panels retain the sidebar and hide secondary columns as needed. Choose split or list in Settings → Data & Files; list mode uses the favorites button for folder selection and management.
- Switching file layouts preserves the current folder, selected file and scroll position without moving or deleting files. Local backups include the layout preference; folder-access permissions remain on this Mac.
- Choose a top or bottom dock in Settings → General → Notch toolbar. Bottom remains the default. The top dock sits below the header controls, outside the camera area; changing position retains content space, native editors, drafts and selection.
- Choose whether Focus, Files, Scratchpad, Music, Calculator, Clipboard and AI Chat appear. Calendar always remains available; Files still requires File Shelf to be enabled. Hiding an entry keeps its data and ongoing timers, playback and Chat requests. Hiding the current tool returns to Calendar; showing it again restores access.
- Save file layout, dock position and visible tools immediately, with local-backup export, restore and undo. Older backups without these preferences restore split layout, bottom placement and all available tools.
- Add SSPai and ITHome public RSS feeds to Briefing alongside GitHub Blog, Swift.org and NASA. Save an All / Chinese / English filter locally and apply it before the 20-headline limit. Changing language clears only an incompatible selected source, and updates source buttons and statuses.
- Keep publishers’ original headlines, dates and links without machine-translating English titles. Retain local search, reading state, bookmarks, 30-minute caching and partial-source recovery, without loading full articles or remote images.

Prepublication validation ran 218 targeted cases serially in separate processes: 216 passed, two optional live-network/Finder integration checks skipped, zero failures. All 21 Python quality checks and the local Release product build passed. Coverage includes retained folder, selection and scroll state across layout changes; dock placement and tool visibility; native settings persistence; backup restore and undo; and Chinese/English filtering. Native windows use isolated data and include compact sizes in both languages. The passing run uses separate processes; shared-process native tests still have state interference.

Live RSS requests to SSPai and ITHome returned HTTP 200; the production parser accepted 10 and the newest 20 articles respectively. These separate download/parser checks do not establish a complete in-app live-client session; the ordinary network test remains skipped by default. This is not a full-app regression or evidence of hardware frame rate or sustained performance. Physical notches, external displays, sleep/wake, real VoiceOver, complete live Briefing sessions, real models and players, upgraded-user Keychain migration and the complete payment/code-delivery flow remain pending complete acceptance.

Quit the old app, replace it in Applications using the DMG, and relaunch. Universal macOS 15+ package for Apple silicon and Intel; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. The independent update window does not enable automatic app replacement for this release.

The seven-day trial, ¥9.9 one-time purchase and manual activation-code delivery remain in place. Updating does not restart the trial or grant a permanent license. Keeping local app data preserves the existing permanent-license and Chat API key storage.

Previous release: [2.0.8](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.8).
