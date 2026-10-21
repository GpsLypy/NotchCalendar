# Notch Calendar 2.0.24

- 重新设计设置页：分组侧边栏、设置搜索与刘海预览让显示、外观、功能入口和权限更容易找到；⌘F 可直接搜索设置。
- 新增刘海「功能库」：从顶部功能按钮、功能栏或 ⌘K 打开，按分组或中英文名称查找已启用工具；隐藏的功能不会被搜索重新显示，空间不足时通过更多菜单继续访问。
- 切换工具、打开功能库或调整窗口时保留草稿；功能库盖住原生编辑器时暂停编辑，关闭后恢复选区与输入焦点。窄窗口中的开发工具也能同时查看输入与结果。
- 新增 8 类开发工具：JSON 格式化／压缩／校验、时间戳转换、UUID 批量生成、二维码生成、变量命名转换、图片压缩、Base64 和 URL 编解码。文字转换在本机完成，可编辑和复制结果；时间戳可选择秒／毫秒与本地时区／UTC，二维码可复制或保存为 PNG。
- 图片压缩默认在本机进行，支持 PNG、JPEG 和 WebP 输入，输出 JPEG 或 PNG，并可调整 JPEG 画质与最长边。显示前后文件大小，另存副本并保护原图；可选 TinyPNG 仅在主动点击「上传至 TinyPNG」后上传，API 密钥只保留在当前应用会话中。
- 新增系统监控：查看 CPU 使用率、内存估算、启动磁盘容量、活跃物理网络接口速率，以及 CPU／网络趋势。仅在监控页可见时采样；切换工具、打开功能库或收起刘海后停止采样。
- 在展开的刘海中，可用 ⌥⌘J 打开开发工具、⌥⌘U 打开系统监控；保留原有工具快捷键和可自定义的功能栏位置。

冻结源码定向回归 202 项：201 通过、1 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及键鼠事件测试使用隔离偏好、测试几何与演示数据；系统监控的界面及暂停行为使用合成计数器验证。TinyPNG 上传流程仅使用模拟响应验证，尚未用真实 API 密钥联网验收。各类硬件的实际摄像头贴合与监控读数、真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒和持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 107。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。开发工具草稿与 TinyPNG API 密钥仅保留在当前应用会话中。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.24/NotchCalendar-2.0.24-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.24/NotchCalendar-2.0.24-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.24/SHA256SUMS.txt)

## English

- Redesign Settings with a grouped sidebar, search and a notch preview, making display, appearance, tool and permission controls easier to find. Press ⌘F to search settings.
- Add a Tool Library to the notch. Open it from the top tool button, the activity rail or ⌘K, then browse groups or search enabled tools in English or Chinese. Search respects hidden tools, and an overflow menu keeps tools reachable when space is limited.
- Keep drafts when switching tools, browsing the library or resizing. Covered native editors stop accepting input; closing the library restores their selection and keyboard focus. Narrow developer workspaces show input and output together.
- Add eight developer tools: JSON formatting, compacting and validation; timestamp conversion; batch UUID generation; QR codes; naming conversion; image compression; Base64; and URL encoding/decoding. Text transforms run on this Mac with editable, copyable results. Choose seconds or milliseconds and local time or UTC for timestamps; copy or save QR codes as PNG.
- Compress PNG, JPEG and WebP images locally by default, exporting JPEG or PNG with JPEG quality and maximum-dimension controls. Compare file sizes, save a copy and preserve the original. Optional TinyPNG compression uploads only after you click Upload to TinyPNG; its API key stays in the current app session.
- Add System Monitor for CPU usage, estimated memory use, startup volume capacity, active physical network interface rates, and CPU/network trends. Sample only while the monitor page is visible; switching tools, opening the library or collapsing the notch stops sampling.
- Use ⌥⌘J for Developer tools and ⌥⌘U for System monitor while the notch is expanded. Existing tool shortcuts and configurable activity rail placement remain available.

Frozen targeted regression: 202 cases, 201 passed, 1 optional skip and zero failures; 21 Python quality checks and universal package verification passed. This is not a full application regression.

Native rendering and mouse/keyboard tests use isolated preferences, test geometry and demonstration data; monitor UI and sampling suspension use synthetic counters. TinyPNG uploads were checked with fixture responses, without acceptance against the live service using a real API key. Physical camera fit and monitor readings across hardware, human VoiceOver, physical multi-display/full-screen use, actual sleep/wake and sustained energy acceptance remain pending.

macOS 15+, Apple silicon and Intel, build 107. Ad-hoc signed without Developer ID signing or Apple notarization; manual installation is required. Quit the old app, replace it in Applications using the DMG, and relaunch. Existing licensing and chat API keys remain available when local app data is retained. Developer drafts and the TinyPNG API key stay in the current app session only.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.24/NotchCalendar-2.0.24-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.24/NotchCalendar-2.0.24-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.24/SHA256SUMS.txt)

Previous release: [2.0.23](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.23).
