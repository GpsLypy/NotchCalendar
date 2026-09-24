# Notch Calendar 1.6.20

macOS 15+ · Apple 芯片与 Intel · build 64 · 2026-09-24

## 新增

- 完成打卡后单独保存当天完成标记；即使修改时段或重新启动应用，已完成的早间或晚间打卡也不会在当天重复出现。

## 修复

- 打卡弹窗移除「移除」操作，只保留「收起提醒」和「完成」，避免误操作。收起只隐藏窗口，待办仍留在刘海旁。
- 旧版将「完成」和「移除」都记为当日已显示且无待办，无法区分。现在调整时段后，如果旧记录已无待办且当前时间落入新时段，提醒可重新出现。旧版已完成的提醒在修改时段后也可能重新出现一次；新版的完成标记不会。

## 安装与升级

下载 `NotchCalendar-1.6.20-macos.dmg`，退出旧版后拖入「应用程序」替换。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

旧版移除后修改时段重现提醒、完成后修改时段及重启不重复的回归测试通过；原生 SwiftUI 弹窗离屏渲染已检查。完整 Swift 测试执行 384 项，17 项按需跳过，零失败；21 项 Python 质量测试与授权配置检查通过。实体刘海及外接屏、真实唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗和 VoiceOver **仍待验收**，未将这些项目宣称为通过。

## English

The check-in popover now offers only Hide reminder and Done, preventing accidental removal. Completion is persisted separately: a finished check-in does not reappear that day when its window changes or the app restarts. Editing a window can restore a legacy empty reminder if the current time is within the new window. Older versions did not distinguish completed from removed reminders, so a previously completed legacy item might also return once after editing its window.

This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. The legacy-removal, completion, and native SwiftUI rendering regressions passed; 384 Swift tests ran with 17 optional skips and no failures, and 21 Python quality tests passed. Physical-display and real wake/login behavior, stationary performance, live payment/activation, Keychain dialogs, and VoiceOver remain **pending**.
