# Notch Calendar 3.2.7

## 3.2.7：独立待办与刘海胶囊提醒

- 新增独立待办入口，默认显示在桌面右上角，也可选择小猫、小狗或隐藏入口。
- 新建待办可直接填写时间、优先级、重复、提醒、标签与备注；回车保存，一句话识别日期后仍可调整。
- 新增定时汇总未完成待办；汇总和单条到点提醒共用刘海胶囊。刘海两侧被占用时，胶囊显示在刘海下方。
- 点击汇总打开未完成列表，点击单条提醒打开任务详情；完成、暂缓、取消或删除后同步收起提醒。

待办与提醒设置保存在本机，支持备份。刘海胶囊需要应用保持运行，无需系统通知权限；休眠或退出期间无法保证准时提醒。

macOS 15+，Apple 芯片与 Intel 通用包，build 147。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行待办存储、入口、添加、汇总、单条提醒与原生胶囊回归，并检查通用安装包。当前 Mac 已实测两种胶囊提醒；多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/NotchCalendar-3.2.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/NotchCalendar-3.2.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/SHA256SUMS.txt)

## 3.2.7: Independent To-Dos and notch capsule reminders

- Open To-Dos from a standalone checkmark at the top right of the desktop, or choose a cat, dog, or hidden entry.
- Set dates, priority, recurrence, reminders, tags and notes while adding a task; press Return to save and adjust dates detected from natural language.
- Schedule unfinished-task summaries. Both summaries and individual reminders use notch capsules, moving below the notch when its sides are occupied.
- Click a summary to open unfinished tasks or an individual capsule to open task details. Completing, deferring, cancelling or deleting a task dismisses its reminder.

Tasks and reminder preferences stay on this Mac and support local backup. Capsules require the app to remain running and do not require system notification permission; punctual delivery during sleep or while the app is closed is not guaranteed.

macOS 15+, universal Apple silicon/Intel, build 147. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release runs To-Do persistence, entry, composer, summary, individual reminder and native capsule regressions plus independent package checks. Both capsule types were exercised on the current Mac; multi-display, sleep/wake, VoiceOver, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/NotchCalendar-3.2.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/NotchCalendar-3.2.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.7/SHA256SUMS.txt)

## 3.2.6：修复重复的菜单栏入口

- 修复收纳开启时同时出现两个「…」入口：原生按钮可见时立即撤下悬浮兜底按钮。
- 收纳面板跟随实际点击的按钮；原生入口恢复时同步交接，不再指向另一个「…」。
- 仅在确认原生入口被隐藏后显示兜底按钮，沿用菜单栏的实际高度与原位置中心。

macOS 15+，Apple 芯片与 Intel 通用包，build 146。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版检查当前系统的原生入口可见性，并执行真实 AppKit 控制器交接、点击锚点、关闭与图标像素回归及独立安装包检查。系统隐藏动作使用隔离测试替身；完整第三方隐藏兼容性、多屏、睡眠唤醒、VoiceOver、Intel 实机和持续性能未重新验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/NotchCalendar-3.2.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/NotchCalendar-3.2.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/SHA256SUMS.txt)

## 3.2.6: Fix duplicate menu bar entries

- Remove the floating fallback immediately when the native organizer entry is visible, preventing two ellipsis buttons.
- Anchor the shelf to the button actually clicked and hand it back when the native entry returns.
- Show a fallback only after confirming the native entry is hidden; preserve the rendered menu bar height and slot center.

macOS 15+, universal Apple silicon/Intel, build 146. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release checks native entry visibility on the current system and runs AppKit controller handoff, click-anchor, dismissal, glyph pixel and independent package checks. Hiding actions use isolated test doubles; full third-party hiding compatibility, multi-display, sleep/wake, VoiceOver, physical Intel and sustained performance were not revalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/NotchCalendar-3.2.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/NotchCalendar-3.2.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.6/SHA256SUMS.txt)

## 3.2.5：分屏边界与菜单栏入口修复

- 修复分屏面板两侧选区溢出，选区和文字按外壳边界留出一致间距。
- 修复从宽面板进入分屏时残留缩放、拖放位置不一致的问题，切换后恢复正确尺寸与落点。
- 修复菜单栏「…」点击后跳到刘海旁的问题，优先保持原位置，临时被占用后可回到原位。
- 修复菜单栏「…」偏上，三个圆点在不同菜单栏高度下保持水平、垂直居中，并保留原生入口图标。

macOS 15+，Apple 芯片与 Intel 通用包，build 145。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行分屏几何、原生面板切换、落点和图标像素居中测试及独立安装包检查。完整多屏拖窗、系统菜单栏隐藏兼容性、睡眠唤醒、VoiceOver、Intel 实机和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/NotchCalendar-3.2.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/NotchCalendar-3.2.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/SHA256SUMS.txt)

## 3.2.5: Window arrangement and menu bar fixes

- Keep window arrangement zones and labels inside the panel edges with consistent padding.
- Reset retained scaling when switching from a wide panel, keeping visible zones and drop targets aligned.
- Keep the menu bar organizer entry in its original slot and return after a temporary obstruction.
- Center the three dots horizontally and vertically at different menu bar heights, and preserve the native entry icon.

macOS 15+, universal Apple silicon/Intel, build 145. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

This release runs focused geometry, native panel transitions, drop target and icon pixel checks plus independent package verification. Full physical multi-display dragging, system menu bar hiding compatibility, sleep/wake, VoiceOver, physical Intel and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/NotchCalendar-3.2.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/NotchCalendar-3.2.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.5/SHA256SUMS.txt)

## 3.2.4：更舒展的界面，更平稳的收起

- 统一行情、计算器、便签、工具库及设置等页面的安全边距，内容与操作按钮不再紧贴外缘。
- 缩小底部导航的视觉占用，保留点击区域，让底部间隙和外壳圆角完整显露。
- 修复收起时导航闪现与材质残影，主面板、内容和背景按同一提交时钟完成过渡，快速反向操作仍然连贯。
- 修复空白便签输入首字后意外切换阅读模式，编辑、草稿和选择范围可持续保留。
- 提供语音日程输入、化妆镜与天气陪伴，以及整合 DeepSeek 网页、API、编程动态和额度的 AI 工作台。日程在确认后才写入日历，摄像头按需授权，镜面画面不保存、不上传。

macOS 15+，Apple 芯片与 Intel 通用包，build 144。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版对冻结输入执行原生界面、收起动效、草稿保留及安装包检查。完整多屏、睡眠唤醒、VoiceOver、Intel 实机、真实麦克风与摄像头和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/NotchCalendar-3.2.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/NotchCalendar-3.2.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/SHA256SUMS.txt)

## 3.2.4: More breathing room and smoother retraction

- Apply safe insets across markets, calculator, notes, the tool library and settings.
- Reduce the bottom navigation's visual footprint while retaining click targets, exposing the shell corners and a clear bottom gap.
- Fix navigation flashes and material remnants during collapse. Shell, content and surface transitions share the commit clock, including rapid reversals.
- Keep new blank notes editable after the first character and preserve drafts and selections.
- Include voice scheduling, a mirror with weather, and an AI workbench combining DeepSeek Web, API chat, coding activity and quotas. Calendar writes require confirmation; camera access is optional and mirror frames are neither saved nor uploaded.

macOS 15+, universal Apple silicon/Intel, build 144. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Native UI, retraction, draft retention and package checks use frozen inputs. Full multi-display, sleep/wake, VoiceOver, physical Intel, real microphone/camera and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/NotchCalendar-3.2.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/NotchCalendar-3.2.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.4/SHA256SUMS.txt)

## 3.2.3：小伴侣悬停更稳定

- 移除“掉下来”动画及设置、右键菜单中的入口，鼠标悬停时保持原位。
- 展开功能面板、打开待办或鼠标停在小伴侣上时暂停自动活动，避免准备点击时突然绕圈或下沉。
- 自动计时器触发前再次检查交互状态；鼠标移开后重新等待完整空闲间隔。
- 保留主动双击跑一圈、拖拽留位或回家、滑滑梯、召唤及刘海避让，更新中英文行为说明。

macOS 15+，Apple 芯片与 Intel 通用包，build 143。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版对冻结输入执行小伴侣交互、原生设置与安装包检查。完整多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/NotchCalendar-3.2.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/NotchCalendar-3.2.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/SHA256SUMS.txt)

## 3.2.3: A steadier companion on hover

- Remove the drop-down animation and its settings and context-menu entries. Hovering now keeps the companion in place.
- Pause automatic activities while expanded panels or tasks are open, or while the pointer is over the companion, preventing surprise walks or downward motion before a click.
- Recheck interaction state when the automatic timer fires. Leaving the companion starts a fresh idle interval.
- Keep explicit double-click walks, drag placement or return, rope slides, summons and notch avoidance. Update the Chinese and English behavior help.

macOS 15+, universal Apple silicon/Intel, build 143. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Companion interaction, native settings and package checks use frozen inputs. Full multi-display, sleep/wake, VoiceOver, physical Intel and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/NotchCalendar-3.2.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/NotchCalendar-3.2.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.2.3/SHA256SUMS.txt)
