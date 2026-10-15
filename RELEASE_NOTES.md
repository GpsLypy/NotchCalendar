# Notch Calendar 1.8.9

macOS 15+ · Apple Silicon and Intel · build 82 · 2026-10-15

## 新增与调整

- AI 聊天支持直接粘贴截图、复制的图片及本地图片文件，也可通过附件选择器添加图片；支持只发图片、缩略图预览、移除和重试。使用具备图片能力的模型。
- 聊天、剪贴板和便笺在悬停模式下，鼠标移开后自动收回，包括点击或输入之后；再次展开保留草稿、图片、便笺内容和剪贴板搜索。沿用仅点击模式和原生弹窗保护。
- 聊天新增「清空对话」和「删除这一轮」。删除经原生确认后同时移除该轮提问、回复、图片及模型上下文；保留未发送草稿。清空对话会停止生成，并清除全部记录、草稿和附件，释放对应的内存引用。
- 图片和文本附件合计最多 4 个。图片按最长边 2048 像素规范化为 PNG，每个图片附件最多 10 MB；文本附件最多 256 KB。图片只在明确发送时提交给配置的模型服务。

## 安装

退出旧版，打开 `NotchCalendar-1.8.9-macos.dmg`，拖入「应用程序」替换并重新启动。另提供 ZIP 和 `SHA256SUMS.txt`。退出会清除仅存在内存中的聊天记录和草稿；已保存的模型设置、钥匙串密钥、便笺和剪贴板历史保留。

沿用 **ad-hoc 签名、手动安装**，未进行 Developer ID 签名或 Apple 公证。

## 验证范围

Swift 全量执行 604 项：578 项通过、26 项按需或环境跳过，零失败。21 项 Python 质量检查全部通过。

原生交互验证图片 ⌘V、文字粘贴与撤销、中英文五档面板尺寸，以及宽窄窗口中的删除、取消、确认与清空。鼠标退出回归验证三种工具自动收回与内容保留；受控网络验证双协议图片请求、重试、删除后上下文和清空时拒绝过期回复。

完整实体屏幕矩阵、真实休眠唤醒与登录、静置性能、VoiceOver、钥匙串弹窗、真实付款激活、完整播放器集成和真实模型联调仍待验收。网络测试使用受控响应，未使用真实服务商密钥。

## English

- Paste screenshots, copied images and local image files into AI Chat, or choose images with the attachment picker. Preview, remove, send image-only messages and retry them. Select a model that supports images.
- Chat, clipboard history and scratchpad retract after pointer exit in hover mode, including after clicks or typing. Reopening retains drafts, images, notes and clipboard search. Click-only mode and native dialog protection still apply.
- Clear the conversation or delete one exchange after native confirmation. Deleting removes the paired question, reply, images and model context while preserving an unsent draft. Clearing stops generation and drops all messages, drafts and attachments.
- Attach up to four images and text files combined. Images become PNG at a maximum 2048-pixel longest edge and 10 MB per attachment; text files are limited to 256 KB. Images go to the configured provider only when explicitly sent.

Quit the old app, replace it in Applications using the DMG, and relaunch. Quitting clears in-memory chat history and drafts; saved model settings, Keychain credentials, notes and clipboard history remain. This is an ad-hoc signed manual-install build without Developer ID signing or Apple notarization.

Full regression executed 604 Swift tests: 578 passed, 26 optional/environment skips, zero failures. All 21 Python quality checks passed.

Native checks cover image paste, text undo, Chinese/English at five panel sizes, narrow/wide cleanup confirmations, pointer exit and content retention. Controlled requests verify both image protocols, retry, deletion context and rejection of late replies after clearing. Physical displays, real sleep/wake/login, stationary performance, VoiceOver, Keychain dialogs, live payment/activation, full player integration and real-provider calls remain pending.
