# Notch Calendar 0.6.0 宣传交付

主题：给工作留一点秩序，也给好奇心留一个位置。

完整图文与视频包作为 [v0.6.0 Release](https://github.com/GpsLypy/NotchCalendar/releases/tag/v0.6.0) 附件提供；仓库保留生成脚本、文案、字幕与验证记录，图片和视频不写入 Git 历史。

## 成品

- output/01-cover-concept.png：3:4 品牌概念首图，使用 Codex 内置 image_gen 生成，图内标注“品牌概念图”。完整提示词见 image-prompt.md。
- output/02-markets.png 至 06-overview.png：五张 1242 × 1656 功能海报。
- output/小红书文案.md：标题、正文、图序、视频配文、置顶评论。
- output/notch-calendar-v0.6.0-xhs-douyin-3min.mp4：1080 × 1920、30fps、H.264/AAC，约 3 分钟介绍视频。
- output/notch-calendar-v0.6.0-3min.zh-Hans.srt：逐句简体中文字幕，成片也已烧录字幕。
- output/notch-calendar-v0.6.0-voice.wav：独立普通话合成旁白。
- output/视频脚本.md：分镜与旁白。
- output/preview-contact-sheet.jpg：全片十二镜头预览。
- output/validation.md：格式与内容验证记录。

## 素材口径

功能画面直接来自本版 SwiftUI 视图的离屏渲染，使用本次真实抓取的公开资讯，**不是实机录屏**。所有渲染均使用独立偏好存储；唯一私人笔记为明确写有“演示笔记”的中性文字。由于 Mac 锁屏，真实窗口点击验收未完成。

行情配置页没有个人密钥，不含虚构价格。连接自己的 Alpha Vantage 密钥后，才能获取个人收盘报价。行情非实时；不宣传内幕消息或投资收益。舆论室是 HN 社区有限样本；简报按源数据分别保留发布或更新时间。

旁白采用 Xiaoxiao Neural 普通话合成语音。仅公开产品介绍文案发送至语音服务，没有发送日历、笔记或凭据。语速按实际 PCM 音频时长温和调整至约三分钟。背景音乐由脚本合成，没有使用外部歌曲素材。

## 重新生成

需要完整 Xcode、Python edge-tts、Node.js sharp，以及 FFmpeg（默认复用本机 Downie 4 附带版本，也可设置 FFMPEG 环境变量）。

1. 用仓库文档中的 NOTCH_CAPTURE_PATH 开启原生渲染测试，生成 assets/*.png。
2. 执行 prepare-voice.py 生成 narration.json 中各句的合成语音（修改配音文案后应移走对应旧音频重新生成）。
3. 设置 NODE_PATH 到包含 sharp 的依赖目录，运行 build-media.cjs。

历史 0.4.0 / 0.5.0 marketing 目录未被覆盖。本目录是本版完整独立交付。
