# Notch Calendar 1.2.0

版本 1.2.0（build 26），支持 macOS 15+、Apple 芯片和 Intel。沿用仅 ad-hoc 签名、无 Developer ID 或 Apple 公证的 DMG 手动安装流程。

- 侧栏底部集中提供 GitHub、分享、设置、检查更新四个入口。
- 分享弹窗展示刘海日历宣传海报，提供复制图片、保存 PNG 和复制项目链接，支持中英文。
- 宣传图使用示例日程，导出分辨率为 1200 × 880。
- 检查更新复用现有更新逻辑，在设置页面显示检查结果。

## 验证

- 完整 Xcode 工具链下 Swift 编译通过，238 项测试中 228 项通过、10 项可选测试跳过，零失败。
- `ShareCalendarPosterTests` 在中英文下调用实际海报渲染器，验证导出 PNG 可重新解码、尺寸为 1200 × 880。
- 中英文资源通过 `plutil -lint`，代码通过 `git diff --check`。
- 系统默认 Command Line Tools 缺少 SwiftUI 宏插件；本地验证使用 `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`。
- 云端测试、Universal 2 打包、签名及 DMG 挂载检查和附件上传由 [Release 工作流](https://github.com/GpsLypy/NotchCalendar/actions/workflows/release.yml)执行，最终结果以该版本运行记录为准。

## 待验收

原生窗口的分享/保存/设置点击流程、最终性能采样以及物理显示器与跨屏验收尚未完成。测试和海报渲染结果不替代这些检查。

依据所有者本次“发布新版本”的请求发布；本版记录绑定当前运行代码指纹，保留确切待验收项，不复用旧版本的发布例外，也不宣称性能门槛已通过。见 [1.2.0 质量记录](1.2.0.json)。严格检查命令：`python3 Scripts/quality/verify_release_gate.py 1.2.0 --strict`。
