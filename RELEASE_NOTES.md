# Notch Calendar 1.6.4

macOS 15+ · Apple 芯片与 Intel · build 48 · 2026-09-17

## 新增 / Added

- **外观与材质**：新增跟随系统、浅色、深色模式，以及标准、通透材质。已打开窗口即时更新，偏好支持备份恢复，小组件同步使用所选颜色模式。

## 修复 / Fixed

- 修复工作区重绘和主题切换反复创建行情数据对象、读取钥匙串及发布未变化预算的问题，消除现场观察到的高 CPU 重建循环。
- 展开刘海现在与摄像头外壳连续衔接，菜单栏两侧保持透明，内容避开摄像头和外接屏菜单栏。
- 展开和回收使用合成遮罩；快速反向操作从当前可见位置继续，不再闪黑、闪强调色或逐帧拉伸内容。
- 延迟到达的内容高度只应用于当前展示；过期动画、布局及紧凑视图回调不能再移动或提前结束新一轮展示。
- 外观、语言和设置变化在主线程刷新小组件，且不会改变运行中专注计时的截止时间。

## 安装与升级

下载 `NotchCalendar-1.6.4-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 335 项，16 项按需测试跳过，零失败；21 项发布质量 Python 测试通过，universal2 Release 编译通过。

4 份新性能样本都检测到指针活动，随后采样因系统锁屏停止，因此没有无效样本被计为通过或有效失败。真实桌面合成的闪帧、完整刘海与外接屏交互，以及每种场景两份静置性能样本仍待实机验收。

## English

### Added

- Added System, Light and Dark appearance modes and Standard or Translucent materials. Open windows update immediately, preferences support backup and restore, and widgets receive the selected color mode.

### Fixed

- Workspace redraws and theme changes no longer recreate market data objects, repeatedly read Keychain, or publish unchanged request budgets, eliminating an observed high-CPU rebuild loop.
- The expanded notch remains attached to the camera housing with transparent menu-bar shoulders and content below camera and menu-bar obstructions.
- Compositor-mask transitions reverse from their visible geometry without black, opacity or accent-color flashes.
- Stale animation, layout and compact-view callbacks cannot move or finish a newer presentation.
- Appearance, locale and settings changes refresh widgets on the main thread without changing an active focus deadline.

This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Four fresh performance attempts were invalidated by pointer activity and sampling then stopped when the Mac locked. Physical-display and final stationary performance acceptance remain pending.
