# 一刻封面赞助功能：完整恢复手册

> 本文件是赞助功能的唯一恢复入口。首发免费版不包含 IAP 页面、支付代码、
> 联网权限或赞助记录模型；完整实现永久保存在 Git 提交
> `0f38f782fd83c4a9efd01304214a19d4795067c5` 中。
>
> 不要把证书密码、私钥、`.p12`、`.cer`、`.p7b` 或服务端私钥写入本文件。

## 什么时候可以恢复

以下六项全部完成后再恢复并提交新版本：

- 华为商户服务审核通过。
- IAP Kit 已在 AppGallery Connect 中启用。
- 发布证书和发布 Profile 已配置完成。
- 五个消耗型商品已经创建并生效。
- HTTPS 订单验签服务已经部署。
- 华为沙盒账号已经完成全流程测试。

任何一项未完成，都继续发布不含赞助功能的免费版。

## 一、创建恢复分支

在项目根目录打开 PowerShell：

```powershell
git switch -c codex/restore-sponsorship
```

如果该分支名已存在，换一个新名字，例如
`codex/restore-sponsorship-v2`。

## 二、一条命令恢复客户端代码

复制下面整段到项目根目录的 PowerShell 中执行：

```powershell
git restore --source=0f38f782fd83c4a9efd01304214a19d4795067c5 -- `
  entry/src/main/ets/pages/SupportDeveloper.ets `
  entry/src/main/ets/services/SupportPaymentService.ets `
  entry/src/main/ets/model/SupportModels.ets `
  entry/src/main/ets/services/LocalStore.ets `
  entry/src/main/resources/base/profile/main_pages.json `
  entry/src/main/module.json5

git restore --source=0f38f782fd83c4a9efd01304214a19d4795067c5^ -- `
  entry/src/main/ets/components/WorksHome.ets `
  entry/src/main/ets/pages/About.ets
```

这两条命令会恢复：

- 赞助金额选择、确认、支付结果和本机记录页面。
- IAP 查询商品、创建订单、服务端验单、完成消耗和自动补单逻辑。
- `SupportRecord`、支付状态和支付结果模型。
- 本机赞助记录的读取、去重和保存。
- `SupportDeveloper` 页面路由。
- `ohos.permission.INTERNET` 权限。
- “作品 → 支持个人开发者”和“关于 → 前往赞助”两个入口。

执行后检查：

```powershell
git status --short
rg -n "IAPKit|SupportDeveloper|support_2|ohos.permission.INTERNET" entry/src/main
```

应该能搜到恢复的页面、IAP 服务、商品 ID、页面路由和联网权限。

### 将来代码改动很大时

上述命令会把 `LocalStore.ets`、`WorksHome.ets`、`About.ets`、
`main_pages.json` 和 `module.json5` 恢复成保存赞助功能时的版本。
因此必须先创建恢复分支，并在构建前查看差异：

```powershell
git diff
```

如果这些文件后来新增了其他功能，不要直接提交旧版本；使用 DevEco Studio
的差异视图，把赞助相关代码合并到最新版。三个独立文件
`SupportDeveloper.ets`、`SupportPaymentService.ets` 和
`SupportModels.ets` 可以直接恢复。

## 三、配置五个商品

在 AppGallery Connect 中为当前元服务创建五个“消耗型”商品。
商品 ID 必须逐字一致：

| 商品 ID | 价格 |
| --- | ---: |
| `support_2` | CNY 2 |
| `support_7` | CNY 7 |
| `support_18` | CNY 18 |
| `support_30` | CNY 30 |
| `support_68` | CNY 68 |

不要把这些商品建成订阅或非消耗型商品。

## 四、部署订单验签服务

客户端会把华为返回的签名订单数据发送到你的 HTTPS 接口：

```json
{
  "purchaseData": "华为 IAP 返回的签名订单数据",
  "expectedProductId": "support_7"
}
```

补单请求的 `expectedProductId` 是空字符串。服务端此时必须从经过验签的
`purchaseData` 中读取真实商品 ID。

服务端必须完成：

1. 使用华为公钥或 Server API 验证签名，不能只做 Base64/JSON 解析。
2. 确认订单已支付、属于当前元服务，商品 ID 在允许列表内。
3. 普通购买时确认商品 ID 与 `expectedProductId` 完全一致。
4. 对 `purchaseOrderId` 建立唯一约束，防止重复入账。
5. 不信任客户端传入的金额、订单号或商品 ID。
6. 重复验单时返回与首次相同的成功结果，保证接口幂等。

成功响应：

```json
{
  "valid": true,
  "purchaseOrderId": "经过验证的华为订单号",
  "purchaseToken": "经过验证的购买令牌",
  "productId": "support_7"
}
```

失败响应：

```json
{
  "valid": false,
  "purchaseOrderId": "",
  "purchaseToken": "",
  "productId": "",
  "message": "订单验证失败"
}
```

客户端只有在验单成功后才会调用 `finishPurchase`、显示支付成功并保存本机
记录。打开赞助页面时，客户端会查询 `UNFINISHED` 订单并自动补单。

## 五、填写验单地址

打开：

`entry/src/main/ets/services/SupportPaymentService.ets`

找到：

```typescript
const SUPPORT_VERIFY_URL: string = '';
```

改为真实 HTTPS 地址，例如：

```typescript
const SUPPORT_VERIFY_URL: string =
  'https://api.example.com/huawei-iap/verify';
```

要求：

- 必须以 `https://` 开头。
- 不要在客户端放私钥、华为服务端密钥或数据库密码。
- 正式环境不能使用本机、局域网或测试地址。

## 六、沙盒测试

按顺序测试，全部通过才可以上架：

1. 五个金额都能查到正确商品和价格。
2. 正常付款成功，页面显示成功且本机出现一条记录。
3. 用户取消付款，不生成记录。
4. 付款前断网，不生成错误的成功记录。
5. 付款后、验单前强制退出，再次打开赞助页面能够自动补单。
6. 同一订单重复验单不会生成多条记录。
7. 伪造或篡改 `purchaseData` 必须被服务端拒绝。
8. 服务端超时后客户端不会提示支付成功。
9. 卸载重装不会影响华为侧正式交易记录。

## 七、构建和上架填写

1. 使用发布证书和发布 Profile 构建 Release `.app` 包。
2. 上传时选择“测试和正式上架”。
3. 启动“合法性检测”和“上架自检”。
4. “应用内资费类型”如实选择包含应用内购买。
5. 随版本添加五个消耗型商品。
6. 隐私政策说明网络请求、订单数据和本机赞助记录的用途。
7. 审核备注写明：

   > 所有封面制作功能永久免费。赞助为自愿的一次性消耗型商品，
   > 不解锁功能、不移除广告、不提供数字内容。支付完成后仅在本机保存
   > 金额、时间和订单标识的简单记录，正式交易记录以华为支付平台为准。

8. 向审核人员提供可测试的商品、账号和必要说明。

## 八、提交前最后检查

```powershell
rg -n "SUPPORT_VERIFY_URL|support_[0-9]|IAPKit" entry/src/main
git diff --check
```

确认 `SUPPORT_VERIFY_URL` 不是空字符串或示例域名，并在 DevEco Studio 中
完成 Release 构建和真机测试。

## 九、出现问题时回到免费版

不要在原分支硬删或强行回滚。切回免费首发分支即可：

```powershell
git switch -
```

赞助功能的权威备份始终是：

`0f38f782fd83c4a9efd01304214a19d4795067c5`

只要该 Git 提交仍在仓库历史中，本文件第二节的命令就能恢复完整实现。
