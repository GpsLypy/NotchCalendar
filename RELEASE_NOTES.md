# Notch Calendar 1.6.5

macOS 15+ · Apple 芯片与 Intel · build 49 · 2026-09-17

## 新增 / Added

- **日历查询缓存**：日历数据未变化时复用当天和整月 EventKit 查询结果，反复切回日历页不再重复读取。

## 修复 / Fixed

- 日历、专注、文件和便笺快速切换时合并面板高度更新，避免每次点击都同步调整 WindowServer 窗口造成卡顿或漏响应。
- 重复点击当前菜单不再发布无效状态变化。

## 安装与升级

下载 `NotchCalendar-1.6.5-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 337 项，15 项按需测试跳过，零失败；EventKit 缓存及四菜单连续八轮快速切换有专项回归覆盖。

本版尚未取得新的静置性能样本。完整刘海与外接屏交互，以及每种场景两份静置性能样本仍待实机验收；本次发布请求已记录对应例外，不将旧样本作为本版通过证据。

## English

### Added

- Added a bounded calendar range cache that reuses unchanged EventKit query results.

### Fixed

- Rapid switching among Calendar, Focus, Files and Scratchpad coalesces panel-height updates instead of synchronously resizing the WindowServer panel after every click.
- Re-selecting the active menu no longer publishes redundant state changes.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Fresh stationary performance samples and complete physical-display acceptance remain pending under the recorded owner exception.
