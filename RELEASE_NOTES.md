# Notch Calendar 1.6.18

macOS 15+ · Apple 芯片与 Intel · build 62 · 2026-09-24

## 修复

- 修复 1.6.17 在 macOS 从后台线程发送跨日通知时可能崩溃的问题。打卡提醒先在主线程接收通知，再刷新刘海旁的胶囊与弹窗。
- 会议提醒的睡眠和唤醒通知也先切至主线程，避免同类线程隔离错误。

早晚打卡时段、手动完成/移除和跨重启保留的行为不变。已安装 1.6.17 的用户请升级到本版。

## 安装与升级

下载 `NotchCalendar-1.6.18-macos.dmg`，退出旧版后拖入「应用程序」替换。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

后台发送跨日和唤醒通知的回归测试通过；完整 Swift 测试执行 380 项，17 项按需跳过，零失败；21 项 Python 质量测试与授权配置检查通过。实体刘海及外接屏、真实唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗和 VoiceOver **仍待验收**，未将这些项目宣称为通过。

## English

Fix a v1.6.17 crash when macOS delivers the calendar-day change from a background thread. Check-in notifications now reach their main-thread handlers safely; meeting sleep/wake notifications use the same scheduling. Morning/evening check-in windows and persistent reminders are unchanged. Users of v1.6.17 should update.

This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. Background day-change and wake regression tests passed; 380 Swift tests ran with 17 optional skips and no failures, and 21 Python quality tests passed. Physical-display and real wake/login behavior, stationary performance, live payment/activation, Keychain dialogs, and VoiceOver remain **pending**.
