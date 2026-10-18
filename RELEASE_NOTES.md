# Notch Calendar 2.0.10

macOS 15+ · Apple Silicon and Intel · build 93 · 2026-10-18

## 刘海行情与资讯

- 功能栏新增「行情」（⌘9）和「资讯」（⌘0）。原有八种工具、⌘1–⌘8、刘海窗口尺寸及顶部／底部位置保留；入口放不下时可从原生「更多工具」菜单访问，也可在设置中隐藏不用的工具。
- 行情适合短暂查看指数／自选的价格、涨跌、来源时间和可用分时小图；小图可关闭，完整自选管理与行业列表在主窗口进行。
- 资讯速览最多三条，支持未读／最新／收藏，与完整信息差简报共享内容语言、已读和收藏。刘海的局部筛选不覆盖主窗口搜索词、阅读筛选或来源选择；切换共享的内容语言时，仍按原规则清除不兼容来源。
- 「查看全部」与「打开完整行情」可打开相应完整页面，包括已隐藏的页面；不会自动改变侧栏显示偏好。
- 情报台、自选行情、舆论室、信息差简报四个原有模块、侧栏顺序及显示偏好继续保留。日历、文件布局、便笺编辑状态和紧凑态会议／专注／音乐规则沿用现有方式。

## A 股报价、分时与自选

- 在主窗口自选行情中加入上证、深成、创业板、沪深 300、科创 50 五个指数，以及最多八只沪深 A 股自选。原有美股区块、Alpha Vantage 配置和额度保留。
- 分时图仅绘制来源实际返回的分钟点，不补造缺失行情；缺失时段断线。主窗口同时显示成交量柱，可关闭分时图以一起隐藏曲线与量柱；刘海小图有独立开关。
- 来源行情时间、交易日和本机获取时间分别记录；过期、异日或请求失败时显示相应状态，保留可用旧报价。不同交易日的分时不与当前报价混绘。
- 行情在进入可见页面、切换标的和手动刷新时按缓存策略读取，没有后台轮询。主窗口与刘海共享数据和进行中的有限请求，避免重复加载。

## 行业与数据来源

报价与分时来自腾讯财经公开网站接口。本轮已通过应用实际网络传输与生产解析验证腾讯报价和分钟数据；这不代表所有时段、标的或网络环境均能成功，也不保证实时性或持续可用。请结合页面显示的来源时间、缓存和错误状态判断当前数据。

行业领涨／领跌采用东方财富行业分类，含不同层级，不包含概念板块。本轮行业接口出现超时及空响应，未完成行业源联网成功验收。行业不可用时显示状态并保留可用缓存，报价可独立更新；本版不承诺行业排名持续可用。

## 验证与安装

发布前 232 项定向测试以独立进程串行执行：226 项通过、6 项可选检查跳过、零失败；21 项 Python 质量检查通过。双架构安装包的实际二进制内容、严格签名、快捷指令元数据和 ZIP／DMG 完整内容检查通过。初次四项原生测试夹具失败已修正，随后完整重跑此定向集通过；这不是整应用全量回归。原生界面检查使用隔离配置和合成行情／文章，不是实时行情截图，也不等同于实体设备验收。

实体刘海、外接屏、休眠唤醒、真实 VoiceOver 与静置 CPU／能耗完整验收仍待完成。完整资讯联网会话、真实模型与播放器、旧用户钥匙串迁移和完整付款发码亦未在本轮完成验收。

[下载 DMG](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/NotchCalendar-2.0.10-macos.dmg) · [下载 ZIP](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/NotchCalendar-2.0.10-macos.zip) · [SHA-256](https://github.com/GpsLypy/NotchCalendar/releases/download/v2.0.10/SHA256SUMS.txt)

退出旧版，将 DMG 中的应用拖入「应用程序」替换并重新启动。通用安装包支持 Apple 芯片与 Intel，最低 macOS 15；沿用 ad-hoc 签名、手动安装，未进行 Developer ID 签名或 Apple 公证。自动替换安装仍禁用，独立更新窗口不代表本版支持自动替换。

沿用 7 天试用、¥9.9 一次买断与人工领码流程。更新不会重新开始试用或授予永久授权；保留本机应用数据时，永久授权与聊天 API Key 继续使用原有保存方式。

## English

- Add Markets (⌘9) and News (⌘0) to the notch toolbar. Retain the original eight tools, ⌘1–⌘8, shared window dimensions and top/bottom placement. More Tools holds entries when space is limited, and optional tools can still be hidden in Settings.
- Use Markets for a brief view of index/watchlist prices, changes, source times and an optional intraday mini-chart. Keep full watchlist management and industry lists in the main window.
- News shows up to three headlines with Unread / Latest / Saved filters. Share content language, reading state and saved headlines with the full Briefing page. Local notch filters preserve the workspace's search, reading filter and source selection; changing the shared content language still clears an incompatible source under the existing rules.
- View all and Open full market workspace can explicitly open a hidden page without changing sidebar visibility preferences. Retain Radar, Markets, Discussion Room and Briefing as four modules, with their existing sidebar order and preferences. Keep Calendar, file layouts, native note editing and compact meeting/focus/music behavior.
- Add the SSE Composite, SZSE Component, ChiNext, CSI 300 and STAR 50, plus up to eight Shanghai/Shenzhen A-share watchlist entries. Preserve the existing US-market section, Alpha Vantage configuration and quota.
- Draw intraday lines only from source-provided minute points and break the line across missing periods. The full workspace includes volume bars; turning off its intraday chart hides both the line and bars. The notch mini-chart has a separate toggle. Preserve available quotes when data is old or a request fails, identify cached/error states, and do not combine intraday data and quotes from different trading days.
- Load on entry to a visible page, instrument changes or manual refresh, using shared cache and in-flight requests between the workspace and notch. There is no background polling.

Quotes and intraday data use Tencent's public website endpoints. This round's actual application network-transport and production-parser checks succeeded for quotes and minute data. These checks do not establish success for every time, instrument or network, or guarantee real-time data and continued availability. The interface shows source times, cached state and errors.

Industry gainers and losers use Eastmoney classifications at multiple levels, excluding concept sectors. Industry requests timed out or returned empty responses in this round; successful live industry access is not established. Show the unavailable state and retain any usable cache while quotes update independently. Continued availability of industry rankings is not promised.

Prepublication validation ran 232 targeted cases serially in separate processes: 226 passed, 6 optional checks skipped, zero failures. All 21 Python quality checks passed. Universal packages passed executable-content, strict-signature, App Intents metadata and complete ZIP/DMG content checks. Four initial native-fixture failures were corrected, then the complete selected set passed again; this is not a full-app regression. Native view checks use isolated configuration and synthetic quotes/headlines, not live-market screenshots or physical-device acceptance.

Physical notches, external displays, sleep/wake, real VoiceOver and complete stationary CPU/energy acceptance remain pending. Complete live Briefing sessions, real models and players, upgraded-user Keychain migration and the full payment/code-delivery flow were not accepted in this round.

Quit the old app, replace it in Applications using the DMG, and relaunch. Universal macOS 15+ package for Apple silicon and Intel; ad-hoc signed for manual installation, without Developer ID signing or Apple notarization. Automatic application replacement remains disabled; the independent update window does not enable it.

The seven-day trial, ¥9.9 one-time purchase and manual activation-code delivery remain in place. Updating does not restart the trial or grant a permanent license. Keeping local app data preserves the existing permanent-license and Chat API key storage.

Previous release: [2.0.9](https://github.com/GpsLypy/NotchCalendar/releases/tag/v2.0.9).
