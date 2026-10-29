# Notch Calendar

从 Mac 刘海展开日历、专注、音乐、文件、便笺、AI 聊天、开发工具、系统监控与便捷工具等功能；通过可搜索的功能库切换，完整工作台和设置支持浅色、深色与可选毛玻璃材质。

[English](README.en.md) · [下载 3.1.6](https://github.com/GpsLypy/NotchCalendar/releases/tag/v3.1.6) · [反馈问题](https://github.com/GpsLypy/NotchCalendar/issues)

## 3.1.6：恢复日历高度，修复摄像头区域误收回

- 从内容较少的截屏或录屏页面切回日历时，立即恢复完整窗口高度，无需先把鼠标移出底部功能栏。
- 自动缩小继续保留底部功能栏保护、内容区停留确认与短暂的过渡保护，减少连续切换时误收回。
- 统一文件工具栏图标的实际绘制尺寸，修正不同符号看起来大小不一致的问题。
- 修复鼠标停在摄像头区域最顶边时被误判为离开的问题；移到外侧仍正常回收，菜单栏与其他显示器的边界保持独立。

macOS 15+，Apple 芯片与 Intel 通用包，build 137。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行冻结输入下的定向功能、原生窗口及安装包检查。完整多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.6/NotchCalendar-3.1.6-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.6/NotchCalendar-3.1.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.6/SHA256SUMS.txt)


## 3.1.5：有序的面板，更连贯的刘海交互

- 日历、便签、专注、文件、剪贴板、系统监控与截屏面板统一间距、圆角和蓝色强调；优化信息分组与深浅色可读性。
- 便签增加分组阅读、命令复制与编辑切换；文件浏览改善路径、滚动、行操作与隔空投送入口。
- 截屏页按内容收紧高度。鼠标仍在底部功能栏附近时暂缓尺寸变化，移入内容区稳定停留后再调整，减少误收回。
- 修复再次展开时从左上向右下偏移的问题：从刘海中央向左右对称展开，并保留原有回收和中途反向效果。
- 保留原生编辑器选区、滚动及撤销，延续试用倒计时和清晰的购买、授权入口。

macOS 15+，Apple 芯片与 Intel 通用包，build 136。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版执行冻结输入下的定向功能、原生窗口及安装包检查。完整多屏、睡眠唤醒、VoiceOver、Intel 实机与持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.5/NotchCalendar-3.1.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.5/NotchCalendar-3.1.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.5/SHA256SUMS.txt)


## 3.1.4：试用倒计时与更清楚的授权入口

- 试用从第一天起显示剩余天、小时、分钟和到期时间，主界面收起侧栏后仍可查看。
- 通用设置顶部增加「购买 / 激活授权」按钮；设置侧栏固定显示「授权与试用」，切换分类、滚动或搜索时均可找到。
- 试用提示更新为「到期后需要一杯咖啡钱 9.9 元人民币永久激活授权，谢谢支持」，同步英文说明。
- 临近到期和已到期状态使用警示色。永久授权用户不显示主界面试用提醒，保留原有激活记录及购买、领码、数据恢复和软件更新流程。

macOS 15+，Apple 芯片与 Intel 通用包，build 135。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

本版完成定向授权、试用与原生界面检查，覆盖中英文、深浅色及窄窗口。完整多屏、睡眠唤醒、VoiceOver、Intel 实机和持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.4/NotchCalendar-3.1.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.4/NotchCalendar-3.1.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.4/SHA256SUMS.txt)

## 3.1.3：刘海截屏、录屏与更简洁的设置

- 从刘海选择区域、窗口或屏幕，保存 PNG 截图或 MP4 录屏；截图同时复制到剪贴板。
- 录屏可选系统声音、麦克风和鼠标指针。窗口支持搜索；录制中可从刘海紧凑态或临时菜单栏入口停止，等待文件保存完成。
- 采集历史支持预览、复制和在 Finder 中显示，也可将结果复制到共享文件架的收藏目录。
- 设置统一原生分组，移除刘海布局预览，将长说明放进问号帮助；权限、错误及必要校验保持直接可见。

macOS 15+，Apple 芯片与 Intel 通用包，build 134。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

定向功能及原生界面检查通过；隔离窗口和区域已实际生成 PNG、MP4 并解码。真实系统声音／麦克风、整屏及多屏切换、VoiceOver、Intel 实机和持续性能验收仍待完成。实现参考 NotchShot 的 ScreenCaptureKit 流程，保留 MIT 版权与许可；不含截图标注编辑器或录屏暂停功能。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/NotchCalendar-3.1.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/NotchCalendar-3.1.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.3/SHA256SUMS.txt)

## 3.1.2：一句话安排的 AI 等待与恢复

- 为“用 AI 理解”增加明确的等待说明和 30 秒时限；超时后保留原输入，提示重试或直接生成日程。
- 等待期间仍可点击“生成日程”进行本机识别，也可取消 AI 请求；晚到的结果不会覆盖新的草稿。
- 日程提取不再附加聊天的高强度思考选项，继续使用已有服务与模型，聊天偏好、会话和附件保持独立。

macOS 15+，Apple 芯片与 Intel 通用包，build 133。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后用 DMG 手动替换安装。

本版本重新执行 39 项定向 Swift 测试（含 5 项原生交互）及 64 项 Python 质量检查，全部通过，无失败、跳过。相同运行代码已通过真实服务生成日程草稿，同时验证超时恢复；不将间歇性服务超时解释为原截图的确定根因。完整多屏、睡眠唤醒、VoiceOver、Intel 实机及持续性能验收仍待完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/NotchCalendar-3.1.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/NotchCalendar-3.1.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.1.2/SHA256SUMS.txt)

## 3.1.1：刘海展开稳定性与系统监控图标

- 修复鼠标仍停留在展开区域内时，刘海意外收回又重新展开的问题。屏幕参数通知未改变实际显示位置时保持当前展开、动效与编辑状态；屏幕几何变化、空间切换和睡眠等必要重置继续生效。
- 缩小系统监控的指标图标、标题图标与网络方向箭头，让紧凑区域更协调。
- 将应用内产品入口更新为官网 HTTPS 地址。

macOS 15+，Apple 芯片与 Intel 通用包，build 132。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后用 DMG 手动替换安装。

本版冻结输入的定向 Swift 测试：56 项，全部通过，0 跳过、0 失败；64 项 Python 质量检查及独立安装包静态校验通过。覆盖悬停与屏幕通知、编辑状态保留、空间切换重置、窗口分屏及系统监控。完整多屏／睡眠唤醒、VoiceOver、Intel 实机及持续性能验收仍待完成。

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

## 3.0.7：音乐歌词胶囊、灵动眼睛与更自然的收回动画

- 外接屏及无刘海屏空闲时显示小胶囊，不占用日期时间空间。音乐播放时自动舒展显示歌词，无同步歌词时显示歌曲信息，暂停后回到小胶囊；保留会议与专注优先级，以及原有悬停／点击展开设置。
- 小胶囊眼睛偶尔轻轻左右看看、随机眨眼，大部分时间保持安静；开启系统“减少动态效果”后保持静止。
- 专注新增深度工作、专注和休息模式选择，分别为 45、25、5 分钟。
- 优化刘海收回时的大阴影与两侧图标突然出现的问题，移除经典样式中多余的模拟刘海黑色连接区域；展开与收回支持中途反向，原生编辑器保持固定尺寸，保留文字选区和滚动状态。

macOS 15+，Apple 芯片与 Intel 通用包，build 130。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证。退出旧应用后用 DMG 手动替换安装。

用户已确认同一运行代码的本机测试版可用。本版冻结清单绑定的定向 Swift 测试执行 107 项：106 通过、1 跳过、0 失败；跳过项为需主动开启录屏的原生背景检查。60 项 Python 质量检查与独立安装包静态校验通过，覆盖通用架构、签名、快捷指令、小组件及 ZIP／DMG 内容。完整多屏／全屏／睡眠唤醒、VoiceOver、Intel 实机和持续性能／能耗仍待验收。

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

## 3.0.5：统一读取菜单栏原图

- 收纳栏采用统一的系统原图采集流程：逐项临时恢复、重新定位并读取实际显示内容，支持同一应用的多个状态项；资源兜底也会继续尝试取得系统当前图像。
- 采集前后核对状态项的进程、标识和位置，防止菜单栏布局变化时保存成其他图标；旧版未经核对的缓存会重新采集，保留收纳选择和排序。
- 补齐通用原生与 macOS 托盘资源读取；已有静态兜底但尚无系统原图时，仍提供原图读取授权入口。

macOS 15+，Apple 芯片与 Intel 通用包，build 128。收纳需要 macOS 27、安装到“应用程序”及辅助功能权限；读取系统当前原图需要屏幕录制权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

61 项定向 Swift 测试和本版重跑的 60 项 Python 质量检查全部通过、零跳过；安装包通过 864 项独立静态校验，覆盖双架构、签名、快捷指令、小组件及 ZIP／DMG 内容。真实菜单栏只读检查采集了 8 个可见状态项，全程未查询应用资源。真实隐藏／恢复与安装升级、完整多屏／全屏／睡眠唤醒、VoiceOver、Intel 实机及持续性能／能耗仍待验收；不保证所有第三方实现或 macOS 版本均可读取。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/NotchCalendar-3.0.5-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/NotchCalendar-3.0.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.5/SHA256SUMS.txt)

## 3.0.4：刘海柔弹动效与原始图标恢复

- 刘海展开更柔和：宽度先舒展，底边随后拉伸回弹，标题、正文和底部图标依次浮现。
- 点击与悬停使用统一动画，等待时间单独设置；连续快速移入移出可顺畅反向，保留编辑器选区、滚动与输入状态。
- 修复旧收纳项缺少原图时出现虚线占位的问题。在已有屏幕录制权限时自动补采并恢复收纳，无权限时提供明确的读取入口。
- 补齐应用原始图标资源识别，保留彩色图标；关闭收纳、撤销权限或退出后不再写回过期恢复结果。

macOS 15+，Apple 芯片与 Intel 通用包，build 127。收纳需要 macOS 27、安装到“应用程序”及辅助功能权限；实时采集原图需要屏幕录制权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

当前运行源码完成 143 项定向 Swift 检查、60 项 Python 质量检查，全部通过、零跳过，含原生动效录制和桌面焦点交互。安装包通过 862 项独立静态校验，覆盖双架构、签名、快捷指令、小组件及 ZIP／DMG 内容。完整多屏／全屏／真实睡眠唤醒、VoiceOver、Intel 实机与持续性能／能耗验收仍未覆盖。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/NotchCalendar-3.0.4-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/NotchCalendar-3.0.4-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.4/SHA256SUMS.txt)

## 3.0.3：设置与刘海个性化，保留菜单栏原图

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


[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.3/NotchCalendar-3.0.3-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.3/NotchCalendar-3.0.3-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.3/SHA256SUMS.txt)


## 3.0.2：收纳栏系统配色与外屏歌词交互

- 收纳栏图标和设置齿轮跟随系统前景色：浅色外观为黑色、深色外观为白色，修复整排图标变蓝的问题。
- 无刘海屏幕的紧凑播放条默认显示当前逐句歌词；保留手动关闭的选择，没有同步歌词时显示歌名。
- 长歌词横向滚动，换行时回到行首；暂停、隐藏或开启系统“减少动态效果”后停止滚动。
- 外接无刘海显示器上的音乐／歌词胶囊支持悬停展开，移开后收起；保留点击打开。
- 便捷工具在未固定时随鼠标离开收起，已启动的倒计时和秒表继续运行。

macOS 15+，Apple 芯片与 Intel 通用包，build 125。状态栏收纳需要 macOS 27、安装到“应用程序”并授予辅助功能权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后用 DMG 手动替换安装。

按所有者最新要求，本次停止追加验证，直接构建发布；未执行最终回归或独立安装包验收，也未进行性能采样。开发阶段分别完成收纳栏原生点击／排序与明暗显示、紧凑歌词同步、便捷工具收起后计时保留、实际外屏悬停及歌词合成层滚动检查；不将这些过程记录表述为完整发行回归通过。完整第三方播放、全屏、真实休眠唤醒、VoiceOver 和 Intel 实机流程未验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/NotchCalendar-3.0.2-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/NotchCalendar-3.0.2-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.2/SHA256SUMS.txt)

## 3.0.1：便捷工具与原生交互打磨

- 新增便捷工具：独立倒计时、秒表、保持唤醒和只读电池状态，可从功能库或 `⌥⌘K` 打开。保持唤醒默认关闭，支持定时结束。
- 无刘海屏幕的紧凑播放条可显示当前逐句歌词。在「设置 → 刘海 → 交互」开启；默认关闭，无可用歌词时显示歌名，保留原有胶囊尺寸。
- 刘海玻璃内卡与外壳采用一致的材质层次，顶栏左右控件靠两侧对齐，保留摄像头中央留白；展开与收起更利落，阅读内容保持稳定。
- 日历工具栏在窄窗口下自动分行，保持时区、新建日程等操作可见；调整窗口时保留当前控件与时区弹出面板。
- 专注页切换横向和纵向布局时保留任务输入框、选区和尚未完成的输入法组合。
- 补齐快捷搜索、关闭和更多工具按钮的悬停、按下与键盘焦点反馈；侧栏显示快捷键时不再挤动文字。状态栏收纳采用单色图标并改善明暗外观下的可读性。

macOS 15+，Apple 芯片与 Intel 通用包，build 124。状态栏收纳需要 macOS 27、安装到“应用程序”并授予辅助功能权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。

最终源码完成 67 项定向功能检查：66 通过、1 项可选截图跳过、0 失败，包含原生鼠标与键盘交互、调整窗口时输入法状态保留，以及真实窗口合成与动效检查。未执行全应用回归；按所有者要求不进行性能采样。外接屏完整流程、全屏、真实睡眠唤醒、VoiceOver、Intel 实机和持续能耗未验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/NotchCalendar-3.0.1-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/NotchCalendar-3.0.1-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.1/SHA256SUMS.txt)

## 3.0.0：主窗口展开更稳定，通知中心单击打开

- 修复从刘海打开主窗口时出现首帧空白和跳闪：显示前完成目标页面布局，保持已保存的窗口尺寸。
- 修复收纳开启时，第一次点击日期时间只闪现图标、需要重复点击才能打开通知中心的问题；关闭后恢复收纳，再次单击仍可打开。
- 包含当前代码中的完整日历、专注、音乐、文件、便笺、AI 对话、开发工具和系统监控功能。检查更新继续使用本仓库的 GitHub 官方 Release API。

macOS 15+，Apple 芯片与 Intel 通用包，build 123。状态栏收纳需要 macOS 27、安装到“应用程序”并授予辅助功能权限。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧应用后使用 DMG 手动替换安装。若更新后辅助功能授权未沿用，请重新添加并开启当前应用。

本次发布按所有者要求停止性能采样，不追加回归或独立安装包验收。停止指令前已完成 109 项主窗口、菜单栏及更新逻辑相关测试：108 通过、1 项可选截图跳过、0 失败。未将中断或不完整的性能样本记为通过。完整应用回归、多屏、全屏、真实睡眠唤醒、VoiceOver、Intel 实机运行及持续能耗仍未验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/NotchCalendar-3.0.0-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/NotchCalendar-3.0.0-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v3.0.0/SHA256SUMS.txt)

## 2.0.37：修复收纳开启后无法打开通知中心

- 修复开启状态栏收纳后，点击右上角日期时间无法打开通知中心的问题。
- 点击日期时间时暂时显示已收纳图标，通知中心关闭后恢复收纳；保留原有收纳选择和顺序。
- 普通鼠标经过和新通知不会主动展开已收纳图标。

菜单栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限；其他功能支持 macOS 15+。Apple 芯片与 Intel，build 120。ad-hoc 签名，未进行 Apple 公证；退出旧版后使用 DMG 手动替换安装。

验证：53 项菜单栏相关定向检查通过，1 项可选截图测试跳过，0 失败；本机同一修复源码的通知中心打开行为已由用户确认。未重复全应用回归，多显示器、全屏、真实睡眠唤醒及关闭通知中心后的现场恢复仍待验；Intel 仅验证通用包结构。十二轮独立 Release 探针采样通过原定 CPU、p95 和唤醒预算；821 项源码、架构、签名及归档检查通过。探针使用隔离数据和空 AX 菜单夹具，不代表真实跨应用收纳或系统总能耗验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/NotchCalendar-2.0.37-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/NotchCalendar-2.0.37-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.37/SHA256SUMS.txt)

## 2.0.36：安装包瘦身与后台资源优化

- 精简分发程序中的调试与本地符号，保留 Apple 芯片和 Intel 通用支持，并在安装包外保留匹配的崩溃调试符号。
- 主工作台改为首次打开时创建；关闭剪贴板记录或菜单栏收纳后，停止相应后台轮询与自动扫描。
- AI 用量改为增量读取日志并限制内存中保留的历史记录，兼顾会话分支、回退和异常恢复；重复模型的价格解析复用结果。
- 剪贴板图片独立保存，历史记录在后台串行写入，减少重复图片编码与主线程磁盘操作，并保留迁移及故障恢复。
- 修复调整窗口宽度时今日节奏输入框的输入法组合文本和选区丢失。
- 优化音乐唱片和节奏动画的持续刷新开销，保持旋转速度与相位，暂停、隐藏或减少动态效果时停止相应动画。
- 修复刘海收起或切页时原生编辑器与输入法的交接顺序，保留剪贴板搜索、便笺与聊天草稿。
- 在通用设置中提供独立的“开机自启动”开关，并显示系统授权状态。

macOS 15+，Apple 芯片与 Intel，build 119。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

完整 Swift 回归执行 1,337 项：1,281 通过、56 跳过、0 失败。Release 隔离探针的六种场景各采样两轮，每轮至少 30 秒，十二轮均通过原 CPU、p95 与唤醒预算。物理内置刘海屏上的自动原生输入验证共 114 项检查通过；通用候选包的 295 项静态与归档检查通过，本地候选 app / DMG / ZIP 分别为 24.65 / 11.68 / 10.51 MB。

探针使用合成数据与空 AX 菜单夹具，未覆盖已安装应用的全部服务或系统总能耗；原生输入检查属于自动化，非人工或正式安装包全流程验收，Intel 仅作静态验证。六项硬件检查仍待验收：内置屏真实睡眠 / 唤醒、外屏悬停 / 点击 / 活动 / 键盘，以及跨屏唤醒。实际重启 / 登录后的自启动、跨设备 AirDrop、VoiceOver、真实服务与持续能耗也未标记通过，WindowServer / GPU 未单独测量。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/NotchCalendar-2.0.36-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/NotchCalendar-2.0.36-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.36/SHA256SUMS.txt)

## 2.0.35：全部刘海面板视觉统一

- 统一全部 14 个刘海工具及工具库、隔空投送等子面板的圆角、字体、留白和背景层级，暗色内容更清楚，浅色图标更易辨认。
- 改进底部 Dock 的激活状态、按钮悬停反馈和面板过渡，保留减少动态效果、高对比度和减少透明度支持。
- 优化日历日期与日程布局、文件列表与投送区、翻译双栏和语言菜单、计算器轻字重结果及实心等号按钮。
- 同步打磨专注、速记、音乐、剪贴板、AI 对话、行情、资讯、开发工具、系统监控与 AI 用量。
- 修复窄窗下深层文件名被挤压、DeepSeek 工具栏超宽，以及 AI 用量卡片和保存按钮越界。

macOS 15+，Apple 芯片与 Intel，build 118。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试。此前开发阶段 108 项回归通过、1 项真实 AirDrop 拖动测试跳过，另有 7 项外观测试通过及 28 张原生面板截图复查。实际跨设备 AirDrop、多屏、睡眠唤醒、VoiceOver、真实服务与持续能耗仍待验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/NotchCalendar-2.0.35-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.35/SHA256SUMS.txt)


## 2.0.34：通知期间保持收纳，改善菜单兼容

- 通知弹出、经过时钟或打开系统面板时，不再主动把已收纳图标恢复到系统菜单栏。
- 原生菜单在对应收纳图标下方打开，改善点击无响应和菜单出现在屏幕左上角的问题；保留菜单勾选、快捷键、分隔线与子菜单。
- 对无法直接打开自定义弹窗的应用，提供明确标注的「应用菜单」入口。豆包使用此入口，暂不提供原自定义快捷面板。
- 新增输入法图标收纳。电池、时钟、控制中心和天气暂不支持收纳，继续保留在系统菜单栏。
- 保留原有收纳选择与排列；关闭收纳、退出或权限失效时恢复图标。

状态栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限。应用其他功能支持 macOS 15+。

Apple 芯片与 Intel，build 117。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试或现场验收。此前开发阶段完成 31 项定向测试，以及同程管家、sftpty、豆包应用菜单和输入法的本机集成检查。这些记录不等同于新发布回归；通知点击与完整收纳栏鼠标、截图验收仍未完成。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/NotchCalendar-2.0.34-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.34/SHA256SUMS.txt)


## 2.0.33：收纳图标留在收纳栏

- 点击收纳图标直接打开原应用菜单，图标继续保留在收纳栏，不再临时移回系统菜单栏。
- 修复隐藏状态切换后点击没有反应的问题；原生菜单关闭后可以再次打开，常驻悬浮窗不会阻塞后续操作。
- 鼠标悬停或经过右上角时钟区域时保持收纳；真实系统面板交互仍保留临时暂停。
- 修复刘海小伴侣的小狗头被系统菜单栏遮挡的问题。
- 保留已有收纳应用选择与排列；系统菜单栏项目暂不支持收纳。

状态栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限。应用其他功能支持 macOS 15+。

Apple 芯片与 Intel，build 116。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试或现场验收。此前开发阶段的 27 项定向测试通过，并完成 Pulse、Docker 原生菜单的两轮打开与关闭检查；收纳栏完整鼠标点击和截图验收受系统捕捉限制，未标记为通过。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/NotchCalendar-2.0.33-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.33/SHA256SUMS.txt)

## 2.0.32：修复状态栏收纳突然失效

- 修复鼠标经过右上角时钟区域后，已收纳图标可能全部回到菜单栏且无法自动恢复的问题。
- 排除通知中心常驻桌面层窗口，避免误认为系统面板一直打开；保留真实系统面板交互期间的临时暂停。
- 保留已有收纳应用选择与排列，无需重新配置。

状态栏收纳需要 macOS 27、安装至“应用程序”并授予辅助功能权限。应用其他功能支持 macOS 15+。

Apple 芯片与 Intel，build 115。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求，本次发布不追加回归测试或现场验收；修复开发阶段已有 13 项定向测试通过。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/NotchCalendar-2.0.32-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/NotchCalendar-2.0.32-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.32/SHA256SUMS.txt)

## 2.0.31：状态栏收纳

- 新增状态栏收纳，默认随应用显示「…」入口，点击展开独立收纳条。
- 在设置中选择收纳应用；支持拖动、右键和辅助功能排序，自动保存排列与显隐。
- 点击收纳图标打开原应用菜单；同一应用多个状态项整组收纳，可选择具体菜单。
- 关闭功能、退出或授权到期时恢复图标，保留系统固定项目。
- 桌面伙伴避让打卡提醒，回家路径避开刘海内容；底部收起缓冲调整为 20px。

状态栏收纳需要 macOS 27、将应用放入“应用程序”并主动允许辅助功能权限。应用其他功能仍支持 macOS 15+。

Apple 芯片与 Intel，build 114。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求跳过本次新增回归与现场交互验证。真实第三方菜单、通知中心、多屏及全屏场景仍待现场验收。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.31/NotchCalendar-2.0.31-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.31/NotchCalendar-2.0.31-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.31/SHA256SUMS.txt)

## 2.0.30：工具反馈与工作台布局优化

- 刘海工具栏新增触觉反馈与可选音效，设置中可分别开关；默认开启触觉、关闭声音，触觉需要受支持的触控板。
- 优化功能库的分组与列表布局，打开时覆盖底部功能栏；调整摄像头两侧的按钮空间，方便在窄刘海中操作。
- AI 用量图表增加最近 14 天的日期、数量刻度与每日读数；修复切换页面后仍触发额度悬停详情的问题。
- DeepSeek 输入框在刘海中贴底显示，保留输入框收起与独立窗口布局。
- 关闭文件浏览时，文件页突出显示 AirDrop 拖放与发送入口。
- 改善专注页的小窗口布局、今日工作台的信息层级和响应式分栏，以及侧栏导航。

macOS 15+，Apple 芯片与 Intel，build 113。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证；退出旧版后使用 DMG 手动替换安装。

按所有者要求跳过本次回归测试。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.30/NotchCalendar-2.0.30-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.30/NotchCalendar-2.0.30-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.30/SHA256SUMS.txt)

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

## 2.0.28：刘海 AI 用量与核心设置

- 在刘海查看 Codex、Claude、Gemini、Z.ai、GLM、Kimi Code 和 Copilot 的额度与用量。
- 新增统一 AI 用量设置：服务启停、登录指导、密钥管理、连接测试、自动刷新及系统代理／直连。
- 支持本地 Token 统计与强制重扫，以及额度阈值、耗尽、恢复和连续读取失败提醒；后台刷新与提醒可独立开启。
- 精简设置说明，保留必要操作与状态。

macOS 15+，Apple 芯片与 Intel，build 111。ad-hoc 签名，未进行 Apple 公证；退出旧版后使用 DMG 手动替换安装。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.28/NotchCalendar-2.0.28-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.28/NotchCalendar-2.0.28-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.28/SHA256SUMS.txt)

## 2.0.27：唱片音乐布局与文件内隔空投送

音乐页参考网易云播放器布局：左侧黑胶唱片，右侧歌曲信息与同步歌词，底部统一进度、居中播放控制、收藏和播放器入口；适配小窗口、深浅色、中英文与减少动态效果。隔空投送整合到文件页，可拖入文件或发送所选文件，在系统界面选择接收人；保留待发送列表和取消重试，兼容旧入口与快捷键。

冻结源码定向回归 306 项：302 通过、4 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

音乐截图和歌词使用示例数据；真实网易云联动、跨设备隔空投送及实际拖到 Finder／桌面仍待人工确认。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 110。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。开发工具草稿与 TinyPNG API 密钥仅保留在当前应用会话中。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.27/NotchCalendar-2.0.27-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.27/NotchCalendar-2.0.27-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.27/SHA256SUMS.txt)

## 2.0.26：修复文件拖入与拖出

修复文件暂存区拖放：支持拖入本地文件与文件夹并复制到当前目录、子目录或收藏位置，保留原文件，重名时提示；拖出改为 macOS 原生文件拖拽，可交给 Finder，拖动期间刘海保持展开，保留双击打开与右键菜单。

冻结源码定向回归 265 项：262 通过、3 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

冻结源码覆盖文件复制、原生拖拽数据与行事件路由；实际拖到 Finder／桌面的鼠标操作仍待安装后人工确认。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 109。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。开发工具草稿与 TinyPNG API 密钥仅保留在当前应用会话中。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/NotchCalendar-2.0.26-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/NotchCalendar-2.0.26-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.26/SHA256SUMS.txt)

## 2.0.25：钉住刘海持续操作，翻译左右对照

- 新增钉住刘海：展开后点击图钉，移开鼠标或点击外部也保持展开；切换工具时保留钉住状态。取消钉住恢复自动收起，手动关闭结束本次钉住。
- 翻译改为左右双栏：左侧原文、右侧译文，窄刘海也能并排对照；等宽编辑区、字符计数和独立滚动让长文更好读。
- 翻译操作集中到顶部：语言选择、交换、粘贴、图片识别、清空和翻译；保留复制译文、原生输入法与工具切换后的草稿。


冻结源码定向回归 218 项：217 通过、1 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

翻译双栏与钉住交互使用隔离偏好、测试几何、演示译文与合成通知验证，不代表真实翻译语言包或硬件验收。系统监控的界面及暂停行为使用合成计数器验证。TinyPNG 上传流程仅使用模拟响应验证，尚未用真实 API 密钥联网验收。各类硬件的实际摄像头贴合与监控读数、真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒和持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 108。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。开发工具草稿与 TinyPNG API 密钥仅保留在当前应用会话中。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/NotchCalendar-2.0.25-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/NotchCalendar-2.0.25-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.25/SHA256SUMS.txt)

## 2.0.24：全新设置与功能库，开发工具和系统监控随手可用

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

## 2.0.23：音乐中也能收到专注结束提醒，小伴侣持续陪伴

- 修复播放音乐时容易错过专注结束提醒的问题：结束时在刘海下方显示独立胶囊，停留 20 秒，可手动关闭。
- 与贴心提醒、音乐状态或展开面板冲突时，胶囊自动向下避让，不抢键盘焦点；关闭提示音后仍显示结束提醒。
- 提示音改用持续持有的独立播放器混音，播放失败时回退；保留原提示音开关，不调整音乐或系统音量。休息结束同样提醒，恢复过期计时不会重复播放。
- 小伴侣在播放音乐、专注计时、展示专注建议和展开刘海内容时继续可见，移动到状态或内容外侧；窄屏空间不足时停在内容下方。
- 走动、拖动归位、吊绳和说话气泡同步避开摄像头、按钮及展开内容，缩放面板时跟随实际边界调整。

冻结源码定向回归 202 项：201 通过、1 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收；尚未进行第三方音乐应用或耳机的主观听感验收。

macOS 15+，Apple 芯片与 Intel，build 106。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/NotchCalendar-2.0.23-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/NotchCalendar-2.0.23-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.23/SHA256SUMS.txt)

## 2.0.22：会议中继续陪伴，聊天缩放更清楚

- 修复会议开始后小伴侣消失：会议中继续显示在状态按钮外侧，会议结束或关闭会议状态后回到原位。
- 走动、拖动归位和吊绳滑梯同步避开会议按钮与摄像头；无刘海屏幕保留胶囊旁的位置。
- 刘海 AI 聊天卡片底部两角新增缩放提示；切换到其他工具时隐藏，拖动期间暂停呼吸效果，减少动态效果或提高对比度时静态显示。

冻结源码定向回归 305 项：302 通过、3 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

前两轮各出现一项不同的桌面交互测试失败；未修改源码，单项诊断及最终完整定向复验通过。早期失败原因未确认，原始日志已保留。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 105。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/NotchCalendar-2.0.22-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/NotchCalendar-2.0.22-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.22/SHA256SUMS.txt)

## 2.0.21：一句话安排日程

- 新增「一句话安排」：在刘海日历页或主窗口输入“明天下午三点和张三开会一小时”，先生成可编辑日程草稿，再由你点击保存写入系统日历。回车只生成草稿。
- 常见日期、时间、时长和全天安排可在本机识别；预览可修改标题、时间、地点与目标日历，并显示已选日历中的占用重叠。未写时长会明确提示默认 30 分钟，含糊、重复或多事项需要补充。
- 可主动选择「用 AI 理解」，复用已配置的聊天 API 服务。只发送本次描述、当前时间与时区；仍需检查草稿并手动保存。DeepSeek 网页登录不等于 API 配置。真实模型服务与个人日历写入仍待实机验收，本次相关回归使用模拟响应和离线日历。
- 保留上一版紧凑的刘海下方专注建议胶囊：展示 5 秒后自动收回，可准备专注或稍后提醒。

冻结源码定向回归 267 项：267 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 104。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/NotchCalendar-2.0.21-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/NotchCalendar-2.0.21-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.21/SHA256SUMS.txt)

## 2.0.20：提醒避让、专注建议与聊天输入优化

- 修正贴心提醒在刘海两侧偏下的问题。空闲时两侧与刘海垂直居中；音乐或会议占位时，图标、文案和关闭按钮合为一颗刘海下方胶囊。状态切换保留阅读时长，回应收窄保持居中。
- 新增会议间隙的专注建议：本机日历发现合适空档时，在刘海下方安静展示 5 秒。可准备 25 分钟专注（不会自动开始），或选择“稍后”暂停建议 30 分钟；支持开关、预览、同场次去重与备份恢复。
- 改善 DeepSeek 网页对话输入区：重新进入已有会话或收起后再打开时，空白输入区保持精简；点击继续输入恢复原编辑器。保留草稿、输入法选词和换行，发送未成功时保持展开。

冻结源码定向回归 228 项：228 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 103。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/NotchCalendar-2.0.20-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/NotchCalendar-2.0.20-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.20/SHA256SUMS.txt)

## 2.0.19：小猫小狗会说话了

- 小猫小狗会说话了：新增心情、打卡、喝水、陪伴与休息气泡，摸摸时也会回应；支持设置和右键“说句话”。
- 新增“偶尔说说话”独立开关。安静型每 20–30 分钟、活泼型每 10–20 分钟主动问候；气泡 12 秒后收起，点击即可关闭。关闭打卡提醒后不再轮播打卡问候。
- 气泡避开摄像头和宠物，适配浅色与深色外观；拖动、展开内容、隐藏、休眠或专注休息时收起，不补播。低电量停止主动问候，减少动态效果时保留静态文字。问候在本地运行，不开麦、不调用模型、不保存心情信息。

冻结源码定向回归 168 项：168 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 102。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/NotchCalendar-2.0.19-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/NotchCalendar-2.0.19-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.19/SHA256SUMS.txt)

## 2.0.18：吊绳滑梯与更舒展的贴心提醒

- 新增小伴侣吊绳滑梯：拖动小猫或小狗时显示吊绳，把它放到左右任一端点松手，即可抓绳滑下、轻荡后跑回家。滑行中可以重新抓起；在其他位置松手仍按原路线回家。
- 设置和宠物右键菜单新增“滑滑梯”入口。吊绳只在拖动和滑行时显示，绳子本身不拦截鼠标；展开日历、隐藏、休眠或屏幕变更会取消动作。减少动态效果时保留静态开心回应。
- 改善贴心提醒的刘海两侧布局：向下调整位置，随收起状态刘海区域居中并留出顶部间距；黑色胶囊可见高度从 20pt 增至 30pt，正文从 12pt 调为 13pt，图标和关闭按钮同步放大，中英文仍按文案自适应宽度。

冻结源码定向回归 163 项：163 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生渲染及事件测试使用隔离偏好和测试几何；不等于各款硬件的实际摄像头贴合验收。真人 VoiceOver、实体多屏／全屏、真实睡眠唤醒与持续能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 101。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/NotchCalendar-2.0.18-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/NotchCalendar-2.0.18-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.18/SHA256SUMS.txt)

## 2.0.17：专注陪伴、累计装扮与每周分享卡

- 侧栏底部改为设置、打赏、漏洞报告和分享四个快捷入口，移除试用引导卡与原更多菜单；授权规则保持原样。
- 专注／休息运行时，小猫或小狗在原计时圆岛安静打盹；暂停仍显示暂停图标。专注完成后短暂庆祝一次，可关闭，尊重减少动态效果和低电源模式。
- 新增个人每周分享卡，可从侧栏或所选周回顾打开，预览、复制或保存 PNG；仅展示角色资料、日期和完成统计，不展示任务名、日历标题或笔记，零记录如实显示。
- 累计 3 个专注日解锁蓝围巾，7 天解锁星星配饰；不要求连续，可先预览再穿戴。资格根据保留的专注记录重算，偏好支持备份恢复。
- 专注结束后可直接前往「今日」记录小收获。

冻结源码定向回归 115 项：115 通过、0 项可选跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。不是全应用全量回归。

原生截图使用隔离的合成记录。真人 VoiceOver、实体多屏／全屏、睡眠唤醒和持续能耗仍待验收；14 天真实用户试用尚未开展，不宣称已提高留存。未新增遥测。

macOS 15+，Apple 芯片与 Intel，build 100。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，原授权及聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.17/NotchCalendar-2.0.17-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.17/NotchCalendar-2.0.17-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.17/SHA256SUMS.txt)

## 2.0.16：椭圆胶囊与日期条跳闪修复

- 无刘海屏幕的中间日期时间条及左右提醒气泡改为完整圆角胶囊形，收紧提醒气泡的黑色背景。
- 修复经典模式展开／收起时日期时间条的跳闪，保留同一时钟视图并修正动画结束时的遮罩衔接。

本次按所有者要求跳过新增发行回归，未宣称本版本完成回归。通用编译、安装包完整性及上传资产元数据核验通过。人工鼠标手感、VoiceOver、实体屏幕拔插／合盖、睡眠唤醒、真实服务和持续 CPU／能耗仍待验收。

macOS 15+，Apple 芯片与 Intel，build 99。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.16/NotchCalendar-2.0.16-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.16/NotchCalendar-2.0.16-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.16/SHA256SUMS.txt)

## 2.0.15：收紧外接屏顶部留白

- 优化无刘海外接屏的贴边模式：标题和窗口按钮靠近顶部，减少空白并增加正文空间。
- 顶部和底部导航均适用；缩放窗口、切换样式时继续保留便笺草稿与选区。
- 经典模式继续显示顶部日期时间；实体刘海和系统顶部安全区保留对应避让。

早期原生工具栏测试曾失败，观察到系统前台归属不一致和鼠标移动；测试补充前台稳定等待、短暂鼠标输入隔离与明确单击状态后，最终同一冻结副本分两组完成全部定向检查。未证明所有早期失败的原因；产品代码和按钮断言保持不变，原始记录已保留。

冻结源码定向回归 215 项：215 通过、0 项可选检查跳过、0 失败；21 项 Python 质量检查与通用安装包核验通过。

已使用连接外接屏上的隔离原生窗口及模拟几何验证布局、按钮、缩放和编辑器状态。人工鼠标手感、VoiceOver、实体屏幕拔插／合盖、睡眠唤醒、真实 AI 服务和持续 CPU／能耗仍待验收；不宣称全量回归或严格设备门禁通过。

macOS 15+，Apple 芯片与 Intel，build 98。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，已有授权与聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/NotchCalendar-2.0.15-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/NotchCalendar-2.0.15-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.15/SHA256SUMS.txt)

## 2.0.14：显示屏选择、窗口缩放与小伴侣交互

- 在「设置 → 通用设置 → 刘海显示屏」选择自动、内置或外接显示屏。
- 无实体刘海的显示屏使用经典模式时，顶部保留日期时间，展开内容显示为独立圆角卡片。
- 重新展开时恢复上次选择的页签。支持拖动窗口左右边、底边及两个下角调整大小，并保存尺寸；拖动时保留编辑内容与网页草稿。
- 小伴侣停靠在刘海左侧；鼠标碰到会掉落并归位，双击沿刘海下沿跑到右侧再返回左侧，单击仍可摸摸。小伴侣需在设置中主动开启，尊重「减少动态效果」。

冻结源码定向回归 265 项：264 通过、1 项可选检查跳过、0 失败；21 项 Python 质量检查与通用安装包核验通过。

已通过原生窗口事件、真实显示屏坐标及模拟几何测试检查显示屏选择、缩放和小伴侣路径。人工鼠标手感、VoiceOver、显示屏拔插／合盖、真实睡眠唤醒、真实 AI 服务和持续 CPU／能耗仍待验收；不是全量回归或严格设备门禁通过。

macOS 15+，Apple 芯片与 Intel，build 97。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，已有授权与聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/NotchCalendar-2.0.14-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/NotchCalendar-2.0.14-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.14/SHA256SUMS.txt)

## 2.0.13：刘海旁，多一个小伴侣

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

## 2.0.12：发送后收起输入区，留更多空间给回答

- DeepSeek 网页对话直接使用官网账号，无需 API Key；保留原有 API 模式、独立草稿和图片。
- 网页发送并清空输入后，聊天框自动收成“继续输入”小按钮，给回答腾出空间；点击恢复并聚焦。中文选词、Shift+回车和未发出的草稿保持展开。
- 刘海网页默认 75% 缩放，可选 75%、85%、100%、125%；在独立窗口和刘海之间移动同一网页，保留网站会话与草稿。
- 修复已下载语言包时翻译一直等待的问题，默认英语 → 简体中文；支持重复翻译、取消和超时恢复。
- 放缓刘海展开节奏，保留连续收起、快速反向和原生输入状态。

发布前 182 项定向回归：180 项通过、2 项可选检查跳过、0 失败；21 项 Python 质量检查及通用安装包核验通过。

DeepSeek 折叠、草稿与窗口往返使用本地 WebKit 页面验证，真实账号发送、上传与官网改版兼容仍待实测。翻译修复另有本机真实英译中验收记录；本轮系统翻译检查按语言包可用性运行，macOS 15 实机、首次语言包下载和其他语言组合未覆盖。实体刘海、外接屏、休眠唤醒、VoiceOver 与静置能耗仍待验收；不宣称全量回归或严格设备门禁通过。

macOS 15+，Apple 芯片与 Intel，build 95。ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装。退出旧版，将 DMG 内应用拖入“应用程序”替换并重新启动。保留本机应用数据时，已有授权与聊天 API Key 可继续使用。

[DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/NotchCalendar-2.0.12-macos.dmg) · [ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/NotchCalendar-2.0.12-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.12/SHA256SUMS.txt)

## 2.0.11：翻译、隔空投送与悬停切换

- 刘海新增「翻译」（⌥⌘T）：自动检测原文语言、选择目标语言、交换语言、复制译文；支持图片导入、粘贴和拖入文字识别。宽窗口双栏、窄窗口上下排列，切页保留草稿。使用 macOS Translation 与 Vision，无需配置 API Key；首次翻译可能需要系统下载语言包。
- 新增「隔空投送」（⇧⌘R）：拖入或选择本机文件／文件夹，再在 macOS 系统窗口选择接收设备。最多暂存 50 项，支持移除、清空和取消后重试，不移动或删除原文件。
- 默认鼠标在功能图标上停留约 160 毫秒即可切换，快速经过不触发；图标保持固定宽度。可在「设置 → 通用设置 → 刘海功能栏」关闭，继续使用点击和原有 ⌘1–0。系统菜单、文件选择与分享期间暂停悬停切换。
- 主窗口将情报台、舆论室和信息差简报整合为「资讯」（⌘5），提供最新／热门／收藏，以及来源、语言、未读和搜索筛选；保留已有收藏、已读、笔记与立场，旧入口进入对应分段。自选行情仍独立保留（⌘6）。
- 修复屏幕参数频繁变化时喝水、舒展提醒反复重新计时的问题；重新定位窗口时保留到期时间和正在展示的提醒。
- 经典模式顶部功能栏与窗口操作合并为一行，移除重复标题，给正文增加 38 点高度；保持窗口尺寸及原生编辑状态。

已完成通用构建、本地 ZIP／DMG 完整内容核验、3 项桌面集中复验及 21 项 Python 质量测试。按发布者要求停止其余回归并直接发布，未完成整组回归或实体硬件验收；不宣称全量测试通过。

本机尚未安装翻译语言包，实际译文与首次下载流程未完成实测；布局截图中的译文为测试数据。真实图片文字识别和系统隔空投送窗口取消恢复已验证，未向其他设备发送文件。资讯使用隔离数据验证，完整发布者／HN 联网、实体刘海、外接屏、休眠唤醒、真实 VoiceOver 与静置 CPU／能耗仍待验收。原生编辑中已有系统 WritingToolsUI 状态发布诊断尚未消除，已测输入、保存、重开与切页通过。

macOS 15+，Apple 芯片与 Intel，build 94。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证，自动替换安装仍禁用。退出旧版，将 DMG 中应用拖入「应用程序」替换并重新启动。更新不会重置试用；保留本机应用数据时继续使用已有授权与聊天 API Key。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/NotchCalendar-2.0.11-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/NotchCalendar-2.0.11-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.11/SHA256SUMS.txt)

## 2.0.10：把行情与资讯带到刘海

- 刘海功能栏新增「行情」（⌘9）和「资讯」（⌘0），保留原有 ⌘1–⌘8、窗口尺寸及顶部／底部布局。入口较多时使用「更多工具」菜单，也可在设置中隐藏不用的工具。
- 查看上证、深成、创业板、沪深 300、科创 50 五个指数，以及最多八只沪深 A 股自选的价格、涨跌和来源时间。自选管理留在主窗口，原有美股 Alpha Vantage 配置与额度保留。
- 分时图绘制来源实际返回的分钟点；主窗口包含成交量柱，可关闭分时图以一起隐藏曲线与量柱。刘海中的小曲线也可单独关闭，无分时数据时仍可查看已有报价。
- 行业领涨／领跌使用东方财富行业分类，不包含概念板块；行业源不可用时显示状态，保留可用缓存，报价仍可独立更新。
- 「资讯」每次速览最多三条，支持未读／最新／收藏；与主窗口共享内容语言、已读与收藏状态；局部阅读切换保留主窗口的搜索、阅读筛选和来源选择，切换共享内容语言仍按原规则清除不兼容来源。「查看全部」继续到完整信息差简报。
- 情报台、自选行情、舆论室、信息差简报四个工作台模块与原有侧栏偏好保留；刘海新增短暂查看入口，完整管理与阅读继续在主窗口进行。

腾讯财经报价与分时已通过本轮应用实际网络传输与生产解析检查；行业接口本轮出现超时及空响应，未完成行业源联网成功验收。行情按进入、切换标的或手动刷新按需更新，没有后台轮询；公开接口不保证实时性或持续可用，页面显示来源时间、缓存与错误状态。

发布前 232 项定向测试以独立进程串行执行：226 项通过、6 项可选检查跳过、零失败；21 项 Python 质量检查通过。双架构安装包的实际二进制内容、严格签名、快捷指令元数据和 ZIP／DMG 完整内容检查通过。初次四项原生测试夹具失败已修正，随后完整重跑此定向集通过；这不是整应用全量回归。实体刘海、外接屏、休眠唤醒、真实 VoiceOver 与静置 CPU／能耗完整验收仍待完成。macOS 15+，Apple 芯片与 Intel，build 93；ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证，自动替换安装仍禁用。[2.0.10 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.10)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/NotchCalendar-2.0.10-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/NotchCalendar-2.0.10-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/SHA256SUMS.txt)

## 2.0.9：按习惯配置文件与功能栏

- 文件默认使用左右分栏，也可在「设置 → 数据与文件 → 文件浮窗」切换为列表；切换保留当前目录、选中文件和滚动位置。
- 在「设置 → 通用设置 → 刘海功能栏」选择顶部或底部，默认底部；切换位置保持正文空间与原生编辑状态。
- 自选功能栏中显示的工具，日历始终保留。隐藏入口不删除数据或停止正在进行的专注、音乐与聊天；隐藏当前工具时回到日历，重新显示后可继续访问。
- 信息差简报新增少数派与 IT之家 RSS，支持全部／中文／英文筛选，保留原文标题、日期与链接；语言筛选先于 20 条展示上限应用。

发布前 218 项定向测试以独立进程串行执行：216 项通过、2 项可选联网／Finder 集成检查跳过、零失败；21 项 Python 质量检查和本地 Release 产品构建通过，中文 RSS 实际下载与生产解析另行验证。这不是整应用全量回归，实体设备与完整真实集成仍待验收。macOS 15+，Apple 芯片与 Intel，build 92；ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。[2.0.9 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.9)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/NotchCalendar-2.0.9-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/NotchCalendar-2.0.9-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.9/SHA256SUMS.txt)

## 2.0.8：窗口更稳定，切换更从容

- 八个工具共用日历页面的窗口尺寸，切换时保持外框与导航位置稳定；仍可在设置中调整整体尺寸。
- 底部胶囊导航更窄、更轻，贴近窗口底边，减少大块留白。选中工具保留名称与颜色，支持 ⌘1–⌘8。
- 优化「未来 7 天的其他安排」布局与「查看全部」点击区域，较多安排可滚动查看；完整七天列表保留进行中的安排，并可返回月历。
- 调整页面内容与导航的切换节奏，保留便笺、输入、选区和页面状态；专注图表的星期、音乐进度与各页底部操作完整可见。
- 日历授权结束后再展示欢迎；应用重新激活或屏幕恢复时继续尚未完成的启动流程。每个安装版本单独记住欢迎完成状态，明确完成或跳过后，普通重启不重播。

本轮 223 项针对性测试：222 项通过、1 项可选 Finder 集成检查跳过、零失败；21 项 Python 质量检查通过。macOS 15+，Apple 芯片与 Intel，build 91；ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。[2.0.8 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.8)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/NotchCalendar-2.0.8-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/NotchCalendar-2.0.8-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.8/SHA256SUMS.txt)

## 2.0.7：随内容伸展，操作更连贯

- 刘海面板按当前工具调整尺寸：便笺与专注更紧凑，日历、聊天和计算器保留需要的空间。八个工具集中到底部胶囊导航，当前工具显示名称，支持 ⌘1–⌘8。
- 展开、收起和切换工具时，外形、内容与导航按同一节奏衔接；动画中途重新进入也能连续展开。保留原生输入、选区、撤销与页面状态，并适配系统「减少动态效果」。
- 永久授权改存本机应用数据目录，保留原安装标识与激活码；已激活用户从旧钥匙串迁移后，重启无需再次读取授权钥匙串。首次迁移若被系统阻止，请点击「重试读取授权」允许一次访问；试用记录与 7 天期限不变。
- 「软件更新」使用独立窗口，试用到期或授权读取失败时也可打开。最新成功检查确认没有更新后清除旧提醒，发现更新版本时改用最新说明。
- 延续 2.0.6 的聊天 API Key 本机保存方式，并加强跨重启、旧密钥迁移失败恢复、删除与服务隔离的回归检查。

macOS 15+，Apple 芯片与 Intel，build 90；ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。[2.0.7 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.7)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/NotchCalendar-2.0.7-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/NotchCalendar-2.0.7-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.7/SHA256SUMS.txt)

## 2.0.6：先授权，后欢迎

- AI 聊天 API Key 改存本机应用数据目录，替换或重装应用且保留应用数据时可继续使用；保存与发送不再依赖钥匙串授权。旧密钥可静默读取时自动迁移，否则重新保存一次。各服务独立保存，主动删除后不会从旧钥匙串恢复；普通笔记备份不包含密钥。
- 启动先等待日历授权结果，再播放刘海欢迎，完成后进入工作台；允许、拒绝或请求失败均可继续，已有授权结果时不重复弹窗。
- 修复旧版完成记录跳过欢迎的问题：升级后重新展示一次，明确完成后普通重启不再播放。
- 等待期间的 Dock 重复打开、小组件链接与屏幕切换保留启动进度和待打开目标。

macOS 15+，Apple 芯片与 Intel，build 89；ad-hoc 签名、手动安装。[2.0.6 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.6)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/NotchCalendar-2.0.6-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/NotchCalendar-2.0.6-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.6/SHA256SUMS.txt)

## 2.0.5：刘海收回更连贯

- 修复「空壳 → 宽黑条 → 两侧胶囊」的突变，卡片与正文同步淡出，真实紧凑视图提前衔接。
- 收回曲线持续平稳，中途重新进入可连续反向展开；修复经典样式胶囊裁切，保留草稿、选区及撤销。
- 33 项定向动画测试和原生合成帧检查通过；完整 Swift 回归 822 项：790 通过、32 条件或环境跳过、零失败；21 项 Python 质量检查通过。实体悬停、外接屏、休眠唤醒与静置性能仍待完整验收。

macOS 15+，Apple 芯片与 Intel，build 88；ad-hoc 签名、手动安装。[2.0.5 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.5)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/NotchCalendar-2.0.5-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/NotchCalendar-2.0.5-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.5/SHA256SUMS.txt)

## 2.0.4：先说 hello，再开始使用

- 修复系统重复打开应用时跳过欢迎、提前弹出日历权限的问题。欢迎期间再次打开应用只唤回介绍；选择「跳过」「开始使用」或前往自定义后，才请求尚未授予的日历权限。
- 从 2.0.3 升级后重新展示一次修复后的欢迎介绍；明确完成后，普通重启不再播放。
- 空闲收起时取消左右各 30 pt 的额外点击入口，让这些区域的点击穿透到菜单栏；默认在刘海附近停稳后悬停展开，已有活动指示保持。
- 前四幕自动换幕总时长由约 21 秒缩短为约 14 秒，最后一幕仍等待主动继续；支持暂停、前后翻页及重播。
- 欢迎标题与介绍以打字机效果逐字出现；开启减少动态效果或旁白时直接显示全文。
- 修复 AI 聊天输入框占位文字与光标的对齐，避免配置按钮的焦点提示和错误信息被裁切或挤压。

macOS 15+，Apple 芯片与 Intel，build 87；ad-hoc 签名、手动安装。[2.0.4 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.4)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/NotchCalendar-2.0.4-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/NotchCalendar-2.0.4-macos.zip) · [SHA-256 校验文件](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.4/SHA256SUMS.txt)

## 2.0.3：从刘海开始，说一声 hello

从 2.0.6 起，新安装和升级用户先处理日历授权，再看到可跳过的欢迎介绍；完成后进入工作台。默认采用经典刘海、玻璃面板与通透工作台，保留已保存的个人选择；设置与窗口菜单均可重播欢迎动画。

包含每日更新与版本说明提醒，以及喝水、舒展、下班关怀。核心检查和通用安装包验证完成后发布，详细回归在发布后继续。macOS 15+，Apple 芯片与 Intel，build 86；ad-hoc 签名、手动安装。[2.0.3 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.3)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/NotchCalendar-2.0.3-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/NotchCalendar-2.0.3-macos.zip) · [SHA-256 校验文件](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.3/SHA256SUMS.txt)

## 2.0.2：打磨每天触达的细节

- 刘海工具导航增加轻薄分组底色与选中描边，悬停提示带有对应快捷键。
- 统一日期、翻月、日程与会议笔记的悬停、按压和键盘反馈；窄栏笔记入口增加文字，更容易辨认与点击。
- 跨午夜日程紧凑显示为「23:30 – 次日 00:15」，按显示时区判断；多日事件仍保留完整结束日期。
- 最小刘海日历使用简短星期，避免英文截断，无障碍朗读仍保留完整星期。

2.0.2（build 85，2026-10-15），支持 macOS 15+、Apple 芯片与 Intel。Swift 全量 625 项：604 通过、21 条件跳过、零失败；21 项 Python 质量检查通过。沿用 ad-hoc 签名与手动安装，未进行 Developer ID 签名或 Apple 公证。实体设备、静置性能与完整真实集成仍待验收。详见 [2.0.2 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.2)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/NotchCalendar-2.0.2-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/NotchCalendar-2.0.2-macos.zip) · [SHA-256 校验文件](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.2/SHA256SUMS.txt)

## 2.0.1：保存密钥后继续聊天

- 修复设置显示保存成功后，发送消息仍反复要求钥匙串授权的问题。API Key 继续保存在本机钥匙串，当前应用会话复用已经读回验证的密钥。
- 启动保持静默读取；如尚未取得密钥，首次发送或重试允许 macOS 请求授权。取消授权会保留草稿与图片附件，可再次发送。
- 各服务的密钥保持隔离；删除或替换密钥时使旧会话缓存失效，切换服务不会沿用上一服务的密钥。
- 保留 2.0 的浅深色界面、侧栏、卡片和刘海动效更新。

2.0.1（build 84，2026-10-15），支持 macOS 15+、Apple 芯片与 Intel，ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。真实用户升级后的钥匙串授权弹窗及真实模型联调仍待验收。详见 [2.0.1 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.1)。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/NotchCalendar-2.0.1-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/NotchCalendar-2.0.1-macos.zip) · [SHA-256 校验文件](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.1/SHA256SUMS.txt)

## 2.0.0：保存反馈与视觉更新

- 修复聊天设置保存时禁止钥匙串授权的问题；读回确认后提交配置，失败保留输入并显示恢复指引和错误码，成功显示「聊天设置已保存」。
- 重整浅深色界面、侧栏、系统设置分段控件、卡片与按钮反馈；以蓝色区分操作、珊瑚红标识日期。
- 刘海展开 280 ms、收起 210 ms，保留滚动位置并适配减少动态效果；继续支持图片聊天、鼠标移开自动收回与对话清理。

2.0.0（build 83，2026-10-15），支持 macOS 15+、Apple 芯片与 Intel，ad-hoc 签名、手动安装。Swift 全量执行 611 项：584 项通过、27 项按需或环境跳过，零失败。21 项 Python 质量检查全部通过。 详见 [2.0.0 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.0)。

## 1.8.9：图片聊天、移开自动收回与对话清理

- 聊天支持粘贴截图、图片和本地图片文件，支持图片预览、只发图片及重试；需使用支持图片的模型。
- 悬停模式下，聊天、剪贴板和便笺在鼠标移开后自动收回，重开保留输入与内容。
- 经确认可删除一轮提问和回复，或清空全部对话、草稿及附件，释放对应内存引用。

1.8.9（build 82，2026-10-15），支持 macOS 15+、Apple 芯片与 Intel，ad-hoc 签名、手动安装。Swift 全量执行 604 项：578 项通过、26 项按需或环境跳过，零失败。21 项 Python 质量检查全部通过。 详见 [1.8.9 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.9)。

## 1.8.8：修复聊天设置卡住与窗口叠加

- 修复聊天设置打开后，点击外部导致刘海收起、输入框与取消按钮一起失效的问题。
- 设置窗口打开时保持父面板活动；切换工具或强制收起时关闭设置，避免再次展开后覆盖日历。
- 验证模型输入、取消、Esc、保存、重复打开，以及延迟点击不会抢走设置窗口的键盘焦点。

1.8.8（build 81，2026-10-15），支持 macOS 15+、Apple 芯片与 Intel，ad-hoc 签名、手动安装。Swift 全量执行 590 项：565 项通过、25 项按需或环境跳过，零失败。 21 项 Python 质量检查通过。详见 [1.8.8 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.8)。

## 1.8.7：独立剪贴板历史与 AI 聊天

- 「剪贴板」（⌘7）是独立历史列表，不并排显示月历。手动开启后记录文字、图片与文件引用，支持搜索、复制、置顶、删除、清空和暂停，最多本地保存 100 条。
- 「AI 聊天」（⌘8）支持 OpenAI Responses 与兼容 Chat Completions 的接口，可配置地址和模型，API Key 保存在本机钥匙串。
- 支持流式回复、多轮、停止、重试与手动文本附件。新配置默认 Responses；原有配置可在聊天设置中切换协议，同一服务的密钥无需重填。
- 剪贴板默认不记录，聊天不会自动读取其他工具内容；聊天与草稿仅保留在本次进程内存中，退出后消失。

本版为 1.8.7（build 80，2026-10-15），支持 macOS 15+、Apple 芯片与 Intel，沿用 ad-hoc 签名与手动安装。26 项新增功能定向测试和中英文五档尺寸原生交互通过；网络采用受控响应，尚未使用真实密钥联调。详见 [1.8.7 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.7)。

全量回归执行 588 项 Swift 测试，563 项通过、25 项按条件跳过、零失败；21 项 Python 质量检查通过。

## 1.8.6：专注结束有声音，打卡对号有动画

- 专注或休息计时结束时播放一声短提示音；在后台计时也会提醒。专注页提供声音开关，并记住选择。
- 提示音只响一次；暂停、重置以及重新启动或恢复已结束的计时不会重复提醒。
- 「打卡」胶囊的对号在提醒出现和点击时描画一下；点击立即打开详情，开启系统“减少动态效果”时显示完整静态对号。

本版为 1.8.6（build 79，2026-10-14），支持 macOS 15+、Apple 芯片与 Intel，沿用 ad-hoc 签名与手动安装。Swift 全量执行 560 项：535 项通过、25 项按需或环境跳过，零失败；21 项 Python 质量检查通过。后台提醒、静音开关、连续点击与中英文宽窄窗口已本地验证；完整实体设备和真实集成验收仍待完成。详见 [1.8.6 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.6)。

## 1.8.5：计算器及时收起，音乐授权更易恢复

- 修复计算器点击或输入后移开鼠标不收起的问题；再次打开保留结果，仍尊重仅点击设置。
- 音乐收藏增加重装后的授权恢复说明和「在访达中显示当前应用」，方便添加正确副本。
- 重新检查与返回音乐页时读取最新状态，保留进行中的收藏确认，恢复后关闭提示。

本版为 1.8.5（build 78，2026-10-14），支持 macOS 15+、Apple 芯片与 Intel，沿用 ad-hoc 签名与手动安装。550 项 Swift 测试执行，526 项通过、24 项按需或环境跳过、零失败；21 项 Python 质量检查通过。实体设备与完整真实集成仍待验收。安装与授权恢复步骤见 [1.8.5 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.5)。

## 1.8.4：随手计算，继续手头的事

- 点击刘海工具栏中的计算器图标，或按 ⌘6，进行加、减、乘、除、小数、正负号与百分比计算。
- 支持连续等号、退格、清空及复制结果；可直接使用键盘输入，⌘C 复制当前结果。
- 切换页面、收起重开或调整尺寸保留当前计算，退出应用后重置。除零或数值超出范围时显示提示，输入新数字或清空后可继续。
- 四则运算按输入顺序计算；百分比结合当前运算，例如 `200 + 10% = 220`。窄面板导航使用图标，宽面板显示文字。

本版为 1.8.4（build 77，2026-10-14），支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。Swift 全量执行 542 项，518 项通过、24 项按需或环境跳过，零失败；21 项 Python 质量检查通过。26 项计算器定向检查和中英文尺寸截图通过。详细验证与待验收范围见 [1.8.4 发行说明](RELEASE_NOTES.md)。

## 1.8.3：恢复日历布局，修复内容空白

- 恢复左侧日期与当天安排、右侧月历的布局；当天没有安排时也保留左栏。
- 修复切换音乐、收起后重开时，日期和未来日程看不见但仍可点击的问题。
- 刘海弹窗恢复固定黑底；520 点宽度下中文活动标签保留文字，包括「跟随系统」中文。
- 月历仅在空间不足时滚动，六周月份与尺寸变化后仍可完整浏览日期。

本版为 1.8.3（build 76，2026-10-13），支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。492 项 Swift 测试通过，24 项按需或环境跳过，零失败；21 项 Python 质量检查、27 项日历定向检查和四个真实窗口合成场景通过。详细验证与待验收范围见 [1.8.3 发行说明](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.8.3)。

## 1.8.2：更连贯的音乐操作与紧凑日程

- 音乐页新增同步歌词，暂停、重开和调整尺寸后仍定位到当前行；歌词与进度条同时可见。
- 点击红心收藏或取消收藏网易云音乐的当前歌曲。需在系统设置中允许辅助功能权限；确认播放器实际状态后更新红心。
- 收藏等待时保留心形；播放按钮和进度条不再因短暂请求一起置灰闪动。
- 减少标准、紧凑弹窗中的无效留白，未来安排独立滚动；「查看全部」展示完整日程和标题，空日程展示全宽月历。

本版为 1.8.2（build 75，2026-10-13），支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。492 项 Swift 测试通过，23 项按需或环境跳过，零失败；21 项 Python 质量检查与 31 项音乐定向检查通过。最终实机复验尚未完成，详细范围见 [1.8.2 发行说明](RELEASE_NOTES.md)。

## 1.8.1：关闭打卡提醒立即生效

- 关闭「启用打卡提醒」后，刘海胶囊与提醒弹窗立即隐藏，并停止新提醒；唤醒、跨日及重启后保持关闭。
- 兼容旧版已保存的关闭状态。已有待打卡记录保留，重新开启后继续处理；已完成的打卡不会重复出现。
- 开关说明明确登录启动和关闭后的行为，关闭时禁用时间设置。

本版为 1.8.1（build 74，2026-10-13），支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。473 项 Swift 测试通过，23 项按需或环境条件跳过，零失败；21 项 Python 质量检查与 14 项打卡定向测试通过。下载、校验与待验收范围见 [1.8.1 发行说明](RELEASE_NOTES.md)。

## 1.8.0：刘海窗口大小可调，内容随窗口排布

- 默认展开尺寸为 520 × 390 点，面积比之前缩小约 27%；支持紧凑、标准、宽敞及自定义尺寸。
- 在「设置 → 通用设置 → 刘海窗口大小」调整宽高，或通过刘海右上角双向箭头切换预设。调整立即生效，重启与本地备份恢复后保留。
- 日历按宽度切换单栏与双栏，优先展示日期和当天安排；文件、专注、便笺和音乐页面均自适应，切换页面不会撑大窗口。

本版为 1.8.0（build 73，2026-10-13），支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。467 项 Swift 测试通过，24 项按需或环境条件跳过，零失败；21 项 Python 质量测试通过。下载、校验与待验收范围见 [1.8.0 发行说明](RELEASE_NOTES.md)。

![1.8.0 紧凑尺寸界面预览](images/notch-size-1.8.0-preview.png)

预览由使用隔离数据的原生 SwiftUI 界面捕获后合成背景，不是实体屏幕实拍。

## 1.7.5：恢复刘海中间悬停，修复专注倒计时裁切

- 音乐播放时，实体刘海中间区域恢复悬停展开；封面与律动双圆仍需点击打开，移开指针后浏览面板在宽限结束时收起。
- 紧凑专注倒计时限定在右侧肩部内，避免展开再收起后时间文字及胶囊边缘被裁切。

本版为 1.7.5（build 72，2026-10-12），支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。按用户明确要求立即发布，跳过发行回归、安装包检查与 SHA-256 核验；专注布局修复后未重新运行测试，不宣称上述检查通过。详见 [1.7.5 发行说明](RELEASE_NOTES.md)。

## 1.7.4：音乐仅点击打开，日历按时收起

- 紧凑音乐封面与律动仅点击打开，悬停不再弹出播放器。
- 实体刘海旁的点击范围收紧到可见的两个圆圈，透明肩部和圆角不再拦截菜单栏操作；指针快速移动时也会及时更新点击范围，避免误开面板。
- 启用悬停打开时，点击音乐再切换日历，移开指针或停在相邻菜单栏控件上，会在移出宽限后收起。
- 便笺、文件和专注编辑、全局「仅点击打开」模式，以及原生子弹窗、sheet 和模态对话框仍保持持续操作会话。

本版为 1.7.4（build 71，2026-10-12），支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。实体屏幕、真实桌面帧率、能耗与静置性能、真实播放器兼容性、VoiceOver、钥匙串弹窗、真实付款激活及休眠唤醒与登录行为仍待验收，详见 [1.7.4 发行说明](RELEASE_NOTES.md)。

## 1.7.3：刘海操作更连贯，收起后继续编辑

- 悬停展开后短暂移出会留出宽限；点击面板后可持续操作，移开指针不再中断编辑，点击外部、按 Esc 或关闭按钮收起。
- 展开约 0.32 秒、收起约 0.24 秒，切页以 0.14 秒淡入；窄屏导航固定使用图标，切换时不改变按钮宽度。
- 完整收起后再次展开，便笺保留选区与独立撤销记录，文件保留选中项和滚动位置；外部更新便笺时清理旧撤销，兼顾输入法组合。
- 文件打开、复制或子目录读取失败时显示可关闭提示，保留当前目录；收起父目录或切换目录后，过期读取不再写回。
- 文件列表支持方向键浏览、左右展开与收起、Home/End、回车打开、⌘C 复制，以及 Tab/Shift-Tab 切换焦点；隐藏页面不截获按键。

本版支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。真实桌面帧率与能耗、实体屏幕及真实播放器兼容性等仍待验收，详见 [1.7.3 发行说明](RELEASE_NOTES.md)。

## 1.7.2：更紧凑、清晰的刘海面板

- 音乐页按内容调整高度，去除播放器下方的大块空白。封面、歌曲信息和播放控件重新整理间距，专辑名与曲名相同时不再重复显示。
- 标准宽度下的导航带文字，按钮统一悬停、按下、焦点与禁用反馈；半透明面板减少壁纸染色，文字和控件更清楚。
- 切换页面保留日历、文件浏览状态，以及便笺的选区和撤销记录。

本版支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。下载与验证范围详见 [1.7.2 发行说明](RELEASE_NOTES.md)。

## 1.7.1：更连贯的刘海展开与收起

- 外壳先展开，内容稍后淡入，配合轻微缩放与下移；收起时内容先淡出，轮廓平稳回收。
- 快速反复开关可从当前轮廓连续衔接，收起末尾不再过度挤压；隐藏的编辑器退出输入焦点。
- 系统「减少动态效果」开启时只淡入淡出，不移动或缩放内容。

本版支持 macOS 15+、Apple 芯片与 Intel，采用 ad-hoc 签名，需手动安装，未进行 Developer ID 签名或 Apple 公证。验证范围详见 [本版发行说明](RELEASE_NOTES.md)。

## 1.7.0：刘海旁的音乐播放器

- 播放音乐时，封面与轻柔律动分别出现在刘海两侧。会议与专注优先；可在设置中关闭「在刘海旁显示音乐」。
- 打开刘海中的「音乐」，查看系统正在播放的歌曲、歌手、专辑、封面和来源播放器；支持上一首、播放/暂停、下一首，以及播放器允许的进度调整。
- 在封面与歌曲区域横向滑动也可切歌；按钮与空格播放/暂停仍可使用。系统「减少动态效果」下，律动保持静态。

律动是播放状态的装饰动画，不是真实音频波形；本版不显示未经播放器确认的无损、杜比全景声或独占标签，也不提供锁屏音乐小组件。Apple Music、Spotify 等真实播放器的兼容性仍待实际播放验收，当前不能把受控演示播放等同于这些软件的完整兼容验证。详见 [本版发行说明](RELEASE_NOTES.md)。

![刘海音乐播放器](images/notch-music.png)

音乐界面来自按内容高度捕获的原生窗口合成结果，歌曲与封面均为示例，不代表实体刘海或真实播放器兼容性验收。

## 1.6.22：更清晰的日常工作与购买流程

- 今日页优先呈现下一场会议、专注与便笺入口和可用专注时段；资讯可按需添加，已保存的显隐选择继续保留。
- 小窗口仍能并排查看月历与当日日程；主要按钮更清晰，刘海长会议标题可显示两行并悬停查看全文。
- 「购买买断」「付款后领码」「已有授权码」各有直接入口；付款前说明 ¥9.9 永久使用、未来更新及人工领码流程。

| 今日工作台 | 小窗口日历 |
| --- | --- |
| ![今日页突出下一场会议、专注和便笺](images/workspace-today.png) | ![小窗口中的月历与所选日期日程](images/workspace-calendar-compact.png) |

### 刘海旁的独立状态岛

专注图标与倒计时、会议标题与进度分别出现在刘海两侧，中间留空，不再连成一整条黑色宽块。

| 专注计时 | 会议进行中 |
| --- | --- |
| ![刘海两侧独立的专注图标圆岛和倒计时胶囊](images/compact-focus-islands.png) | ![刘海两侧独立的会议标题胶囊和进度圆岛](images/compact-meeting-islands.png) |

原生紧凑视图采用隔离演示数据，菜单栏与实体刘海为合成示意背景，非实拍。

![展开的刘海日历与四项功能菜单](images/notch-calendar.png)

## 从刘海展开

悬停或点击顶部入口展开面板，再通过功能栏切换 **日历、专注、便笺、音乐、计算器、剪贴板、AI 聊天、行情和资讯**；在设置中启用文件浮窗后，还可从 **文件** 页面浏览收藏目录。入口较多时使用「更多工具」菜单。剪贴板记录需单独开启，AI 聊天需配置服务。无刘海的外接显示器使用顶部居中入口。

下方功能截图来自较早版本；2.0.10 保留顶部或底部功能栏选择，默认底部，新增行情和资讯，工具继续共用日历页面的窗口尺寸。

| 日历 | 专注 |
| --- | --- |
| ![刘海日历和今日安排](images/notch-calendar.png) | ![刘海专注菜单](images/notch-focus.png) |
| 文件（需启用） | 便笺 |
| ![刘海文件浮窗中的演示文件](images/notch-files.png) | ![刘海便笺菜单](images/notch-scratchpad.png) |

## 深浅色与毛玻璃

完整工作台可选浅色、深色或跟随系统，也可在设置中启用半透明毛玻璃材质。展开的刘海面板跟随所选外观；紧凑刘海保留深色以贴合摄像头区域。

| 浅色工作台 | 深色工作台 |
| --- | --- |
| ![浅色日历工作台，半透明材质设置](images/workspace-light-glass.png) | ![深色日历工作台，半透明材质设置](images/workspace-dark-glass.png) |

图片来自原生 SwiftUI 视图的离屏渲染，使用隔离演示日程、文件和笔记；不包含实体刘海或桌面背景，不能展示真实桌面上的折射效果。

## 1.6.21：对称胶囊与安静的打卡提醒

- 左右圆形胶囊统一尺寸、间距和居中位置；打卡胶囊显示待处理数字红点，超过 2 项时轻柔闪烁，系统「减少动态效果」下保持静态。
- 打卡详情仅手动点击胶囊展开，启动、唤醒和新待办均不自动弹窗，全部完成后隐藏。

## 1.6.20：打卡只需收起或完成

- 打卡弹窗移除「移除」按钮，只保留「收起提醒」与「完成」。新版完成后即使修改当天时段也不会重复弹出；旧版被清掉的空白打卡记录，在修改时段且当前时间落入新时段时可重新出现。

## 1.6.19：更紧凑的打卡弹窗

- 弹窗高度随打卡事项数量变化，不再为单条提醒留下大块空白。「收起提醒」只隐藏弹窗，胶囊仍保留待办；「移除」清除对应打卡，操作与「完成」清楚区分。

## 1.6.18：打卡稳定性修复

- 修复 macOS 在后台线程发送跨日通知时可能导致 1.6.17 退出的问题；早晚打卡和会议唤醒提醒现在会在主线程处理通知。

## 1.6.17：早晚打卡提醒

- 刘海左侧新增打卡胶囊；默认早间 08:00–10:00、晚间 18:00–20:00，在应用启动、电脑唤醒或持续运行进入时段时弹出。待办会保留到完成或手动移除，关闭弹窗后仍可点击胶囊查看。
- 在「设置 → 通用 → 打卡提醒」调整早晚时间；已安装应用默认请求登录时启动，可在设置中关闭，macOS 可能要求在登录项中批准。

## 1.6.15：专注控制与胶囊交互

- 运行或暂停专注时，可在刘海专注面板点击「取消」结束计时并收起专注胶囊；取消不计入已完成专注。
- 专注和会议双侧胶囊显示期间，点击胶囊才展开面板；空闲时仍按原有悬停或点击设置操作。

## 1.6.14：刘海状态岛与工作台

- 紧凑状态分别显示在刘海两侧；工作台可选择浅色、深色和毛玻璃材质。
- 更新日历、专注、文件及工作台交互，补充离线诗笺与私密收藏入口。

## 1.6.13：刘海展开与窗口适配

- 日历数据在刘海展开过程中刷新时，展开窗口不再突然改变高度；中途收起或重新展开时旧动画不会继续拉动窗口。
- 矮屏下可以滚动查看展开内容，窄屏下可横向滚动，顶部功能入口保持可用。
- 以下购买、试用与数据保护功能沿用 1.6.12：

- 免费试用期间正常使用；仅在最后 48 小时显示一次可关闭的到期提醒，侧栏可查看截止时间。
- ¥9.9 一次买断包含未来所有版本更新，无订阅；付款码须主动展开，付款后需发送凭证与安装标识人工领码，不会自动激活。
- 到期后仍可只读查看本地便笺、会议笔记、专注记录和文件位置并导出普通备份；私密收藏单独通过系统认证并导出未加密文件。
- 工作台侧栏可隐藏/恢复；打赏不等于买断或激活。

## 个人工作台

- **今日诗笺**：14 条离线古典诗句，每日轮换，可换一句、收藏和收起。
- **私密收藏**：系统身份验证后访问本机加密的网站收藏，支持搜索、置顶和编辑；离开页面、切换应用或窗口、锁屏和休眠时自动锁定。
- **按需上手**：从设置主动打开上手引导，选择查看日历、开始专注或收藏诗句中的一个目标。
- **按需显示资讯**：在侧栏或设置隐藏不用的资讯模块，快捷键和搜索入口同步调整。
- **领码更方便**：复制所需资料，或打开预填邮件后附上付款凭证并自行发送；已激活用户也能自愿打赏。

私密收藏不包含在普通 JSON 备份内，到期后仍需通过系统身份验证才能单独导出；导出的文件未加密，应妥善保管。本机加密收藏仍需保留钥匙串密钥。打开网站仍使用默认浏览器，浏览器可能记录历史。详见 [本版发行说明](RELEASE_NOTES.md)。

## 下载与使用

要求 macOS 15 或更新版本，支持 Apple 芯片与 Intel Mac。下载 DMG 后将应用拖入「应用程序」，打开应用开始使用。

采用闭源发行。新用户首次启动自动开始 **7 天免费试用**，不先展示收款二维码；试用结束后需要永久授权码，但仍可只读查看并导出本地数据。一次支付 **¥9.9**，永久使用，**包含未来所有版本更新，无订阅**。已激活用户不再自动弹出收款窗口。

历史 MIT 版本不受新的付费规则追溯影响。请以所下载版本的发行说明为准。

## 支持作者与永久激活

1. 在工作台侧栏「授权与试用」（或设置中的同名入口）选择「购买买断」，了解步骤并主动展开付款码后扫码支付 ¥9.9。
2. 选择「付款后领码」，复制领码资料或打开预填邮件，附上付款凭证后自行发送给作者。
3. 作者收到完整付款凭证和安装标识后通常 24 小时内回复授权码；选择「已有授权码」，粘贴并按回车激活。付款不会自动开通。

![永久买断说明及购买、领码、激活三个入口](images/license-purchase.png)

联系邮箱：**498988598@qq.com**；手机：**13191513539**。

收到完整付款凭证和安装标识后，通常 **24 小时内回复**。换机或重装可凭购买记录免费补发，不设年度次数限制，仅限本人使用。已付款但未收到或丢失授权码，请回复原邮件并提供凭证和当前安装标识，无需再次付款。

![微信扫码购买永久授权（¥9.9，需人工领码）](images/payment.png)

授权码在本机离线验证，绑定安装标识。从 2.0.7 起，永久授权保存在本机应用数据目录；替换或重装应用且保留应用数据时可继续使用，不包含在普通设置备份内。旧永久授权会从钥匙串迁移，原记录保留；若系统阻止读取，请在「授权与试用」点击「重试读取授权」允许一次访问。试用记录仍保存在 macOS 钥匙串中，不会因升级重新计时。换机或丢失原安装记录时，请联系作者补发。

## 数据与权限

日历通过系统 EventKit 访问；便笺和专注记录保存在本机。日历、通知等权限按功能需要申请。公开资讯与更新检查需要网络；付款由微信处理，应用不会自动核实到账或读取支付账户。

本仓库只保存公开说明、必要图片与许可证说明。安装包通过 Releases 发布。
许可条款见 [LICENSE](LICENSE)，历史 MIT 声明见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
