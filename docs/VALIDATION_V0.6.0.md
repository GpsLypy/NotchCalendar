# Notch Calendar 0.6.0 验证报告

验证日期：2026-09-05。发布前本地验证快照，版本 0.6.0，构建号 17。后续 GitHub 构建和发布状态请查看 [v0.6.0 Release](https://github.com/GpsLypy/NotchCalendar/releases/tag/v0.6.0)。

## 已通过

- 完整 Xcode 环境 Debug 编译与统一测试：118 项中 116 项离线确定性测试通过，2 项需显式开启的联网/原生渲染测试按设计跳过；零失败。
- 单独开启 Briefing 真实来源测试后通过：GitHub Blog 10 条、Swift.org 20 条、NASA 10 条，使用应用自己的 Swift 客户端和解析器。
- 单独开启 MarketingCaptureTests 后通过：真实公开 HN 话题及评论、三路简报、无密钥行情配置页、收藏/已读状态的原生 SwiftUI 视图渲染。使用隔离的偏好存储，没有读取用户的日历、随手记或行情密钥。
- 渲染检查包括默认页面大小及最小页面内容区 647 × 520。实际新功能视图没有出现空白、横向截断的关键操作或重叠文案；长内容允许滚动。
- 双架构 Release：主程序、更新器、小组件全部包含 arm64 与 x86_64。
- 主应用、小组件版本一致：0.6.0 (17)。嵌套签名验证、DMG 校验及只读挂载验证通过，Applications 快捷方式指向 /Applications。
- 资源字符串、Info.plist 格式以及 git diff --check 通过。

## 验证过程中发现并修正

1. GitHub RSS 正文的 CDATA 中有 HTML DOCTYPE，被原来的全局扫描误当作 XML 外层声明拒绝。改为线性扫描合法文本区域，继续拒绝真正的 DTD/ENTITY，并补充回归测试和真实源验证。
2. 舆论室读取旧缓存后成功刷新仍保留“缓存”标记。完整成功现在正确清除旧状态。
3. 舆论室一次强刷后，后续切换话题一直绕过缓存。强刷现在只消费一次。
4. 损坏的评论字段曾被当作正常跳过，可能让部分响应覆盖完整缓存。现在区分明确删除与坏数据，部分失败保留健康缓存。
5. 一项删除评论测试夹具错误覆盖了自己的话题条目，修复夹具后相关候选上限测试通过。

## 当前验收边界

- Mac 处于锁屏状态，Computer Use 无法操作，已请求用户解锁。尚未完成真实前台窗口的点击、中文输入法及切换回归；原生离屏渲染不等同于真实窗口操作。
- 未提供个人 Alpha Vantage 密钥，因此没有使用用户凭据验证真实行情报价，也未申请或保存新的外部凭据。行情请求、解析、缓存、限流及失败处理使用固定响应测试。首次使用需在应用内配置个人密钥。
- 此报告中的安装包是 ad-hoc 签名的本地手动安装构建，未做 Developer ID 公证。报告记录于公开发布前；GitHub 发布由独立 CI 流程重新构建和验证，产物校验和可能不同。社交平台内容尚未发布。

## 可复现命令

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
NOTCH_LIVE_BRIEFING=1 DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter BriefingTests
NOTCH_CAPTURE_PATH="$PWD/marketing/v0.6.0/assets" DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter MarketingCaptureTests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ALLOW_ADHOC_RELEASE=1 Scripts/create_release.sh 0.6.0
```

## 安装包 SHA-256

```text
48a3efc975f7ffbe7d9ba47b08df8431156571e4cf69e05b42cf8a5e379af5bb  NotchCalendar-0.6.0-macos.dmg
fd7f882c21d61cc45e984bfd089ef25ed0801be53f253a801be9b85692e82d6e  NotchCalendar-0.6.0-macos.zip
```

宣传素材与视频的格式校验记录另见 marketing/v0.6.0/output/validation.md。
