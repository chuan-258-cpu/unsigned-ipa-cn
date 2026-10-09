# 微信分身与 TestFlight 可行性说明

核查日期：2026-10-09。目标是让用户在 iPhone 上安装第二个微信，登录真实微信账号，并通过 TestFlight 接受邀请、从苹果服务器下载安装。

本文记录最初的调研和原始包检查。后续构建、上传与审核进度见 [TestFlight构建报告.md](TestFlight构建报告.md)。原始 IPA 已整理到 `ipa/original/`，相对于本文为 [fchat_8.0.71.ipa](../ipa/original/fchat_8.0.71.ipa)。

## 结论

付费 Apple Developer 账号可以用于提交自己的 App 到 TestFlight，但不能仅靠修改第三方微信 IPA 的 Bundle ID、重新签名，就把它变成符合苹果上传和测试审核要求的应用。

本次没有找到腾讯公开授权、可重新编译并以其他开发者身份提交 TestFlight 的完整 iOS 微信客户端源码。搜索到的项目主要是 IPA 收集、重签名工具、插件源码或仿微信界面的独立聊天应用。它们没有同时满足“真实微信账号聊天”和“符合 TestFlight 分发要求”这两个条件。

如果必须保留这两个条件，需要先取得相应的腾讯客户端修改、分发和微信服务接入授权，以及可维护的客户端构建工程或授权分发包；即使取得授权，仍需完成技术校验和苹果测试审核。

## 能修改 ID 的 GitHub 项目

这里的 ID 指 iOS 应用的 Bundle Identifier，例如 `com.example.chatbeta`，不是微信账号 ID。

| 项目 | 实际提供的内容 | 修改 ID 的能力 | 对当前 TestFlight 目标的适用性 |
| --- | --- | --- | --- |
| [zhlynn/zsign](https://github.com/zhlynn/zsign) | 开源 IPA/Mach-O 重签名工具 | 支持 `-b` / `--bundle_id`，也支持证书、描述文件和权限配置 | 能处理签名，不提供微信源码或第三方分发授权，也不保证苹果接受上传或审核 |
| [DanTheMan827/ios-app-signer](https://github.com/DanTheMan827/ios-app-signer) | Mac 图形界面重签名工具 | 可指定新的 Application ID、证书和描述文件 | 适合重签名操作，不能据此认定微信分身符合 TestFlight 要求 |
| [Naituw/IPAPatch](https://github.com/Naituw/IPAPatch) | 给已有解密 IPA 注入代码的 Xcode 模板 | README 明确要求配置 Bundle Identifier 和签名 | 有工具源码，原微信仍是已有二进制；不是可重新编译的微信客户端源码 |
| [AloneMonkey/MonkeyDev](https://github.com/AloneMonkey/MonkeyDev) | 插件开发、注入和调试工具 | 通过工程配置和重签名处理应用标识 | 面向已有应用的修改和调试，没有提供当前目标所需的客户端源码及授权 |
| [itenfay/WeChat_tweak](https://github.com/itenfay/WeChat_tweak) | 微信插件、动态库及重签名教程 | 教程包含修改 `Info.plist` 中应用标识的步骤 | 只提供插件及处理流程，不等于完整微信源码；新系统和微信版本兼容性需另行验证 |
| [Taosky/unsigned-ipa-cn](https://github.com/Taosky/unsigned-ipa-cn) | FChat 等 IPA 收集 | FChat 已使用 `com.tencent.fchat` | 仓库文件只有说明、应用列表和图标，没有完整客户端构建工程 |

上述工具的开源许可证只覆盖相应工具或插件，不能据此取得腾讯微信二进制、商标、资源或服务的使用与分发权。工具支持改 ID、生成 IPA，与苹果接受该 App 是不同的事情。

本次核实了项目说明，没有编译或验证这些工具在本机 Xcode 27 上的兼容性。

## 不满足当前目标的源码

- `TSWeChat`、`SwiftUI-WeChat`、`wechat_flutter` 等仿微信项目，可以开发自己的聊天应用，但不能凭这些源码登录真实微信账号并与原有微信好友收发消息。
- 微信 Open SDK 的“微信登录”是 OAuth 授权：用户用微信身份登录你的第三方 App。官方接口提供授权凭证及基本用户信息，不提供完整个人微信聊天客户端能力。
- `wechat-ipad-login` 等项目提供的是依赖已有微信的插件；本次检查的项目说明要求越狱和 Theos，并非可上传 TestFlight 的完整应用工程。
- GitHub 上的非官方微信协议项目，不等于腾讯授权的客户端接入方案；仅有协议代码不能证明符合 TestFlight 要求。

## 本地 FChat 的检查结果

文件：`fchat_8.0.71.ipa`。读取包内 `Payload/WeChat.app/Info.plist` 得到：

```text
CFBundleIdentifier: com.tencent.fchat
CFBundleExecutable: WeChat
CFBundleShortVersionString: 8.0.71
CFBundleVersion: 8.0.71.34
MinimumOSVersion: 15.0
DTSDKName: iphoneos26.1
DTXcode: 2611
DTXcodeBuild: 17B100
```

本机 `xcodebuild -version` 返回 Xcode 27.0，Build version 27A266a。

包内配置声明使用 iOS 26.1 SDK，但读取配置不能证明实际编译来源、所有 Mach-O 的构建信息、签名权限、第三方组件及审核合规情况。不能通过改写 SDK 字段代替真实编译，也不能据此保证 App Store Connect 校验通过。

本次未修改或重签名该 IPA，未上传 App Store Connect，未进行 TestFlight 审核，也未在真机验证启动、登录、收发消息和推送。

## TestFlight 的签名与上传要求

以下流程适用于有权修改和分发的应用，不代表当前 FChat 已经满足这些要求。

1. 确定源码、二进制、图片、商标、SDK 和第三方服务的使用与分发权限；真实微信客户端接入需有对应的腾讯授权，微信 Open SDK 登录接入不能替代它。
2. 在自己的 Apple Developer 团队注册 Explicit App ID，并在 App Store Connect 建立对应应用记录。工程、描述文件和应用记录中的 Bundle ID 必须匹配。
3. 在 Xcode 中为应用及扩展配置自己的 Team、Bundle Identifier、Capabilities 和 Entitlements。App Groups、钥匙串访问组、Associated Domains、推送等能力需要相应配置；不能直接保留其他团队的权限并假定可用。
4. 用 Apple Distribution 签名和对应的 App Store Connect 分发描述文件构建，或由 Xcode 自动管理分发签名。免费自签、开发签名、Ad Hoc 签名和企业签名不能直接作为同一套 TestFlight 分发流程使用。
5. 使用符合当前要求的 Xcode/SDK 构建。目前苹果要求上传到 App Store Connect 的 iOS 应用使用 Xcode 26 或更高版本及 iOS 26 SDK 或更高版本；最低支持系统与编译 SDK 是不同设置。2026-09-09 起，iOS/iPadOS 应用的最低支持系统还须为 iOS 13 或更高。
6. 完成发布构建的版本号、构建号、图标、权限说明、隐私清单及适用的第三方 SDK 要求，并如实申报加密使用情况。每次提交新构建使用符合要求且未重复的构建号。
7. 在 Mac 上通过 Xcode `Product > Archive`，在 Organizer 中选择 `Distribute App > App Store Connect`，完成校验与上传。也可通过 Transporter 上传符合要求的分发 IPA。
8. 等待苹果处理构建，在 TestFlight 填写测试说明、反馈联系方式、审核联系方式，以及需要登录时的有效测试账号和操作说明。
9. 建立外部测试组，提交 TestFlight App Review。首个外部测试构建需要完整测试审核，同一版本的后续构建可能不需要完整审核，仍以苹果处理结果为准。
10. 审核通过并开始测试后，通过邮件邀请或公开邀请链接让用户加入。

面向普通用户的测试应使用外部测试流程。Xcode 的 `TestFlight Internal Only` 构建只能用于内部测试组，不能用于外部邀请。

苹果上传技术校验、服务器构建处理和 TestFlight App Review 是不同阶段。一个阶段通过不等于后续阶段已经通过；Xcode 校验成功也不等于苹果批准分发。

## 用户安装体验与有效期

通过审核的正常流程如下：

```text
开发者上传构建
    -> 苹果处理构建
    -> 外部测试审核通过
    -> 开发者发送邀请邮件或公开邀请链接
    -> 用户安装 TestFlight 并接受邀请
    -> 用户点击安装，由苹果服务器提供应用
```

- 用户不需要提供 Apple ID 密码给开发者，不需要导入开发者证书或登记 UDID，也无需像开发签名侧载一样信任自签开发者。
- 用户使用自己的 Apple 账号和 TestFlight；安装完成后仍需要登录自己的微信账号。TestFlight 的安装授权不能替代微信的登录验证。
- 每个构建最多可测试 90 天，具体到期时间以 App Store Connect/TestFlight 的记录为准，不会因为后来接受邀请或重新安装就获得新的完整 90 天。
- 到期后需要发布可用的新构建，用户通过 TestFlight 更新。测试资格、签名或账号年费不会把原构建自动延期。
- 每个 App 最多可邀请 10,000 名外部测试者；最多 100 名内部测试者须为有相应权限的 App Store Connect 用户。
- 邀请链接或邀请中的兑换入口只是加入测试的方式，不能代替应用上传和审核。苹果审核规则 2.2 也明确禁止以有偿方式向测试者分发 TestFlight 测试资格。

## 当前可以推进到哪一步

已经确认了修改 Bundle ID 的工具源码和正常 TestFlight 分发流程，但没有确认满足“真实微信账号聊天 + 经授权的 TestFlight 分发”的客户端源码。

当前需要补齐的材料是：可授权修改和分发的微信客户端源码或构建包、对应的微信服务接入许可，以及可配置到自己开发者团队的构建与权限方案。拿到这些材料后，才能针对具体工程完成 ID 修改、签名、Archive 和上传前校验。

## 参考资料

- [Apple TestFlight 概览：90 天、测试人数和审核](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)
- [Apple 邀请外部测试者](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers/)
- [Apple 上传构建](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)
- [Apple 注册 App ID](https://developer.apple.com/help/account/identifiers/register-an-app-id/)
- [Apple 创建 App Store Connect 分发描述文件](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile/)
- [Apple 当前上传要求](https://developer.apple.com/news/upcoming-requirements/)
- [Apple 审核规则：2.2、2.5、4.1、5.2](https://developer.apple.com/app-store/review/guidelines/)
- [微信移动应用登录开发指南](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html)
- [FChat 发布说明](https://github.com/Taosky/unsigned-ipa-cn/releases/tag/fchat)

本文基于上述公开说明、GitHub 仓库内容及本地 IPA 的配置检查。未验证任何第三方微信分身可通过 TestFlight 审核，不承诺苹果或腾讯的审批结果。
