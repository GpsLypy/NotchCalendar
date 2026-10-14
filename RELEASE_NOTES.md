# Notch Calendar 1.8.6

macOS 15+ · Apple Silicon and Intel · build 79 · 2026-10-14

## 新增与调整

- 专注或休息计时结束时播放一声短提示音，后台计时也会提醒。专注页新增「计时结束时播放提示音」开关，关闭后保持静音，并记住选择。
- 同一次计时只提醒一次。暂停、重置、重新启动或恢复已结束的计时不会误响或重复响；完成记录照常保存。
- 「打卡」胶囊的对号加入约 0.34 秒的描画动画，在提醒出现和点击时触发。点击立即打开待打卡详情，连续点击后对号也会完整显示。
- 尊重系统“减少动态效果”：直接显示完整静态对号。

## 安装

退出旧版，打开 `NotchCalendar-1.8.6-macos.dmg`，将应用拖入「应用程序」替换并重新启动。另提供 ZIP 和 `SHA256SUMS.txt`。沿用 **ad-hoc 签名、手动安装**，未进行 Developer ID 签名或 Apple 公证。

## 验证范围

Swift 全量执行 560 项：535 项通过、25 项按需或环境跳过，零失败；21 项 Python 质量检查通过。

原生本地验证覆盖后台计时结束、静音与重新启用、恢复过期计时、对号描画中间帧、连续触发和减少动态效果，以及中文宽窗口与英文窄窗口。验证使用隔离数据；实际扬声器听感、完整实体屏幕矩阵、真实休眠唤醒与登录、静置性能、VoiceOver、钥匙串弹窗、真实付款激活和完整播放器集成仍待验收。

## English

- Play one short sound when a focus or break timer ends, including background timers. The Focus page offers a sound switch and remembers your choice.
- Pausing, resetting, relaunching or restoring an already completed timer does not replay feedback. Completed history is still saved when sound is off.
- Draw the check-in capsule's tick in about 0.34 seconds when a reminder appears or the capsule is clicked. Details open immediately, and rapid clicks settle on a complete tick.
- Respect Reduce Motion by displaying a complete static tick.

Quit the previous app, replace it in Applications using the DMG, and relaunch. This ad-hoc signed manual-install build has no Developer ID signing or Apple notarization.

560 Swift tests executed: 535 passed, 25 optional/environment checks skipped, zero failures; all 21 Python quality checks passed.

Native checks use isolated data and cover background completion, muting, expired-timer restoration, animated intermediate frames, rapid replays, Reduce Motion and Chinese/English layouts at two widths. Speaker listening acceptance, full physical displays, real sleep/wake/login, stationary performance, VoiceOver, Keychain dialogs, live payment/activation and full player integrations remain pending.
