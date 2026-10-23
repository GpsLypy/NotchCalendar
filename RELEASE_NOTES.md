# Notch Calendar 2.0.29

## 2.0.29：紧凑用量圆环、多屏选择与收起缓冲

- AI 用量改为小圆环与服务图标，从左到右紧凑排列，服务较多时可横向滚动；保留已用百分比与未知状态。
- 鼠标停留在圆环上可查看额度周期、重置时间和各额度窗口，移入详情卡片继续查看，点击打开完整服务详情。
- 底部功能栏下方增加 10px 收起缓冲；缓慢移向边缘时显示轻量虚线提示，减少误收起。
- 显示设置可选择具体显示器，同名外接屏可区分；断开时回退，重新连接后恢复所选屏幕。
- 修复已运行的音乐播放器关闭窗口后，点击播放器入口无法重新显示窗口的问题。

macOS 15+，Apple 芯片与 Intel，build 112。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

冻结源码定向回归 183 项：179 通过、4 项可选跳过、0 失败；21 项 Python 质量检查与通用安装包核验通过。不是全应用全量回归。

圆环截图与交互使用隔离偏好和示例数据验证。真实服务额度、真人 VoiceOver、双外接显示器硬件、睡眠唤醒与持续能耗仍待人工确认。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.29/NotchCalendar-2.0.29-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.29/NotchCalendar-2.0.29-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.29/SHA256SUMS.txt)

## 2.0.29: Compact usage rings, display selection and collapse tolerance

- AI usage now uses small rings and service icons in a compact horizontal row, with scrolling for additional services. Used percentages and unavailable states stay explicit.
- Hover a ring for quota windows and reset times; move into the readout to keep reading, or click to open full service details.
- A 10px buffer below the bottom toolbar helps prevent accidental collapse. A subtle dashed hint appears when slowly approaching the boundary.
- Select an individual display, including external displays with identical names. A disconnected display falls back safely and the saved selection returns when reconnected.
- Fixed reopening a running music player's window after it has been closed.

macOS 15+, Apple silicon and Intel, build 112. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Frozen-source targeted regression: 183 cases, 179 passed, 4 optional skips, no failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Ring screenshots and interactions use isolated preferences and fixture data. Live service quotas, human VoiceOver use, dual external-display hardware, sleep/wake and sustained energy use remain pending manual acceptance.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.29/NotchCalendar-2.0.29-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.29/NotchCalendar-2.0.29-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.29/SHA256SUMS.txt)
