# Notch Calendar 1.6.13

macOS 15+ · Apple 芯片与 Intel · build 57 · 2026-09-18

## 修复

- 日历事件在刘海展开过程中更新时，窗口尺寸在动画期间保持稳定；展开完成后才平滑适配新内容。
- 收起或再次展开会取消旧的高度调整，避免旧动画干扰新状态。
- 矮屏可纵向滚动查看全部展开内容，窄屏可横向滚动内容区；顶部操作栏保留入口和辅助功能标签。

## 安装与升级

下载 `NotchCalendar-1.6.13-macos.dmg`，退出旧版后拖入「应用程序」替换。另提供 ZIP 和 SHA-256 校验文件。已有授权和本地数据不会因正常覆盖安装而清除。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 372 项，17 项按需测试跳过，零失败；Python 发行质量测试 21 项通过。新增回归覆盖展开中日历刷新、动画中断和中英文的小屏滚动。自动测试不能替代实体设备验收。

本版静置性能样本、实体刘海与外接屏交互、真实付款发码、钥匙串权限和 VoiceOver **仍待验收**。所有者明确授权 1.6.13 在披露这些待验收项目后发布；不复用旧样本，不豁免实测失败。

## English

Calendar updates no longer resize the notch window during its opening reveal. Interrupted height adjustments cannot continue after the panel closes or reopens. Expanded content scrolls vertically on short displays and horizontally on narrow displays, with the top toolbar kept accessible.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. 372 Swift tests ran with 17 optional skips and no failures; 21 Python quality tests passed. Fresh stationary performance samples, physical-notch and external-display interaction, live payment and activation, Keychain permissions, and VoiceOver remain **pending** under the owner's explicit version-specific authorization. No measured failures are waived.
