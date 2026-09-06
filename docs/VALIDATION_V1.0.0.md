# 1.0.0 发布验证

2026-09-06，版本 1.0.0，构建 22，支持 macOS 15+，Apple 芯片与 Intel。

## 发布决定与验收边界

项目所有者在获知未完成项后再次要求发布 1.0。本版据此发布，保留[原始验收记录](quality/1.0.0.json)的 pending 状态。该记录单独列出只适用于 1.0.0 当前运行代码指纹的发布例外，不把未完成检查写成通过，也不沿用到后续版本。

最终解锁性能采样、最终构建的内置屏交互复核、完整悬停路径、实际休眠唤醒、普通显示器及跨屏验收仍待完成；本版不宣称已经通过这些验收。详情与早期样本在[质量报告](quality/README.md)。

## 已完成的检查

- 标准 Swift 回归：227 项中 218 项通过、9 项需显式启用的实机、截图或联网测试跳过、0 失败。
- Python 发布门槛与 CPU 计量检查：12 项通过。覆盖发布例外不会改变严格检查结果、不能用于其他版本、不能覆盖实测超预算、运行代码或待验收列表变化后失效。
- 将实际调用 Finder 打开不存在 DMG 的测试改为 `NOTCH_WORKSPACE_OPEN_INTEGRATION=1` 显式启用，避免常规回归显示系统错误对话框。后台成功与失败回调测试仍默认执行。
- 本地 DMG 和 ZIP 均生成成功；DMG 挂载后检查，ZIP 完整性检查通过。
- 主程序、更新器及小组件均包含 arm64 与 x86_64，应用与小组件版本均为 1.0.0 (22)。
- 三个目标均为 ad-hoc 签名，嵌套签名与所有架构验证通过；没有 Developer ID 证书签名、Apple 公证或自动替换安装。
- 安装包包含有效 App Intents 元数据、应用图标、双语资源及指向 `/Applications` 的安装快捷方式。

## 本地安装包校验和

| 文件 | 字节数 | SHA-256 |
| --- | ---: | --- |
| NotchCalendar-1.0.0-macos.dmg | 6,414,378 | `aa741201479c698edd24f595d9dd130bd887c706654a31fe646fa44ce1eaf5ec` |
| NotchCalendar-1.0.0-macos.zip | 5,407,923 | `908151be057970194af8c54e84845d3bde873b450aa420ad1df12566dfe2d4f0` |

公开附件由 GitHub Actions 从 v1.0.0 标签重新构建并验证，公开附件的校验和以[发布页](https://github.com/GpsLypy/NotchCalendar/releases/tag/v1.0.0)附带的 SHA256SUMS.txt 为准。本地重新构建的签名和归档时间可能不同。

## 重现

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
python3 -m unittest discover -s Scripts/quality -p 'test_*.py'
python3 Scripts/quality/verify_release_gate.py 1.0.0 --strict
DEVELOPER_ID_APPLICATION=- NOTARYTOOL_PROFILE='' ALLOW_ADHOC_RELEASE=1 Scripts/create_release.sh 1.0.0
```

严格检查预期返回未通过并列出上述缺口；打包会明确输出本次已记录的发布例外及缺口。
