# Notch Calendar 1.6.19

macOS 15+ · Apple 芯片与 Intel · build 63 · 2026-09-24

## 新增

- 打卡弹窗将「收起提醒」和「移除」作为不同操作展示：收起只隐藏窗口，刘海旁的打卡胶囊仍在；移除只清除该条打卡。「完成」继续用于结束对应打卡。

## 修复

- 打卡弹窗按待处理事项数量调整高度：只有一条时不再出现大片空白，多条时逐步增高，超出后可滚动查看。

## 安装与升级

下载 `NotchCalendar-1.6.19-macos.dmg`，退出旧版后拖入「应用程序」替换。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

真实 SwiftUI 弹窗离屏渲染已检查，单条打卡窗口高度及背景通知回归测试通过；完整 Swift 测试执行 381 项，17 项按需跳过，零失败；21 项 Python 质量测试与授权配置检查通过。实体刘海及外接屏、真实唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗和 VoiceOver **仍待验收**，未将这些项目宣称为通过。

## English

The check-in popover now fits its pending items instead of showing a large blank area for one reminder. Hide reminder collapses the window while keeping the pending notch capsule; Remove clears only that entry, separately from Done. More items expand the popover up to a scrollable limit.

This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. The native SwiftUI capture, check-in height and background-notification regressions passed; 381 Swift tests ran with 17 optional skips and no failures, and 21 Python quality tests passed. Physical-display and real wake/login behavior, stationary performance, live payment/activation, Keychain dialogs, and VoiceOver remain **pending**.
