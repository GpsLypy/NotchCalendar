# superNotch 4.3.12

## 4.3.12：切页布局优化与网络详情

- 优化刘海展开、切页和调整尺寸时的布局处理，减少重复同步布局与外壳遮罩重建。
- 优化系统监控卡片测量和剪贴板相对时间格式化的重复开销。
- 系统监控新增网络详情：本机地址、接口信息，以及可用的 Wi-Fi 连接参数；可自行开启公网 IP 与地区查询。
- 调整系统监控在较小窗口中的卡片与快捷入口布局。
- 修复“仅点击展开”模式启动后刘海点击入口可能无响应的问题。
- 改善端口管理面板的收起行为：移出面板或点击外部可收起，确认操作期间保持打开。

macOS 15+，Apple 芯片与 Intel 通用包，build 205，2026-11-18。ad-hoc 签名、未公证，需手动安装。公网 IP 查询默认关闭，开启后使用第三方网络服务；Wi-Fi 参数视系统与硬件可用性显示。本版未进行同场景优化前后 CPU 对照，原生交互、外接屏及长期性能仍待实机验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.3.12/NotchCalendar-4.3.12-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.3.12/NotchCalendar-4.3.12-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.3.12/SHA256SUMS.txt)

## 4.3.12: Page-layout optimizations and network details

- Optimize layout work when opening the notch, switching pages, and resizing, reducing redundant synchronous layouts and shell-mask rebuilding.
- Reduce repeated system-monitor card measurements and clipboard relative-time formatting.
- Add network details to System Monitor, including local addresses, interface information, and available Wi-Fi connection details. Public IP and region lookup can be enabled separately.
- Refine System Monitor cards and shortcuts for smaller windows.
- Fix the notch click target occasionally failing to respond after launch in click-only mode.
- Improve Port Management dismissal when moving the pointer away or clicking outside, while keeping confirmation actions open.

macOS 15+, universal for Apple silicon and Intel, build 205, 2026-11-18. Ad-hoc signed and not notarized; install manually. Public IP lookup is off by default and uses third-party services when enabled. Wi-Fi details depend on system and hardware availability. No controlled before-and-after CPU comparison was performed; native interactions, external displays and sustained performance still require device acceptance.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.3.12/NotchCalendar-4.3.12-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.3.12/NotchCalendar-4.3.12-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v4.3.12/SHA256SUMS.txt)
