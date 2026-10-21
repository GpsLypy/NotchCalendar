# Notch Calendar 2.0.23

- 修复播放音乐时容易错过专注结束提醒的问题：结束时在刘海下方显示独立胶囊，停留 20 秒，可手动关闭。
- 与贴心提醒、音乐状态或展开面板冲突时，胶囊自动向下避让，不抢键盘焦点；关闭提示音后仍显示结束提醒。
- 提示音改用持续持有的独立播放器混音，播放失败时回退；保留原提示音开关，不调整音乐或系统音量。休息结束同样提醒，恢复过期计时不会重复播放。
- 小伴侣在播放音乐、专注计时、展示专注建议和展开刘海内容时继续可见，移动到状态或内容外侧；窄屏空间不足时停在内容下方。
- 走动、拖动归位、吊绳和说话气泡同步避开摄像头、按钮及展开内容，缩放面板时跟随实际边界调整。

冻结源码定向回归 202 项：201 通过、1 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收；尚未进行第三方音乐应用或耳机的主观听感验收。

macOS 15+，Apple 芯片与 Intel，build 106。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/NotchCalendar-2.0.23-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/NotchCalendar-2.0.23-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/SHA256SUMS.txt)

## English

- Add an independent 20-second completion capsule below the notch so focus endings remain visible while music is playing; dismiss it with the close button.
- Move the capsule below care reminders, music status or expanded panels when they overlap, without taking keyboard focus. Muting the chime keeps the visual reminder available.
- Use a retained audio player for the completion chime with a checked fallback. Keep the existing sound switch and other audio volumes. Break endings also show a reminder; restoring an expired timer does not replay feedback.
- Keep your companion visible beside music, focus status, focus suggestions and expanded notch content; move it below the content when a narrow display has no side space.
- Keep walking, drag-return routes, rope rides and speech bubbles clear of the camera, controls and expanded content, following the actual panel bounds during resizing.

Frozen targeted regression: 202 cases, 201 passed, 1 optional skips and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Native rendering and event tests use isolated preferences and test geometry; they do not prove physical camera fit on every Mac. Human VoiceOver, physical multi-display/full-screen use, actual sleep/wake and sustained energy acceptance remain pending, as does subjective listening with third-party music apps or headphones.

macOS 15+, Apple silicon and Intel, build 106. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/NotchCalendar-2.0.23-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/NotchCalendar-2.0.23-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/SHA256SUMS.txt)

Previous release: [2.0.22](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.22).
