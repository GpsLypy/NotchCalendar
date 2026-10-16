# Notch Calendar 2.0.4

macOS 15+ · Apple Silicon and Intel · build 87 · 2026-10-16

## 修复

- 修复系统重复打开应用时将欢迎误判为完成、直接弹出日历权限的问题。欢迎期间再次打开应用只唤回介绍，外部打开请求等待欢迎结束后处理。
- 仅在选择「跳过」「开始使用」或前往自定义后启动工作区并请求尚未授予的日历权限；欢迎尚未展示成功时也不会提前请求权限。
- 从 2.0.3 升级到本版后，重新展示一次修复后的欢迎介绍。明确完成后普通重启不再播放；中途退出仍可下次继续进入。
- 修复 AI 聊天输入框占位文字与光标的对齐，避免配置按钮的焦点提示和错误信息被裁切或挤压。

## 优化

- 空闲收起时取消左右各 30 pt 的额外点击入口，让这些区域的点击穿透到菜单栏；默认在刘海附近停稳后悬停展开，已有活动指示保持。
- 前四幕自动换幕总时长由约 21 秒缩短为约 14 秒，最后一幕继续等待「开始使用」；保留暂停、前后翻页、重播及减少动态效果和旁白下的手动翻页。
- 欢迎标题与介绍加入打字机逐字出现效果；开启减少动态效果或旁白时直接显示全文，不改变约 14 秒的自动换幕节奏。

## 安装

[2.0.4 发行页面](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.4) · [下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/NotchCalendar-2.0.4-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/NotchCalendar-2.0.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/SHA256SUMS.txt)

退出旧版，将 DMG 中的应用拖入「应用程序」替换并重新启动。通用安装包支持 Apple 芯片与 Intel，最低 macOS 15；沿用 ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。

上一版的功能与发布记录见 [2.0.3 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.3)。

## English

- Fix system reopen events incorrectly completing the welcome and requesting calendar access immediately. Reopening the app brings the current introduction forward; external destinations wait until the welcome finishes.
- Start the workspace and request calendar access, if needed, only after an explicit Skip, Get started or customization action. A welcome window that has not yet appeared cannot authorize an early permission request.
- Show the corrected welcome once after upgrading from 2.0.3. Explicit completion keeps ordinary launches quiet; quitting midway leaves the introduction available on the next launch.
- Align the AI Chat placeholder with the text cursor, and prevent the configuration button’s focus indicator and error messages from being clipped or squeezed.
- Remove the extra 30 pt click targets on each side of the idle, collapsed notch so clicks pass through to the menu bar. By default, the notch expands after the pointer settles nearby; existing activity indicators remain.
- Reduce automatic progression through the first four steps from about 21 seconds to about 14 seconds. The final greeting still waits for Get started. Pause, navigation, replay and manual paging with Reduce Motion or VoiceOver remain available.
- Add a typewriter effect to welcome headings and introductory text. Reduce Motion and VoiceOver display the full text immediately; automatic progression remains about 14 seconds.

Quit the old app, replace it in Applications using the DMG, and relaunch. Universal macOS 15+ package for Apple silicon and Intel; ad-hoc signed, manual installation, without Developer ID signing or Apple notarization.

For the previous release, see the [2.0.3 release notes](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.3).
