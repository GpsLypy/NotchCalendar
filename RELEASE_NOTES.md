# Notch Calendar 1.6.22

macOS 15+ · Apple 芯片与 Intel · build 66 · 2026-10-10

## 新增

- 授权页提供「购买买断」「付款后领码」「已有授权码」三个直接入口。付款前清晰展示 ¥9.9 永久使用、未来版本更新、日程与专注的具体用途，以及人工领码和通常 24 小时内回复的流程。
- 主要按钮使用统一样式，补齐键盘焦点、按下与禁用状态。

## 调整

- 今日页优先展示下一场会议、专注与便笺入口和可用专注时段；诗笺移至工作内容之后，减少空时间轴。
- 未保存资讯偏好时默认展示五个核心页面，其他资讯通过「添加资讯」启用。已保存的显隐选择继续保留；分享、使用引导与自愿打赏收纳至「更多选项」。

## 修复

- 860 点宽的小窗口仍能并排查看月历与所选日期日程。
- 刘海会议标题支持两行显示及悬停查看全文；未来七天安排去除已展示的同次日程，同时保留周期会议的后续场次。
- 空日程与便笺共用稳定面板高度，避免页切换时跳动；修正英文单条日程的计数文案。

## 安装与升级

下载 `NotchCalendar-1.6.22-macos.dmg`，退出旧版后拖入「应用程序」替换，再重新启动。另提供 ZIP 和 SHA-256 校验文件。正常覆盖安装不会清除已有授权或本地数据。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试执行 393 项，13 项按需跳过，零失败；21 项 Python 质量测试和授权配置检查通过。原生输入验证了错误授权码修改后按回车激活、专注快捷键和页面导航；中英文、浅深色、小窗口、长标题和刘海页切换截图及回归检查已核对。

实体刘海及外接屏、真实休眠唤醒与登录启动、静置性能、真实付款激活、钥匙串弹窗和 VoiceOver **仍待验收**。本版保留人工核实付款、人工发码；付费转化效果尚未测量。

## English

Today prioritizes the next meeting, focus and note shortcuts, and available focus time. Optional insights start hidden when no preference has been saved; existing visibility choices are retained. Sharing, getting started and voluntary tips move into More options.

Smaller windows keep the month and selected-day agenda side by side. Primary buttons share focus, pressed and disabled states. Notch meeting titles wrap to two lines with full text on hover. The next-seven-days section excludes displayed occurrences while retaining later recurring instances; empty calendars and notes use a stable panel height.

Purchase, Claim a code and I have a code each provide a direct path. The one-time CNY 9.90 lifetime price, all future updates and manual code delivery are explained before payment. Payment does not activate the app automatically.

This ad-hoc signed build requires manual installation and has no Developer ID signing or Apple notarization. 393 Swift tests ran with 13 optional skips and no failures; 21 Python quality tests passed. Native interaction and Chinese/English, light/dark, compact-window and long-title checks passed. Physical displays, real sleep/wake/login behavior, stationary performance, live payment/activation, Keychain dialogs and VoiceOver remain **pending**.
