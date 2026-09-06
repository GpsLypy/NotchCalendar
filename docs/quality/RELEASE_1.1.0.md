# Notch Calendar 1.1.0

版本 1.1.0，构建号 23。支持 macOS 15 及以上、Apple 芯片与 Intel。发行包采用 ad-hoc 签名和手动安装，不做 Developer ID 证书签名或 Apple 公证。

## 本次迭代

工作台统一为石墨灰底色，清楚区分主内容、侧栏与卡片，使用克制的强调色。桌面月历使用独立的自适应布局，让月份网格和所选日期的安排随窗口分配空间，修整旧版蓝色框架与黑色日历内容拼接的不协调感。

启动默认保持日历收缩态，主动打开工作台时从日历开始。上次的暂停计时器不再自动占据刘海：包括用户反馈的 49:20，会保留原任务、剩余时长和历史。本次主动开始或恢复专注后才显示活动，同次暂停仍保留入口；恢复前仍在运行的专注继续在后台完成，不抢占窗口或键盘焦点。

会议继续使用相同的启用状态、有效性筛选与优先规则。今日时间轨道、笔记、快捷键和本地数据约束保持一致，没有新增活动种类。

## 验证记录

| 范围 | 当前记录 |
| --- | --- |
| Swift 完整回归 | [232 项：226 通过、6 项可选测试跳过、0 失败](evidence/swift-tests-1.1.0.log)，包括原生键盘、任务输入空格、恢复计时与日历选择 |
| 启动与保存的专注 | [两轮原生窗口状态探针通过](evidence/startup-1.1.0.json)：恢复暂停 49:20 和运行中的计时后，均选择日历并保持收缩、不获取键盘焦点 |
| 中英文界面 | [双语宽窄窗口、六行月份、今日、专注与刘海截图](../images/v1.1.0/README.md)已复核；截图使用本地合成日程 |
| 发布门槛与 CPU 计量工具 | [20 项 Python 检查通过](evidence/release-gate-tests-1.1.0.log) |
| 双架构主程序、更新器、小组件 | [arm64 + x86_64 均通过](evidence/package-1.1.0.json)，主程序和小组件版本同为 1.1.0（23） |
| 本地 DMG/ZIP、签名和快捷指令元数据 | [DMG 挂载、ZIP CRC、App Intents、应用程序链接均通过](evidence/package-1.1.0.json)；三个组件均为 ad-hoc，无证书签名 |
| 公开下载附件 | 发布流程重新构建并验证安装包，上传 DMG、ZIP 和 SHA256SUMS；结果见 [Release 工作流](https://github.com/GpsLypy/NotchCalendar/actions/workflows/release.yml) |
| 最终解锁性能与部分实机项目 | pending；详见 [1.1 验收记录](1.1.0.json) |

窗口探针运行时显示器可见状态为 false，仅证明原生窗口和模型状态，不视为物理交互或性能通过。短时样本未观察到后台计时逐秒递减；截止时间完成逻辑由回归测试覆盖。未完成的项目继续保持 pending，1.0 样本不作为当前代码的验收结果。

## 已知验收限制

最终源码的静置、专注运行与会议切换需要两轮有效解锁采样；物理悬停、实际休眠唤醒、普通显示器及跨屏验收仍待完成，当前没有外接显示器。自动化测试和合成唤醒通知不替代这些实机项目。

本次所有者要求打磨后发布。发布决定和质量通过分别记录；如最终仍有待验收项，例外必须逐项绑定本版本、运行代码指纹及用户原话，不继承 1.0 例外，也不能覆盖实测失败。用下列命令查看完整未通过项：

```sh
python3 Scripts/quality/verify_release_gate.py 1.1.0 --strict
```

## English

Version 1.1.0 (build 23) brings a consistent graphite workspace and a dedicated responsive desktop month calendar. Cold launch stays on the collapsed calendar. Saved focus tasks, remaining time and history are preserved; only an explicit start or resume in the current launch promotes focus to a notch activity. Previously running sessions still complete in the background, and meeting priority is unchanged.

This manual-install release uses ad-hoc signatures only, with no Developer ID signing or notarization. Final performance and some physical hardware acceptance remain pending. Any publication exception is bound to this version, runtime fingerprint, the owner's recorded request and the exact outstanding checks; it cannot hide a measured failure or reuse an earlier release's authorization.
