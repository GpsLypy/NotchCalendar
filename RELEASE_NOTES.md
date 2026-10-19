# Notch Calendar 2.0.13

- 新增可选的「刘海小伴侣」，在「设置 → 通用 → 刘海小伴侣」主动开启；奶油小猫与杏色小狗一次选择一只。
- 支持探头、左右往返、点击摸头和静态打盹；右键选择动作或隐藏，设置提供「暂时隐藏／叫出来」和同等动作按钮。
- 两只角色分别取名，选择安静或活泼性格；角色、名字、性格与自动活动偏好保存在本机，并支持备份恢复。
- 自动活动可完全关闭。安静型约每 8–15 分钟活动一次，活泼型约每 5–10 分钟；静止时停止动画刷新。
- 尊重系统「减少动态效果」，使用静态表情；低电源模式暂停自动活动。主刘海展开／收起、会议和音乐／专注状态优先，宠物让位。
- 围巾、蝴蝶结及更多彩蛋留作后续扩展。

最终定向回归 189 项：188 项通过、1 项可选检查跳过、0 失败；21 项 Python 质量检查与通用安装包核验通过。

已读取本机真实刘海几何，检查原生窗口往返、摸头不展开日历和展开／收起交接；外屏坐标、减少动态效果、低电源及睡眠暂停也有注入状态或几何测试。真人菜单栏操作、VoiceOver 语音、实体外屏插拔、真实睡眠唤醒、完整全屏／共享场景和持续 CPU／能耗仍待验收；不宣称全量回归或严格设备门禁通过。

macOS 15+，Apple 芯片与 Intel，build 96。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，已有授权与聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/NotchCalendar-2.0.13-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/NotchCalendar-2.0.13-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/SHA256SUMS.txt)

## English

- Add an optional Notch companion in Settings → General → Notch companion. Enable it to choose one cream cat or apricot puppy.
- Peek, stroll from left to right and back, click to pet, or settle into a static nap. Secondary click for actions or hide; settings offer Hide for now / Come back and equivalent action buttons.
- Name each animal separately and choose Quiet or Playful. Store the animal, names, personality and automatic activity choice locally, including backup and restore.
- Turn automatic activity off completely. Quiet companions act about every 8–15 minutes and playful companions every 5–10 minutes; animation updates stop at rest.
- Respect Reduce Motion with static expressions and pause automatic activity in Low Power Mode. Yield to notch expansion/collapse, meetings, and music/focus status.
- Scarves, bows and further companion moments are planned for later versions.

Final prepublication targeted regression: 189 cases, 188 passed, 1 optional check skipped, zero failures; 21 Python quality checks and universal package validation passed.

Native automation checks this Mac’s actual notch geometry, window travel, petting without opening Calendar, and expansion/collapse handoff. External-display coordinates, reduced motion, low power and suspension also use injected states or geometry tests. Human menu-bar interactions, VoiceOver speech, physical display hotplug, real sleep/wake, complete full-screen/sharing scenarios and stationary CPU/energy remain pending. No full-app or strict hardware-gate pass is claimed.

macOS 15+, Apple silicon and Intel, build 96. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Keeping local app data preserves existing licenses and Chat API keys.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/NotchCalendar-2.0.13-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/NotchCalendar-2.0.13-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.13/SHA256SUMS.txt)

Previous release: [2.0.12](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.12).
