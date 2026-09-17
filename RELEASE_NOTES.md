# Notch Calendar 1.6.9

macOS 15+ · Apple 芯片与 Intel · build 53 · 2026-09-17

## 修复 / Fixed

- 日历、专注、文件和便笺四个标签的完整可见区域均响应首次点击。
- 修复透明留白区域漏掉点击、需要再次点击而表现为偶发响应慢的问题。

## 安装与升级

下载 `NotchCalendar-1.6.9-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 341 项，15 项按需测试跳过，零失败；Python 发布质量测试 21 项通过。四个标签的文字区域及透明留白均有原生鼠标事件专项回归覆盖。

本版尚未取得新的静置性能样本。完整刘海与外接屏交互，以及每种场景两份静置性能样本仍待实机验收；本次发布请求记录独立例外，不将旧样本作为本版通过证据，不豁免实测失败。

## English

### Fixed

- Make the full visible area of the Calendar, Focus, Files and Scratchpad tabs respond to the first click.
- Fix dropped clicks in transparent tab padding that could feel like intermittent slow response.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Fresh stationary performance samples and complete physical-display acceptance remain pending under the recorded owner exception.
