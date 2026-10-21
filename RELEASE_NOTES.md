# Notch Calendar 2.0.21

- 新增「一句话安排」：在刘海日历页或主窗口输入“明天下午三点和张三开会一小时”，先生成可编辑日程草稿，再由你点击保存写入系统日历。回车只生成草稿。
- 常见日期、时间、时长和全天安排可在本机识别；预览可修改标题、时间、地点与目标日历，并显示已选日历中的占用重叠。未写时长会明确提示默认 30 分钟，含糊、重复或多事项需要补充。
- 可主动选择「用 AI 理解」，复用已配置的聊天 API 服务。只发送本次描述、当前时间与时区；仍需检查草稿并手动保存。DeepSeek 网页登录不等于 API 配置。真实模型服务与个人日历写入仍待实机验收，本次相关回归使用模拟响应和离线日历。
- 保留上一版紧凑的刘海下方专注建议胶囊：展示 5 秒后自动收回，可准备专注或稍后提醒。

冻结源码定向回归 267 项：267 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 104。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/NotchCalendar-2.0.21-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/NotchCalendar-2.0.21-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/SHA256SUMS.txt)

## English

- Added Quick plan in the notch calendar and main calendar window. Enter “Tomorrow at 15:00, design review for 1 hour”, review the editable draft, then explicitly save it to the system calendar. Return only generates a draft.
- Common dates, times, durations and all-day events are recognized locally. Edit the title, time, location and destination calendar, with overlap hints for selected calendars. An omitted duration is visibly set to 30 minutes; ambiguous, recurring or multiple events need clarification.
- Optionally choose “Understand with AI” using your configured chat API. Only this description, current time and time zone are sent; review and manual saving remain required. A DeepSeek web login does not configure an API. Live model services and personal calendar writes remain pending; related regression uses mocked responses and offline calendars.
- Retains the compact focus suggestion capsule from the previous release: it retracts after 5 seconds and lets you prepare a focus session or snooze.

Frozen targeted regression: 267 cases, 267 passed, 0 optional skips and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Native rendering and event tests use isolated preferences and test geometry; they do not prove physical camera fit on every Mac. Human VoiceOver, physical multi-display/full-screen use, actual sleep/wake and sustained energy acceptance remain pending.

macOS 15+, Apple silicon and Intel, build 104. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/NotchCalendar-2.0.21-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/NotchCalendar-2.0.21-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/SHA256SUMS.txt)

Previous release: [2.0.20](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.20).
