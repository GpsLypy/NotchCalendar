# Notch Calendar 1.8.2

macOS 15+ · Apple 芯片与 Intel · build 75 · 2026-10-13

## 更新内容

- **歌词与红心收藏**：音乐页显示匹配当前录音的同步歌词，居中突出当前行；暂停、重开和调整尺寸保留对应位置。网易云音乐可点击红心收藏或取消收藏，需辅助功能授权，确认实际状态后才更新红心。
- **操作更连贯**：收藏等待时保留心形，收藏与播放请求分开处理；播放、切歌及进度控件不再因短暂请求一起置灰闪动。
- **更充分使用弹窗空间**：优化标准与紧凑排布，未来安排独立滚动；「查看全部」显示完整日程及标题，空日程展示全宽月历，并明确显示日程开始与结束时间。
- **保留编辑状态**：便笺切页及收起重开保留选区与编辑状态，隐藏编辑器不再进入当前页面的无障碍树。

歌词仅在找到匹配录音时提供；红心收藏目前支持网易云音乐。

## 下载与验证

下载 [DMG 安装包](https://github.com/GpsLypy/NotchCalendar/releases/download/v1.8.2/NotchCalendar-1.8.2-macos.dmg)，退出旧版后拖入「应用程序」替换，再重新启动。另提供 ZIP 与 SHA-256 校验文件。采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。

Swift 全量执行 515 项：492 项通过，23 项按需或环境跳过，零失败；21 项 Python 质量检查与 31 项音乐定向检查通过。紧凑与标准尺寸的原生画面对比检查确认收藏等待期间画面不变、确认后仅红心变化。主应用、更新器、小组件及音乐桥接库均为 arm64/x86_64 通用构建；本地签名、安装包内容与 SHA-256 检查通过。

最终交互修复的实机复验尚未完成；进度拖拽、外部收藏同步、完整实体屏幕矩阵、真实休眠唤醒与登录、静置性能、VoiceOver、钥匙串弹窗、真实付款激活及 Apple Music/Spotify 兼容性仍待验收。

## English

Version 1.8.2 adds matched synchronized lyrics and NetEase Cloud Music favorites to Music. The current lyric remains centered after pausing, reopening and resizing. The heart requires Accessibility permission and changes only after the player's actual state is confirmed. Lyrics depend on a matching recording; favorites currently support NetEase Cloud Music.

Favorite requests preserve the heart and run independently from playback. Short commands no longer dim transport controls and progress together. Compact and standard panels make better use of space: upcoming events scroll independently, a complete agenda displays full titles, and empty days use a full-width month. Scratchpad selection and editing survive tab changes and close/reopen; hidden editors stay out of the active page's accessibility tree.

The full Swift suite executed 515 tests: 492 passed, 23 optional/environment checks skipped, zero failures. All 21 Python quality checks and 31 targeted music checks passed. Native pixel comparisons cover held favorite requests at compact and standard sizes. Universal arm64/x86_64 app, updater, widget and music bridge, local signatures, package contents and SHA-256 checks passed.

Final live acceptance of the interaction fix is incomplete. Pointer dragging, external favorite synchronization, the full physical-display matrix, real sleep/wake/login, stationary performance, VoiceOver, Keychain dialogs, live payment/activation and Apple Music/Spotify compatibility remain pending. This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization.

---

# Notch Calendar 1.8.1

> **Manual installation / 手动安装：** Open the DMG, drag Notch Calendar to Applications, then relaunch it. Automatic app replacement remains disabled in this release. / 打开 DMG，将 Notch Calendar 拖入“应用程序”，然后重新启动；此版本仍未启用自动替换安装。

## [1.8.1] - 2026-10-13

macOS 15+ · Apple Silicon and Intel · build 74 · Ad-hoc signed, manual installation; no Developer ID signing or notarization.

### Added / 新增

- Add regression coverage for turning reminders off, disabled startup with pending items, wake/day changes, preference reload, and reenabling without duplicate check-ins. / 增加关闭提醒、带待办启动、唤醒与跨日、重新读取设置及重新开启不重复打卡的回归验证。

### Fixed / 修复

- Turning off check-in reminders now immediately hides both the notch capsule and reminder panel and stops new reminders. The disabled state is honored on wake, day changes and app restarts; existing pending records are retained. / 关闭打卡提醒后，刘海胶囊与提醒弹窗立即隐藏，并停止生成新提醒；唤醒、跨日和重启均遵守关闭状态，已有待打卡记录保留。
- Honor the off state saved by earlier versions, whose switch only controlled launching at login. Reenabling restores pending items without reopening details automatically or repeating completed check-ins. / 兼容旧版已保存的关闭状态，修复原开关只控制登录启动的问题；重新开启后恢复待打卡项，不自动展开详情，也不重复已完成的打卡。

### Changed / 调整

- Rename the setting to “Enable check-in reminders,” explain its login and reminder behavior, and disable time controls while reminders are off. / 开关改为「启用打卡提醒」，明确登录启动与关闭后的行为；关闭时禁用时间设置。

### Validation / 验证

- The full Swift suite executed 496 tests: 473 passed, 23 optional/environment checks skipped, zero failures. All 21 Python quality checks and 14 targeted check-in tests passed. / Swift 全量测试执行 496 项，473 项通过，23 项按需或环境条件跳过，零失败；21 项 Python 质量检查与 14 项打卡定向测试全部通过。
- Reviewed native Chinese and English settings captures with reminders on and off. Physical displays, real sleep/wake/login, stationary performance, frame rate, live players, VoiceOver, Keychain dialogs and payment/activation remain pending. / 已核对中英文设置在开启与关闭状态下的原生截图；实体屏幕、真实休眠唤醒与登录、静置性能、桌面帧率、真实播放器、VoiceOver、钥匙串弹窗及付款激活仍待验收。


---

# Notch Calendar 1.8.0

macOS 15+ · Apple Silicon and Intel · build 73 · 2026-10-13

## 刘海窗口大小与自适应布局

- 默认展开尺寸为 **520 × 390 点**，面积比旧版 600 × 460 点缩小约 **27%**。支持紧凑、标准、宽敞和自定义宽高；自定义范围为宽 440–880 点、高 340–680 点。
- 在 **设置 → 通用设置 → 刘海窗口大小** 调整，或点击刘海窗口右上角双向箭头切换预设。调整立即生效，重启和本地备份恢复后保留。
- 日历采用更清晰的日期层级与紧凑日程；窄窗优先展示当天安排，宽窗使用双栏。文件页在窄窗收起次要列，专注和音乐调整间距与封面，便笺使用可用编辑高度并保留选区和撤销记录。
- 工具栏固定在顶部，更多内容纵向滚动；日程变化及切换页面保持用户选择的窗口大小。

## 安装与验证

下载 `NotchCalendar-1.8.0-macos.dmg`，退出旧版，将应用拖入「应用程序」替换后重新启动。另提供 ZIP 和 `SHA256SUMS.txt`。正常覆盖安装保留已有授权和本地数据。本版沿用 **ad-hoc 签名和手动安装**，未进行 Developer ID 签名或 Apple 公证。

Swift 全量测试执行 491 项：467 项通过，24 项按需或环境条件跳过，零失败；21 项 Python 质量测试全部通过。原生界面捕获覆盖五个页面的三种尺寸、空日历、英文长标题和设置。双架构 Release 构建、安装包内容、签名与本地 SHA-256 检查通过。

实体刘海及外接屏、真实休眠唤醒与登录、静置性能和桌面帧率、真实播放器兼容性、VoiceOver、钥匙串弹窗及付款激活仍待验收；受控原生测试和模拟数据不代表这些项目已经通过。

## English

The expanded notch panel defaults to **520 × 390 pt**, about **27% smaller in area** than 600 × 460 pt. Choose Compact, Standard, Spacious, or custom dimensions of 440–880 pt wide and 340–680 pt tall in **Settings → General Settings → Notch Window Size**, or switch presets using the arrows in the notch toolbar. Changes apply immediately and persist through restarts and local backup restore.

Calendar prioritizes the date and today's agenda, switching between one and two columns. Files hides secondary columns in narrow panels, Focus and Music adapt spacing and artwork, and Scratchpad uses the available editing height while retaining selection and undo history. The toolbar stays at the top; content scrolls vertically and tab changes keep the chosen panel size.

Quit the older app, open the DMG, replace the app in Applications, and relaunch. ZIP and SHA-256 files are also available. A normal replacement preserves existing licenses and local data. This **ad-hoc signed manual-install build** has no Developer ID signing or Apple notarization.

491 Swift tests executed: 467 passed, 24 optional/environment checks skipped, zero failures. All 21 Python quality tests passed. Native captures cover all five pages at three sizes, an empty calendar, long English titles and settings. Universal Release build, package contents, signatures and local SHA-256 checks passed. Physical displays, real sleep/wake/login, stationary performance, frame rate, live players, VoiceOver, Keychain dialogs and payment/activation remain pending.

---

# Notch Calendar 1.7.5

macOS 15+ · Apple Silicon and Intel · build 72 · 2026-10-12

下载 / Download `NotchCalendar-1.7.5-macos.dmg`，退出旧版后拖入「应用程序」替换并重新启动。另提供 ZIP 和 SHA-256 校验文件。/ Quit the older app, replace it in Applications, and relaunch; ZIP and SHA-256 files are also available.

### Fixed / 修复

- Restore hover opening over the central hardware notch during music playback. The artwork and rhythm circles remain click targets, and moving the pointer away closes the browsing panel after the exit grace period. / 恢复音乐播放时实体刘海中间区域的悬停展开；封面与律动双圆仍需点击打开，移开指针后浏览面板在宽限结束时收起。
- Keep the compact focus countdown within the right shoulder, preventing clipped time text and capsule edges after opening and closing the panel. / 将紧凑专注倒计时限定在右侧肩部内，避免面板展开再收起后时间文字及胶囊边缘被裁切。

### Validation / 验证

- At the user's explicit request for immediate publication, release regression tests, artifact checks and SHA-256 verification were skipped. Tests were not rerun after the focus layout fix; this release does not claim those checks passed. / 按用户明确要求立即发布，跳过发行回归、安装包检查与 SHA-256 核验；专注布局修复后未重新运行测试，本版不宣称上述检查通过。
- Ad-hoc signed for manual installation; no Developer ID signing or Apple notarization. / 本版采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。

---

# Notch Calendar 1.7.4

macOS 15+ · Apple Silicon and Intel · build 71 · 2026-10-12

下载 / Download `NotchCalendar-1.7.4-macos.dmg`，退出旧版后拖入「应用程序」替换并重新启动。另提供 ZIP 和 SHA-256 校验文件。/ Quit the older app, replace it in Applications, and relaunch; ZIP and SHA-256 files are also available.

## [1.7.4] - 2026-10-12

macOS 15+ · Apple Silicon and Intel · build 71 · Ad-hoc signed, manual installation; no Developer ID signing or notarization.

### Added / 新增

- Add regression coverage for compact music click targets, pointer departure after switching from Music to Calendar, and retained editing, click-only and native-dialog sessions. / 新增紧凑音乐点击区域、音乐切换日历后的指针移出，以及编辑、仅点击模式和原生弹窗持续会话的回归覆盖。

### Fixed / 修复

- Open Music from its compact artwork or rhythm only on a click, preventing pointer hover from opening the player. / 紧凑音乐封面与律动仅在点击后打开音乐页，悬停不再弹出播放器。
- Limit compact music input beside a hardware notch to the two visible circles. Transparent shoulders and rounded corners pass clicks through to the menu bar, and window input updates promptly as the pointer moves, so neighboring menu-bar controls no longer open the panel. / 实体刘海旁的紧凑音乐点击范围限制在可见的两个圆圈内；透明肩部和圆角将点击传递给菜单栏，指针快速移动时及时更新窗口输入，避免点击相邻菜单栏控件时误开面板。
- With hover opening enabled, clicking compact Music and then switching to Calendar no longer keeps the calendar open indefinitely. Moving the pointer away, including onto neighboring menu-bar controls, closes it after the exit grace period. / 启用悬停打开时，点击紧凑音乐后切换日历不再一直停留；移开指针，包括停在相邻菜单栏控件上，均会在移出宽限结束后收起。
- Preserve continued interaction while editing Scratchpad, Files or Focus, using the global click-only preference, or operating native popovers, sheets and modal dialogs. / 便笺、文件和专注编辑、全局「仅点击打开」偏好，以及原生子弹窗、sheet 和模态对话框仍保持持续操作会话。

### Validation / 验证

- The targeted run executed 71 tests: 69 passed, 2 opt-in checks skipped, zero failures. / 本轮相关测试执行 71 项，69 项通过，2 项按需检查跳过，零失败。
- The full Swift release regression executed 471 tests with 22 optional/environment skips and zero failures; all 21 Python quality checks, licensing validation and localization syntax checks passed. / Swift 全量发行回归执行 471 项，22 项按需或环境条件跳过，零失败；21 项 Python 质量检查、授权配置及本地化语法检查通过。
- Universal arm64/x86_64 app, updater, widget and music bridge, ad-hoc signatures, Shortcuts metadata, complete ZIP/DMG payloads, installation link and local SHA-256 checks passed. / 主应用、更新器、小组件及音乐桥接库的 arm64/x86_64 双架构、ad-hoc 签名、快捷指令元数据、ZIP/DMG 完整内容、安装链接和本地 SHA-256 核验通过。
- Physical displays, real desktop frame rate, energy use and stationary performance, live-player compatibility, VoiceOver, Keychain dialogs, live payment/activation and real sleep/wake/login behavior remain pending. Controlled native windows and simulated notch sizes do not establish hardware or live-player acceptance. / 实体屏幕、真实桌面帧率、能耗与静置性能、真实播放器兼容性、VoiceOver、钥匙串弹窗、真实付款激活，以及真实休眠唤醒与登录行为仍待验收；受控原生窗口及模拟刘海尺寸不等同于实体硬件或真实播放器验收。

---

# Notch Calendar 1.7.3

macOS 15+ · Apple 芯片与 Intel · build 70 · 2026-10-12

## 刘海展开、悬停与收起

- 悬停展开后，短暂移出面板会留出宽限，返回时取消收起；点击面板后保持操作会话，移开指针不再打断便笺编辑或文件操作。点击外部、按 Esc 或关闭按钮可收起，原生菜单和文件选择框仍属于当前操作。
- 展开约 0.32 秒、收起约 0.24 秒，轮廓在设定时长内连续到达目标；快速反向开关继续使用当前可见轮廓。切页只对进入页面做 0.14 秒淡入，窄屏导航固定使用图标，避免按钮宽度随选择变化。
- 完整收起后保留便笺编辑器、选区和独立撤销/重做记录，以及文件选择与滚动位置；再次展开不会因紧凑尺寸挤压编辑器。外部更新便笺时清理旧撤销，输入法组合期间也按提交后的文本同步。
- 隐藏页面释放输入焦点，停用快捷键与无障碍输入；隐藏的日历停止页面刷新，专注和音乐页面停止各自的显示计时与动画。系统「减少动态效果」下不播放外壳形变，内容只淡入淡出，切页立即完成。

## 文件浏览与错误反馈

- 打开、复制或子目录读取失败时，显示可关闭的就地提示，当前目录和文件列表继续保留；目录本身读取失败可直接重试。
- 收起父目录会取消后代读取；切换目录、停用文件架或刷新后删除目录时，过期读取不会写回列表或错误提示。
- 文件列表支持上下选择、左右展开/收起及返回父级、Home/End、回车打开、⌘C 复制，并保持所选项可见；Tab 和 Shift-Tab 可进入或离开列表焦点。复制与打开按键只由当前文件列表处理，不占用便笺的文本操作。

## 安装与升级

下载 `NotchCalendar-1.7.3-macos.dmg`，退出旧版后拖入「应用程序」替换，再重新启动。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，提供 arm64/x86_64 双架构包，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

Swift 全量发行回归执行 462 项，22 项按需或环境条件跳过，零失败；21 项 Python 质量检查及授权配置检查通过。本轮定向检查执行 105 项，102 项通过，3 项需要桌面条件的检查跳过，零失败，涵盖刘海开关与重开布局、便笺选区及实际撤销/重做、外部更新、文件键盘交互和过期目录读取。

主应用、更新器、小组件与音乐桥接库均包含 arm64/x86_64；ad-hoc 签名、快捷指令元数据、ZIP/DMG 完整内容、安装链接和本地 SHA-256 核验通过。

真实桌面帧率、能耗与静置性能，实体刘海及外接屏，真实休眠唤醒与登录启动，真实付款激活、钥匙串弹窗、VoiceOver，以及 Apple Music、Spotify 及其他播放器的真实播放兼容性 **仍待验收**。受控原生窗口和模拟刘海尺寸检查不代表实体硬件或真实播放器验收。本版保留人工核实付款、人工发码；音乐能力及其验收范围沿用 1.7.0 的说明。

## English

Version 1.7.3 gives hover interactions a brief exit grace period and keeps a clicked panel open while the pointer moves away. Click outside, press Esc, or use Close to dismiss it; native menus and file dialogs remain part of the interaction. Opening takes about 0.32 seconds and closing 0.24 seconds, with continuous shell motion and reversals from the visible shape. Incoming pages fade in over 0.14 seconds. Narrow navigation keeps fixed icon widths.

A complete close and reopen retains the scratchpad editor, selection and independent undo/redo history, plus file selection and scroll position. Compact geometry does not squeeze the retained editor. External note updates invalidate old undo actions, including updates during input-method composition, while undo and redo synchronize the saved text. Hidden pages release focus and do not receive shortcuts or accessibility input; hidden calendar pages stop refreshing, and hidden Focus and Music pages stop their display timers and animations. Reduce Motion disables shell deformation, keeps content fading and makes page changes immediate.

File-open, copy and child-folder failures show dismissible messages while keeping the directory and rows. An unreadable directory offers Retry. Collapsing an ancestor, changing directories, disabling the shelf or removing a directory during refresh invalidates obsolete reads. The file list supports arrows, left/right expansion and parent navigation, Home/End, Return, ⌘C and Tab/Shift-Tab, with the selected row kept visible. File commands remain local to the focused list and leave scratchpad text editing alone.

Download `NotchCalendar-1.7.3-macos.dmg`, quit the older app, replace it in Applications, and relaunch. ZIP and SHA-256 files are also provided. A normal replacement preserves existing licenses and local data. This ad-hoc signed arm64/x86_64 build requires manual installation and has no Developer ID signing or Apple notarization.

The full Swift release regression executed 462 tests with 22 optional/environment skips and zero failures. All 21 Python quality checks and licensing validation passed. The targeted run executed 105 checks: 102 passed, 3 desktop-dependent checks were skipped, and none failed. Coverage includes notch closing and reopening layout, scratchpad selection and actual undo/redo, external updates, file keyboard interaction and stale directory reads.

The app, updater, widget and music bridge contain arm64/x86_64. Ad-hoc signatures, Shortcuts metadata, complete ZIP/DMG contents, installation link and local SHA-256 checks passed.

Real desktop frame rate, energy use and stationary performance, physical notch and external displays, real sleep/wake/login behavior, live payment/activation, Keychain dialogs, VoiceOver and live Apple Music, Spotify and other player compatibility remain **pending**. Controlled native windows and simulated notch sizes do not establish physical-hardware or live-player acceptance. Manual payment verification and code delivery continue; music capabilities and their acceptance scope remain as documented for 1.7.0 below.

---

# Notch Calendar 1.7.2

macOS 15+ · Apple 芯片与 Intel · build 69 · 2026-10-11

## 视觉与细节体验

- 音乐页按实际内容调整高度，移除播放器下方的大块空白；封面、歌曲信息与播放控件采用更紧凑的间距。
- 标准宽度下的导航补充文字，工具栏按钮统一悬停、按下、键盘焦点与禁用反馈。专辑名与曲名相同时不再重复显示，律动收纳到播放状态，进度条改为中性色。
- 加深半透明刘海面板，减少壁纸染色，提升文字与控件的对比度。
- 切换音乐页时保留日历与文件浏览状态，便笺保留编辑器、选区与撤销记录；隐藏页面不接收鼠标、键盘或无障碍输入。
- 沿用 1.7.1 的刘海展开与收起动画，以及系统「减少动态效果」下的淡入淡出。

## 安装与升级

下载 `NotchCalendar-1.7.2-macos.dmg`，退出旧版后拖入「应用程序」替换，再重新启动。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

Swift 全量执行 416 项，22 项按需或环境条件跳过，零失败；21 项 Python 质量检查及授权配置通过。39 项界面、音乐与外观定向检查通过，已核对合成歌曲、封面及隔离配置下的原生界面截图。

arm64/x86_64 通用安装包、ad-hoc 签名、快捷指令元数据、ZIP/DMG 内容、安装链接和本地 SHA-256 核验通过。截图不代表实体屏幕或真实播放器验收。

实体刘海及外接屏、真实休眠唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗、VoiceOver，以及 Apple Music、Spotify 及其他播放器的真实播放兼容性 **仍待验收**。本版保留人工核实付款、人工发码；音乐能力及其验收范围沿用 1.7.0 的说明。

## English

Version 1.7.2 refines the notch's visual details. Music now fits its actual content without a large empty area below the player. Artwork, track information and playback controls have balanced spacing; an album name that repeats the song title is omitted, the rhythm sits beside playback status, and the progress control uses a neutral color.

Navigation includes labels at the standard panel width, with consistent hover, pressed, keyboard focus and disabled feedback. A darker translucent surface reduces desktop color tint and improves contrast. Tab changes retain calendar and file browsing state, as well as the scratchpad's editor, selection and undo history. Hidden pages do not receive pointer, keyboard or accessibility input. The opening and closing animation from 1.7.1, including Reduce Motion's fade-only behavior, is retained.

Download `NotchCalendar-1.7.2-macos.dmg`, quit the older app, replace it in Applications, and relaunch. ZIP and SHA-256 files are also provided. A normal replacement preserves existing licenses and local data. This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization.

Executed 416 Swift tests with 22 optional/environment skips and zero failures; 21 Python quality checks and licensing validation passed. The 39 targeted UI, music and appearance checks passed, and native captures using synthetic music and isolated configuration were reviewed. Universal arm64/x86_64 packaging, ad-hoc signatures, Shortcuts metadata, ZIP/DMG contents, installation link and local SHA-256 checks passed. Captures do not establish physical-display or live-player acceptance.

Physical displays, real sleep/wake/login behavior, stationary performance, live payment/activation, Keychain dialogs, VoiceOver and live Apple Music, Spotify and other player compatibility remain **pending**. Manual payment verification and code delivery continue. Music capabilities and their acceptance scope remain as documented for 1.7.0 below.

---

# Notch Calendar 1.7.1

macOS 15+ · Apple 芯片与 Intel · build 68 · 2026-10-11

## 刘海动画改进

- 参考 Pulse 的外壳与内容分段动画：外壳先展开，内容稍后淡入，配合轻微缩放与下移；收起时内容先淡出，轮廓随后平稳回收。
- 展开约 0.44 秒，收起约 0.32 秒。内容延迟 0.10 秒后出现，让阅读区域在外壳展开后进入。
- 快速反复展开、收起时从当前可见轮廓继续衔接，收起末尾不再挤压到紧凑刘海以下；隐藏的便笺等编辑器退出输入焦点。
- 系统「减少动态效果」开启时只淡入淡出，不播放轮廓形变动画、不移动或缩放内容。

## 安装与升级

下载 `NotchCalendar-1.7.1-macos.dmg`，退出旧版后拖入「应用程序」替换，再重新启动。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

Swift 全量执行 415 项，18 项按需跳过，零失败；21 项 Python 质量检查及授权配置通过。arm64/x86_64 通用安装包、ad-hoc 签名、快捷指令元数据、ZIP/DMG 内容、安装链接和本地 SHA-256 核验通过。

实体刘海及外接屏、真实休眠唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗、VoiceOver，以及 Apple Music、Spotify 及其他播放器的真实播放兼容性 **仍待验收**。本版保留人工核实付款、人工发码；音乐能力及其验收范围沿用 1.7.0 的说明。

## English

Version 1.7.1 improves notch opening and closing with separate shell and content timing inspired by Pulse. The shell expands first; content follows with a short delay, fade, slight scale and downward movement. On dismissal, content fades before the shell finishes closing. Opening takes approximately 0.44 seconds and closing 0.32 seconds; content begins appearing after 0.10 seconds.

Reversing an in-progress transition continues from the currently visible shape. The final compact notch no longer squeezes below its destination, and hidden text editors release input focus. Reduce Motion uses a fade-only transition, without shell animation or content movement and scaling.

Download `NotchCalendar-1.7.1-macos.dmg`, quit the older app, replace it in Applications, and relaunch. ZIP and SHA-256 files are also provided. A normal replacement preserves existing licenses and local data. This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization.

Executed 415 Swift tests with 18 optional skips and zero failures; 21 Python quality checks and licensing checks passed. Universal arm64/x86_64 packages, ad-hoc signatures, Shortcuts metadata, ZIP/DMG contents, installation link and local SHA-256 checks passed. Physical displays, real sleep/wake/login behavior, stationary performance, live payment/activation, Keychain dialogs, VoiceOver and live Apple Music, Spotify and other player compatibility remain **pending**. Manual payment verification and code delivery continue. Music capabilities and their acceptance scope remain as documented for 1.7.0 below.

---

# Notch Calendar 1.7.0

macOS 15+ · Apple 芯片与 Intel · build 67 · 2026-10-11

## 新增

- 刘海新增「音乐」页：读取系统正在播放的信息，展示歌曲、歌手、专辑、封面和来源播放器，并可直接打开来源播放器。
- 上一首、播放/暂停、下一首和进度调整按播放器报告的能力启用；未提供时长或不支持跳转时，不提供可拖动进度。
- 播放音乐时，封面和轻柔律动分别出现在刘海两侧。会议与专注优先；在设置中可关闭「在刘海旁显示音乐」，展开的音乐控制仍可使用。
- 在封面与歌曲区域横向滑动可切歌，也可使用按钮；空格播放/暂停。按钮提供悬停说明和无障碍标签，系统「减少动态效果」下律动保持静态。

## 音乐功能范围

请先在兼容的播放器中播放歌曲，再打开刘海中的「音乐」。本应用控制系统正在播放的来源，不提供音乐目录、账户登录或音乐下载服务。播放器未提供的歌曲信息、封面或操作能力可能无法显示或使用。

律动是表达播放状态的装饰动画，**不采集音频，也不是真实音频波形**。本版不显示未经确认的 Lossless 无损、Dolby Atmos 杜比全景声或独占标签，**不提供锁屏音乐小组件**。

已只读确认本机网易云音乐的歌曲信息、时长与控制能力，未对用户的真实播放发送控制请求。Apple Music、Spotify 等播放器的完整兼容性仍待实际播放验收；受控「正在播放」演示只验证本应用读取信息和发出控制请求的路径，不能代替各播放器的真实账户、媒体、广告和播放队列验证。

## 安装与升级

下载 `NotchCalendar-1.7.0-macos.dmg`，退出旧版后拖入「应用程序」替换，再重新启动。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 回归执行 411 项，17 项按需跳过，零失败；21 项 Python 质量测试及授权配置检查通过。原生音乐标签首次点击、长曲名、空状态、暂停状态、连接失败、中英文与减少动态效果布局已核对。在本机 macOS 27.0.1 的静音受控播放器中，系统歌曲与封面读取、播放/暂停、上一首、下一首、进度跳转和过期请求拦截均确认通过。

真实 Apple Music、Spotify 及其他播放器，实体刘海及外接屏、真实休眠唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗和 VoiceOver **仍待验收**。本版保留人工核实付款、人工发码。

## English

Version 1.7.0 adds Music to the notch, with the system's current track, artist, album, artwork and source player. Previous, play/pause, next and seeking follow the capabilities reported by that player. Open the source player directly from the card.

Album art and a gentle rhythm appear on separate sides of the notch during playback. Meetings and focus take priority. Show music beside the notch can be disabled in Settings while the expanded Music tab stays available. Swipe horizontally across the artwork and track area to change tracks, or use the buttons; Space plays or pauses. Controls include tooltips and accessibility labels, and Reduce Motion keeps the rhythm still.

The rhythm is decorative playback feedback, **not sampled audio or a live waveform**. This version does not add unverified Lossless, Dolby Atmos or exclusive-format badges, or a lock-screen music widget. It controls the system's current player rather than providing a music catalog, account service or downloads. Metadata and controls depend on what the source reports.

Read-only metadata, duration and advertised capabilities were also confirmed with NetEase Cloud Music; no controls were sent to the user's real player. Full Apple Music, Spotify and other player compatibility remains **pending live playback acceptance**. A controlled Now Playing fixture verifies this app's metadata and command path; it does not establish full compatibility with each player's accounts, media, advertisements or queues.

This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. 411 Swift tests ran with 17 optional skips and zero failures; 21 Python quality tests and licensing checks passed. Native Music-tab input and long titles, empty, paused and unavailable states, Chinese/English and Reduce Motion layouts were checked. A silent controlled player on macOS 27.0.1 confirmed native metadata/artwork, play/pause, previous, next, seeking and stale-request rejection. Physical displays, real sleep/wake/login behavior, stationary performance, live payment/activation, Keychain dialogs and VoiceOver remain **pending**.
