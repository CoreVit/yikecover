import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { iap } from '@kit.IAPKit';
import { http } from '@kit.NetworkKit';
import { SupportPaymentResult, SupportPaymentStatus } from '../model/SupportModels';

// Fill this after deploying the order verification endpoint.
// The endpoint must verify Huawei's signed purchaseData and return the verified
// purchaseOrderId, purchaseToken, and productId. Never put a private key in the app.
const SUPPORT_VERIFY_URL: string = '';

interface VerifiedPurchase {
  valid: boolean;
  purchaseOrderId: string;
  purchaseToken: string;
  productId: string;
  message?: string;
}

interface VerifyPurchaseRequest {
  purchaseData: string;
  expectedProductId: string;
}

export class SupportPaymentService {
  static isConfigured(): boolean {
    return SUPPORT_VERIFY_URL.startsWith('https://');
  }

  static productIdForAmount(amount: number): string {
    if (amount === 2) {
      return 'support_2';
    }
    if (amount === 7) {
      return 'support_7';
    }
    if (amount === 18) {
      return 'support_18';
    }
    if (amount === 30) {
      return 'support_30';
    }
    if (amount === 68) {
      return 'support_68';
    }
    return '';
  }

  private static unavailable(message: string): SupportPaymentResult {
    return {
      status: SupportPaymentStatus.UNAVAILABLE,
      transactionId: '',
      message: message
    };
  }

  private static failed(message: string): SupportPaymentResult {
    return {
      status: SupportPaymentStatus.FAILED,
      transactionId: '',
      message: message
    };
  }

  private static errorResult(error: BusinessError): SupportPaymentResult {
    if (error.code === iap.IAPErrorCode.USER_CANCELED) {
      return {
        status: SupportPaymentStatus.CANCELLED,
        transactionId: '',
        message: '支付已取消'
      };
    }
    if (error.code === iap.IAPErrorCode.APP_NOT_AUTHORIZED ||
      error.code === iap.IAPErrorCode.INVALID_PRODUCT) {
      return SupportPaymentService.unavailable('应用内商品尚未启用');
    }
    if (error.code === iap.IAPErrorCode.ACCOUNT_NOT_LOGGED_IN) {
      return SupportPaymentService.failed('请先登录华为账号后再试');
    }
    if (error.code === iap.IAPErrorCode.NETWORK_ERROR) {
      return SupportPaymentService.failed('网络连接异常，请稍后重试');
    }
    if (error.code === iap.IAPErrorCode.ACCOUNT_TERRITORY_NOT_SUPPORTED ||
      error.code === iap.IAPErrorCode.PRODUCT_TERRITORY_NOT_SUPPORTED) {
      return SupportPaymentService.unavailable('当前账号所在国家或地区暂不支持应用内支付');
    }
    if (error.code === iap.IAPErrorCode.USER_NOT_ALLOWED) {
      return SupportPaymentService.failed('当前账号暂时无法完成购买');
    }
    return SupportPaymentService.failed('支付未完成，请稍后重试');
  }

  private static async verifyPurchase(purchaseData: string,
    expectedProductId: string): Promise<VerifiedPurchase> {
    const client: http.HttpRequest = http.createHttp();
    const requestBody: VerifyPurchaseRequest = {
      purchaseData: purchaseData,
      expectedProductId: expectedProductId
    };
    try {
      const response: http.HttpResponse = await client.request(SUPPORT_VERIFY_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        extraData: JSON.stringify(requestBody),
        connectTimeout: 15000,
        readTimeout: 15000
      });
      if (response.responseCode < 200 || response.responseCode >= 300 ||
        typeof response.result !== 'string') {
        throw new Error('订单验证服务暂时不可用');
      }
      return JSON.parse(response.result) as VerifiedPurchase;
    } finally {
      client.destroy();
    }
  }

  private static async verifyAndFinish(context: common.UIAbilityContext,
    purchaseData: string, expectedProductId: string): Promise<SupportPaymentResult> {
    const verified: VerifiedPurchase =
      await SupportPaymentService.verifyPurchase(purchaseData, expectedProductId);
    if (!verified.valid || verified.productId !== expectedProductId ||
      verified.purchaseOrderId.length === 0 || verified.purchaseToken.length === 0) {
      return SupportPaymentService.failed(
        verified.message !== undefined ? verified.message : '订单验证失败，请勿重复支付');
    }

    await iap.finishPurchase(context, {
      productType: iap.ProductType.CONSUMABLE,
      purchaseToken: verified.purchaseToken,
      purchaseOrderId: verified.purchaseOrderId
    });
    return {
      status: SupportPaymentStatus.SUCCESS,
      transactionId: verified.purchaseOrderId,
      message: '支付成功',
      amount: SupportPaymentService.amountForProductId(verified.productId)
    };
  }

  static async startPayment(context: common.UIAbilityContext,
    amount: number): Promise<SupportPaymentResult> {
    const productId: string = SupportPaymentService.productIdForAmount(amount);
    if (productId.length === 0) {
      return SupportPaymentService.failed('请选择有效的支持金额');
    }
    if (!SupportPaymentService.isConfigured()) {
      return SupportPaymentService.unavailable('订单验证服务尚未配置');
    }

    try {
      const products: iap.Product[] = await iap.queryProducts(context, {
        productType: iap.ProductType.CONSUMABLE,
        productIds: [productId]
      });
      if (products.length !== 1 || products[0].id !== productId) {
        return SupportPaymentService.unavailable('应用内商品尚未启用');
      }

      const result: iap.CreatePurchaseResult = await iap.createPurchase(context, {
        productId: productId,
        productType: iap.ProductType.CONSUMABLE,
        developerPayload: `support:${productId}:${Date.now()}`
      });
      return await SupportPaymentService.verifyAndFinish(
        context, result.purchaseData, productId);
    } catch (error) {
      const businessError: BusinessError = error as BusinessError;
      if (typeof businessError.code === 'number') {
        return SupportPaymentService.errorResult(businessError);
      }
      return SupportPaymentService.failed('订单确认失败，请勿重复支付，稍后将自动补单');
    }
  }

  static async restorePendingPayments(context: common.UIAbilityContext):
    Promise<SupportPaymentResult[]> {
    if (!SupportPaymentService.isConfigured()) {
      return [];
    }

    const restored: SupportPaymentResult[] = [];
    try {
      let continuationToken: string | undefined = undefined;
      do {
        const result: iap.QueryPurchaseResult = await iap.queryPurchases(context, {
          productType: iap.ProductType.CONSUMABLE,
          queryType: iap.PurchaseQueryType.UNFINISHED,
          continuationToken: continuationToken
        });
        for (let index: number = 0; index < result.purchaseDataList.length; index++) {
          // The verifier obtains and validates the actual product ID from purchaseData.
          // Passing an empty expected ID tells it this is a recovery request.
          const verified: VerifiedPurchase =
            await SupportPaymentService.verifyPurchase(result.purchaseDataList[index], '');
          const amount: number = SupportPaymentService.amountForProductId(verified.productId);
          if (!verified.valid || amount === 0) {
            continue;
          }
          await iap.finishPurchase(context, {
            productType: iap.ProductType.CONSUMABLE,
            purchaseToken: verified.purchaseToken,
            purchaseOrderId: verified.purchaseOrderId
          });
          restored.push({
            status: SupportPaymentStatus.SUCCESS,
            transactionId: verified.purchaseOrderId,
            message: '支付成功',
            amount: amount
          });
        }
        continuationToken = result.continuationToken;
      } while (continuationToken !== undefined && continuationToken.length > 0);
    } catch (error) {
      // Recovery is best-effort. Unfinished purchases remain queryable next time.
    }
    return restored;
  }

  static amountForProductId(productId: string): number {
    if (productId === 'support_2') {
      return 2;
    }
    if (productId === 'support_7') {
      return 7;
    }
    if (productId === 'support_18') {
      return 18;
    }
    if (productId === 'support_30') {
      return 30;
    }
    if (productId === 'support_68') {
      return 68;
    }
    return 0;
  }
}
