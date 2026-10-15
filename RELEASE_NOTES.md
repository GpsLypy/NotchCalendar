# Notch Calendar 2.0.0

macOS 15+ · Apple Silicon and Intel · build 83 · 2026-10-15

## 聊天设置保存修复

- 点击「保存」时允许 macOS 请求钥匙串授权，并读回确认 API Key；启动时继续静默读取，避免无操作时弹出授权。
- 保存成功后关闭设置，在聊天页显示「聊天设置已保存」。没有密钥时明确提示需要添加 API Key。
- 保存失败时保留输入，显示「聊天设置未保存」、恢复指引和钥匙串错误码；取消授权或读回失败不会提交新配置。可在授权后直接重试。

## 视觉与交互更新

- 浅色与深色界面采用冷灰、石墨层次，蓝色区分操作，珊瑚红标识日期；保留各日历来源颜色。
- 简化侧栏选中态，悬停或键盘聚焦时显示快捷键；设置采用系统分段控件，统一卡片边界、系统字体和按钮反馈。
- 刘海展开为 280 ms、收起为 210 ms，滚动内容保持位置并淡入淡出；主窗口切页遵循「减少动态效果」。
- 保留图片聊天、聊天/剪贴板/便笺鼠标移开自动收回，以及单轮删除和清空对话。

## 安装

退出旧版，打开 `NotchCalendar-2.0.0-macos.dmg`，拖入「应用程序」替换并重新启动。另提供 ZIP 和 `SHA256SUMS.txt`。如果保存时 macOS 请求钥匙串授权，请允许访问；无需把密钥发送给作者。退出会清除仅存在内存中的聊天记录和草稿，已保存设置、钥匙串密钥、便笺和剪贴板历史保留。

沿用 **ad-hoc 签名、手动安装**，未进行 Developer ID 签名或 Apple 公证。

## 验证范围

Swift 全量执行 611 项：584 项通过、27 项按需或环境跳过，零失败。21 项 Python 质量检查全部通过。

原生交互覆盖中英文宽窄窗口中的保存失败、保留输入、再次保存、成功提示与重新打开设置；隔离测试钥匙串项完成真实新增、更新、读回及删除，未访问用户实际 API Key，未请求真实模型服务。此前专注右肩的测试沿用旧版红色断言，现已与实际蓝色倒计时对齐并纳入回归。

完整实体屏幕矩阵、真实休眠唤醒与登录、静置性能、VoiceOver、真实用户升级后的钥匙串授权弹窗、付款激活、完整播放器集成和真实模型联调仍待验收。

## English

- Allow macOS Keychain authorization during explicit Save and verify the stored key before committing chat settings. Startup reads remain silent.
- Confirm successful saves in Chat. On failure, keep the entered fields and show recovery steps and the Keychain error code. Retry after allowing access; settings saved without a key explicitly say a key is still required.
- Refine light/dark surfaces, sidebar selection, native settings segments, typography and button feedback. Use blue actions and coral dates while preserving calendar source colors.
- Reveal the notch in 280 ms and retract in 210 ms; preserve scroll positions and respect Reduce Motion. Keep image chat, pointer-exit retraction and conversation cleanup.

Quit the old app, replace it in Applications using the DMG, and relaunch. Allow Keychain access if macOS asks during Save. Quitting clears in-memory chats and drafts; saved settings, credentials, notes and clipboard history remain. This is an ad-hoc signed manual-install build without Developer ID signing or Apple notarization.

Full regression executed 611 Swift tests: 584 passed, 27 optional/environment skips, zero failures. All 21 Python quality checks passed.

Native checks cover failure retention, retry, success and reopening in Chinese/English at narrow/wide sizes. Real Keychain operations use an isolated test item; no user API key was accessed and no real model request was sent. The focus rendering assertion now checks the blue countdown used by the current palette. Physical displays, real sleep/wake/login, stationary performance, VoiceOver, upgraded-user authorization prompts, payment/activation, full player integration and live models remain pending.
