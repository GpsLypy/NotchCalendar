# Notch Calendar 2.0.26

修复文件暂存区拖放：支持拖入本地文件与文件夹并复制到当前目录、子目录或收藏位置，保留原文件，重名时提示；拖出改为 macOS 原生文件拖拽，可交给 Finder，拖动期间刘海保持展开，保留双击打开与右键菜单。

冻结源码定向回归 265 项：262 通过、3 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

冻结源码覆盖文件复制、原生拖拽数据与行事件路由；实际拖到 Finder／桌面的鼠标操作仍待安装后人工确认。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 109。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。开发工具草稿与 TinyPNG API 密钥仅保留在当前应用会话中。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/NotchCalendar-2.0.26-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/NotchCalendar-2.0.26-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/SHA256SUMS.txt)

## English

Repair file-shelf drag and drop: copy local files and folders into the current directory, subfolders or favorites while preserving originals and reporting name conflicts. Outgoing drags use native macOS file dragging for Finder; the notch stays open during transfer, with double-click and context menus retained.

Frozen targeted regression: 265 cases, 262 passed, 3 optional skips and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Frozen tests cover file copying, native drag payloads and row event routing. Actual pointer dragging to Finder or Desktop still requires manual verification after installation. Human VoiceOver, physical displays, sleep/wake and sustained energy acceptance remain pending.

macOS 15+, Apple silicon and Intel, build 109. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained. Developer drafts and the TinyPNG API key stay in the current app session only.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/NotchCalendar-2.0.26-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/NotchCalendar-2.0.26-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/SHA256SUMS.txt)

Previous release: [2.0.25](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.25).
