# Notch Calendar 2.0.6

macOS 15+ · Apple Silicon and Intel · build 89 · 2026-10-16

## 修复

- AI 聊天 API Key 改存本机应用数据目录，替换或重装应用且保留应用数据时可继续使用；保存与发送不再依赖钥匙串授权。旧密钥可静默读取时自动迁移，否则重新保存一次。各服务独立保存，主动删除后不会从旧钥匙串恢复；普通笔记备份不包含密钥。
- 启动顺序改为「日历授权 → 刘海欢迎 → 工作台」。等待系统授权处理完，再开始欢迎动画；允许、拒绝或请求失败都能继续。已处理过日历授权时直接进入欢迎，不重复请求。
- 修复升级后旧版完成记录导致欢迎被跳过的问题。升级到本版重新展示一次；明确跳过、开始使用或前往自定义后，普通重启不再播放。
- 等待授权或欢迎期间重复点击 Dock、打开小组件链接或切换屏幕，继续等待当前步骤，并保留待打开的工作台目标。
- 保留 2.0.5 的刘海收回连续动画修复。

## 验证与安装

本轮回归覆盖密钥跨实例读取、迁移失败恢复、权限、删除与服务隔离；启动顺序回归覆盖允许、拒绝、错误、延迟回调、旧记录迁移和原生欢迎窗口；发布前执行完整回归、双架构构建与安装包校验。授权测试使用隔离数据源，未重置本机系统权限；全新真实 TCC 提示、实体刘海、外接屏、休眠唤醒、VoiceOver、真实模型联调和静置性能仍待完整验收。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/NotchCalendar-2.0.6-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/NotchCalendar-2.0.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/SHA256SUMS.txt)

退出旧版，将 DMG 中的应用拖入「应用程序」替换并重新启动。通用安装包支持 Apple 芯片与 Intel，最低 macOS 15；沿用 ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。

## English

- Store AI Chat API keys in local app data so replacing or reinstalling the app with that data retained keeps them available without repeated Keychain authorization. Silently migrate readable legacy keys; blocked legacy keys need one explicit Save. Keep providers separate and respect key removal; ordinary note backups exclude credentials.
- Resolve Calendar authorization first, then show the notch welcome, then start the workspace. Allow, deny and request errors all continue to the introduction. Previously determined authorization does not trigger another prompt.
- Re-offer the corrected introduction once to upgrading users whose old completion flag previously suppressed it. Skip, Get started or customization completes it; ordinary subsequent restarts remain quiet.
- Dock reopens, widget links and screen changes wait for the current startup step and preserve the queued workspace destination.
- Retain the continuous notch retraction fix from 2.0.5.

Credential regression covers persistence across instances, migration recovery, private file permissions, removal and provider isolation. Startup regression covers allow, deny, errors, delayed callbacks, completion migration and real AppKit welcome panels using isolated calendar sources. Full regression, universal build and package verification run before publication. No real TCC preferences were reset; fresh system permission prompts, physical notch, external displays, sleep/wake, VoiceOver, live model integration and stationary performance remain pending complete acceptance.

Quit the old app, replace it in Applications using the DMG, and relaunch. Universal macOS 15+ package for Apple silicon and Intel; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization.

Previous release: [2.0.5](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.5).
