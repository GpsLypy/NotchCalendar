# Notch Calendar 2.0.22

- 修复会议开始后小伴侣消失：会议中继续显示在状态按钮外侧，会议结束或关闭会议状态后回到原位。
- 走动、拖动归位和吊绳滑梯同步避开会议按钮与摄像头；无刘海屏幕保留胶囊旁的位置。
- 刘海 AI 聊天卡片底部两角新增缩放提示；切换到其他工具时隐藏，拖动期间暂停呼吸效果，减少动态效果或提高对比度时静态显示。

冻结源码定向回归 305 项：302 通过、3 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

前两轮各出现一项不同的桌面交互测试失败；未修改源码，单项诊断及最终完整定向复验通过。早期失败原因未确认，原始日志已保留。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 105。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/NotchCalendar-2.0.22-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/NotchCalendar-2.0.22-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/SHA256SUMS.txt)

## English

- Fixed the companion disappearing when a meeting starts. It stays visible outside the meeting controls and returns to its idle position when the meeting ends or meeting status is disabled.
- Walking, drag returns and rope slides now avoid both meeting controls and the camera housing. Displays without a notch retain the position beside the compact pill.
- Added resize hints at the lower corners of the notch AI chat card. They hide on other tools, stop pulsing while dragging, and remain static with Reduce Motion or Increase Contrast.

Frozen targeted regression: 305 cases, 302 passed, 3 optional skips and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

The first two runs each had one different desktop interaction failure. Without source changes, isolated diagnostics and the final complete targeted run passed. The earlier causes remain unresolved and original logs are retained.

Native rendering and event tests use isolated preferences and test geometry; they do not prove physical camera fit on every Mac. Human VoiceOver, physical multi-display/full-screen use, actual sleep/wake and sustained energy acceptance remain pending.

macOS 15+, Apple silicon and Intel, build 105. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/NotchCalendar-2.0.22-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/NotchCalendar-2.0.22-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/SHA256SUMS.txt)

Previous release: [2.0.21](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.21).
