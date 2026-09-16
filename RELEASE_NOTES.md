# Notch Calendar 1.6.3

macOS 15+ · Apple 芯片与 Intel · build 40 · 2026-09-16

## 新增 / Added

- **跨月小组件数据**：日历快照预先保存本月和下月事件。主应用在月末未运行时，月历和今日日程小组件跨月后仍可显示下月安排。

## 修复 / Fixed

- **私密收藏不再在阅读中自动锁定**：移除固定两分钟锁定；停留当前页面时保持解锁，离开页面、切换应用或所属窗口、锁屏和休眠仍会隐藏内容。
- 身份验证和钥匙串访问后等待原窗口稳定恢复焦点，再显示解密内容；焦点未恢复时给出可操作提示。
- 默认静默读取收藏密钥，确需许可时显示错误码和明确的钥匙串恢复入口；已批准密钥只在当前进程内复用，每次解锁仍要求系统身份验证。
- 离开页面或取消解锁后，即使密钥创建刚刚完成，也不会发布过期的解锁结果或覆盖原收藏。
- 修复主应用关闭时跨月后，小组件缺少下月日程的问题。

## 安装与升级

下载 `NotchCalendar-1.6.3-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

普通用户升级后若需恢复钥匙串访问，可在应用内点击「重试读取授权」，按 macOS 提示允许访问。若仍失败，可提供界面显示的错误码排查；请保留原钥匙串记录。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 320 项，14 项按需测试跳过，零失败；发布质量脚本通过。

6 份新性能样本均检测到持续鼠标活动，不满足静置验收条件，原始数据作为排除证据保留。本版没有可豁免的有效实测失败；每种场景两份有效样本以及实体刘海屏、外接屏验收仍待补齐，并按本版本记录的所有者发布例外发行。

回归验证覆盖私密收藏解锁、焦点恢复、钥匙串恢复、取消与保存失败，以及主应用关闭时的跨月小组件快照。开发者机器上的真实系统身份验证与钥匙串恢复仍需最终人工确认。

普通用户真实密码交互、锁屏和跨设备钥匙串恢复，以及完整刘海/外接屏交互仍待实机验收。开发机免购买激活不代表这些普通用户流程已完成验证。

## English

### Added

- Calendar snapshots now include this month and next month, keeping widget events available across month rollover while the host app is closed.

### Fixed

- Private bookmarks no longer lock on a fixed two-minute timer while their page remains in use. They still lock when leaving, switching apps or windows, locking the screen, or sleeping.
- Wait for the requesting window to regain stable focus after authentication and Keychain access before publishing decrypted content.
- Read bookmark keys silently by default, provide explicit Keychain recovery with error codes, and retain approved keys only in process memory while requiring authentication for every unlock.
- Cancelled or stale unlock attempts cannot publish content after vault-key creation.
- Month and agenda widgets retain next-month events when the main app is closed at month rollover.

All six fresh performance attempts contained continuous pointer activity and were retained as excluded evidence rather than counted as passes or failures. No valid measured failure is waived; two valid samples per scenario and physical-display acceptance remain pending under this version's recorded owner exception.

Existing lifetime licenses remain valid. This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Real customer authentication, Keychain recovery and complete physical-display acceptance remain pending.
