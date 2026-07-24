import { common } from '@kit.AbilityKit';
import { SupportPaymentResult, SupportPaymentStatus } from '../model/SupportModels';

// Configure a verified checkout endpoint here after choosing a payment provider.
// The endpoint must create the order server-side and return the payment result
// through the provider's verified callback. An empty value keeps the UI honest:
// no payment is started and no local success record is written.
const SUPPORT_CHECKOUT_URL: string = '';

export class SupportPaymentService {
  static isConfigured(): boolean {
    return SUPPORT_CHECKOUT_URL.length > 0;
  }

  static async startPayment(context: common.UIAbilityContext,
    amount: number): Promise<SupportPaymentResult> {
    if (!SupportPaymentService.isConfigured()) {
      return {
        status: SupportPaymentStatus.UNAVAILABLE,
        transactionId: '',
        message: '收款方式尚未配置'
      };
    }

    const checkoutUrl: string =
      `${SUPPORT_CHECKOUT_URL}?amount=${encodeURIComponent(amount.toString())}`;
    try {
      await context.openLink(checkoutUrl);
      return {
        status: SupportPaymentStatus.PENDING,
        transactionId: '',
        message: '请在支付平台完成操作'
      };
    } catch (error) {
      return {
        status: SupportPaymentStatus.FAILED,
        transactionId: '',
        message: '暂时无法打开支付平台'
      };
    }
  }
}
