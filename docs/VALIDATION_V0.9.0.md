# 0.9.0 发布验证

2026-09-06，版本 0.9.0，构建 21，支持 macOS 15+、Apple 芯片与 Intel。本版包含今日时间轨道、刘海专注活动、⌘K 快速入口和蓝灰工作台配色。

## 测试与原生界面

使用完整 Xcode 工具链运行 220 项测试，215 项通过、5 项按需跳过、0 失败。本轮显式启用两个新的原生体验测试；跳过项为原有需要单独开启的截图或真实资讯源检查。

原生交互验证实际创建隔离测试窗口，覆盖 ⌘K 打开、中文查询、回车打开页面、方向键导航、暂停／继续当前计时、搜索日程后转入会议笔记、Esc 关闭。共导出 17 张中英文界面图，覆盖 860/1120 点窗口、完整刘海展开、两种紧凑显示、空结果、密集重叠与隐藏日历来源。

逻辑测试覆盖区间边界、30 个并发日程、夏令时的 23/25 小时日、重复场次身份、被拒绝／取消日程、双语多词搜索、会议与专注活动优先级、暂停后重启及单次完成记录。测试使用合成日程与独立本机配置，不读写用户的真实日历。

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
NOTCH_DESK_INTERACTION=1 \
NOTCH_DESK_CAPTURE_PATH="$PWD/.build/release-0.9.0-review" swift test
```

默认 `swift test` 不开启临时界面窗口，两个新增界面测试也会按需跳过。

## 安装包

`ALLOW_ADHOC_RELEASE=1 Scripts/create_release.sh 0.9.0` 成功生成 DMG 和 ZIP。已挂载本地最终 DMG 并验证：

- 主程序、更新器、小组件均包含 `arm64` 与 `x86_64`。
- 应用与小组件版本均为 0.9.0 (21)，嵌套签名校验通过。
- 四个原生 App Intents 与 App Shortcuts 元数据及参数校验通过。
- DMG 校验和、Applications 快捷方式、ZIP CRC 正常；DMG 与 ZIP 主程序字节一致。
- 两种语言资源、版本声明与 `git diff --check` 检查通过。

本地包 SHA-256：

```text
DMG fc553bdd3d63e2851a3b701e041548a3c715be88de867c24cbe29992f2c3cb39
ZIP e4f4f7745d885767e9508aef753725f59d7144972a75d9c7750c7f1fe7c2b23d
```

公开包由 [GitHub Actions](https://github.com/GpsLypy/NotchCalendar/actions/workflows/release.yml) 对发布标签重新运行测试、构建并核验，因此公开附件的校验和以 [v0.9.0 发布页](https://github.com/GpsLypy/NotchCalendar/releases/tag/v0.9.0) 为准。

## 分发与实机边界

继续采用 ad-hoc 签名与手动安装，未进行 Developer ID 公证。打开 DMG，退出旧版，将应用拖入 Applications 后重新打开。

实体刘海跨屏位置与悬停、真实休眠、系统通知和账户同步需要在实际设备上验收；自动测试、原生窗口事件和离线图像不能替代这些系统环境检查。功能说明与演示图见[体验审视](EXPERIENCE_REVIEW_2026-09-06.md)。
