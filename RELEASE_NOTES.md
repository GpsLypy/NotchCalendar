# Notch Calendar 1.6.6

macOS 15+ · Apple 芯片与 Intel · build 50 · 2026-09-17

## 修复 / Fixed

- 修复快速展开、收起时，紧凑刘海可能因渲染确认早于遮罩安装而持续被覆盖的问题。
- 将展开态悬停通道限制在实体刘海触发区附近，旁边无关菜单栏项目不再阻止面板收起。

## 安装与升级

下载 `NotchCalendar-1.6.6-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 337 项，15 项按需测试跳过，零失败；紧凑遮罩交接与悬停通道边界有专项回归覆盖。Python 发布质量测试 21 项通过。

本版尚未取得新的静置性能样本。完整刘海与外接屏交互，以及每种场景两份静置性能样本仍待实机验收；本次发布请求已记录对应例外，不将旧样本作为本版通过证据。

## English

### Fixed

- Fixed a compact-notch handoff race that could leave the collapsed surface covered after rapid opening and closing.
- Narrowed the hover corridor between the hardware notch and expanded card so unrelated menu-bar items no longer keep the panel open.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Fresh stationary performance samples and complete physical-display acceptance remain pending under the recorded owner exception.
