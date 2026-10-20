# Notch Calendar 2.0.15

- 优化无刘海外接屏的贴边模式：标题和窗口按钮靠近顶部，减少空白并增加正文空间。
- 顶部和底部导航均适用；缩放窗口、切换样式时继续保留便笺草稿与选区。
- 经典模式继续显示顶部日期时间；实体刘海和系统顶部安全区保留对应避让。

早期原生工具栏测试曾失败，观察到系统前台归属不一致和鼠标移动；测试补充前台稳定等待、短暂鼠标输入隔离与明确单击状态后，最终同一冻结副本分两组完成全部定向检查。未证明所有早期失败的原因；产品代码和按钮断言保持不变，原始记录已保留。

冻结源码定向回归 215 项：215 通过、0 项可选检查跳过、0 失败；21 项 Python 质量检查与通用安装包核验通过。

已使用连接外接屏上的隔离原生窗口及模拟几何验证布局、按钮、缩放和编辑器状态。人工鼠标手感、VoiceOver、实体屏幕拔插／合盖、睡眠唤醒、真实 AI 服务和持续 CPU／能耗仍待验收；不宣称全量回归或严格设备门禁通过。

macOS 15+，Apple 芯片与 Intel，build 98。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，已有授权与聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/NotchCalendar-2.0.15-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/NotchCalendar-2.0.15-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/SHA256SUMS.txt)

## English

- Reduce the empty top band in Edge-attached mode on external displays without a notch. Move the title and window controls upward to make more room for content.
- Support both top and bottom navigation while preserving note drafts and selections during resizing and style changes.
- Keep the Classic date/time display and respect physical camera and system top safe areas.

Earlier native toolbar runs failed; diagnostics observed inconsistent foreground ownership and pointer movement. After test-only foreground waits, brief mouse-input suppression and explicit single-click state, two disjoint groups completed all selected checks on identical frozen inputs. The causes of all earlier failures remain unproven. Product code and button assertions were unchanged; original records are retained.

Frozen-source targeted regression: 215 cases, 215 passed, 0 optional checks skipped, zero failures; 21 Python quality checks and universal package validation passed.

Isolated native windows on the connected external screen and simulated geometry cover layout, controls, resizing and editor state. Manual pointer use, VoiceOver, display hotplug/lid close, sleep/wake, live AI services and stationary CPU/energy remain pending. This is not a full-app regression or strict hardware-gate pass.

macOS 15+, Apple silicon and Intel, build 98. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Keeping local app data preserves existing licenses and Chat API keys.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/NotchCalendar-2.0.15-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/NotchCalendar-2.0.15-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/SHA256SUMS.txt)

Previous release: [2.0.14](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.14).
