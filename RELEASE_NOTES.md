# Notch Calendar 3.0.3

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
