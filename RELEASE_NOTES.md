# Notch Calendar 1.6.7

macOS 15+ · Apple 芯片与 Intel · build 51 · 2026-09-17

## 修复 / Fixed

- 修复日历与文件切换时，页面重建及延迟调整窗口造成的闪烁、跳动。
- 两页常驻共用布局容器，保留已加载日程与文件浏览状态，切换时窗口边界和毛玻璃背景保持稳定。
- 隐藏页面不接收点击、快捷键和辅助功能操作，隐藏日历暂停定时刷新。

## 安装与升级

下载 `NotchCalendar-1.6.7-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 338 项，15 项按需测试跳过，零失败；Python 发布质量测试 21 项通过。新增原生窗口回归测试验证反复切换日历与文件时窗口尺寸、位置、内容容器及毛玻璃背景保持稳定。

本版尚未取得新的静置性能样本。完整刘海与外接屏交互，以及每种场景两份静置性能样本仍待实机验收；本次发布请求已记录对应例外，不将旧样本作为本版通过证据。

## English

### Fixed

- Fixed flicker and window jumps caused by recreating Calendar/Files pages and resizing the panel after tab changes.
- Keep both browsing pages mounted in a shared layout envelope, preserving loaded events and file browsing state.
- Disable interaction and accessibility on hidden pages and pause the hidden calendar clock.

338 Swift tests, 15 optional tests skipped, zero failures; 21 Python release-quality tests passed. A native-window regression verifies stable geometry, content hosting and glass material across repeated Calendar/Files switches.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Fresh stationary performance samples and complete physical-display acceptance remain pending under the recorded owner exception.
