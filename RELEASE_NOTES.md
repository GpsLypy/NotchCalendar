# Notch Calendar 1.5.0

macOS 15+ · Apple 芯片与 Intel · 2026-09-16

## 新增

- 首次启动展示微信收款二维码，可选择免费试用 7 天。
- ¥9.9 一次买断、永久使用、无订阅。试用到期后需要永久授权码；激活后不再自动弹出收款窗口。
- 作者核实到账后人工发码：请把付款凭证和应用里的安装标识发送至 **498988598@qq.com**，或联系 **13191513539**。
- 授权码绑定安装标识，保存在 macOS 钥匙串中，可离线验证。换机或钥匙串丢失后可联系作者补发。
- 新版本采用闭源发行，公开资料与安装包单独发布。历史 MIT 版本保留原许可。

## 修复

- 文件浮窗的目录展开按钮扩大点击范围，第一次点击即可展开或收回。
- 安装包包含收款图和授权配置所需资源。

## 安装

下载 `NotchCalendar-1.5.0-macos.dmg`，退出旧版后，将应用拖入「应用程序」替换。也提供 ZIP 压缩包和 SHA-256 校验文件。

**此版本仅采用 ad-hoc 签名，未进行 Developer ID 签名和 Apple 公证，需要手动安装；macOS 可能显示安全提示。** 不提供自动替换安装。

## 验证范围

本地 Swift 测试 263 项，10 项可选测试跳过，零失败；Apple 芯片和 Intel 双架构构建通过。已验证签名篡改、错机授权、试用到期、时钟回拨和授权持久化。

实际微信收款、完整人工发码交付、不同设备上的钥匙串升级，以及刘海/外接显示器的完整交互验收尚未完成。离线授权不能防止有权限的用户删除钥匙串或修改程序。

## English

Version 1.5.0 introduces a seven-day trial and a one-time CNY 9.90 perpetual license. Send your payment receipt and installation ID to 498988598@qq.com for a manually issued activation code. Activated installations work offline without recurring fees. Historical MIT releases retain their original terms.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Physical-device and real payment acceptance remain incomplete as disclosed above.
