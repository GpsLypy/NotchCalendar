# Notch Calendar 1.6.8

macOS 15+ · Apple 芯片与 Intel · build 52 · 2026-09-17

## 修复 / Fixed

- 文件和便笺切换时复用便笺原生编辑器，保留选区和撤销记录；隐藏后释放键盘焦点。
- 文件图标在后台加载，先显示占位图标，避免慢速图标读取阻塞界面。

## 安装与升级

下载 `NotchCalendar-1.6.8-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 340 项，15 项按需测试跳过，零失败；Python 发布质量测试 21 项通过。文件图标后台加载与便笺编辑器切换有专项回归覆盖。

本版尚未取得新的静置性能样本。完整刘海与外接屏交互，以及每种场景两份静置性能样本仍待实机验收；本次发布请求记录独立例外，不将旧样本作为本版通过证据，不豁免实测失败。

## English

### Fixed

- Reuse the native scratchpad editor across Files/Scratchpad switches, preserving selection and undo history while releasing keyboard focus when hidden.
- Load file icons in the background and show placeholders while loading so slow icon lookups do not block the UI.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Fresh stationary performance samples and complete physical-display acceptance remain pending under the recorded owner exception.
