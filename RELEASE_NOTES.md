# Notch Calendar 2.0.8

macOS 15+ · Apple Silicon and Intel · build 91 · 2026-10-18

## 稳定的窗口与紧凑导航

- 八个工具共用日历页面的窗口尺寸。切换日历、专注、文件、便笺、音乐、计算器、剪贴板和 AI 聊天时，外框、标题与导航位置保持稳定；仍可在设置中调整整体尺寸。
- 底部胶囊导航更窄、更轻，贴近窗口底边，减少大块留白。选中工具显示名称与颜色，保留鼠标操作、⌘1–⌘8 快捷键和无障碍标签。
- 页面内容与导航切换连贯衔接；快速切换和动画中途重新进入保留当前状态。继续保留原生文本编辑、选区、撤销与页面状态，并适配「减少动态效果」。
- 调整各页内容空间，让专注图表的七个星期、音乐进度、计算器底排、便笺保存状态和聊天底部操作完整可见。

## 未来七天安排

- 优化日历下方「未来 7 天的其他安排」布局，为较多安排保留可滚动的阅读空间；继续显示日期、时间、日程名称与日历颜色，避免重复展示上方已出现的安排。
- 完善「查看全部」的点击区域与完整七天列表，确保较多安排和仍在进行中的安排可查看，保留完整标题、日历来源与返回月历入口。
- 月历和安排列表分别使用可用空间，较多内容可滚动查看；新增日程与「查看全部」保持可点击。

## 授权后的欢迎与启动

- 等待日历授权结果后展示欢迎，再进入工作台；允许、拒绝或请求失败均可继续，已有授权结果时不重复发起初始请求。
- 若授权结束时应用尚未激活或屏幕暂不可用，在应用重新激活、唤醒或显示器恢复时继续尚未完成的启动流程，避免欢迎停留在等待状态。
- 欢迎完成记录与安装版本和构建号绑定。升级后展示一次；明确完成或跳过后，普通重启不重播。中途退出仍可在下次启动看到介绍。
- 沿用本机永久授权与聊天 API Key 保存方式，以及独立的软件更新窗口。

## 验证与安装

本轮界面与欢迎流程 126 项针对性测试通过；另有授权、更新及密钥保存 97 项检查，96 项通过、1 项可选 Finder 集成检查跳过。合计 223 项、222 项通过、零失败；21 项 Python 质量检查通过。界面验证覆盖固定窗口、原生 Dock 交互、连续展开收起、日历列表、欢迎启动及输入状态保留；已检查原生合成截图中的八工具布局。测试使用隔离数据与受控环境。本轮定向验证不等于重新完成全部回归；原生录制也不构成硬件稳定 60 fps 的结论。真实用户旧钥匙串迁移与授权弹窗、完整付款发码、真实模型与播放器、实体刘海及外接屏、休眠唤醒、VoiceOver 和长时间性能仍待完整验收。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/NotchCalendar-2.0.8-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/NotchCalendar-2.0.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/SHA256SUMS.txt)

退出旧版，将 DMG 中的应用拖入「应用程序」替换并重新启动。通用安装包支持 Apple 芯片与 Intel，最低 macOS 15；沿用 ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。独立更新窗口不代表本版支持自动替换安装。

## English

- All eight tools share the Calendar window size. Changing tools keeps the outer frame, header and navigation in place; the overall size remains adjustable in Settings.
- A narrower, lighter capsule dock sits close to the bottom edge with less unused space. The selected tool shows its name and color, with mouse input, ⌘1–⌘8 shortcuts and accessibility labels.
- Coordinate content and navigation transitions while retaining state through rapid changes and mid-animation reentry. Preserve native text input, selection, undo and page state, with Reduce Motion support.
- Refine content space so all seven Focus weekdays, Music progress, the bottom Calculator row, Scratchpad save status and Chat controls remain visible.
- Improve the “More in the next 7 days” layout with scrollable space for longer agendas. Keep dates, times, event titles and calendar colors, and omit occurrences already shown above from this preview.
- Refine the “View all” click target and complete seven-day list so longer agendas and ongoing events remain accessible, with full titles, calendar names and a return to the month. Calendar and agenda content can scroll within their allotted space; New event and View all remain clickable.
- Resolve Calendar authorization before presenting the welcome and starting the workspace. Allow, deny and errors all continue; a determined authorization state does not trigger another initial request.
- Resume unfinished startup when the app becomes active, the Mac wakes or the display becomes available after authorization. Record welcome completion per version and build: show it once on upgrade, retain completion or Skip across ordinary restarts, and offer it again after an interrupted introduction.
- Retain local permanent-license and Chat API key storage, plus the independent Software Update window.

The 126 targeted UI and welcome tests passed. A further 97 licensing, update and credential checks had 96 passes and one optional Finder integration skip: 223 targeted cases, 222 passed, zero failures. All 21 Python quality checks passed. UI coverage includes the fixed viewport, native Dock input, continuous reveal and retraction, calendar lists, welcome startup and retained input state. Native compositor captures were inspected across all eight tools. Tests use isolated data and controlled conditions. This focused validation is not a new full regression, and native recording does not establish sustained hardware performance at 60 fps. Real upgraded-user Keychain migration and prompts, the complete payment and code-delivery flow, live model and player integration, physical notches and external displays, sleep/wake, VoiceOver and sustained performance remain pending complete acceptance.

Quit the old app, replace it in Applications using the DMG, and relaunch. Universal macOS 15+ package for Apple silicon and Intel; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. The independent update window does not enable automatic app replacement for this release.

Previous release: [2.0.7](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.7).
