import { common } from '@kit.AbilityKit';
import { SystemBackButton } from '../components/SystemBackButton';
import { SupportRecord, SupportPaymentResult, SupportPaymentStatus } from '../model/SupportModels';
import { LocalStore } from '../services/LocalStore';
import { SupportPaymentService } from '../services/SupportPaymentService';

interface SupportTier {
  amount: number;
  title: string;
}

const REPOSITORY_URL: string = 'https://github.com/CoreVit/yikecover';
const SUPPORT_TIERS: SupportTier[] = [
  { amount: 1, title: '一点心意' },
  { amount: 6, title: '请喝饮料' },
  { amount: 18, title: '大力支持' }
];

@Entry
@Component
struct SupportDeveloper {
  @State selectedAmount: number = 6;
  @State customMode: boolean = false;
  @State customAmountText: string = '';
  @State confirming: boolean = false;
  @State paying: boolean = false;
  @State resultStatus: SupportPaymentStatus | undefined = undefined;
  @State resultMessage: string = '';
  @State records: SupportRecord[] = [];

  aboutToAppear(): void {
    const hostContext: Context | undefined = this.getUIContext().getHostContext();
    if (hostContext !== undefined) {
      LocalStore.initialize(hostContext);
    }
    this.loadRecords();
  }

  private async loadRecords(): Promise<void> {
    this.records = await LocalStore.loadSupportRecords();
  }

  private amount(): number {
    if (!this.customMode) {
      return this.selectedAmount;
    }
    const value: number = Number(this.customAmountText);
    if (!Number.isFinite(value)) {
      return 0;
    }
    return Math.floor(value);
  }

  private amountValid(): boolean {
    const value: number = this.amount();
    return value >= 1 && value <= 200;
  }

  private tierName(): string {
    const value: number = this.amount();
    for (let index: number = 0; index < SUPPORT_TIERS.length; index++) {
      if (SUPPORT_TIERS[index].amount === value) {
        return SUPPORT_TIERS[index].title;
      }
    }
    return '随心支持';
  }

  private selectTier(tier: SupportTier): void {
    this.selectedAmount = tier.amount;
    this.customMode = false;
    this.customAmountText = '';
    this.confirming = false;
    this.resultStatus = undefined;
  }

  private selectCustom(): void {
    this.customMode = true;
    this.confirming = false;
    this.resultStatus = undefined;
  }

  private continueToConfirmation(): void {
    if (!this.amountValid()) {
      this.getUIContext().getPromptAction().showToast({
        message: '请输入 1～200 元的整数金额',
        duration: 1800
      });
      return;
    }
    this.confirming = true;
    this.resultStatus = undefined;
  }

  private async startPayment(): Promise<void> {
    if (this.paying || !this.amountValid()) {
      return;
    }
    const context: common.UIAbilityContext =
      this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (!context) {
      this.resultStatus = SupportPaymentStatus.FAILED;
      this.resultMessage = '暂时无法打开支付平台';
      this.confirming = false;
      return;
    }

    this.paying = true;
    const result: SupportPaymentResult =
      await SupportPaymentService.startPayment(context, this.amount());
    this.paying = false;
    this.confirming = false;
    this.resultStatus = result.status;
    this.resultMessage = result.message;

    if (result.status === SupportPaymentStatus.SUCCESS) {
      const record: SupportRecord = {
        id: result.transactionId.length > 0 ? result.transactionId : `support-${Date.now()}`,
        amount: this.amount(),
        tierName: this.tierName(),
        paidAt: new Date().toLocaleString(),
        transactionId: result.transactionId
      };
      await LocalStore.saveSupportRecord(record);
      await this.loadRecords();
    }
  }

  private openRepository(): void {
    const context: common.UIAbilityContext =
      this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (!context) {
      return;
    }
    context.openLink(REPOSITORY_URL).catch(() => {
      this.getUIContext().getPromptAction().showToast({
        message: '暂时无法打开 GitHub',
        duration: 1800
      });
    });
  }

  private resetResult(): void {
    this.resultStatus = undefined;
    this.resultMessage = '';
    this.confirming = false;
  }

  @Builder
  private thankYouMark() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(122)
        .height(68)
        .backgroundColor($r('app.color.control_background'))
        .border({
          width: 1,
          color: $r('app.color.divider')
        })
        .borderRadius(11)
        .rotate({ angle: -6 })
        .translate({ x: -16, y: 5 })

      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.card_background'))
        Row()
          .width(34)
          .height(96)
          .backgroundColor($r('app.color.brand_primary'))
          .rotate({ angle: 17 })
          .translate({ x: -40, y: 0 })
        Text('谢谢')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.source_accent'))
          .padding({ left: 13, right: 13, top: 7, bottom: 7 })
          .border({
            width: 2,
            color: $r('app.color.source_accent')
          })
          .borderRadius(7)
          .rotate({ angle: -7 })
      }
      .width(132)
      .height(74)
      .borderRadius(11)
      .clip(true)
      .shadow({
        radius: 12,
        color: '#26000000',
        offsetX: 0,
        offsetY: 6
      })
      .translate({ x: 15, y: 0 })
    }
    .width('100%')
    .height(112)
  }

  @Builder
  private tierCard(tier: SupportTier) {
    Column({ space: 6 }) {
      Text(tier.title)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)
      Text(`¥${tier.amount}`)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedAmount === tier.amount && !this.customMode ?
          $r('app.color.brand_primary') : $r('app.color.text_primary'))
      Text(this.selectedAmount === tier.amount && !this.customMode ? '已选择' : ' ')
        .fontSize(9)
        .fontColor($r('app.color.brand_primary'))
    }
    .layoutWeight(1)
    .height(96)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.selectedAmount === tier.amount && !this.customMode ?
      $r('app.color.brand_soft') : $r('app.color.card_background'))
    .border({
      width: this.selectedAmount === tier.amount && !this.customMode ? 2 : 1,
      color: this.selectedAmount === tier.amount && !this.customMode ?
        $r('app.color.brand_primary') : $r('app.color.divider')
    })
    .borderRadius(14)
    .onClick(() => {
      this.selectTier(tier);
    })
  }

  @Builder
  private selectionContent() {
    Column() {
      this.thankYouMark()

      Text('如果一刻封面对你有帮助，\n可以请独立开发者喝杯饮料。')
        .width('100%')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .lineHeight(31)
        .textAlign(TextAlign.Center)
        .margin({ top: 5 })

      Text('所有功能都可以继续免费使用。支持完全自愿，不会解锁额外功能。')
        .width('100%')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
        .textAlign(TextAlign.Center)
        .margin({ top: 10 })

      Row({ space: 9 }) {
        ForEach(SUPPORT_TIERS, (tier: SupportTier) => {
          this.tierCard(tier)
        }, (tier: SupportTier) => tier.amount.toString())
      }
      .width('100%')
      .margin({ top: 24 })

      Column({ space: 10 }) {
        Row() {
          Column({ space: 3 }) {
            Text('随心支持')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
            Text('输入 1～200 元的整数金额')
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text(this.customMode ? '已选择' : '自定义金额')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.customMode ? '#FFFFFF' : $r('app.color.brand_primary'))
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor(this.customMode ?
              $r('app.color.brand_primary') : $r('app.color.brand_soft'))
            .borderRadius(15)
        }
        .width('100%')

        if (this.customMode) {
          Row({ space: 8 }) {
            Text('¥')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            TextInput({
              text: this.customAmountText,
              placeholder: '例如 30'
            })
              .layoutWeight(1)
              .height(44)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .placeholderColor($r('app.color.text_muted'))
              .backgroundColor($r('app.color.control_background'))
              .borderRadius(10)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.customAmountText = value.replace(/[^0-9]/g, '').slice(0, 3);
              })
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(15)
      .backgroundColor(this.customMode ?
        $r('app.color.brand_soft') : $r('app.color.card_background'))
      .borderRadius(14)
      .margin({ top: 12 })
      .onClick(() => {
        this.selectCustom();
      })

      Button(this.amountValid() ? `支持 ¥${this.amount()}` : '请输入支持金额',
        { type: ButtonType.Normal })
        .width('100%')
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor(this.amountValid() ?
          $r('app.color.brand_primary') : $r('app.color.control_selected'))
        .borderRadius(12)
        .margin({ top: 20 })
        .enabled(this.amountValid())
        .onClick(() => {
          this.continueToConfirmation();
        })

      Text('无需登录 · 正式交易记录以支付平台为准')
        .width('100%')
        .fontSize(10)
        .fontColor($r('app.color.text_muted'))
        .textAlign(TextAlign.Center)
        .margin({ top: 10 })
    }
    .width('100%')
  }

  @Builder
  private confirmationCard() {
    Column({ space: 16 }) {
      Text('确认支持')
        .width('100%')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Row() {
        Column({ space: 4 }) {
          Text(this.tierName())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Text('一次性自愿支持')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(`¥${this.amount()}.00`)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.brand_primary'))
      }
      .width('100%')
      .padding({ top: 4, bottom: 4 })

      Divider().color($r('app.color.divider'))

      Row() {
        Text('账号')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        Blank()
        Text('无需登录')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.source_accent'))
      }
      .width('100%')

      Text('支持完全自愿，不会解锁额外功能。支付完成后，正式交易记录由支付平台保存。')
        .width('100%')
        .fontSize(11)
        .lineHeight(18)
        .fontColor($r('app.color.text_secondary'))

      Row({ space: 10 }) {
        Button('返回修改', { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(46)
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.control_background'))
          .borderRadius(11)
          .enabled(!this.paying)
          .onClick(() => {
            this.confirming = false;
          })

        Button(this.paying ? '正在打开…' : `确认支持 ¥${this.amount()}`,
          { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(46)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(11)
          .enabled(!this.paying)
          .onClick(() => {
            this.startPayment();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(18)
  }

  @Builder
  private resultContent() {
    Column() {
      if (this.resultStatus === SupportPaymentStatus.SUCCESS) {
        this.thankYouMark()
        Text('谢谢你的支持')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 8 })
        Text('你的这份心意我收到了。\n谢谢你愿意支持这件小而认真的事。')
          .fontSize(13)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .margin({ top: 10 })
      } else if (this.resultStatus === SupportPaymentStatus.PENDING) {
        Text('正在确认支付结果')
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('如果已经扣款，请不要重复支付。\n正式交易结果请以支付平台为准。')
          .fontSize(13)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .margin({ top: 12 })
      } else if (this.resultStatus === SupportPaymentStatus.UNAVAILABLE) {
        Text('支持功能暂未开放')
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('页面已经准备好，但开发者还没有配置经过验证的收款方式。你仍然可以在 GitHub 查看和支持项目。')
          .fontSize(13)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .margin({ top: 12 })
      } else if (this.resultStatus === SupportPaymentStatus.CANCELLED) {
        Text('支付已取消')
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('没有产生费用，你可以随时再回来。')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 12 })
      } else {
        Text('支付未完成')
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text(this.resultMessage.length > 0 ? this.resultMessage :
          '本次没有完成支付，请稍后重试。')
          .fontSize(13)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .margin({ top: 12 })
      }

      if (this.resultStatus === SupportPaymentStatus.SUCCESS) {
        Row({ space: 10 }) {
          Button('完成', { type: ButtonType.Normal })
            .layoutWeight(1)
            .height(46)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(11)
            .onClick(() => {
              this.getUIContext().getRouter().back();
            })
          Button('查看 GitHub', { type: ButtonType.Normal })
            .layoutWeight(1)
            .height(46)
            .fontSize(14)
            .fontColor($r('app.color.source_accent'))
            .backgroundColor($r('app.color.source_soft'))
            .borderRadius(11)
            .onClick(() => {
              this.openRepository();
            })
        }
        .width('100%')
        .margin({ top: 24 })
      } else {
        Button(this.resultStatus === SupportPaymentStatus.UNAVAILABLE ?
          '查看 GitHub' : '返回支持页面', { type: ButtonType.Normal })
          .width('100%')
          .height(46)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor(this.resultStatus === SupportPaymentStatus.UNAVAILABLE ?
            $r('app.color.source_accent') : $r('app.color.brand_primary'))
          .borderRadius(11)
          .margin({ top: 24 })
          .onClick(() => {
            if (this.resultStatus === SupportPaymentStatus.UNAVAILABLE) {
              this.openRepository();
            } else {
              this.resetResult();
            }
          })

        if (this.resultStatus === SupportPaymentStatus.UNAVAILABLE) {
          Text('返回选择金额')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .padding({ top: 14, bottom: 4, left: 16, right: 16 })
            .onClick(() => {
              this.resetResult();
            })
        }
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 30, bottom: 24 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(18)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private localRecords() {
    Column() {
      Text('本机支持记录')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      if (this.records.length === 0) {
        Text('支付成功后，本机会在这里保留一份简单记录。卸载应用或清除本机数据后，记录可能消失。')
          .width('100%')
          .fontSize(11)
          .lineHeight(19)
          .fontColor($r('app.color.text_secondary'))
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(14)
      } else {
        Column() {
          ForEach(this.records, (record: SupportRecord, index: number) => {
            Column() {
              Row() {
                Column({ space: 4 }) {
                  Text(record.tierName)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                  Text(`${record.paidAt} · 支付成功`)
                    .fontSize(10)
                    .fontColor($r('app.color.text_secondary'))
                }
                .alignItems(HorizontalAlign.Start)
                Blank()
                Text(`¥${record.amount}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.brand_primary'))
              }
              .width('100%')
              .padding({ top: 14, bottom: 14 })
              if (index < this.records.length - 1) {
                Divider().color($r('app.color.divider'))
              }
            }
            .width('100%')
          }, (record: SupportRecord) => record.id)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(14)

        Text('记录仅保存在本机，正式交易记录请以支付平台为准。')
          .width('100%')
          .fontSize(10)
          .fontColor($r('app.color.text_muted'))
          .margin({ top: 9 })
      }
    }
    .width('100%')
    .margin({ top: 28, bottom: 28 })
  }

  build() {
    Column() {
      Row() {
        SystemBackButton({
          onBack: (): void => {
            this.getUIContext().getRouter().back();
          }
        })
        Column({ space: 3 }) {
          Text('支持一刻封面')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('一次性支持 · 无需登录')
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 14, bottom: 14 })
      .backgroundColor($r('app.color.nav_background'))

      Scroll() {
        Column() {
          if (this.resultStatus !== undefined) {
            this.resultContent()
          } else if (this.confirming) {
            this.confirmationCard()
          } else {
            this.selectionContent()
          }

          if (this.resultStatus === undefined && !this.confirming) {
            this.localRecords()
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 18 })
      }
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
