# 华为 IAP 上线配置

客户端 IAP 流程已经接入 `SupportPaymentService.ets`。正式测试前仍需完成以下配置。

## AppGallery Connect 商品

创建五个“消耗型”商品，商品 ID 必须与代码完全一致：

| 商品 ID | 价格 |
| --- | ---: |
| `support_2` | CNY 2 |
| `support_7` | CNY 7 |
| `support_18` | CNY 18 |
| `support_30` | CNY 30 |
| `support_68` | CNY 68 |

## 订单验证服务

将 `entry/src/main/ets/services/SupportPaymentService.ets` 中的
`SUPPORT_VERIFY_URL` 修改为 HTTPS 验单接口。

客户端请求：

```json
{
  "purchaseData": "华为 IAP 返回的签名订单数据",
  "expectedProductId": "support_7"
}
```

补单请求的 `expectedProductId` 为空字符串，服务端应从已验签的订单数据中读取商品 ID。

服务端必须完成：

1. 使用华为提供的公钥或 Server API 验证订单，不能只解析载荷。
2. 确认订单已支付、属于当前 App，且商品 ID 在允许列表内。
3. 正常购买时确认商品 ID 与 `expectedProductId` 一致。
4. 以 `purchaseOrderId` 建立唯一约束，重复请求返回同一成功结果。
5. 不信任客户端传入的金额、订单号或商品 ID。

成功响应：

```json
{
  "valid": true,
  "purchaseOrderId": "已验证的华为订单号",
  "purchaseToken": "已验证的购买令牌",
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

客户端只有在响应验证通过后才会调用 `finishPurchase`、显示支付成功并保存本机记录。
进入支持页面时，客户端会通过 `queryPurchases(UNFINISHED)` 自动恢复尚未完成的订单。

## 测试顺序

1. 商户服务审核通过。
2. 启用 IAP Kit 并配置应用身份、发布证书和商品。
3. 部署验单服务并填写 `SUPPORT_VERIFY_URL`。
4. 配置华为沙盒账号。
5. 分别测试成功、取消、断网、付款后强制退出和重新进入页面补单。
6. 沙盒验证通过后再提交正式版本。
