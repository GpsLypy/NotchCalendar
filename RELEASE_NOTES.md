# Notch Calendar 2.0.14

- 在「设置 → 通用设置 → 刘海显示屏」选择自动、内置或外接显示屏。
- 无实体刘海的显示屏使用经典模式时，顶部保留日期时间，展开内容显示为独立圆角卡片。
- 重新展开时恢复上次选择的页签。支持拖动窗口左右边、底边及两个下角调整大小，并保存尺寸；拖动时保留编辑内容与网页草稿。
- 小伴侣停靠在刘海左侧；鼠标碰到会掉落并归位，双击沿刘海下沿跑到右侧再返回左侧，单击仍可摸摸。小伴侣需在设置中主动开启，尊重「减少动态效果」。

冻结源码定向回归 265 项：264 通过、1 项可选检查跳过、0 失败；21 项 Python 质量检查与通用安装包核验通过。

已通过原生窗口事件、真实显示屏坐标及模拟几何测试检查显示屏选择、缩放和小伴侣路径。人工鼠标手感、VoiceOver、显示屏拔插／合盖、真实睡眠唤醒、真实 AI 服务和持续 CPU／能耗仍待验收；不是全量回归或严格设备门禁通过。

macOS 15+，Apple 芯片与 Intel，build 97。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，已有授权与聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/NotchCalendar-2.0.14-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/NotchCalendar-2.0.14-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/SHA256SUMS.txt)

## English

- Choose Automatic, Built-in or External in Settings → General → Notch display.
- On a display without a physical notch, Classic mode keeps the date and time at the top and opens its content in a separate rounded card.
- Reopening restores the last selected tab. Drag either side, the bottom edge or a lower corner to resize and save the window size while preserving editor content and web drafts.
- Rest the companion to the left of the notch. Pointer entry makes it fall and return; double-click to run along the lower edge to the right and back. Single-click still pets it. Enable the optional companion in settings; Reduce Motion is respected.

Frozen-source targeted regression: 265 cases, 264 passed, 1 optional check skipped, zero failures; 21 Python quality checks and universal package validation passed.

Native window events, actual display coordinates and simulated geometry cover display selection, resizing and companion paths. Manual pointer use, VoiceOver, display hotplug/lid close, real sleep/wake, live AI services and stationary CPU/energy remain pending. This is not a full-app regression or strict hardware-gate pass.

macOS 15+, Apple silicon and Intel, build 97. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Keeping local app data preserves existing licenses and Chat API keys.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/NotchCalendar-2.0.14-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/NotchCalendar-2.0.14-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/SHA256SUMS.txt)

Previous release: [2.0.13](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.13).
