# unsigned-ipa-cn

## 本地项目目录

| 目录 | 内容 |
| --- | --- |
| [ipa/original](ipa/original/) | 原始 FChat IPA |
| [ipa/sideload](ipa/sideload/) | 手机显示名称改为“微信”的侧载包，也是重签脚本的输入 |
| [ipa/testflight](ipa/testflight/) | 当前 TestFlight 分发包及对应 JSON 构建记录 |
| [archive/testflight-b1](archive/testflight-b1/) | 因 `SC_Info` 路径被拒绝的构建 1，仅用于追溯 |
| [signing/profiles](signing/profiles/) | Apple 分发描述文件 |
| [scripts](scripts/) | IPA 构建和重签脚本 |
| [docs](docs/) | 安装说明、可行性说明、签名配置和构建报告 |

当前包：[fchat_8.0.71_appstore_b2.ipa](ipa/testflight/fchat_8.0.71_appstore_b2.ipa)，版本 `8.0.71`，构建号 `2`。

2026-10-09 最近确认：构建 2 已上传并处理完成，内部群组显示“正在测试”，外部测试已提交并显示“正在等待审核”。实际后续状态以 [App Store Connect](https://appstoreconnect.apple.com/teams/576c415c-7612-4bec-ab6e-d85fd8ceb5ea/apps/6820996068/testflight) 为准。

文档入口：[构建报告](docs/TestFlight构建报告.md) · [签名配置](docs/TestFlight签名配置.md) · [安装说明](docs/爱思助手安装IPA说明.md) · [可行性说明](docs/微信分身与TestFlight可行性说明.md)。JSON 构建记录保留生成时的内容；后续上传和审核状态记在构建报告中。

在项目根目录生成下一个构建：

```sh
swift scripts/prepare_appstore_ipa.swift 3
```

输出 IPA 和 JSON 均位于 `ipa/testflight/`，同名现有包和归档包会拒绝覆盖。签名使用本机钥匙串里的分发身份，脚本不执行上传。

`apps.json` 和 `icon/` 保留在根目录，供原仓库的应用源及图标引用使用。整理只移动文件并更新路径，没有删除 IPA 或描述文件，也没有改动包内内容。

IPA 文件仅保留在本地，已通过 `.gitignore` 排除，不随 Git 提交或推送。远程仓库保留脚本、文档、描述文件和 JSON 构建记录；克隆后需自行放入对应 IPA 才能运行构建脚本。上面的 IPA 链接用于本地文件定位。

## 原仓库说明

**常用iOS应用(砸壳IPA)收集**

*本仓库只是针对个人在用的App进行收录, 更多国际化的应用和tweaks可以看[swaggyP36000/TrollStore-IPAs](https://github.com/swaggyP36000/TrollStore-IPAs)这个仓库*

**iOS侧载玩法：** https://taosky.org/story/ios-sideload/

**微信双开教程（非开发者自签）：** https://taosky.org/story/ios-dual-wechat/


### 安装方式

1.TrollStore：应该不用特别说明，安装各种应用几乎都没有限制


2.自签（非开发者账户）：便捷方法可以看下[SideStore](https://sidestore.io/)，配置好之后，手机上（通过互联网）即可完成自签和签名刷新。配合 [LiveContainer](https://github.com/khanhduytran0/LiveContainer) 无限制“加载”使用App (可灵活注入插件)


3.证书签名：需要花钱买证书，自行研究，使用feather或轻松签导入使用

### 轻松签

Feather签名微信有闪退问题的可以试试这个

下载地址: [releases/tag/esign](https://github.com/Taosky/trollstore-ipa-cn/releases/tag/esign)

### 微信



##### 砸壳、注入净化版本（官替）

TrollStore、证书签名可正常推送，自签无法推送

下载地址: [releases/tag/wechat](https://github.com/Taosky/trollstore-ipa-cn/releases/tag/wechat)

##### 普通多开版本（无法直接推送消息）

免费自签多开教程: https://taosky.org/story/ios-dual-wechat/

下载地址: [releases/tag/fchat](https://github.com/Taosky/trollstore-ipa-cn/releases/tag/fchat)

##### 无后台推送版本（特殊包名）

TrollStore、证书签名可用，自签会改变BundleID因此不可用（不能推送）

下载地址：[releases/tag/wechat_qy](https://github.com/Taosky/trollstore-ipa-cn/releases/tag/wechat_qy)


### 酷安（去广告）

TrollStore / 证书签名 / LiveContainer 可用，非开发者自签会改变BundleID导致验证失败

下载地址: [releases/tag/coolapk](https://github.com/Taosky/unsigned-ipa-cn/releases/tag/coolapk)


### 豆瓣（去广告）

TrollStore / 证书签名 / LiveContainer 可用，自签会改变BundleID导致验证失败

下载地址: [releases/tag/douban](https://github.com/Taosky/unsigned-ipa-cn/releases/tag/douban)


### 抖音（新增解除登陆限制插件）
下载地址: [releases/tag/aweme](https://github.com/Taosky/unsigned-ipa-cn/releases/tag/aweme)


### Infuse（Pro）

下载地址: [releases/tag/infuse](https://github.com/Taosky/unsigned-ipa-cn/releases/tag/infuse)


### Spotify （EveeSpotify）

如果需要灵动岛点击和Siri正常使用，要自行配置Signtools签名，参见这个[issue](https://github.com/whoeevee/EeveeSpotify/issues/32#issuecomment-2080750016)

https://github.com/whoeevee/EeveeSpotify


### SimplyPiano
钢琴学习（使用中需要注册登陆论坛的账号才能解锁）

下载地址: [releases/tag/simplypiano](https://github.com/Taosky/unsigned-ipa-cn/releases/tag/simplypiano)


### Simple Live
简简单单的看直播

https://github.com/xiaoyaocz/dart_simple_live/releases/


### PiliPala
使用 Flutter 开发的 BiliBili 第三方客户端

https://github.com/guozhigq/pilipala/releases
