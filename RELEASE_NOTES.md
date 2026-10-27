# Notch Calendar 3.0.5

## 3.0.5：统一读取菜单栏原图

- 收纳栏采用统一的系统原图采集流程：逐项临时恢复、重新定位并读取实际显示内容，支持同一应用的多个状态项；资源兜底也会继续尝试取得系统当前图像。
- 采集前后核对状态项的进程、标识和位置，防止菜单栏布局变化时保存成其他图标；旧版未经核对的缓存会重新采集，保留收纳选择和排序。
- 补齐通用原生与 macOS 托盘资源读取；已有静态兜底但尚无系统原图时，仍提供原图读取授权入口。

macOS 15+，Apple 芯片与 Intel 通用包，build 128。收纳需要 macOS 27、安装到“应用程序”及辅助功能权限；读取系统当前原图需要屏幕录制权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

61 项定向 Swift 测试和本版重跑的 60 项 Python 质量检查全部通过、零跳过；安装包通过 864 项独立静态校验，覆盖双架构、签名、快捷指令、小组件及 ZIP／DMG 内容。真实菜单栏只读检查采集了 8 个可见状态项，全程未查询应用资源。真实隐藏／恢复与安装升级、完整多屏／全屏／睡眠唤醒、VoiceOver、Intel 实机及持续性能／能耗仍待验收；不保证所有第三方实现或 macOS 版本均可读取。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/NotchCalendar-3.0.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/NotchCalendar-3.0.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/SHA256SUMS.txt)

## 3.0.5: Read original menu-bar artwork through one capture flow

- Use a common capture flow for collected icons: temporarily reveal each item, rediscover its position and read the system-rendered artwork, including apps with multiple status items. Resource fallbacks no longer stop attempts to capture the current image.
- Verify the process, identity and bounds before and after capture to avoid saving another icon after a layout change. Recapture legacy unverified caches while preserving collection choices and order.
- Extend generic native/macOS tray-resource fallbacks and keep the capture-permission action available when a static fallback exists but a current system image is missing.

macOS 15+, universal Apple silicon/Intel, build 128. Collection requires macOS 27, installation in Applications and Accessibility permission; reading current system artwork needs screen-recording permission. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

All 61 targeted Swift tests passed on the matching runtime source; all 60 Python quality checks rerun for this release also passed, with no skips. The packages passed 864 independent static checks covering both architectures, signatures, App Intents, widgets and ZIP/DMG contents. Read-only live capture retrieved 8 visible status items without any app-resource lookup. Actual hide/reveal and installation upgrades, complete multi-display/full-screen/sleep-wake flows, VoiceOver, Intel runtime and sustained performance/energy acceptance remain unvalidated. Capture is not guaranteed for every third-party implementation or macOS version.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/NotchCalendar-3.0.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/NotchCalendar-3.0.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/SHA256SUMS.txt)

## 3.0.4：刘海柔弹动效与原始图标恢复

- 刘海展开更柔和：宽度先舒展，底边随后拉伸回弹，标题、正文和底部图标依次浮现。
- 点击与悬停使用统一动画，等待时间单独设置；连续快速移入移出可顺畅反向，保留编辑器选区、滚动与输入状态。
- 修复旧收纳项缺少原图时出现虚线占位的问题。在已有屏幕录制权限时自动补采并恢复收纳，无权限时提供明确的读取入口。
- 补齐应用原始图标资源识别，保留彩色图标；关闭收纳、撤销权限或退出后不再写回过期恢复结果。

macOS 15+，Apple 芯片与 Intel 通用包，build 127。收纳需要 macOS 27、安装到“应用程序”及辅助功能权限；实时采集原图需要屏幕录制权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

当前运行源码完成 143 项定向 Swift 检查、60 项 Python 质量检查，全部通过、零跳过，含原生动效录制和桌面焦点交互。安装包通过 862 项独立静态校验，覆盖双架构、签名、快捷指令、小组件及 ZIP／DMG 内容。完整多屏／全屏／真实睡眠唤醒、VoiceOver、Intel 实机与持续性能／能耗验收仍未覆盖。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/NotchCalendar-3.0.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/NotchCalendar-3.0.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/SHA256SUMS.txt)

## 3.0.4: Softer notch springs and original-icon recovery

- Give notch expansion a softer spring: width opens first, the lower edge stretches and rebounds next, and titles, content and navigation fade in with a staged rhythm.
- Use the same motion for click and hover opening, independently of hover dwell. Rapid reversals remain continuous while preserving native editor selection, scrolling and input state.
- Recover original artwork for legacy collected icons that showed dashed placeholders. Automatically recapture missing artwork with existing screen-recording permission; provide an explicit action when permission is needed.
- Recognize more original app icon resources and retain color. Discard stale recovery results after collection is disabled, permission is revoked or the app exits.

macOS 15+, universal Apple silicon/Intel, build 127. Collection requires macOS 27, installation in Applications and Accessibility permission; live original-artwork capture needs screen-recording permission. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

All 143 targeted Swift checks and 60 Python quality checks passed with no skips, including native motion capture and desktop focus interactions. The packages passed 862 independent static checks covering both architectures, signatures, App Intents, widgets and ZIP/DMG contents. Complete multi-display/full-screen/real sleep-wake flows, VoiceOver, Intel runtime and sustained performance/energy acceptance remain unvalidated.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/NotchCalendar-3.0.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/NotchCalendar-3.0.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/SHA256SUMS.txt)

## 新增

- 设置整合到主窗口，提供返回操作；重新分组设置内容，统一侧栏颜色，并加入官网与推荐入口。
- 刘海支持记住上次工具、以秒精调悬停展开延迟，以及拖动／按钮自定义工具顺序；“调整顺序”入口更醒目。

## 改进

- 分享页缩小预览尺寸，刷新应用介绍图，统一介绍与周回顾的卡片比例，保留复制、保存和分享链接。
- 点击打卡标记后显示紧凑胶囊，提供“已打卡”和“稍后”；保留未处理记录，支持 Esc／外部点击收起。

## 修复

- 收纳栏优先保留应用原始菜单栏图像，支持原生与 Electron 图标资源，移除应用首字／猜测符号替代，保留彩色及宽图比例。

macOS 15+，Apple 芯片与 Intel 通用包，build 126。状态栏收纳需要 macOS 27、安装到“应用程序”及辅助功能权限；实时采集原图需要已有屏幕录制权限。旧收纳项若没有缓存且无法读取原生资源，需移回菜单栏、刷新后重新收纳。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

冻结源码执行 148 项定向 Swift 检查：146 通过、2 项可选的显示设置截图／Finder 缺失 DMG 集成测试跳过、0 失败；60 项 Python 质量检查通过。安装包已通过 861 项独立静态校验，覆盖双架构、签名、快捷指令、小组件及 ZIP／DMG 内容。未执行全应用回归、完整多屏／全屏／真实睡眠唤醒、VoiceOver、Intel 实机与持续性能／能耗验收。

## What's changed

- Embed Settings in the main window with Back navigation, clearer grouping, consistent sidebar colors and an official website/recommendations link.
- Add remembered notch tools, a precise hover delay in seconds and custom tool ordering by dragging or buttons, with a more visible reorder action.
- Make sharing compact with refreshed introduction artwork, consistent card proportions and existing copy/save/link actions.
- Open a compact check-in capsule with Checked in and Later actions. Preserve pending entries and dismiss with Escape or an outside click.
- Preserve original menu-bar artwork using captured images and native/Electron tray resources. Remove app initials and guessed symbols; retain color and wide artwork proportions.

macOS 15+, universal Apple silicon/Intel, build 126. Collection requires macOS 27, installation in Applications and Accessibility permission; live icon capture uses existing screen recording permission. Legacy collected items without a saved/readable original need to be returned to the menu bar, refreshed and collected again. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Frozen sources ran 148 targeted Swift checks: 146 passed, two optional display-settings capture / Finder missing-DMG integration tests skipped and zero failures; all 60 Python quality checks passed. The packages passed 861 independent static checks covering both architectures, signatures, App Intents, widgets and ZIP/DMG contents. Full application regression, complete multi-display/full-screen/real sleep-wake flows, VoiceOver, Intel runtime and sustained performance/energy acceptance are not claimed.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.3/NotchCalendar-3.0.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.3/NotchCalendar-3.0.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.3/SHA256SUMS.txt)
