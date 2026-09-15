# Notch Calendar 1.4.1

版本 1.4.1（build 30），支持 macOS 15+、Apple 芯片和 Intel。沿用仅 ad-hoc 签名、无 Developer ID 或 Apple 公证的 DMG 手动安装流程。

- 文件浮窗工具栏新增打开、复制和访达定位操作，选中文件后立即可用。
- 支持 Return 打开和 `⌘C` 复制；复制写入标准 macOS file URL，可粘贴到访达或其他应用。
- 刘海 SwiftUI 宿主接收 AppKit first-mouse，第一次点击即可传入控件。
- 文件行单击选择不再等待双击识别，双击打开行为保持不变。
- 默认悬停确认由 350ms 降至 140ms，展开动画由 320ms 降至 200ms。
- 设置新增快速、平衡、防误触三档；快速档约 70ms 确认和 180ms 展开。

## 验证

- 完整 Xcode 工具链下，Swift 编译与 258 项测试完成：248 项通过、10 项可选测试跳过、零失败。
- 文件架 11 项测试覆盖 Finder 兼容 file URL 剪贴板、first-mouse、1,000 项目录读取及既有多目录行为。
- 原生刘海键盘/展开测试和文件浮窗工具栏离屏渲染通过。
- 1,000 项目录元数据扫描耗时 0.109–0.159 秒，预算 2 秒。
- 当前源码指纹下，idle、focus、meeting-switch 均取得两次独立、无鼠标输入、屏幕可见且不中断的优化样本，并通过固定 CPU/p95/interrupt wakeups 预算。
- Universal 2 打包、ad-hoc 签名、DMG 挂载核验和上传由 [Release 工作流](https://github.com/GpsLypy/NotchCalendar/actions/workflows/release.yml)执行，最终结果以该版本运行记录为准。

## 待验收

自动化 first-mouse 与剪贴板验证不替代实体刘海上的第一次点击、实际访达粘贴、三档悬停手感、跨应用拖放、外接屏和休眠唤醒验收。最终性能预算已经通过，不再列为待完成。

依据所有者本次“发布新版本”的请求发布；验收记录绑定当前运行代码指纹并保留确切硬件待验收项，不继承旧版本发布例外。见 [1.4.1 质量记录](1.4.1.json)。严格检查命令：`python3 Scripts/quality/verify_release_gate.py 1.4.1 --strict`。
