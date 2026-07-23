import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { SystemBackButton } from '../components/SystemBackButton';

const REPOSITORY_URL: string = 'https://github.com/CoreVit/yikecover';

@Entry
@Component
struct About {
  private goBack(): void {
    this.getUIContext().getRouter().back();
  }

  private showOpenError(): void {
    this.getUIContext().getPromptAction().openToast({
      message: '暂时无法打开 GitHub'
    }).catch((_error: BusinessError) => {
    });
  }

  private openRepository(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (!context) {
      this.showOpenError();
      return;
    }
    context.openLink(REPOSITORY_URL).catch((_error: BusinessError) => {
      this.showOpenError();
    });
  }

  @Builder
  private branchMark() {
    Stack() {
      Column()
        .width(2)
        .height(74)
        .backgroundColor($r('app.color.source_accent'))
        .position({ x: 26, y: 20 })

      Column()
        .width(2)
        .height(40)
        .backgroundColor($r('app.color.source_accent'))
        .rotate({ angle: 42 })
        .position({ x: 40, y: 31 })

      Row()
        .width(12)
        .height(12)
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(6)
        .position({ x: 21, y: 13 })

      Row()
        .width(12)
        .height(12)
        .backgroundColor($r('app.color.source_accent'))
        .borderRadius(6)
        .position({ x: 50, y: 32 })

      Row()
        .width(12)
        .height(12)
        .backgroundColor($r('app.color.card_background'))
        .border({
          width: 2,
          color: $r('app.color.source_accent')
        })
        .borderRadius(6)
        .position({ x: 21, y: 87 })

      Text('</>')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .position({ x: 68, y: 44 })
    }
    .width(120)
    .height(112)
  }

  @Builder
  private detailRow(label: string, value: string, showDivider: boolean) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Blank()
        Text(value)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding({ top: 15, bottom: 15 })

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
            this.goBack();
          }
        })

        Text('关于一刻封面')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ left: 13 })

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 18, right: 18 })

      Scroll() {
        Column() {
          Column() {
            Row() {
              Row({ space: 7 }) {
                Row()
                  .width(7)
                  .height(7)
                  .backgroundColor($r('app.color.source_accent'))
                  .borderRadius(4)
                Text('OPEN SOURCE')
                  .fontSize(11)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.source_accent'))
                  .letterSpacing(1)
              }
              .padding({ left: 11, right: 11, top: 7, bottom: 7 })
              .backgroundColor($r('app.color.source_soft'))
              .borderRadius(16)

              Blank()

              this.branchMark()
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)

            Text('代码公开，\n改进也公开。')
              .width('100%')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .lineHeight(39)
              .margin({ top: 4 })

            Text('一刻封面的项目源码公开托管在 GitHub。你可以查看实现、反馈问题，也可以参与改进。')
              .width('100%')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .lineHeight(22)
              .margin({ top: 14 })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 22 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(20)

          Column() {
            Row() {
              Column({ space: 4 }) {
                Text('GitHub 仓库')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                Text('CoreVit / yikecover')
                  .fontSize(19)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Text('PUBLIC')
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.source_accent'))
                .padding({ left: 8, right: 8, top: 5, bottom: 5 })
                .border({
                  width: 1,
                  color: $r('app.color.source_accent')
                })
                .borderRadius(12)
            }
            .width('100%')

            Text('github.com/CoreVit/yikecover')
              .width('100%')
              .fontSize(12)
              .fontColor($r('app.color.text_muted'))
              .margin({ top: 13 })

            Button({ type: ButtonType.Normal }) {
              Row({ space: 7 }) {
                Text('查看 GitHub 源码')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
                  .fontSize(16)
                  .fontColor(['#FFFFFF'])
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
            }
              .width('100%')
              .height(46)
              .backgroundColor($r('app.color.brand_primary'))
              .borderRadius(12)
              .margin({ top: 18 })
              .onClick(() => {
                this.openRepository();
              })

            Text('源码与使用说明以 GitHub 仓库中的最新内容为准。')
              .width('100%')
              .fontSize(11)
              .fontColor($r('app.color.text_muted'))
              .textAlign(TextAlign.Center)
              .margin({ top: 11 })
          }
          .width('100%')
          .padding(18)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(18)
          .margin({ top: 14 })

          Text('关于项目')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          Text('一刻封面希望把重复的封面排版，变成几步清楚、稳定的操作：选择模板，替换内容，然后导出。')
            .width('100%')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(23)
            .padding(18)
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(16)

          Text('项目信息')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          Column() {
            this.detailRow('版本', '1.0.0', true)
            this.detailRow('开发者', 'CoreVit', true)
            this.detailRow('运行平台', 'HarmonyOS', false)
          }
          .width('100%')
          .padding({ left: 17, right: 17 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)

          Text('© 2026 CoreVit')
            .width('100%')
            .fontSize(11)
            .fontColor($r('app.color.text_muted'))
            .textAlign(TextAlign.Center)
            .margin({ top: 28, bottom: 30 })
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 10 })
      }
      .align(Alignment.TopStart)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
