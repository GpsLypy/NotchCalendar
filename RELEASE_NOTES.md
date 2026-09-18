# Notch Calendar 1.6.12

macOS 15+ · Apple 芯片与 Intel · build 56 · 2026-09-18

## 新增与修复

- 公开双语 README 以展开刘海为首图，展示日历、专注、文件与便笺四项菜单，以及工作台浅色/深色与可选半透明材质。文件浮窗需在设置中启用；离屏截图不代表桌面折射或实机验收。
- 试用期间安静使用，仅在到期前 48 小时显示一次可关闭的温和提示；侧栏仍可主动查看截止时间与授权状态。
- ¥9.9 一次买断包含未来所有版本更新，无订阅。授权页先说明付款、发送凭证和安装标识、通常 24 小时内人工回复授权码；用户主动展开后才显示付款码。付款不会自动激活；打赏也不等于买断。
- 试用结束后可通过「我的数据」只读查看本地便笺、会议笔记、专注历史和已记录的文件位置，导出普通备份。私密收藏需系统身份验证后单独导出；导出的文件**不加密**，请妥善保管。
- 主工作台支持收起侧栏（Option–Command–S），紧凑导航保留页面入口与快捷键；提高部分次级文字的可读性，补齐授权相关中英文提示及错误反馈。
- 钥匙串故障优先显示重试而非误报试用到期；错误授权码仍可在原输入框中修改。已有永久授权继续有效，无需再次付款。

## 安装与升级

下载 `NotchCalendar-1.6.12-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 366 项，17 项按需测试跳过，零失败；Python 发行质量测试 21 项通过。原生界面截图使用合成资料。

本版尚未取得新的静置性能样本。完整刘海与外接屏交互、真实付款与授权码往返、VoiceOver、实体机器钥匙串权限和浅色/字号放大体验仍待人工验收。本次公开发布按所有者本版决定记录待验收例外；不复用旧样本，不豁免实测失败。

## English

The bilingual README now leads with the expanded notch's Calendar, Focus, Files, and Scratchpad tabs, plus light and dark workspaces with optional translucent material. Files must be enabled in Settings. Offscreen captures do not establish desktop refraction or physical-device acceptance. The seven-day trial stays quiet until a single dismissible reminder in its final 48 hours. A CNY 9.90 one-time purchase includes lifetime use and all future versions. Payment or a voluntary tip does not activate a license.

After the trial, My data gives read-only access to locally saved notes, focus history, file locations and ordinary backup export. Private bookmarks still require system authentication and are exported separately as an unencrypted file you must protect. The sidebar can be hidden without losing available navigation shortcuts.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Fresh stationary performance samples, complete physical-display acceptance, a live payment/activation walkthrough and accessibility checks remain pending under this version's recorded owner exception.
