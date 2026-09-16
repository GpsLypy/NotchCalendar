# Notch Calendar 1.6.0

macOS 15+ · Apple 芯片与 Intel · build 33 · 2026-09-16

## 新增

- **今日诗笺**：14 条内置古典诗词摘句，按本地日期轮换，支持换一句、收藏、我的诗笺和收起，离线可用。
- **私密收藏（⌘9）**：通过 Mac 系统身份验证解锁，加密保存网站标题和网址，支持搜索、编辑、置顶和删除。离开页面、切换应用或窗口、休眠或解锁两分钟后锁定。
- **首次上手**：从查看日历、开始专注、收藏诗句中选择一个目标，按实际操作记录完成。可跳过，以后从设置重新打开，不会自动启动或覆盖计时。
- **资讯显隐**：可隐藏情报台、自选行情、舆论室、信息差简报，侧栏、快捷键与快速搜索同步调整，已有数据保留。
- **领码与售后**：一键复制申请资料或打开预填邮件草稿。收到完整付款凭证和安装标识后通常 24 小时内回复；换机、重装凭购买记录免费补发，无年度次数限制，仅限本人使用；丢码无需再次付款。
- **自愿打赏**：侧栏新增打赏作者入口，已激活用户也可自愿支持，无需续费。

## 修复

- 有效试用期间重启不再反复弹出收款窗口；新增侧栏「授权与试用」入口。
- 永久授权检查不再反复写入钥匙串；后台检查保留激活错误提示。
- 没有定时日程时收起空时间轴，空闲状态提供直接进入专注的操作。

## 授权与隐私

7 天免费试用，**¥9.9 一次买断、永久使用、无订阅**。付款核实和发码仍由作者人工完成。邮箱 **498988598@qq.com**，手机 **13191513539**。1.5.0 的有效授权继续使用，升级无需再次付款。

私密收藏在本机加密保存，密钥位于 macOS 钥匙串；不抓取网站预览，也不上传云端。**收藏和密钥不包含在应用 JSON 备份中**，请将本机加密文件和钥匙串一起妥善备份。打开网站会交给默认浏览器，浏览器可能记录历史；此功能不是无痕浏览器。

## 安装

下载 `NotchCalendar-1.6.0-macos.dmg`，退出旧版后，将应用拖入「应用程序」替换。也提供 ZIP 压缩包和 SHA-256 校验文件。

**此版本仅采用 ad-hoc 签名，未进行 Developer ID 签名和 Apple 公证，需要手动安装；macOS 可能显示安全提示。** 不提供自动替换安装。

## 验证范围

本地 Swift 测试 291 项，10 项可选测试跳过，零失败；Apple 芯片和 Intel 双架构构建通过。包括私密收藏加密与错误处理、自动锁定、上手引导实际操作、跳过记忆、隐藏模块导航回退、邮件模板编码，以及授权持久化测试。

真实 Touch ID/登录密码交互、锁屏/跨设备钥匙串恢复、邮件客户端兼容性、实际微信收款与发码，以及完整刘海/外接屏交互仍待实机验收。相关测试使用隔离偏好与模拟认证，不替代这些实机流程。

## English

Version 1.6.0 adds offline daily poetry, encrypted private bookmarks, a skippable first-use guide, optional insight modules, activation-request templates and voluntary author support. Existing 1.5.0 lifetime licenses remain valid. Complete activation requests usually receive a reply within 24 hours; personal-use replacement codes are free with proof of purchase, with no annual limit.

Private bookmarks require the local encrypted file and its Keychain key for recovery and are excluded from app JSON backups. Links use the default browser and may be recorded in browser history.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Physical-device and real payment acceptance remain incomplete as disclosed above.
