# Notch Calendar 1.6.1

macOS 15+ · Apple 芯片与 Intel · build 34 · 2026-09-16

## 优化 / Improved

- **设置重新排版**：顶部固定分类导航，下方分组卡片。通用设置、日历设置、会议提醒、工作台、数据与文件、软件更新各自独立，内容在 820 × 620 的窗口内滚动。
- **直接进入更新页**：点击「检查更新」或新版本提示，直接进入软件更新分类；日历来源、会议提醒入口也会定位对应设置。
- **精简窗口顶部**：授权入口移至「通用设置 → 授权与试用」，避免额外占用一行工具栏。

## 修复 / Fixed

- **修复授权钥匙串反复弹窗**：启动、定时检查、唤醒及试用记录保存改为静默访问钥匙串。需要许可时在应用内提示，仅点击「重试读取授权」才允许出现系统授权框。
- 钥匙串访问被拒绝时保留原记录，不新建安装标识、不重置试用，也不会错误授予永久权限。

## 升级与授权

下载 `NotchCalendar-1.6.1-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 与 SHA-256 校验文件。1.5.0 / 1.6.0 的有效永久授权继续使用，升级无需再次付款。

若升级后提示无法读取授权，请点击「重试读取授权」，在 macOS 提示中输入登录钥匙串密码（通常为 Mac 登录密码）并选择「始终允许」。不要删除原授权钥匙串记录。

**此版本仅采用 ad-hoc 签名，未进行 Developer ID 签名和 Apple 公证，需要手动安装；macOS 可能显示安全提示。不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 295 项，12 项按需测试跳过，零失败；发布质量脚本测试 20 项通过。

授权回归测试覆盖静默读取、试用检查点写入、显式重试恢复、系统交互策略恢复、永久授权持久化及试用到期。设置页面已进行原生渲染检查。

真实升级后的登录密码交互、锁屏/跨设备钥匙串恢复，以及完整刘海/外接屏交互仍待实机验收。自动测试与合成日历性能探针不替代这些流程。

## English

### Improved

- Settings now uses a persistent top navigation bar with six categories and grouped cards in an 820 × 620 window.
- Update, calendar-source and meeting-reminder actions open the relevant category directly. License access is available under General settings.

### Fixed

- Startup and background license checks, including trial checkpoint writes, no longer open Keychain password dialogs. Only the explicit Retry reading license action permits system interaction.
- Denied access preserves existing records and does not reset trials or grant access incorrectly.

Existing lifetime licenses remain valid. Quit the previous version and replace the app using the DMG or ZIP. If authorization is needed, use Retry reading license and follow the macOS prompt. This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Real authentication and physical-device acceptance remain pending.
