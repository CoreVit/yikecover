import { LocalStore } from '../services/LocalStore';
import { SystemBackButton } from '../components/SystemBackButton';

@Entry
@Component
struct HistoryRecords {
  @State recordCount: number = 0;
  @State confirming: boolean = false;
  @State confirmSeconds: number = 0;
  @State clearing: boolean = false;
  @State cleared: boolean = false;
  private countdownTimer: number = -1;

  aboutToAppear(): void {
    const hostContext: Context | undefined = this.getUIContext().getHostContext();
    if (hostContext !== undefined) {
      LocalStore.initialize(hostContext);
    }
    this.loadSummary();
  }

  aboutToDisappear(): void {
    this.stopCountdown();
  }

  private async loadSummary(): Promise<void> {
    this.recordCount = (await LocalStore.loadHistory()).length;
  }

  private stopCountdown(): void {
    if (this.countdownTimer >= 0) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }
  }

  private cancelConfirmation(): void {
    this.stopCountdown();
    this.confirming = false;
    this.confirmSeconds = 0;
  }

  private startConfirmation(): void {
    if (this.confirming || this.clearing) {
      return;
    }
    this.confirming = true;
    this.confirmSeconds = 3;
    this.countdownTimer = setInterval(() => {
      if (this.confirmSeconds > 1) {
        this.confirmSeconds -= 1;
      } else {
        this.confirmSeconds = 0;
        this.stopCountdown();
      }
    }, 1000);
  }

  private async clearEverything(): Promise<void> {
    if (!this.confirming || this.confirmSeconds > 0 || this.clearing) {
      return;
    }
    this.clearing = true;
    try {
      await LocalStore.clearAllLocalData();
      await this.loadSummary();
      if (this.recordCount !== 0) {
        throw new Error('历史记录清理后仍有残留');
      }
      this.confirming = false;
      this.cleared = true;
      this.getUIContext().getPromptAction().showToast({
        message: '本机数据已清空',
        duration: 1800
      });
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({
        message: '清理失败，请重试',
        duration: 1800
      });
    } finally {
      this.clearing = false;
    }
  }

  @Builder
  private dataRow(symbol: Resource, title: string, description: string,
    showDivider: boolean) {
    Column() {
      Row({ space: 12 }) {
        SymbolGlyph(symbol)
          .fontSize(20)
          .fontColor([$r('app.color.text_secondary')])
          .width(30)
        Column({ space: 3 }) {
          Text(title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Text(description)
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 14, bottom: 14 })

      if (showDivider) {
        Divider()
          .strokeWidth(1)
          .color($r('app.color.divider'))
      }
    }
    .width('100%')
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
          Text('历史记录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text(`${this.recordCount} 条本机记录`)
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
        Column({ space: 16 }) {
          Column() {
            Text('保存在本机')
              .width('100%')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 5 })
            this.dataRow($r('sys.symbol.rectangle_on_rectangle'), '草稿与已导出记录',
              '作品页中的全部记录与封面内容', true)
            this.dataRow($r('sys.symbol.plus'), '上传图片副本',
              '为了继续编辑而保存在应用目录中的图片', true)
            this.dataRow($r('sys.symbol.more'), '偏好与导出设置',
              '模板偏好、分辨率、格式与图片质量', false)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)

          Column({ space: 12 }) {
            Row({ space: 9 }) {
              SymbolGlyph($r('sys.symbol.exclamationmark_triangle'))
                .fontSize(19)
                .fontColor([$r('app.color.brand_primary')])
              Text('清空全部本机数据')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')

            Text('草稿、历史记录、上传图片副本和所有设置都会删除，应用恢复到首次使用时的默认状态。此操作无法撤销。')
              .width('100%')
              .fontSize(12)
              .lineHeight(20)
              .fontColor($r('app.color.text_secondary'))

            if (this.cleared) {
              Row({ space: 7 }) {
                SymbolGlyph($r('sys.symbol.checkmark'))
                  .fontSize(13)
                  .fontColor(['#3B7568'])
                Text('已清空，导出设置已恢复为 1080P · PNG')
                  .fontSize(11)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
            }

            if (!this.confirming) {
              Button('清空全部数据', { type: ButtonType.Normal })
                .width('100%')
                .height(46)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .backgroundColor($r('app.color.brand_primary'))
                .borderRadius(11)
                .enabled(!this.clearing)
                .onClick(() => {
                  this.startConfirmation();
                })
            } else {
              Text(this.confirmSeconds > 0 ?
                `${this.confirmSeconds} 秒后可确认清理` : '请再次确认是否清空')
                .width('100%')
                .fontSize(12)
                .fontColor($r('app.color.brand_primary'))
                .textAlign(TextAlign.Center)

              Row({ space: 10 }) {
                Button('取消', { type: ButtonType.Normal })
                  .layoutWeight(1)
                  .height(46)
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .backgroundColor($r('app.color.control_background'))
                  .borderRadius(11)
                  .enabled(!this.clearing)
                  .onClick(() => {
                    this.cancelConfirmation();
                  })

                Button(this.clearing ? '正在清理…' :
                  (this.confirmSeconds > 0 ? `等待 ${this.confirmSeconds} 秒` : '确认清空'),
                  { type: ButtonType.Normal })
                  .layoutWeight(1)
                  .height(46)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.confirmSeconds > 0 ?
                    $r('app.color.control_selected') : $r('app.color.brand_primary'))
                  .borderRadius(11)
                  .enabled(this.confirmSeconds === 0 && !this.clearing)
                  .onClick(() => {
                    this.clearEverything();
                  })
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 28 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
