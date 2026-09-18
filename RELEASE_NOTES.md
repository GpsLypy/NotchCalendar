# Notch Calendar 1.6.10

macOS 15+ · Apple 芯片与 Intel · build 54 · 2026-09-18

## 新增与修复

- 首次启动直接进入主工作台，自动开启 7 天试用，不先弹出付款或上手引导窗口。
- 顶部一次性买断提示可关闭；侧栏在打赏入口上方显示试用剩余天数及截止时间。
- 到期后停用刘海与自动化，不突然关闭正在使用的工作台；本地数据保留，可主动购买或激活。
- 打赏入口明确区分自愿支持与 ¥9.9 永久买断；钥匙串读取失败提供重试，不误报到期。

## 安装与升级

下载 `NotchCalendar-1.6.10-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 342 项，15 项按需测试跳过，零失败；Python 发行质量测试 21 项通过。首次上手与授权状态回归覆盖静默开启试用和主动打开上手引导。

本版尚未取得新的静置性能样本。完整刘海与外接屏交互、真实付款发码，以及每种场景两份静置性能样本仍待验收；本次发布请求记录独立例外，不将旧样本作为本版通过证据，不豁免实测失败。

## English

First launch now starts the seven-day trial and opens the workspace without a payment or onboarding modal. The purchase banner can be dismissed, while the sidebar shows remaining trial days. Expiry disables notch features without closing the open workspace, retains local data, and offers activation. Optional tips are not license purchases.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Fresh stationary performance samples, complete physical-display acceptance, and live payment/activation remain pending under the recorded owner exception.
