# Notch Calendar 2.0.25

- 新增钉住刘海：展开后点击图钉，移开鼠标或点击外部也保持展开；切换工具时保留钉住状态。取消钉住恢复自动收起，手动关闭结束本次钉住。
- 翻译改为左右双栏：左侧原文、右侧译文，窄刘海也能并排对照；等宽编辑区、字符计数和独立滚动让长文更好读。
- 翻译操作集中到顶部：语言选择、交换、粘贴、图片识别、清空和翻译；保留复制译文、原生输入法与工具切换后的草稿。


冻结源码定向回归 218 项：217 通过、1 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

翻译双栏与钉住交互使用隔离偏好、测试几何、演示译文与合成通知验证，不代表真实翻译语言包或硬件验收。系统监控的界面及暂停行为使用合成计数器验证。TinyPNG 上传流程仅使用模拟响应验证，尚未用真实 API 密钥联网验收。各类硬件的实际摄像头贴合与监控读数、真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒和持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 108。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。开发工具草稿与 TinyPNG API 密钥仅保留在当前应用会话中。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/NotchCalendar-2.0.25-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/NotchCalendar-2.0.25-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/SHA256SUMS.txt)

## English

- Pin the expanded notch to keep it open when the pointer leaves or you click outside. Pinning survives tool changes; unpinning restores automatic dismissal, and closing ends the current pin.
- Translation now uses equal side-by-side source and result panes, including narrow notch layouts, with character counts and independent scrolling for comparison.
- Translation actions move above the reading panes: language selection, swapping, paste, image recognition, clear and Translate. Copying results, native input methods and retained drafts remain available.


Frozen targeted regression: 218 cases, 217 passed, 1 optional skip and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Translation layout and pinning tests use isolated preferences, fixture translations, test geometry and synthetic notifications, without acceptance of live language-pack translation or physical hardware; monitor UI and sampling suspension use synthetic counters. TinyPNG uploads were checked with fixture responses, without acceptance against the live service using a real API key. Physical camera fit and monitor readings across hardware, human VoiceOver, physical multi-display/full-screen use, actual sleep/wake and sustained energy acceptance remain pending.

macOS 15+, Apple silicon and Intel, build 108. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained. Developer drafts and the TinyPNG API key stay in the current app session only.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/NotchCalendar-2.0.25-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/NotchCalendar-2.0.25-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/SHA256SUMS.txt)

Previous release: [2.0.24](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.24).
