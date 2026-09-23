# Notch Calendar 1.6.17

macOS 15+ · Apple 芯片与 Intel · build 61 · 2026-09-23

## 新增

- 刘海左侧新增打卡胶囊。早间 08:00–10:00、晚间 18:00–20:00 打开电脑或应用、从睡眠唤醒，或在应用运行期间进入时段，会弹出提醒；在「设置 → 通用 → 打卡提醒」自定义早晚时段。
- 关闭弹窗不会清除打卡。待办跨重启保留，只有点击完成或手动移除才消失；点击胶囊可重新打开弹窗。
- 已安装应用默认请求登录时启动，可在设置中关闭；macOS 可能需要在系统设置的登录项中批准。

## 修复

- 当天完成或移除的打卡不会因反复唤醒而重复生成；刘海两侧会议和专注状态变化时，打卡胶囊跟随面板左边缘定位。

## 安装与升级

下载 `NotchCalendar-1.6.17-macos.dmg`，退出旧版后拖入「应用程序」替换。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

379 项 Swift 测试执行，17 项按需跳过，零失败；21 项 Python 质量测试通过，授权配置检查通过。实体刘海及外接屏、唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗和 VoiceOver **仍待验收**，未将这些项目宣称为通过。

## English

Add a check-in capsule to the left of the notch. Morning (08:00–10:00) and evening (18:00–20:00) reminders appear on launch, wake, or when the running app enters either window. Customize both windows in Settings. Closing the reminder keeps pending check-ins until you complete or remove them; clicking the capsule reopens it. The installed app requests launch at login by default, subject to macOS Login Items approval.

This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. 379 Swift tests ran with 17 optional skips and no failures; 21 Python quality tests passed. Physical display, wake and login, stationary performance, live payment and activation, Keychain dialogs, and VoiceOver remain **pending**.
