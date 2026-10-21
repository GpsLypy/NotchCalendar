# Notch Calendar 2.0.20

- 修正贴心提醒在刘海两侧偏下的问题。空闲时两侧与刘海垂直居中；音乐或会议占位时，图标、文案和关闭按钮合为一颗刘海下方胶囊。状态切换保留阅读时长，回应收窄保持居中。
- 新增会议间隙的专注建议：本机日历发现合适空档时，在刘海下方安静展示 5 秒。可准备 25 分钟专注（不会自动开始），或选择“稍后”暂停建议 30 分钟；支持开关、预览、同场次去重与备份恢复。
- 改善 DeepSeek 网页对话输入区：重新进入已有会话或收起后再打开时，空白输入区保持精简；点击继续输入恢复原编辑器。保留草稿、输入法选词和换行，发送未成功时保持展开。

冻结源码定向回归 228 项：228 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 103。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/NotchCalendar-2.0.20-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/NotchCalendar-2.0.20-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/SHA256SUMS.txt)

## English

- Align idle care reminders with the notch instead of lowering them. When music or a meeting occupies its sides, combine the icon, message and close action into one capsule below the notch. Placement changes keep the original reading time; acknowledgements stay centered.
- Add focus suggestions between meetings using the local calendar. A quiet capsule retracts after five seconds. Prepare a 25-minute focus timer without starting it, or choose Later to pause suggestions for 30 minutes. Includes a switch, preview, occurrence deduplication and backup support.
- Refine the DeepSeek web composer: reopening an existing conversation keeps an empty composer compact; Continue typing restores the same editor. Drafts, input-method composition, newlines and rejected sends stay expanded.

Frozen targeted regression: 228 cases, 228 passed, 0 optional skips and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Native rendering and event tests use isolated preferences and test geometry; they do not prove physical camera fit on every Mac. Human VoiceOver, physical multi-display/full-screen use, actual sleep/wake and sustained energy acceptance remain pending.

macOS 15+, Apple silicon and Intel, build 103. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/NotchCalendar-2.0.20-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/NotchCalendar-2.0.20-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/SHA256SUMS.txt)

Previous release: [2.0.19](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.19).
