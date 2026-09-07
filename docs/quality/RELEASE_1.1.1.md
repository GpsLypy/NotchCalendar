# Notch Calendar 1.1.1

版本 1.1.1（build 24），支持 macOS 15+、Apple 芯片和 Intel。仅 ad-hoc 签名，无 Developer ID 签名或 Apple 公证；通过 DMG 手动替换安装。

默认工作台增大为 1120×780，月历与日程并排显示。旧的小窗口首次按当前屏幕可用空间放大，之后保留手动调整的尺寸。刘海日程竖线现在跟随文字高度，全天日程不再出现贯穿面板的长红线。

## 验证

- [Swift 回归](evidence/swift-tests-1.1.1.log)：235 项中 228 通过、7 项可选测试跳过、0 失败，包含原生键盘检查。
- [发布工具检查](evidence/release-gate-tests-1.1.1.log)：20 项通过。
- [原生截图](../images/v1.1.1/README.md)：宽幅月历及全天日程竖线已复核；截图使用虚构日程，不读取个人日历。
- [安装包核验](evidence/package-1.1.1.json)：主程序、更新器和小组件均含 arm64 与 x86_64；版本 1.1.1（24）一致，ad-hoc 签名、DMG 挂载、ZIP CRC、快捷指令元数据及 Applications 链接检查均通过。
- 云端独立测试、构建与上传结果见 [Release 工作流](https://github.com/GpsLypy/NotchCalendar/actions/workflows/release.yml)，发布附件包括 DMG、ZIP 与 SHA256SUMS。

最终性能、实际悬停/休眠唤醒及外接屏/跨屏验收仍为 pending，不用旧版结果替代。按所有者本次“发布新版本”的明确要求发布，待验收项和例外绑定当前运行代码指纹，详见 [1.1.1 验收记录](1.1.1.json)。严格检查仍可用：`python3 Scripts/quality/verify_release_gate.py 1.1.1 --strict`。
