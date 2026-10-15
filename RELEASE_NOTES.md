# Notch Calendar 2.0.2

macOS 15+ · Apple Silicon and Intel · build 85 · 2026-10-15

## 日常细节，更清晰也更顺手

- 刘海工具导航增加轻薄分组底色和选中细描边，悬停提示展示对应快捷键。
- 日期、翻月、回到今天、日程与会议笔记使用一致的悬停、按压和键盘反馈。窄栏会议笔记入口增加文字与更大的点击区域。
- 跨午夜日程紧凑显示为「23:30 – 次日 00:15」，按显示时区的自然日判断并处理夏令时；多日事件保留完整结束日期。
- 最小刘海日历使用简短星期，避免英文星期截断；无障碍朗读仍保留完整星期。

## 安装

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/NotchCalendar-2.0.2-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/NotchCalendar-2.0.2-macos.zip) · [SHA-256 校验文件](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/SHA256SUMS.txt)

退出旧版，打开 DMG，拖入「应用程序」替换并重新启动。支持 Apple 芯片和 Intel 的通用安装包，最低 macOS 15。

沿用 **ad-hoc 签名、手动安装**，未进行 Developer ID 签名或 Apple 公证。

## 验证范围

Swift 全量执行 625 项：604 通过、21 条件跳过、零失败；21 项 Python 质量检查全部通过。32 项定向检查覆盖中英文时间格式、显示时区和夏令时边界、首次点击、内容过渡与对比度。

原生外观矩阵覆盖浅深色、中英文、两档桌面尺寸及三档刘海尺寸；实际窗口合成检查覆盖工具切回、收起重开和调整尺寸。截图和交互使用隔离演示数据，不请求真实模型服务。

完整实体屏幕矩阵、实际悬停手感、真实休眠唤醒与登录、静置性能、VoiceOver、升级用户钥匙串授权、真实模型、付款激活及完整播放器集成仍待验收。

## English

- Refine notch navigation with a subtle grouped surface and a fine selected border. Tooltips include the matching keyboard shortcuts.
- Make hover, press and keyboard feedback consistent across dates, month controls, Today, agenda items and meeting notes. Narrow agenda cards give notes a visible label and a larger click target.
- Show overnight event ranges compactly as “23:30 – Next day 00:15”, comparing civil days in the displayed time zone and handling daylight-saving changes. Longer events retain an absolute end date.
- Use short weekday names in the smallest notch calendar to prevent English truncation. Accessibility retains the full spoken weekday.

Quit the old app, open the DMG above, replace the app in Applications and relaunch. The universal package supports Apple silicon and Intel on macOS 15+. This is an **ad-hoc signed manual-install build**, without Developer ID signing or Apple notarization.

Full regression: 625 Swift tests, 604 passed, 21 conditional skips, zero failures; all 21 Python quality checks passed. The 32 targeted checks cover Chinese/English time formatting, displayed time zones and daylight-saving boundaries, first clicks, content transitions and contrast.

Native visual checks cover light/dark appearances, Chinese/English, two desktop sizes and three notch sizes. Window compositor checks cover switching tools, reopening and resizing. Captures and interactions use isolated demo data without real model requests.

Physical displays, real hover behavior, sleep/wake/login, stationary performance, VoiceOver, upgraded-user Keychain authorization, live models, payment/activation and full player integration remain pending acceptance.
