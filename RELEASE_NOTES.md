# Notch Calendar 2.0.34

## 2.0.35：全部刘海面板视觉统一

- 统一全部 14 个刘海工具及工具库、隔空投送等子面板的圆角、字体、留白和背景层级，暗色内容更清楚，浅色图标更易辨认。
- 改进底部 Dock 的激活状态、按钮悬停反馈和面板过渡，保留减少动态效果、高对比度和减少透明度支持。
- 优化日历日期与日程布局、文件列表与投送区、翻译双栏和语言菜单、计算器轻字重结果及实心等号按钮。
- 同步打磨专注、速记、音乐、剪贴板、AI 对话、行情、资讯、开发工具、系统监控与 AI 用量。
- 修复窄窗下深层文件名被挤压、DeepSeek 工具栏超宽，以及 AI 用量卡片和保存按钮越界。

macOS 15+，Apple 芯片与 Intel，build 118。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试。此前开发阶段 108 项回归通过、1 项真实 AirDrop 拖动测试跳过，另有 7 项外观测试通过及 28 张原生面板截图复查。实际跨设备 AirDrop、多屏、睡眠唤醒、VoiceOver、真实服务与持续能耗仍待验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/SHA256SUMS.txt)

## 2.0.35: A consistent finish across every notch panel

- Unify all 14 notch tools, the tool library and supporting panels with consistent corners, system typography, spacing and surface depth. Improve dark-mode clarity and light-mode symbol contrast.
- Refine active Dock items, button hover feedback and panel transitions while preserving reduced motion, increased contrast and reduced transparency.
- Improve calendar hierarchy, file lists and AirDrop, translation columns and language menus, and the calculator's light result digits and filled equals button.
- Polish Focus, Scratchpad, Music, Clipboard, AI Chat, Markets, News, Developer Tools, System Monitor and AI Usage.
- Fix narrow-window clipping of deeply nested filenames, the DeepSeek toolbar, AI Usage cards and the credential save button.

macOS 15+, Apple silicon and Intel, build 118. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

No additional release regression was run at the owner's request. Prior development work passed 108 regression tests, skipped one live AirDrop drag test, and passed seven appearance tests with 28 native panel screenshots reviewed. Cross-device AirDrop, multiple displays, sleep/wake, VoiceOver, live services and sustained resource use remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/SHA256SUMS.txt)

## 2.0.34：通知期间保持收纳，改善菜单兼容

- 通知弹出、经过时钟或打开系统面板时，不再主动把已收纳图标恢复到系统菜单栏。
- 原生菜单在对应收纳图标下方打开，改善点击无响应和菜单出现在屏幕左上角的问题；保留菜单勾选、快捷键、分隔线与子菜单。
- 对无法直接打开自定义弹窗的应用，提供明确标注的「应用菜单」入口。豆包使用此入口，暂不提供原自定义快捷面板。
- 新增输入法图标收纳。电池、时钟、控制中心和天气暂不支持收纳，继续保留在系统菜单栏。
- 保留原有收纳选择与排列；关闭收纳、退出或权限失效时恢复图标。

状态栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限。应用其他功能支持 macOS 15+。

Apple 芯片与 Intel，build 117。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试或现场验收。此前开发阶段完成 31 项定向测试，以及同程管家、sftpty、豆包应用菜单和输入法的本机集成检查。这些记录不等同于新发布回归；通知点击与完整收纳栏鼠标、截图验收仍未完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/SHA256SUMS.txt)

## 2.0.34: Keep icons collected during notifications and improve menu compatibility

- Notifications, clock-area interaction and system panels no longer deliberately return collected icons to the system menu bar.
- Native menus open below the corresponding tray button, improving unresponsive clicks and menus appearing at the upper-left corner. Checkmarks, shortcuts, separators and submenus are preserved.
- Apps whose custom popups cannot open directly offer an explicitly labelled application-menu fallback. Doubao uses this fallback; its original custom quick panel is not provided.
- Added collection for Input Sources. Battery, clock, Control Center and Weather remain in the system menu bar and cannot currently be collected.
- Preserve collection choices and ordering. Disabling the organizer, quitting or losing permission restores icons.

The organizer requires macOS 27, installation in Applications and Accessibility permission. Other features support macOS 15+.

Apple silicon and Intel, build 117. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

No additional release regression tests or live acceptance were run, as requested by the owner. Prior development work passed 31 targeted tests and checked native integration for Tongcheng, sftpty, Doubao application menus and Input Sources. This is separate from frozen-release regression; notification-click, full tray mouse-click and screenshot acceptance remain incomplete.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/SHA256SUMS.txt)

## 2.0.33：收纳图标留在收纳栏

- 点击收纳图标直接打开原应用菜单，图标继续保留在收纳栏，不再临时移回系统菜单栏。
- 修复隐藏状态切换后点击没有反应的问题；原生菜单关闭后可以再次打开，常驻悬浮窗不会阻塞后续操作。
- 鼠标悬停或经过右上角时钟区域时保持收纳；真实系统面板交互仍保留临时暂停。
- 修复刘海小伴侣的小狗头被系统菜单栏遮挡的问题。
- 保留已有收纳应用选择与排列；系统菜单栏项目暂不支持收纳。

状态栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限。应用其他功能支持 macOS 15+。

Apple 芯片与 Intel，build 116。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试或现场验收。此前开发阶段的 27 项定向测试通过，并完成 Pulse、Docker 原生菜单的两轮打开与关闭检查；收纳栏完整鼠标点击和截图验收受系统捕捉限制，未标记为通过。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/SHA256SUMS.txt)

## 2.0.33: Keep collected icons in the tray

- Open the original app menu directly while keeping its icon collected, without temporarily returning it to the system menu bar.
- Fixed unresponsive clicks after visibility changes. Menus can open again after closing, and persistent floating panels no longer hold the menu session open.
- Keep icons collected when hovering over or passing the clock area, while preserving temporary suspension during actual system panel interaction.
- Fixed the notch companion's dog head being covered by the system menu bar.
- Preserve saved collection choices and ordering. Collecting macOS system items is not yet supported.

The organizer requires macOS 27, installation in Applications and Accessibility permission. Other features support macOS 15+.

Apple silicon and Intel, build 116. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

No additional release regression tests or live acceptance were run, as requested by the owner. Prior development work passed 27 targeted tests and checked two open/close cycles of the real Pulse and Docker menus. Full shelf mouse-click and screenshot acceptance was blocked by system capture and is not marked as passed.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/SHA256SUMS.txt)
