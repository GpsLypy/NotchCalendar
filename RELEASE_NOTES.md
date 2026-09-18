# Notch Calendar 1.6.11

macOS 15+ · Apple 芯片与 Intel · build 55 · 2026-09-18

## 新增 / Added

- 试用到期后仍可打开只读「我的数据」，查看便笺、专注记录和文件位置，导出普通备份；私密收藏需单独验证身份、明确确认后导出可读文件，权限仅限本人。
- 工作台侧栏可隐藏，使用 Option-Command-S 恢复，紧凑导航保留页面入口。

## 修复 / Fixed

- 七天试用仅在最后 48 小时显示一次可关闭的提醒；付款码按需展开，付款前说明 ¥9.9 永久买断包含未来版本、人工核对凭证与发码步骤，以及收到完整资料后通常 24 小时回复。自愿打赏不等于购买授权。
- 输入错误授权码后仍可继续编辑；钥匙串读取失败不会误报为试用到期。

## 安装与升级

下载 `NotchCalendar-1.6.11-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 364 项，16 项按需测试跳过，零失败；Python 发布质量测试 21 项通过。双架构安装包、签名、挂载与归档完整性已核验。

本版尚未取得新的静置性能样本。实体刘海与外接屏交互、VoiceOver、真实钥匙串权限及付款发码流程、每种场景两份静置性能样本仍待验收；本版记录了逐版本发布例外，不将旧样本作为本版通过证据，不豁免实测失败。

## English

### Added

- Read-only My data after trial expiry, including notes, focus history, file references and ordinary backup export. Private-bookmark export requires separate authentication and confirmation and creates an owner-only readable file.
- Hide the sidebar and restore navigation with Option-Command-S or the compact menu.

### Fixed

- Limit trial reminders to one dismissible message in the final 48 hours. Reveal the payment QR code on request and explain lifetime access, future updates, manual receipt/code delivery and the usual 24-hour reply time. Optional tips are separate from activation.
- Keep the activation field usable after invalid input and report Keychain failures separately from expiry.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Fresh stationary performance samples, physical-display and VoiceOver acceptance, real Keychain permission and live payment/activation checks remain pending under this version's recorded owner exception.
