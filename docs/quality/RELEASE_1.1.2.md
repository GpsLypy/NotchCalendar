# Notch Calendar 1.1.2

版本 1.1.2（build 25），支持 macOS 15+、Apple 芯片和 Intel。仅 ad-hoc 签名，无证书签名或 Apple 公证，通过 DMG 手动替换安装。

- 刘海展开顶部新增“主界面”按钮，日历和专注页共用。点击收起刘海、打开日历主窗口并恢复程序坞图标。
- 关闭主窗口后切换为后台应用，刘海、提醒与专注继续运行；再次打开主窗口恢复程序坞图标。手动固定在程序坞的快捷方式由用户管理。
- 统一过滤已取消日程，包括来源仅在标题前标记“已取消：”的情况，不删除原始日历数据。

## 验证

- [Swift 回归](evidence/swift-tests-1.1.2.log)：237 项中 228 通过、9 项可选测试跳过、0 失败，包含取消日程过滤及原生截图生成。
- [主界面入口截图](../images/v1.1.2/notch-main-entry.png)已复核。离屏截图和模型测试不替代实际 Dock/窗口切换验收。
- [发布工具检查](evidence/release-gate-tests-1.1.2.log)：20 项通过。[安装包核验](evidence/package-1.1.2.json)：主程序、更新器与小组件均为 arm64 + x86_64，版本 1.1.2（25）一致；ad-hoc 签名、DMG 挂载、ZIP CRC、快捷指令元数据和 Applications 链接通过。
- 云端测试、构建和附件上传见 [Release 工作流](https://github.com/GpsLypy/NotchCalendar/actions/workflows/release.yml)。

最终性能与物理显示器验收继续为 pending，不引用旧版结果作为通过证据。本次按所有者“改完发个新版本”的明确请求发布，具体待验收项绑定本版源码，见 [质量记录](1.1.2.json)。严格检查：`python3 Scripts/quality/verify_release_gate.py 1.1.2 --strict`。
