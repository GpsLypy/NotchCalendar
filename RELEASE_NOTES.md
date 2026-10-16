# Notch Calendar 2.0.3

macOS 15+ · Apple Silicon and Intel · build 86 · 2026-10-16

## 新增

- 新安装和首次升级到此版本时，欢迎介绍从屏幕顶部刘海展开：hello、产品与功能、个性化设置，以及一天的美好祝福。
- 支持跳过、暂停、上一幕/下一幕；最后一幕等待「开始使用」。设置和窗口菜单提供「重播欢迎动画」。开启减少动态效果或旁白时使用手动翻页。
- 提供每日更新检查与版本说明提醒，以及喝水、舒展和下班关怀设置。

## 优化与修复

- 默认使用经典刘海、玻璃面板和通透工作台；已保存的个人外观选择保留，减少透明度和增强对比度仍可回退为清晰表面。
- 日历权限请求延后到欢迎介绍结束或跳过之后；已经授权的用户不会重复授权。
- 欢迎期间暂停普通刘海和提醒的展示；支持中途退出后重新进入，完成后正常重启不反复播放。
- 增加刘海样式、尺寸和材质选择，调整屏幕顶部工具布局与应用内「打开刘海控制」入口。

## 安装与验证范围

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/NotchCalendar-2.0.3-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/NotchCalendar-2.0.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/SHA256SUMS.txt)

退出旧版，将 DMG 中的应用拖入「应用程序」替换并重新启动。通用安装包支持 Apple 芯片与 Intel，最低 macOS 15；沿用 ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。

本版按先核心检查、发布后详细回归的顺序交付。发布前检查欢迎状态、权限时序、默认外观，以及双架构构建、签名和安装包完整性；完整界面回归、实体刘海、多屏、休眠唤醒、VoiceOver 和真实集成验证在发布后继续。暂不宣称这些详细验收已通过。

## English

- Welcome new and upgrading users with an introduction unfolding from the notch: hello, product features, customization, and a wish for a lovely day. Skip, pause, go back or forward, and replay from Settings or the Window menu. Reduce Motion and VoiceOver use manual paging.
- Default to the classic notch, glass panel and translucent workspace. Preserve saved appearance choices and accessibility contrast/transparency fallbacks.
- Request calendar permission after completing or skipping the welcome. Existing authorization is retained. Interrupted introductions can restart; completed introductions stay quiet on ordinary launches.
- Include daily update checks with release notes, hydration/stretch/end-of-day reminders, and notch style, size and material controls.

Quit the old app, replace it in Applications using the DMG, and relaunch. Universal macOS 15+ package for Apple silicon and Intel; ad-hoc signed, manual installation, without Developer ID signing or Apple notarization.

This release follows core checks before publication and detailed regression afterward. Core welcome, permission and appearance checks, universal build, signatures and package integrity are checked before publication. Full UI, physical displays, multi-screen, sleep/wake, VoiceOver and live integrations remain pending further verification.
