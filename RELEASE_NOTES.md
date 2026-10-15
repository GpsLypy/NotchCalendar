# Notch Calendar 2.0.1

macOS 15+ · Apple Silicon and Intel · build 84 · 2026-10-15

## 保存密钥后继续聊天

- 修复聊天设置显示保存成功后，发送消息仍因再次静默读取钥匙串而报错的问题。API Key 继续持久保存在本机钥匙串，当前应用会话复用已读回验证的密钥，不再每次发送都重新读取。
- 启动时静默读取；如果尚未取得密钥，用户首次发送或重试时允许 macOS 请求授权。取消授权保留草稿和图片附件，再次发送可重新授权。
- 密钥按服务隔离。切换服务后使用对应密钥；新服务没有密钥时明确提示添加，不会借用上一服务的密钥。
- 删除或替换密钥时，旧会话缓存失效；替换写入后验证失败，也不会继续发送旧密钥。保存另一服务失败时，当前服务的已验证密钥仍可使用。
- 保留 2.0 的浅深色界面、蓝色操作与珊瑚红日期、侧栏与卡片更新，以及尊重「减少动态效果」的刘海展开和收起动效。

## 安装

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/NotchCalendar-2.0.1-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/NotchCalendar-2.0.1-macos.zip) · [SHA-256 校验文件](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/SHA256SUMS.txt)

退出旧版，打开 DMG，拖入「应用程序」替换并重新启动。如 macOS 请求钥匙串授权，请允许访问。退出会清除当前会话中的密钥内存副本、聊天记录和草稿；已保存设置、钥匙串密钥、便笺和剪贴板历史保留，重启后从钥匙串重新读取密钥。

沿用 **ad-hoc 签名、手动安装**，未进行 Developer ID 签名或 Apple 公证。

## 验证范围

Swift 全量执行 621 项：595 通过、26 条件跳过、零失败；21 项 Python 质量检查全部通过。定向回归 125 项零失败，包含中英文小窗口和标准窗口中实际保存后发送图片。

本版回归覆盖保存后连续发送与重试、启动静默读取和首次发送授权、取消授权保留草稿与图片、服务隔离，以及删除或替换失败时的缓存处理。隔离测试不使用用户实际 API Key，也不请求真实模型服务。

真实用户升级后的钥匙串授权弹窗与访问控制、真实模型联调，以及完整实体屏幕矩阵、真实休眠唤醒与登录、静置性能、VoiceOver、付款激活和完整播放器集成仍待验收。

## English

- Fix sending failures after a successful settings save caused by another silent Keychain read. API keys remain persisted in this Mac's Keychain; the current app session reuses a key after reading and verifying it.
- Startup reads stay silent. If a key has not yet been obtained, an explicit Send or Retry allows macOS to request access. Cancelling authorization preserves the draft and image attachments for another attempt.
- Keep credentials separate for each service. A service without a key asks you to add one and never borrows the previous service's credential.
- Removing or replacing a key invalidates its old session cache, including when a replacement was written but could not be verified. A failed save for another service preserves the current service's verified credential.
- Retain the 2.0 light/dark surfaces, blue actions, coral dates, sidebar and cards, plus notch motion that respects Reduce Motion.

Quit the old app, replace it in Applications using the DMG above, and relaunch. Allow Keychain access if macOS asks. Quitting clears the session's in-memory credential, chats and drafts; saved settings, Keychain credentials, notes and clipboard history remain. A new app session reads the key from Keychain again. This is an **ad-hoc signed manual-install build**, without Developer ID signing or Apple notarization.

Full regression: 621 Swift tests, 595 passed, 26 conditional skips, zero failures; all 21 Python quality checks passed. The 125 targeted checks included native Save-to-Send image interactions in Chinese and English at compact and standard sizes.

Regression coverage includes repeated sending and retry after Save, silent startup and explicit authorization, cancellation with retained drafts and images, provider isolation, and cache invalidation after removal or replacement failures. Isolated tests do not use user API keys or real model services. Upgraded-user Keychain authorization dialogs and access controls, live models, physical displays, real sleep/wake/login, stationary performance, VoiceOver, payment/activation and full player integration remain pending acceptance.
