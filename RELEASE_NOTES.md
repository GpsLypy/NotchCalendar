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
