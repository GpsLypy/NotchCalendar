# Notch Calendar 2.0.19

- 小猫小狗会说话了：新增心情、打卡、喝水、陪伴与休息气泡，摸摸时也会回应；支持设置和右键“说句话”。
- 新增“偶尔说说话”独立开关。安静型每 20–30 分钟、活泼型每 10–20 分钟主动问候；气泡 12 秒后收起，点击即可关闭。关闭打卡提醒后不再轮播打卡问候。
- 气泡避开摄像头和宠物，适配浅色与深色外观；拖动、展开内容、隐藏、休眠或专注休息时收起，不补播。低电量停止主动问候，减少动态效果时保留静态文字。问候在本地运行，不开麦、不调用模型、不保存心情信息。

冻结源码定向回归 168 项：168 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 102。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/NotchCalendar-2.0.19-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/NotchCalendar-2.0.19-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/SHA256SUMS.txt)

## English

- Cats and dogs can now speak in bubbles about your mood, check-ins, water, company and breaks. Petting gets a reply, with Say something available in Settings and the context menu.
- Add an independent Occasional greetings switch. Quiet companions greet every 20–30 minutes; playful companions every 10–20 minutes. Bubbles close after 12 seconds or a click. Disabling check-in reminders also removes check-in questions.
- Bubbles stay clear of the camera and pet and adapt to light and dark appearances. Dragging, expanded content, hiding, sleep and focus rest dismiss them without queuing. Low Power Mode stops automatic greetings; Reduce Motion keeps static text. Greetings run locally without a microphone, model requests or stored mood information.

Frozen targeted regression: 168 cases, 168 passed, 0 optional skips and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Native rendering and event tests use isolated preferences and test geometry; they do not prove physical camera fit on every Mac. Human VoiceOver, physical multi-display/full-screen use, actual sleep/wake and sustained energy acceptance remain pending.

macOS 15+, Apple silicon and Intel, build 102. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/NotchCalendar-2.0.19-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/NotchCalendar-2.0.19-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/SHA256SUMS.txt)

Previous release: [2.0.18](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.18).
