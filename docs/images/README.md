# README 界面配图

这些文件随仓库一起保存，README 不依赖本机绝对路径或外部图床。主文档展示 13 张原生界面图，另有 1 张应用图标；日程、笔记、任务和配置为隔离的演示数据。中文和英文文档共用图片，应用本身支持两种语言。

## 来源与范围

| 图片 | 来源 | 说明 |
| --- | --- | --- |
| `workspace.png` | `WorkflowCaptureTests` / `MainWorkspaceView` | 2026-09-06 导出，完整桌面工作台 |
| `notch-expanded.png` | `WorkflowCaptureTests` / `CalendarDashboardView` | 展开的刘海内容组件；不含实体摄像头或桌面背景 |
| `focus.png` | `WorkflowCaptureTests` / `FocusWorkspaceView` | 当前专注界面，演示任务标签 |
| `calendar-search.png`、`event-composer.png` | `WorkflowCaptureTests` | 日程搜索、第二时区与周期日程创建 |
| `meeting-controls.png`、`meeting-notes.png` | `WorkflowCaptureTests` | 会议操作卡片与单场会议笔记 |
| `weekly-review.png` | `WorkflowCaptureTests` | 隔离的演示完成记录，不是作者个人统计 |
| `backup-preview.png` | `BackupCaptureTests`，2026-09-05 导出 | 实际恢复预览组件，使用演示备份 |
| `radar.png` | 2026-09-05 原生 Radar 界面导出 | 当时取得的公开 Hacker News 内容，非实时状态 |
| `markets.png` | v0.6.0 原生行情页面导出 | 未连接数据源的设置状态，无密钥或虚构报价 |
| `discussion.png`、`briefing.png` | v0.6.0 原生页面导出 | 历史公开内容缓存；私人笔记位置使用明确的演示文本 |
| `app-icon.png` | 项目现有应用图标 | 品牌图标 |

图片直接复制自原生渲染结果，未重绘界面按钮或替换界面文字。精确原始路径与 SHA-256 记录在 [sources.json](sources.json)；其中 `.build/` 与部分 `marketing/` 原始目录是本地生成产物，不要求克隆仓库后存在。

这些图片用于说明界面，不作为真实通知投递、热键、账户同步或系统小组件的实机验收证据。资讯画面的日期、标题和热度只反映导出时的公开内容。

## 重新生成核心界面

在 macOS、完整 Xcode 与可用图形会话中，从仓库根目录运行：

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
NOTCH_WORKFLOW_CAPTURE_PATH="$PWD/.build/readme-captures" \
swift test --filter WorkflowCaptureTests
```

该导出使用生产 SwiftUI 视图，日历、通知、热键及偏好设置使用隔离测试对象，不读取私人日程、不加入会议、不注册真实快捷键。会同时导出中英文与多种宽度；背景在原生渲染时填充，避免 GitHub 浅色主题下透明区域中的文字不可读。

备份页面可通过下列命令重新生成：

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
NOTCH_WORKFLOW_CAPTURE_PATH="$PWD/.build/readme-captures" \
swift test --filter BackupCaptureTests
```

选择生成的对应图片复制到本目录，检查截图内容和图片尺寸，再同步更新 `sources.json` 中的来源与 SHA-256。无需发布新的应用版本即可更新文档。
