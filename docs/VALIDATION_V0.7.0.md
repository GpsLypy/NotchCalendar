# Notch Calendar 0.7.0 验证报告

验证日期：2026-09-05。发布前本地验证快照，版本 0.7.0，构建号 18。公开构建和发布状态见 [v0.7.0 Release](https://github.com/GpsLypy/NotchCalendar/releases/tag/v0.7.0)。本版继续免费，不增加账号或功能授权门槛。

## 已通过

- 完整 Xcode 环境 Debug 编译与统一测试：149 项中 146 项通过，3 项需显式开启的实时来源或原生渲染测试按设计跳过，零失败。
- 功能开发阶段单独启用 PlanningCaptureTests 并通过：使用模拟日历和独立偏好设置，渲染 647 / 980 点宽的中英文时间规划、专注界面，以及全隐藏状态和日历来源设置，共 10 张图像；未读取用户的真实日历。
- 日历来源筛选、全部隐藏、权限撤销、相邻日期缓冲、相邻及重叠日程、夏令时、过期推荐均有确定性覆盖。
- 专注迁移、立即暂停保护、暂停恢复、重启完成一次、按完成日期归属日/周、1,000 条历史上限，以及 CSV 实际读写和失败均有覆盖。
- 小组件旧快照兼容、五分钟专注/休息区分、立即暂停状态和 180 分钟计时完成新增 4 项回归检查。
- Release 主应用、更新器、小组件全部包含 arm64 与 x86_64；应用与小组件版本一致为 0.7.0 (18)。
- 嵌套签名、DMG 校验及只读挂载通过；Applications 快捷方式正确指向 /Applications；ZIP 完整性通过，其主程序内容与 DMG 一致。
- 打包资源中的中英文字符串、版本文件格式以及 git diff --check 通过。

## 发布前修正

发布审查发现桌面小组件缺少专注/休息类型和已开始会话标记。现将真实状态传入共享快照，正确显示休息及刚开始就暂停的计时器；旧版快照缺失新字段时保留兼容行为。

## 当前验收边界

- 日历仍为只读；推荐时长只准备计时器，不自动启动或写入系统日程。全天日程不会占用本轮空档计算，界面明确说明这一点。
- 专注完成分钟按完成日期计入；睡眠期间也经过计时时间，记录不代表实际劳动量。
- 真实 iCloud/Google/Exchange 账户切换与重新授权、实体 Mac 休眠/跨屏、系统保存面板完整点击尚未作为本轮发布的实机验收完成。离屏渲染与纯逻辑测试不等同于这些检查。
- 安装包沿用 ad-hoc 签名的手动安装渠道，未做 Developer ID 公证，自动替换安装仍关闭。本报告记录本地产物；GitHub 工作流会独立重建、验证并发布，公开产物校验和可能不同。

## 可复现命令

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
NOTCH_PLANNING_CAPTURE_PATH="$PWD/.build/planning-review" DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter PlanningCaptureTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ALLOW_ADHOC_RELEASE=1 Scripts/create_release.sh 0.7.0
Scripts/extract_release_notes.sh 0.7.0 dist/release-notes-0.7.0.md
```

## 本地安装包 SHA-256

```text
5fc738d6fcb79b7c5d20555172b34d1f080e586b034802f708ac3816c8a0bd7c  NotchCalendar-0.7.0-macos.dmg
2e27b8ef58dfcbba9928e0c303656339a3c84383b14716a2928676f2a9620ef9  NotchCalendar-0.7.0-macos.zip
```
