# TestFlight 签名配置

配置日期：2026-10-09。以下 App ID 和描述文件已在 Apple Developer 公司团队中创建，并核对下载内容。

| 配置项 | 值 |
| --- | --- |
| 团队 | Pax Capital Limited |
| Team ID | `K242QGHJQZ` |
| App ID 说明名称 | `FChat Beta` |
| Bundle ID | `com.paxcapital.chatbeta` |
| 完整 Application Identifier | `K242QGHJQZ.com.paxcapital.chatbeta` |
| App Store Connect 应用名称 | `FChat Beta` |
| App Store Connect Apple ID | `6820996068` |
| SKU | `FCHAT-BETA-20261009` |
| 主要语言 / 平台 | 简体中文 / iOS |
| 描述文件类型 | App Store Connect（门户显示 App Store） |
| 描述文件名称 | `FChat_Beta_AppStore_20261009` |
| 描述文件 UUID | `6805171f-3bd4-4872-b1de-e9062a37900d` |
| 描述文件 | [FChat_Beta_AppStore_20261009.mobileprovision](../signing/profiles/FChat_Beta_AppStore_20261009.mobileprovision) |
| 分发证书 | `Apple Distribution: Pax Capital Limited (K242QGHJQZ)` |
| 证书 SHA-1 指纹 | `0AE301C7AF9ACE7152E38E2C56DFF456FB221CB9` |
| 到期时间 | 2027-04-24 13:30:49，日本时间（UTC+9） |

## 已核对

- 描述文件里的团队、Bundle ID 和注册记录一致。
- `get-task-allow` 为 `false`，`beta-reports-active` 为 `true`。
- 描述文件没有 `ProvisionedDevices`，不是按设备登记的 Ad Hoc 描述文件。
- 文件内分发证书的指纹与 Mac 钥匙串中的有效签名身份一致。
- 项目中的文件位于 `signing/profiles/`，并已复制到 Xcode 的描述文件目录：

```text
~/Library/Developer/Xcode/UserData/Provisioning Profiles/6805171f-3bd4-4872-b1de-e9062a37900d.mobileprovision
```

App ID 使用基础能力配置，未额外开启 Push Notifications、App Groups、Associated Domains 等能力。具体应用构建若需要这些权限，还须配置自己的对应能力并重新生成描述文件。注册说明名称 `FChat Beta` 不会改变手机上显示的“微信”名称。

## 应用记录和 IPA

App Store Connect 应用记录已创建并核对：

- [应用信息](https://appstoreconnect.apple.com/apps/6820996068/distribution/info)
- [TestFlight](https://appstoreconnect.apple.com/teams/576c415c-7612-4bec-ab6e-d85fd8ceb5ea/apps/6820996068/testflight)

最新公司分发签名包：[fchat_8.0.71_appstore_b2.ipa](../ipa/testflight/fchat_8.0.71_appstore_b2.ipa)，版本 `8.0.71`，构建号 `2`，手机显示名称为“微信”。构建号 `1` 上传时被苹果以 `SC_Info` 禁止路径拒绝，现已归档到 `archive/testflight-b1/`。最新包已清理主应用和全部框架中的 15 个同名目录并重新签名。详细结果见 [TestFlight构建报告.md](TestFlight构建报告.md)，机器可读记录为 [fchat_8.0.71_appstore_b2.json](../ipa/testflight/fchat_8.0.71_appstore_b2.json)。

这个文件来自已有 IPA 的重新打包和签名，没有从微信源码重新编译。主程序和全部 14 个框架均使用这里的公司分发证书；严格签名校验和 ZIP 完整性检查已通过。原始 IPA、改名的侧载 IPA 和手机上的现有安装均保留。

## 后续状态

2026-10-09，构建号 `1` 因 `Validation failed (409)` / `Disallowed paths [SC_Info]` 上传失败。修正版构建号 `2` 已通过本地检查，用户通过 Transporter 上传后，App Store Connect 已处理完成。内部群组显示“正在测试”，外部群组显示“正在等待审核”；外部测试尚未获批。

测试描述、审核联系人和登录信息已在 App Store Connect 保存，隐私政策网址暂时留空。本地文档不保存审核密码，也没有据此确认加密或其他审核合规性。外部测试需通过 Beta App Review。每个构建最多 90 天的测试期限独立于证书和描述文件的到期时间。
