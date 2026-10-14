# Notch Calendar 1.8.5

macOS 15+ · Apple Silicon and Intel · build 78 · 2026-10-14

## 修复与调整

- 修复点击或输入后，计算器移开鼠标仍不自动收起的问题。悬停模式下按既有宽限收起，重新移入可取消；再次打开计算器保留结果。仅点击模式与便笺、文件、专注的编辑行为保留。
- 音乐收藏提示新增更新或重装后的授权恢复说明，以及「在访达中显示当前应用」按钮，方便重新添加正确的应用副本。
- 「重新检查」读取最新收藏状态；从系统设置返回可见音乐页时检查未获授权状态。拒绝旧读取的迟到结果，保留进行中的收藏确认，恢复后关闭帮助并清除对应提示。

## 安装与授权

退出旧版，打开 `NotchCalendar-1.8.5-macos.dmg`，将应用拖入「应用程序」替换并重新启动。另提供 ZIP 和 `SHA256SUMS.txt`。沿用 **ad-hoc 签名、手动安装**，未进行 Developer ID 签名或 Apple 公证。

若辅助功能列表已开启，但音乐收藏仍提示授权，请移除旧 Notch Calendar 条目，重新添加当前应用并开启，然后完全退出并重新打开。当前签名方式下，更新后仍可能需要重新添加授权；本版提供恢复指引，不自动修改系统权限。

## 验证范围

Swift 全量执行 550 项：526 项通过、24 项按需或环境跳过，零失败；21 项 Python 质量检查通过。原生窗口验证覆盖计算器鼠标移出、宽限内移回、仅点击模式、`200 + 10% = 220`、收起重开保留结果和释放键盘焦点，以及四种中英文授权帮助状态和按钮操作。

通用构建、签名、快捷指令元数据、完整 DMG/ZIP 内容、安装链接与本地 SHA-256 检查通过。完整实体屏幕矩阵、真实休眠唤醒与登录、静置性能、VoiceOver、钥匙串弹窗、真实付款激活和完整播放器集成仍待验收。用户已确认安装版 1.8.4 重新添加授权后音乐收藏恢复；原生测试使用隔离数据，不代表修复版全部实机验收。

## English

Fix calculator retraction after clicking or typing: in hover mode, pointer exit retracts the notch after the existing grace period, reentry cancels it, and reopening the calculator retains the result. Click-only preferences and editing sessions in other tools remain supported.

Add music-favorite permission recovery instructions and “Show this app in Finder.” Explicit rechecks and returning to a visible denied music page read fresh state, reject obsolete responses, preserve pending favorite confirmation, and dismiss recovered help.

Quit the previous app, replace it in Applications using the DMG, and relaunch. This ad-hoc signed manual-install build has no Developer ID signing or Apple notarization. If Accessibility is already enabled but favorites remain unavailable after an update, remove the old entry, add and enable the current app, then quit and reopen. This release does not automatically modify system permissions or guarantee permission inheritance across ad-hoc signed updates.

550 Swift tests executed: 526 passed, 24 optional/environment checks skipped, zero failures; all 21 Python quality checks passed. Native checks cover calculator retraction, retained results, keyboard release, permission recovery and four Chinese/English help states. Universal packages, signatures, Shortcuts metadata, ZIP/DMG contents and SHA-256 checks passed. Physical displays, real sleep/wake/login, stationary performance, VoiceOver, Keychain dialogs, live payment/activation and full player integrations remain pending.
