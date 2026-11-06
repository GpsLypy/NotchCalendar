# SuperNotch 4.0.2

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
