# Notch Calendar 2.0.32

## 2.0.32：修复状态栏收纳突然失效

- 修复鼠标经过右上角时钟区域后，已收纳图标可能全部回到菜单栏且无法自动恢复的问题。
- 排除通知中心常驻桌面层窗口，避免误认为系统面板一直打开；保留真实系统面板交互期间的临时暂停。
- 保留已有收纳应用选择与排列，无需重新配置。

状态栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限。应用其他功能支持 macOS 15+。

Apple 芯片与 Intel，build 115。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试或现场验收；修复开发阶段已有 13 项定向测试通过。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/NotchCalendar-2.0.32-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/NotchCalendar-2.0.32-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/SHA256SUMS.txt)

## 2.0.32: Restore menu bar collection after system interaction

- Fixed collected icons returning to the menu bar and failing to hide again after the pointer passes the clock area.
- Exclude persistent Notification Center desktop-layer windows from open-panel detection, while keeping temporary suspension for real system panels.
- Preserve saved collection choices and icon ordering.

The organizer requires macOS 27, installation in Applications and Accessibility permission. Other features support macOS 15+.

Apple silicon and Intel, build 115. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

No additional release regression tests or live acceptance were run, as requested by the owner. The fix passed 13 targeted tests during development before the publication request.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/NotchCalendar-2.0.32-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/NotchCalendar-2.0.32-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/SHA256SUMS.txt)

