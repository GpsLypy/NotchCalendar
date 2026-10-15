# Notch Calendar 1.8.8

macOS 15+ · Apple Silicon and Intel · build 81 · 2026-10-15

## 修复

- 修复「聊天设置」打开后，点击外部让刘海收起但弹窗残留、输入框和取消按钮变灰而无法退出的问题。
- 设置打开时保持父面板活动，不让外部点击或延迟到达的父窗口点击禁用设置或抢走键盘焦点。
- 切换工具或强制结束刘海会话时关闭设置；再次展开不再把聊天设置叠在日历上。

## 安装

退出旧版，打开 `NotchCalendar-1.8.8-macos.dmg`，拖入「应用程序」替换并重新启动。另提供 ZIP 和 `SHA256SUMS.txt`。如果旧窗口卡住无法退出，可使用系统「强制退出」结束旧进程后安装；退出会清除仅存在内存中的聊天记录和草稿，已保存的模型设置与钥匙串密钥保留。

沿用 **ad-hoc 签名、手动安装**，未进行 Developer ID 签名或 Apple 公证。

## 验证范围

Swift 全量执行 590 项：565 项通过、25 项按需或环境跳过，零失败。 21 项 Python 质量检查通过。

通过真实刘海齿轮打开原生设置窗口，验证模型字段输入、取消不保存、Esc 退出、保存生效、重复打开、键盘焦点、外部点击、强制收起和切换工具后不残留弹窗。聊天协议、受控网络、剪贴板、刘海展示、Space 和工具栏定向回归共 68 项：67 项通过、1 项按需跳过、零失败。现有原生交互同时复验中英文五档面板尺寸。

完整实体屏幕矩阵、真实休眠唤醒与登录、静置性能、VoiceOver、钥匙串弹窗、真实付款激活、完整播放器集成和真实模型联调仍待验收。网络测试使用受控响应，未使用真实服务商密钥。

## English

- Fix Chat settings becoming stuck and disabled after an outside click collapsed the notch while leaving the sheet attached.
- Keep the parent panel active during settings, and prevent delayed parent clicks from stealing keyboard focus.
- Dismiss settings when changing tools or ending the notch session, preventing an orphaned sheet from covering the calendar on reopening.

Quit the old app, replace it in Applications using the DMG, and relaunch. If necessary, use macOS Force Quit to end a stuck old instance first; quitting clears in-memory chat history and drafts. Saved model settings and Keychain credentials remain. This is an ad-hoc signed manual-install build without Developer ID signing or Apple notarization.

Full regression executed 590 Swift tests: 565 passed, 25 optional/environment skips, zero failures. All 21 Python quality checks passed. Actual notch-to-sheet tests verify editing, Cancel, Escape, Save, repeated opening, focus, outside clicks, forced collapse and activity changes. The 68-test targeted regression had 67 passes, one optional skip and no failures; existing native interaction checks also covered Chinese/English at five panel sizes.

Physical displays, real sleep/wake/login, stationary performance, VoiceOver, Keychain dialogs, live payment/activation, full player integration and real-provider calls remain pending.
