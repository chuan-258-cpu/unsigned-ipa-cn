# TestFlight 构建报告

记录日期：2026-10-09，日本时间。构建号 `1` 因 `SC_Info` 禁止路径上传失败并已归档。修正版构建号 `2` 已上传、处理完成，内部群组显示“正在测试”，外部测试已提交并显示“正在等待审核”。

## 应用和产物

| 项目 | 值 |
| --- | --- |
| App Store Connect 应用名称 | FChat Beta |
| Apple ID | `6820996068` |
| Bundle ID | `com.paxcapital.chatbeta` |
| 团队 | Pax Capital Limited / `K242QGHJQZ` |
| 平台 / 主要语言 | iOS / 简体中文 |
| SKU | `FCHAT-BETA-20261009` |
| 手机显示名称 | 微信 |
| 版本 / 构建号 | `8.0.71` / `2` |
| IPA | [fchat_8.0.71_appstore_b2.ipa](../ipa/testflight/fchat_8.0.71_appstore_b2.ipa) |
| 文件大小 | 307,109,672 字节，约 292.9 MiB |
| SHA-256 | `a05110bb7607667c283dac64b184e9d911339c2efd2f689401e5577cfe12fbf7` |
| 构建方式 | 从 [fchat_8.0.71_weixin.ipa](../ipa/sideload/fchat_8.0.71_weixin.ipa) 重新打包并签名 |
| 构建脚本 | [prepare_appstore_ipa.swift](../scripts/prepare_appstore_ipa.swift) |
| 构建记录 | [fchat_8.0.71_appstore_b2.json](../ipa/testflight/fchat_8.0.71_appstore_b2.json) |

[App Store Connect 应用信息](https://appstoreconnect.apple.com/apps/6820996068/distribution/info) · [TestFlight 页面](https://appstoreconnect.apple.com/teams/576c415c-7612-4bec-ab6e-d85fd8ceb5ea/apps/6820996068/testflight)

## 已完成的修改

- 主 Bundle ID 从 `com.tencent.fchat` 改为 `com.paxcapital.chatbeta`。
- `CFBundleVersion` 从四段的 `8.0.71.34` 改为 `2`。营销版本继续为 `8.0.71`；原应用自用的 `WeChatBundleVersion` 保留。
- 在签名前移除主应用和 14 个框架中共 15 个 `SC_Info` 目录，并在最终 IPA 路径列表中检查此目录不再存在。
- 恢复 `CFBundleIcons` 和 iPad 图标声明，指向已有 `AppIcon` 资源。原图标目录内有默认不透明的 1024 × 1024 图标。
- 删除 `UIBackgroundModes` 中非标准的 `network-authentication` 条目。
- 主程序和 14 个内嵌框架补齐可执行权限，并逐个重签后再签主应用。
- 嵌入 `FChat_Beta_AppStore_20261009.mobileprovision`；主程序权限改为公司描述文件允许的 Application Identifier、Team ID、Beta Reports、Keychain Group，`get-task-allow=false`。

原始和改名的侧载 IPA 未覆盖。此次没有操作手机安装。

## 本地核验结果

- 新 IPA 解压后执行 `codesign --verify --deep --strict`，结果为 `valid on disk` 和 `satisfies its Designated Requirement`。
- 14 个框架均独立通过严格签名检查；所有签名的 Team ID 均为 `K242QGHJQZ`。
- 主程序签名证书与描述文件包含的证书 SHA-1 均为 `0AE301C7AF9ACE7152E38E2C56DFF456FB221CB9`。
- 包内描述文件与下载的公司分发文件逐字节一致，具有 `beta-reports-active=true`，没有设备列表。
- 主程序实际 Mach-O 的平台为 iOS，SDK 为 `26.1`，最低系统为 `15.0`，不是仅通过 Info.plist 推断。
- 主程序及 14 个框架的 `cryptid` 均为 `0`，均为 arm64；没有发现额外可执行扩展或 dylib。
- `unzip -tq` 压缩完整性检查通过；IPA 只有 `Payload` 内容，没有混入构建脚本或签名权限文件。
- 构建号 `2` 的 IPA 路径扫描确认 `SC_Info` 为零项。清理后重新签名，最终 IPA 解压后的严格签名校验通过。
- 原有主应用、SoundTouch、Lottie 隐私清单保留，未替用户作新的隐私或加密合规声明。

## 仍需验证的事项

本地签名成功不等于 Apple 上传校验、处理或审核成功。这份 IPA 是第三方修改的微信二进制，无法据此证明腾讯授权、完整源码、私有 API 合规或修改后功能正确。

原签名包含腾讯的 Push、App Groups、Associated Domains、支付、HealthKit、CarPlay、HotspotHelper 等权限。新的公司基础描述文件不允许这些权限，因此没有沿用。微信的推送、群组容器、支付等功能可能不可用；新 Bundle ID 下真实微信登录和持续运行尚未验证。不能承诺 TestFlight 版本能保留原微信全部功能。

若干内嵌框架由旧 SDK 编译，此次没有改写 Mach-O 或伪造 SDK 信息。是否触发苹果当前的上传要求，须以服务器实际校验为准。隐私清单存在也不能证明第三方 SDK 的声明和数据收集完全符合要求。

App 中包含 OpenSSL 和多种加密实现，脚本未把 `ITSAppUsesNonExemptEncryption` 直接填成 `false`。加密问卷或材料须依据真实实现和适用豁免；本报告没有验证这些声明。测试说明、测试登录账号和审核联系信息已在 App Store Connect 保存，审核密码不写入本地文档。隐私政策网址暂时留空；应用内容版权和年龄分级等事项没有在本报告中确认。

## 构建号 1 的实际上传结果

用户提供的 Transporter 日志显示，2026-10-09 22:51:04 上传失败，错误为 `Validation failed (409)` / `Disallowed paths [SC_Info]`。完整日志包含 15 条同类错误，分别对应主应用和全部 14 个框架。该结果没有报告账号或描述文件错误，也不能据此推断其他检查已经全部通过。

`SC_Info` 是 App Store 已分发包里的 FairPlay 相关元数据，包含 `.sinf`、`.supp`、`.supf`、`.supx` 等文件，开发者重新提交的上传包不能带有这些目录。首版打包脚本遗漏了清理，构建号 `2` 已修正。清理在解包副本中、重新签名之前执行；没有修改原始 IPA，也没有改变二进制加密标记。

失败的 IPA 和 JSON 位于 [archive/testflight-b1](../archive/testflight-b1/)，仅供追溯，不作为当前上传包。

## 构建号 2 的上传和测试状态

- 用户通过 Transporter 成功交付构建 `8.0.71 (2)`，随后 App Store Connect 已处理完成。
- 已创建“FChat 内部测试”群组并添加构建 2，构建状态为“正在测试”；已向第一个邮箱发送内部邀请。
- 第二个邮箱已有开发者用户，但缺少 FChat Beta 访问权限；权限变更未保存，等待用户确认页面显示的“所有 App”范围。
- 已创建“FChat 外部测试”群组，填写测试内容并提交构建 2。最近确认的状态为“正在等待审核”，群组尚无外部测试员。
- JSON 构建记录保留生成当时的本地核验状态，未改写为上传成功或审核通过。后续状态以 App Store Connect 为准。

## 下一步

1. 内部测试员在邀请邮件中接受邀请，并在 TestFlight 安装构建 2。
2. 确认第二个邮箱的 App 访问范围后，补齐内部测试员。
3. 等待 Beta App Review；通过后再邀请外部测试员或启用公开链接。每个构建最多可测试 90 天。
4. 若审核或实际运行发现问题，根据具体原因修正包或从有授权的源码重新构建。

App Store Connect 自动创建的 App Store 待提交版本为 `1.0`。TestFlight 可以单独处理营销版本 `8.0.71`；以后若提交 App Store，需要将待提交版本与所选构建的营销版本对齐。

## 再次生成包

在项目根目录 `unsigned-ipa-cn/` 执行：

```sh
swift scripts/prepare_appstore_ipa.swift 3
```

会在 `ipa/testflight/` 生成构建号 `3` 的新 IPA 和 JSON。脚本从 `ipa/sideload/` 读取源包，从 `signing/profiles/` 读取描述文件，清理所有 `SC_Info` 并检查最终包路径，使用本机钥匙串里的分发私钥，不导出私钥，不需要 Apple 账号密码，不执行上传。已存在的同名输出或归档包会拒绝覆盖。

参考：[Apple 上传构建说明](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)、[TestFlight 概览](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)。
