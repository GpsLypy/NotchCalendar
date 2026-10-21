# Notch Calendar 2.0.18

- 新增小伴侣吊绳滑梯：拖动小猫或小狗时显示吊绳，把它放到左右任一端点松手，即可抓绳滑下、轻荡后跑回家。滑行中可以重新抓起；在其他位置松手仍按原路线回家。
- 设置和宠物右键菜单新增“滑滑梯”入口。吊绳只在拖动和滑行时显示，绳子本身不拦截鼠标；展开日历、隐藏、休眠或屏幕变更会取消动作。减少动态效果时保留静态开心回应。
- 改善贴心提醒的刘海两侧布局：向下调整位置，随收起状态刘海区域居中并留出顶部间距；黑色胶囊可见高度从 20pt 增至 30pt，正文从 12pt 调为 13pt，图标和关闭按钮同步放大，中英文仍按文案自适应宽度。

冻结源码定向回归 163 项：163 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 101。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/NotchCalendar-2.0.18-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/NotchCalendar-2.0.18-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/SHA256SUMS.txt)

## English

- Add a rope slide for the notch companion. Drag the cat or dog to reveal the rope, release at either endpoint, and it slides down, gently swings and runs home. Pick it up again during the ride; releases elsewhere keep the existing running return.
- Add Rope slide to Settings and the pet context menu. The rope appears only during dragging or sliding and never intercepts clicks. Opening Calendar, hiding, sleep or display changes cancel play. Reduce Motion retains a static happy response.
- Refine care reminders beside the notch: lower and align both wings with the compact notch region, with space below the screen edge. Increase the visible pill height from 20pt to 30pt and text from 12pt to 13pt, with larger icons and close targets. Widths still fit the current Chinese or English message.

Frozen targeted regression: 163 cases, 163 passed, 0 optional skips and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Native rendering and event tests use isolated preferences and test geometry; they do not prove physical camera fit on every Mac. Human VoiceOver, physical multi-display/full-screen use, actual sleep/wake and sustained energy acceptance remain pending.

macOS 15+, Apple silicon and Intel, build 101. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/NotchCalendar-2.0.18-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/NotchCalendar-2.0.18-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/SHA256SUMS.txt)

Previous release: [2.0.17](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.17).
