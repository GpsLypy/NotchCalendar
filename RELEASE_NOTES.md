# Notch Calendar 1.8.7

macOS 15+ · Apple Silicon and Intel · build 80 · 2026-10-15

## 新增

- 新增独立「剪贴板」历史页（⌘7），不并排显示月历。手动开启记录后，可搜索、预览、复制、置顶、删除或清空文字、图片和文件引用；支持暂停，最多本地保存 100 条。自动跳过明确标记为密码或临时内容的复制，无法识别来源未标记的敏感信息。
- 新增「AI 聊天」（⌘8），支持 OpenAI Responses 和兼容 Chat Completions 的服务。可配置基础地址、模型名和 API Key，密钥保存在本机钥匙串。
- 支持流式回复、多轮对话、停止、重试、复制回复、新对话及手动附加 UTF-8 文本文件。中文输入法、换行与撤销可正常使用，⌘Return 发送。
- 新配置默认使用 Responses；已有配置保留原协议，可在「聊天设置 → 接口协议」切换。同一服务切换协议无需重填已保存的密钥，切换服务、模型或协议会开启新对话。

## 数据与使用

剪贴板默认不记录，需主动开启。不会自动把剪贴板、日历或便笺发送给模型。聊天内容和草稿仅保留在本次进程内存中，退出应用后消失；Responses 请求使用 `store: false`，多轮所需的返回项保留在内存中。服务商自身的数据保留仍取决于其政策。深度思考默认关闭，仅应对支持对应参数的模型开启。

## 安装

退出旧版，打开 `NotchCalendar-1.8.7-macos.dmg`，拖入「应用程序」替换并重新启动。另提供 ZIP 和 `SHA256SUMS.txt`。沿用 **ad-hoc 签名、手动安装**，未进行 Developer ID 签名或 Apple 公证。

## 验证范围

Swift 全量执行 588 项，563 项通过、25 项按需或环境跳过、零失败；21 项 Python 质量检查全部通过。

新增功能 26 项定向测试通过，包含请求编码、分段 SSE/JSON、完整多轮上下文、完成判定、失败/停止/重试、密钥隔离和原生协议选择保存。原生面板覆盖中英文与 440×340、520×390、600×460、720×540、880×680 五档尺寸，验证剪贴板复制、中文输入、发送与编辑器保留。

网络测试使用受控响应，尚未使用真实 API Key 调用模型。完整实体屏幕矩阵、真实休眠唤醒与登录、静置性能、VoiceOver、钥匙串弹窗、真实付款激活和完整播放器集成仍待验收。

## English

- Add a standalone clipboard history page (⌘7), with no calendar beside it. Opt in to capture text, images and file references; search, preview, copy, pin, delete, clear or pause recording. Keep up to 100 entries locally. Explicitly marked concealed or transient copies are skipped; unmarked sensitive content cannot be identified automatically.
- Add AI Chat (⌘8) for OpenAI Responses and compatible Chat Completions services, with editable base URL, model and an API key stored in this Mac’s Keychain.
- Stream replies, retain multi-turn context, stop, retry, copy, start a new conversation and explicitly attach UTF-8 text files. Preserve Chinese IME composition, multiline input and undo; send with ⌘Return.
- New configurations default to Responses; existing configurations keep their protocol. Select it in Chat settings. Switching protocols on the same provider reuses its key; changing provider, model or protocol starts a new conversation.

Clipboard recording is opt-in. No clipboard, calendar or note content is attached automatically. Chat and drafts stay in process memory until the app quits. Responses requests set `store: false` and replay completed output items from memory; provider retention policies still apply. Enable deep thinking only for models supporting the corresponding parameters.

Quit the previous app, replace it in Applications using the DMG, and relaunch. This is an ad-hoc signed manual-install build without Developer ID signing or Apple notarization.

The full Swift suite executed 588 tests: 563 passed, 25 optional/environment skips, zero failures. All 21 Python quality checks passed.

All 26 targeted feature tests passed, with native Chinese/English interaction at five panel sizes. Network checks use controlled responses; no real provider API key was used. Physical displays, real sleep/wake/login, stationary performance, VoiceOver, Keychain dialogs, live payment/activation and full player integration remain pending.
