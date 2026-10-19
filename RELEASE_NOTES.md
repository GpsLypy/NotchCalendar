# Notch Calendar 2.0.12

- DeepSeek 网页对话直接使用官网账号，无需 API Key；保留原有 API 模式、独立草稿和图片。
- 网页发送并清空输入后，聊天框自动收成“继续输入”小按钮，给回答腾出空间；点击恢复并聚焦。中文选词、Shift+回车和未发出的草稿保持展开。
- 刘海网页默认 75% 缩放，可选 75%、85%、100%、125%；在独立窗口和刘海之间移动同一网页，保留网站会话与草稿。
- 修复已下载语言包时翻译一直等待的问题，默认英语 → 简体中文；支持重复翻译、取消和超时恢复。
- 放缓刘海展开节奏，保留连续收起、快速反向和原生输入状态。

发布前 182 项定向回归：180 项通过、2 项可选检查跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。

DeepSeek 折叠、草稿与窗口往返使用本地 WebKit 页面验证，真实账号发送、上传与官网改版兼容仍待实测。翻译修复另有本机真实英译中验收记录；本轮系统翻译检查按语言包可用性运行，macOS 15 实机、首次语言包下载和其他语言组合未覆盖。实体刘海、外接屏、休眠唤醒、VoiceOver 与静置能耗仍待验收；不宣称全量回归或严格设备门禁通过。

macOS 15+，Apple 芯片与 Intel，build 95。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，已有授权与聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/NotchCalendar-2.0.12-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/NotchCalendar-2.0.12-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/SHA256SUMS.txt)

## English

- Use your DeepSeek website account in AI Chat without an API key; retain the existing API mode and its separate draft and images.
- Fold the website composer into a small “Continue typing” button after a send clears the input, giving replies more room. Click to restore and focus it. IME composition, Shift+Enter and unsent drafts stay expanded.
- Default the notch website to 75% zoom, with 75%, 85%, 100% and 125% choices. Move the same live page between the notch and a separate window while retaining its session and draft.
- Fix translation waiting indefinitely with installed language packs. Default to English → Simplified Chinese, with repeat translation, cancellation and timeout recovery.
- Slow the notch opening motion while retaining continuous closing, quick reversals and native editing state.

Prepublication targeted regression: 182 cases, 180 passed, 2 optional checks skipped, zero failures; 21 Python quality checks and universal package validation passed.

DeepSeek folding, drafts and window transfer were checked with local WebKit pages; authenticated sends, uploads and compatibility with website updates remain unverified. The translation fix has separate local English-to-Chinese acceptance evidence; this run checks system translation only when its language packs are available. macOS 15 hardware, initial downloads and other pairs remain unverified. Physical notches, external displays, sleep/wake, VoiceOver and stationary energy acceptance remain pending; no full-app or strict hardware-gate pass is claimed.

macOS 15+, Apple silicon and Intel, build 95. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Keeping local app data preserves existing licenses and Chat API keys.

Previous release: [2.0.11](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.11).
