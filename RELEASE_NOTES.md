# Notch Calendar 3.1.3

## 3.1.3：刘海截屏、录屏与更简洁的设置

- 从刘海选择区域、窗口或屏幕，保存 PNG 截图或 MP4 录屏；截图同时复制到剪贴板。
- 录屏可选系统声音、麦克风和鼠标指针。窗口支持搜索；录制中可从刘海紧凑态或临时菜单栏入口停止，等待文件保存完成。
- 采集历史支持预览、复制和在 Finder 中显示，也可将结果复制到共享文件架的收藏目录。
- 设置统一原生分组，移除刘海布局预览，将长说明放进问号帮助；权限、错误及必要校验保持直接可见。

macOS 15+，Apple 芯片与 Intel 通用包，build 134。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

定向功能及原生界面检查通过；隔离窗口和区域已实际生成 PNG、MP4 并解码。真实系统声音／麦克风、整屏及多屏切换、VoiceOver、Intel 实机和持续性能验收仍待完成。实现参考 NotchShot 的 ScreenCaptureKit 流程，保留 MIT 版权与许可；不含截图标注编辑器或录屏暂停功能。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/NotchCalendar-3.1.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/NotchCalendar-3.1.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/SHA256SUMS.txt)

## 3.1.3: Capture from the notch and simpler settings

- Capture an area, window or display as a PNG screenshot or MP4 recording. Screenshots are also copied to the clipboard.
- Choose system audio, microphone and pointer options. Search windows before capture; stop from the compact notch or temporary menu-bar control and wait for the file to finish saving.
- Preview, copy and reveal recent captures in Finder, or copy them to a favorite folder in the shared file shelf.
- Simplify settings with native groups and contextual question-mark help. Remove the notch layout preview while keeping permissions, errors and required validation visible.

macOS 15+, universal Apple silicon/Intel, build 134. Ad-hoc signed without Developer ID signing or Apple notarization; quit the old app and replace it manually using the DMG.

Targeted functional and native UI checks passed. Isolated window/area capture produced real PNG and MP4 files with decoded video frames. Real system/microphone audio, full-display and multi-display capture, VoiceOver, Intel hardware and sustained performance acceptance remain pending. The ScreenCaptureKit flow references NotchShot with its MIT attribution retained; screenshot annotation and recording pause are not included.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/NotchCalendar-3.1.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/NotchCalendar-3.1.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/SHA256SUMS.txt)

## 3.1.2：一句话安排的 AI 等待与恢复

- 为“用 AI 理解”增加明确的等待说明和 30 秒时限；超时后保留原输入，提示重试或直接生成日程。
- 等待期间仍可点击“生成日程”进行本机识别，也可取消 AI 请求；晚到的结果不会覆盖新的草稿。
- 日程提取不再附加聊天的高强度思考选项，继续使用已有服务与模型，聊天偏好、会话和附件保持独立。

macOS 15+，Apple 芯片与 Intel 通用包，build 133。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后用 DMG 手动替换安装。

本版本重新执行 39 项定向 Swift 测试（含 5 项原生交互）及 64 项 Python 质量检查，全部通过，无失败、跳过。相同运行代码已通过真实服务生成日程草稿，同时验证超时恢复；不将间歇性服务超时解释为原截图的确定根因。完整多屏、睡眠唤醒、VoiceOver、Intel 实机及持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/NotchCalendar-3.1.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/NotchCalendar-3.1.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/SHA256SUMS.txt)

## 3.1.2: Recoverable AI scheduling

- Add clear waiting feedback and a 30-second deadline to Understand with AI. Keep the input on timeout and offer retry or local event generation.
- Keep Generate event available while AI is running, support cancellation, and prevent late replies from replacing a newer draft.
- Stop adding chat's high-effort reasoning option to event extraction. Keep the existing provider and model, with chat preferences, conversation and attachments separate.

macOS 15+, universal Apple silicon/Intel, build 133. Ad-hoc signed without Developer ID signing or Apple notarization. Quit the old app and replace it manually using the DMG.

Fresh version-bound validation passed: 39 targeted Swift tests, including 5 native interaction tests, and 64 Python quality checks, with no failures or skips. The same runtime produced an editable event through the real provider and correctly recovered from timeouts. Intermittent provider timeouts do not establish the original screenshot's root cause. Complete multi-display, sleep-wake, VoiceOver, Intel hardware and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/NotchCalendar-3.1.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/NotchCalendar-3.1.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/SHA256SUMS.txt)

## 3.1.1：刘海展开稳定性与系统监控图标

- 修复鼠标仍停留在展开区域内时，刘海意外收回又重新展开的问题。屏幕参数通知未改变实际显示位置时保持当前展开、动效与编辑状态；屏幕几何变化、空间切换和睡眠等必要重置继续生效。
- 缩小系统监控的指标图标、标题图标与网络方向箭头，让紧凑区域更协调。
- 将应用内产品入口更新为官网 HTTPS 地址。

macOS 15+，Apple 芯片与 Intel 通用包，build 132。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后用 DMG 手动替换安装。

本版冻结输入的定向 Swift 测试：56 项，全部通过，0 跳过、0 失败；64 项 Python 质量检查及独立安装包静态校验通过。覆盖悬停与屏幕通知、编辑状态保留、空间切换重置、窗口分屏及系统监控。完整多屏／睡眠唤醒、VoiceOver、Intel 实机及持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.1/NotchCalendar-3.1.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.1/NotchCalendar-3.1.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.1/SHA256SUMS.txt)

## 3.1.1: Stable notch expansion and smaller system-monitor icons

- Fix the notch unexpectedly collapsing and reopening while the pointer stays inside the expanded area. Screen-parameter notifications preserve the current expansion, motion and editing state when placement has not changed; actual screen-geometry changes, Space transitions and sleep retain their required resets.
- Reduce system-monitor metric symbols, heading symbols and network arrows for a more balanced compact layout.
- Update the in-app product link to the official HTTPS website.

macOS 15+, universal Apple silicon/Intel, build 132. Ad-hoc signed without Developer ID signing or Apple notarization. Quit the old app and replace it manually using the DMG.

Fresh targeted Swift tests bound to frozen inputs: 56 executed, all passed, no skips or failures. All 64 Python quality checks and independent static package checks passed. Coverage includes hover/display notifications, editor retention, Space resets, window placement and the system monitor. Complete multi-display/sleep-wake, VoiceOver, Intel hardware and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.1/NotchCalendar-3.1.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.1/NotchCalendar-3.1.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.1/SHA256SUMS.txt)

## 3.1：视觉焕新、大时钟与刘海窗口分屏

- 拖动应用窗口到刘海，即可选择五区、四分屏、左右分屏、专注或铺满布局。预览落点后松手安排窗口，支持取消和最小尺寸约束，结束后恢复原工具与编辑状态。需要辅助功能权限。
- 更新圆体标题、菜单图标字重与分组底色，统一深色层次；保留浅色模式、材质选择与高对比适配。
- 专注页采用自适应大圆环时钟和进度圆点，薄荷绿表示专注、暖杏色表示休息；侧边摘要、日程和主要操作重新排布，主窗口与小尺寸刘海保持一致。
- 简化聊天模式与输入区视觉，修复中型刘海中错误恢复入口被挤出可视区的问题，保留中文输入法、会话草稿和编辑状态。
- 修复点击应用自身控件时，分屏监听从后台辅助功能查询进入原生视图引发的线程断言崩溃；将查询限制在外部窗口，并正确处理系统透明浮层。

macOS 15+，Apple 芯片与 Intel 通用包，build 131。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后用 DMG 手动替换安装。

本版冻结输入的定向 Swift 测试：86 项，82 通过、4 项跳过（2 项可选截图、2 项需连接外接屏）、0 失败；64 项 Python 质量检查及独立安装包静态校验通过。修复后的运行代码完成内置屏真实鼠标菜单切换、展开收回和窗口分屏验证。最新代码的完整多屏／睡眠唤醒、VoiceOver、Intel 实机及持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1/NotchCalendar-3.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1/NotchCalendar-3.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1/SHA256SUMS.txt)

## 3.1: Refreshed visuals, a larger Focus clock and notch window layouts

- Drag an app window to the notch to choose five-zone, quarter, split, focus or fill layouts. Preview the destination and release to place the captured window. Cancellation, minimum-size constraints and restoration of the previous tool are supported. Accessibility permission is required.
- Refine rounded headings, menu-symbol weights and grouped surfaces while retaining light appearance, material settings and increased contrast.
- Focus gains an adaptive circular clock with a progress dot, mint focus and warm break accents, reorganized summaries and primary actions in both the notch and workspace.
- Simplify chat mode and composer styling; keep error recovery visible in medium-sized notches while preserving IME composition and conversation drafts.
- Fix the thread assertion when background window-snap accessibility queries hit the app's own controls. Queries now target foreign windows and account for transparent system overlays.

macOS 15+, universal Apple silicon/Intel, build 131. Ad-hoc signed without Developer ID signing or Apple notarization. Quit the old app and replace it manually using the DMG.

Fresh targeted Swift tests bound to frozen inputs: 86 executed, 82 passed, 4 skipped (two optional captures and two requiring an external monitor), no failures. All 64 Python quality checks and independent static package checks passed. The fixed runtime was exercised with real mouse input for menus, reveal/retraction and window placement on the built-in display. Complete current-build multi-display/sleep-wake, VoiceOver, Intel hardware and sustained-performance acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1/NotchCalendar-3.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1/NotchCalendar-3.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1/SHA256SUMS.txt)

## 3.0.7：音乐歌词胶囊、灵动眼睛与更自然的收回动画

- 外接屏及无刘海屏空闲时显示小胶囊，不占用日期时间空间。音乐播放时自动舒展显示歌词，无同步歌词时显示歌曲信息，暂停后回到小胶囊；保留会议与专注优先级，以及原有悬停／点击展开设置。
- 小胶囊眼睛偶尔轻轻左右看看、随机眨眼，大部分时间保持安静；开启系统“减少动态效果”后保持静止。
- 专注新增深度工作、专注和休息模式选择，分别为 45、25、5 分钟。
- 优化刘海收回时的大阴影与两侧图标突然出现的问题，移除经典样式中多余的模拟刘海黑色连接区域；展开与收回支持中途反向，原生编辑器保持固定尺寸，保留文字选区和滚动状态。

macOS 15+，Apple 芯片与 Intel 通用包，build 130。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证。退出旧应用后用 DMG 手动替换安装。

用户已确认同一运行代码的本机测试版可用。本版冻结清单绑定的定向 Swift 测试执行 107 项：106 通过、1 跳过、0 失败；跳过项为需主动开启录屏的原生背景检查。60 项 Python 质量检查与独立安装包静态校验通过，覆盖通用架构、签名、快捷指令、小组件及 ZIP／DMG 内容。完整多屏／全屏／睡眠唤醒、VoiceOver、Intel 实机和持续性能／能耗仍待验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.7/NotchCalendar-3.0.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.7/NotchCalendar-3.0.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.7/SHA256SUMS.txt)

## 3.0.7: Music and lyrics capsule, quiet animated eyes and smoother retraction

- External and notchless displays use a small idle capsule without a date or clock. Playback expands it for lyrics, with song information as the fallback; pausing returns it to the small capsule. Meeting/focus priority and existing hover/click settings are preserved.
- Idle eyes occasionally glance sideways and blink at random, remaining quiet most of the time. They stay still when Reduce Motion is enabled.
- Choose Deep Work, Focus or Break modes with 45-, 25- and 5-minute durations.
- Refine the large retraction shadow and abrupt side-icon appearance; remove the unnecessary simulated-notch connector in Classic style. Motion can reverse mid-transition while native editors retain fixed geometry, text selection and scroll position.

macOS 15+, universal Apple silicon/Intel, build 130. Ad-hoc signed without Developer ID signing or Apple notarization. Quit the old app and replace it manually using the DMG.

The owner accepted a local candidate with identical runtime sources. Fresh targeted Swift tests bound to the frozen input manifest: 107 executed, 106 passed, 1 skipped, no failures. The skip is an opt-in native backdrop recording check. All 60 Python quality checks and independent static package checks passed, covering universal architectures, signatures, App Intents, widgets and ZIP/DMG integrity. Complete multi-display/full-screen/sleep-wake flows, VoiceOver, Intel hardware and sustained performance/energy acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.7/NotchCalendar-3.0.7-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.7/NotchCalendar-3.0.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.7/SHA256SUMS.txt)

## 3.0.6：恢复激活入口，修复启动崩溃与收纳点击

- 未激活用户更新后，即使授权钥匙串读取失败，仍可填写激活码并重试。显式激活可请求系统许可读取原记录；取消、重试及更正激活码均保留输入，不重建安装标识或重置试用。
- 修复 3.0.5 启动读取菜单栏原图时，后台无障碍检测回调自身窗口引起的线程断言崩溃。
- 收纳项恢复并操作原菜单栏按钮，由原应用决定打开菜单、弹窗或切换主窗口；输入法使用系统原生输入菜单，保留完整动态选项、收纳选择与排序。
- 已识别的电池、时钟、控制中心、天气及 Wi-Fi 系统图标支持独立收纳，点击时打开原生系统面板，关闭后恢复收纳。

macOS 15+，Apple 芯片与 Intel 通用包，build 129。菜单栏收纳需要 macOS 27、安装到“应用程序”及辅助功能权限；读取系统当前原图需要屏幕录制权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后用 DMG 手动替换安装。

本版冻结源码定向 Swift 测试执行 115 项：112 通过、3 跳过、0 失败；跳过项为两项 opt-in 原图实测和当前锁屏阻挡的实机窗口命中测试。后者此前已在解锁桌面以相同生产实现完成 12 次真实窗口回归。60 项 Python 质量检查与 864 项独立安装包静态校验通过。相关生产菜单栏源码的实测覆盖哔哩哔哩、FlClash、微信输入法，以及电池、控制中心、时钟和天气；Wi-Fi 本机未显示，未现场验证。微信主程序曾出现一次点击无响应，独立复测两轮通过，仍保留为已知兼容性边界。

授权恢复测试使用注入的读取失败与临时存储，未复现客户机器的钥匙串 ACL 根因；系统拒绝读取时仍需允许访问，无法恢复原记录时按原流程补发。完整升级、多屏／全屏／睡眠唤醒、VoiceOver、Intel 实机和持续性能／能耗仍待验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.6/NotchCalendar-3.0.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.6/NotchCalendar-3.0.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.6/SHA256SUMS.txt)

## 3.0.6: Restore activation and fix startup crashes and collected-item actions

- Keep the activation-code field and retry action available when an unactivated installation cannot read its Keychain record after an update. Explicit activation may request native permission to read the original record. Preserve entered codes after cancellation, retry or correction, without replacing the installation ID or resetting the trial.
- Fix the 3.0.5 startup assertion caused by a background accessibility hit test synchronously entering the app's own native window.
- Reveal and operate the original menu-bar button so its owner determines whether to show a menu, panel or app window. Use the native system input menu for input methods, retaining dynamic options, collection choices and order.
- Allow recognized battery, clock, Control Center, weather and Wi-Fi items to be collected individually; open their native panels and restore collection after dismissal.

macOS 15+, universal Apple silicon/Intel, build 129. Collection requires macOS 27, installation in Applications and Accessibility permission; current system artwork requires screen-recording permission. Ad-hoc signed without Developer ID signing or Apple notarization. Quit the old app and replace it manually using the DMG.

Frozen-source targeted Swift tests: 115 executed, 112 passed, 3 skipped, no failures. Skips cover two opt-in capture checks and an own-window hit test blocked by the currently locked desktop; the latter previously passed 12 real-window reads with the same production implementation on an unlocked desktop. All 60 Python quality checks and 864 independent static package checks passed. Live checks using matching production menu-bar sources covered Bilibili, FlClash, WeType, battery, Control Center, clock and weather. Wi-Fi was not displayed and was not tested live. WeChat's main app had one no-response result, then passed two independent retest rounds; intermittent compatibility remains a known limitation.

License recovery uses injected read failures and temporary storage; the customer's Keychain ACL cause has not been reproduced. Native read permission is still required, and unrecoverable original records use the existing replacement-code process. Complete installation upgrades, multi-display/full-screen/sleep-wake flows, VoiceOver, Intel runtime and sustained performance/energy acceptance remain pending.

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.6/NotchCalendar-3.0.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.6/NotchCalendar-3.0.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.6/SHA256SUMS.txt)

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
