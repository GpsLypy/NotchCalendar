# Notch Calendar 1.6.15

macOS 15+ · Apple 芯片与 Intel · build 59 · 2026-09-18

## 修复

- 刘海专注面板新增「取消」按钮，可结束运行或暂停的计时并收起专注胶囊。取消不计入已完成专注。
- 专注或会议双侧胶囊显示期间，仅点击胶囊才展开面板，不再因鼠标悬停弹出；胶囊消失后沿用原悬停或点击设置。

## 安装与升级

下载 `NotchCalendar-1.6.15-macos.dmg`，退出旧版后拖入「应用程序」替换。另提供 ZIP 和 SHA-256 校验文件。已有授权和本地数据不会因正常覆盖安装而清除。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共执行 374 项，18 项按需跳过，零失败；Python 发行质量测试 21 项通过。双架构安装包另经本地构建及必要的产物检查。

静置性能样本、实体刘海与外接屏交互、真实付款发码、钥匙串权限和 VoiceOver **仍待验收**。这些项目未作为通过项宣称；不复用旧样本，不豁免实测失败。

## English

Cancel a running or paused focus session from the expanded notch panel to dismiss its capsule without counting a completion. Active focus and meeting islands now expand only when clicked; idle interaction still follows your configured hover or click preference.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. 374 Swift tests ran with 18 optional skips and no failures; 21 Python quality tests passed. Stationary performance samples, physical-notch and external-display interaction, live payment and activation, Keychain permissions, and VoiceOver remain **pending**. No measured failures are waived.
