# Notch Calendar 1.6.2

macOS 15+ · Apple 芯片与 Intel · build 37 · 2026-09-16

## 优化 / Improved

- **侧栏更简洁**：将 GitHub 和「检查更新」收进「设置 → 软件更新」，保留打赏作者、授权与试用、分享和设置入口。
- **开发机独立识别**：已配置作者签名凭证的开发机无需购买激活，主界面、设置、快捷指令与小组件统一识别。凭证绑定本机，不随安装包分发；普通用户的试用和永久授权规则不变。

## 修复 / Fixed

- **继续修复 1.6.1 的授权恢复问题**：读取成功后，在本次运行中复用已验证授权，避免点击一次「允许」后被后续读取打断；保存激活信息后也不再立即请求读取。
- 系统密码框打开期间阻止定时器和其他入口重复发起授权检查。
- 将读取许可与试用检查点写入许可分开处理，避免一个重试动作连续触发两个系统授权请求。重试恢复成功后直接进入工作台。
- 无法访问钥匙串时显示具体错误码，并避免误显示「试用已结束」。

## 安装与升级

下载 `NotchCalendar-1.6.2-macos.dmg`，退出旧版后拖入「应用程序」替换。也提供 ZIP 和 SHA-256 校验文件。已有永久授权继续有效，无需再次付款。

普通用户升级后若需恢复钥匙串访问，可在应用内点击「重试读取授权」，按 macOS 提示允许访问。若仍失败，可提供界面显示的错误码排查；请保留原钥匙串记录。

**本版采用 ad-hoc 签名，未进行 Developer ID 签名或 Apple 公证，需手动安装；macOS 可能显示安全提示，不提供自动替换安装。**

## 验证范围

完整 Swift 测试共 304 项，12 项按需测试跳过，零失败；发布质量脚本测试 20 项通过。

性能探针目前取得静置、专注、会议切换各一份有效样本，均在固定预算内。另有 11 份样本因鼠标活动或面板遮挡而不满足静置验收条件，原始记录保留；每种场景的第二份独立样本仍待补齐，本版按已记录的发布例外发行，不宣称性能验收已全部完成。

回归验证覆盖一次性允许后的会话访问、授权保存、试用到期、授权交互期间的重入，以及开发者凭证签名与机器绑定。开发者机器已验证真实本机凭证、应用重启和后台检查后的访问状态。

普通用户真实密码交互、锁屏和跨设备钥匙串恢复，以及完整刘海/外接屏交互仍待实机验收。开发机免购买激活不代表这些普通用户流程已完成验证。

## English

### Improved

- GitHub and Check for Updates now live in Settings → Software Update. Support, License & trial, Share and Settings remain in the sidebar.
- Provisioned developer Macs use author-signed, machine-bound credentials to skip purchase activation. Credentials are excluded from installers and do not unlock another Mac. Customer licensing rules are unchanged.

### Fixed

- Continues the 1.6.1 licensing fix: reuse a loaded, verified license for the current session instead of repeatedly reading Keychain after one-time approval or activation saves.
- Prevent reentrant checks during system authorization, separate read and checkpoint-write permissions, and enter the workspace after successful recovery.
- Display Keychain error codes and avoid showing trial expiry when storage access failed.

Existing lifetime licenses remain valid. This is an ad-hoc signed, manual-install build without Developer ID signing or Apple notarization. Developer-machine startup has been verified locally; real customer authentication, Keychain recovery and complete physical-display acceptance remain pending.

Performance acceptance is partial: one valid sample for each of idle, focus and meeting switching passed its budget. Eleven interrupted samples are retained separately; a second independent sample per scenario remains pending under the recorded release exception.
