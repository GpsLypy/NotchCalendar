# Notch Calendar 2.0.5

macOS 15+ · Apple Silicon and Intel · build 88 · 2026-10-16

## 修复

- 修复刘海收起时先出现空壳和宽黑条、再突然切换成两侧胶囊的割裂感。卡片与正文同步淡出，真实紧凑视图提前衔接。
- 调整收回曲线，使整个 240ms 过渡持续、平稳地收缩；中途重新进入仍从当前位置继续展开。
- 修复经典样式收回期间胶囊边缘被裁切的问题；保留原生文本编辑器、草稿、选区和撤销状态。

## 验证与安装

33 项动画定向测试全部通过，并检查了生产视图的原生 WindowServer 合成帧。完整 Swift 回归 822 项：790 通过、32 条件或环境跳过、零失败；21 项 Python 质量检查通过。双架构构建和安装包校验通过；实体刘海悬停、外接屏、休眠唤醒、VoiceOver 和静置性能仍待完整验收。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/NotchCalendar-2.0.5-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/NotchCalendar-2.0.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/SHA256SUMS.txt)

退出旧版，将 DMG 中的应用拖入「应用程序」替换并重新启动。通用安装包支持 Apple 芯片与 Intel，最低 macOS 15；沿用 ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。

## English

- Fix the abrupt empty shell and wide black bar before the notch switches to its compact islands. The expanded card and content fade together while the retained compact view appears during retraction.
- Keep the full 240ms closing transition smooth and continuous. Re-entering during retraction resumes expansion from the current position.
- Fix clipped compact islands during classic-style retraction. Preserve the native editor, drafts, selection and undo history.

All 33 targeted animation checks passed, with native WindowServer compositor frames inspected. Full Swift regression: 822 tests, 790 passed, 32 conditional or environment skips, zero failures; all 21 Python quality checks passed. Universal build and package checks passed. Physical notch hover, external displays, sleep/wake, VoiceOver and stationary performance remain pending complete acceptance.

Quit the old app, replace it in Applications using the DMG, and relaunch. Universal macOS 15+ package for Apple silicon and Intel; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization.

Previous release: [2.0.4](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.4).
