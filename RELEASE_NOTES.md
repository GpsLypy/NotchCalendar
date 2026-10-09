# Notch Calendar 1.6.21

macOS 15+ · Apple 芯片与 Intel · build 65 · 2026-10-09

## 新增

- 打卡胶囊内显示待处理数字红点，单条也显示，超过 99 条显示 99+。待处理数量超过 2 时胶囊轻柔闪烁；开启系统「减少动态效果」时保持静态。

## 修复

- 左右圆形胶囊统一尺寸、间距及图标与背景的中心位置，适配不同菜单栏高度。
- 打卡详情不再在启动、唤醒、新提醒到达、修改时段或主面板收起后自动展开。用户手动点击胶囊才能处理待办，全部完成后提醒隐藏。

## 安装与升级

下载 `NotchCalendar-1.6.21-macos.dmg`，退出旧版后拖入「应用程序」替换，再重新启动。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

启动积压待办、背景跨日通知、唤醒通知、主面板展开收起、手动打开关闭及完成后隐藏的回归检查通过。左右对称和数字红点的原生 SwiftUI 离屏截图已检查。完整 Swift 测试执行 387 项，19 项按需跳过，零失败；21 项 Python 质量测试与授权配置检查通过。实体刘海及外接屏、真实休眠唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗和 VoiceOver **仍待验收**。

## English

The check-in capsule now shows a red pending-count badge, including a single item and 99+ for counts above 99. More than two pending items gently pulse the capsule; the system Reduce Motion setting keeps it static. Circular capsules beside the notch now share mirrored dimensions, spacing and centered content across menu-bar heights.

Check-in details stay collapsed on launch, wake, new reminders, schedule changes and after closing the main notch panel. Only an explicit capsule click opens the pending items. Completing all items hides the reminder.

This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. Native rendering and reminder regressions passed; 387 Swift tests ran with 19 optional skips and no failures, and 21 Python quality tests passed. Physical-display and real sleep/wake/login behavior, stationary performance, live payment/activation, Keychain dialogs, and VoiceOver remain **pending**.
