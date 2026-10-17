# Notch Calendar 2.0.7

macOS 15+ · Apple Silicon and Intel · build 90 · 2026-10-17

## 刘海外观与动效

- 面板按当前工具调整宽高，减少便笺、专注等页面的留白，为日历、聊天和计算器保留合适的操作空间；仍可通过设置调整尺寸偏好。
- 八个工具集中到底部胶囊导航，选中项显示名称与颜色，支持鼠标、键盘快捷键 ⌘1–⌘8 和无障碍标签。
- 左上图标与标题增加内侧留白，顶部控件围绕镜头保持稳定对齐；导航与外壳同步调整位置，减少快速切换时的边缘裁切。
- 展开、收起与工具尺寸变化连续衔接，外形、内容和选中状态保持协调；中途重新进入或切换工具时从当前状态继续，减少空壳、跳变与文字叠影。
- 保留原生文本编辑、选区、撤销和页面状态；调整紧凑页面的输入区、按钮与滚动区域，并适配「减少动态效果」「减少透明度」及增强对比度。

## 授权与更新

- 永久授权改存本机应用数据目录，沿用现有公钥、NC1 激活码和原安装标识。成功迁移后，应用重启无需再次访问授权钥匙串；替换或重装应用且保留应用数据时可继续使用。
- 旧永久授权首次从钥匙串迁移时保留原记录。若系统拒绝读取，请在「授权与试用」点击「重试读取授权」允许一次访问。保存失败不覆盖原记录；本机授权文件损坏时保留文件并提示恢复，不静默替换。
- 新的永久激活不要求写入钥匙串。试用记录仍保存在钥匙串中，7 天期限与防时钟回拨检查保持不变；升级不会重置试用。普通设置备份不包含授权，换机或丢失原安装记录时仍需联系作者补发。
- 「软件更新」使用独立窗口，试用到期、授权读取失败或尚未进入工作台时也可检查更新、下载并打开安装包；更新不会重置试用或授予永久授权。
- 修复延后更新提醒与手动检查结果不一致的问题：最新检查确认无新版本时清除旧提醒，发现更新版本时显示最新版本说明。
- 延续 2.0.6 的聊天 API Key 本机保存方式，加强跨重启、旧密钥迁移失败恢复、文件权限、删除及服务隔离的回归检查；保存与发送不依赖钥匙串授权。旧密钥无法静默迁移时仍需重新保存一次。

## 验证与安装

本轮回归重点包括连续动画、八工具切换和紧凑布局、原生输入与撤销、永久授权迁移和失败重试、激活码兼容、试用到期与时钟回拨、独立更新窗口及提醒一致性。授权与网络检查使用隔离数据和受控响应；真实用户旧钥匙串授权弹窗、完整付费发码、真实模型与播放器联调、实体刘海和外接屏、休眠唤醒、VoiceOver 及长时间性能仍待完整验收。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/NotchCalendar-2.0.7-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/NotchCalendar-2.0.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/SHA256SUMS.txt)

退出旧版，将 DMG 中的应用拖入「应用程序」替换并重新启动。通用安装包支持 Apple 芯片与 Intel，最低 macOS 15；沿用 ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。独立更新窗口不代表本版支持自动替换安装。

## English

- Adapt the notch panel to each tool, keeping Scratchpad and Focus compact while giving Calendar, Chat and Calculator room to work. Size preferences remain adjustable.
- Bring all eight tools into a bottom capsule dock, with a name and color for the selected tool, ⌘1–⌘8 shortcuts and accessibility labels.
- Add breathing room beside the upper-left icon and title, keep the header aligned around the camera, and move navigation with the shell to avoid edge clipping during rapid tool changes.
- Coordinate opening, closing and tool size changes across the panel shape, content and selected state. Reentry and tool changes continue from the current animation state to reduce empty frames, jumps and overlapping labels.
- Preserve native text input, selection, undo and page state. Refine inputs, controls and scrolling at compact sizes, with support for Reduce Motion, Reduce Transparency and increased contrast.
- Store permanent licenses in local app data without changing the public key, NC1 code format or original installation ID. After migration, restarts no longer access the licensing Keychain. Replacing or reinstalling the app retains activation when app data is kept.
- Keep the original Keychain record during migration. If macOS blocks the first read, choose Retry reading license in License & trial to allow access once. Failed saves keep the previous record; damaged local license files are preserved with a recovery message instead of being silently replaced.
- New permanent activation does not require a Keychain write. Trial records remain in Keychain with the same seven-day limit and clock rollback checks. Upgrades do not restart a trial. Ordinary settings backups exclude licenses; changing Macs or losing the original installation record still requires a replacement code from the author.
- Open Software Update independently of license status or workspace startup, including after trial expiry or a license read failure. Check for updates, download and open the installer without activating first. Updating does not reset the trial or grant a permanent license.
- Keep deferred update reminders consistent with manual checks: clear an old reminder when the latest check finds no update, and use the latest release details when a newer version becomes available.
- Retain the local Chat API key storage introduced in 2.0.6, with reinforced regression checks for persistence, migration recovery, file permissions, removal and provider isolation. Save and Send do not require Keychain authorization; an unreadable legacy key still needs one explicit Save.

Regression focuses on continuous motion, eight-tool navigation and compact layouts, native editing and undo, permanent license migration and retries, activation compatibility, trial expiry and clock rollback, and independent update windows and reminders. License and network checks use isolated data and controlled responses. Real upgraded-user Keychain prompts, the complete payment and code delivery flow, live model and player integration, physical notches and external displays, sleep/wake, VoiceOver and sustained performance remain pending complete acceptance.

Quit the old app, replace it in Applications using the DMG, and relaunch. Universal macOS 15+ package for Apple silicon and Intel; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. The independent update window does not enable automatic app replacement for this release.

Previous release: [2.0.6](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.6).
