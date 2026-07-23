import { CoverPreview } from './CoverPreview';
import { createDefaultDraft, getTemplateDefinition } from '../model/CoverModels';

interface TemplateShortcut {
  id: number;
}

const TEMPLATE_SHORTCUTS: TemplateShortcut[] = [
  {
    id: 1
  },
  {
    id: 2
  },
  {
    id: 4
  }
];

@Component
export struct CreateHome {
  private previewJson(templateId: number): string {
    return JSON.stringify(createDefaultDraft(getTemplateDefinition(templateId)));
  }

  @Builder
  private heroCover(templateId: number) {
    Stack() {
      CoverPreview({
        templateId: templateId,
        draftJson: this.previewJson(templateId)
      })
        .width('100%')
    }
    .width(220)
    .height(124)
    .borderRadius(12)
    .clip(true)
    .shadow({
      radius: 18,
      color: '#66000000',
      offsetX: 0,
      offsetY: 10
    })
  }

  @Builder
  private templateCard(item: TemplateShortcut) {
    Column({ space: 10 }) {
      CoverPreview({
        templateId: item.id,
        draftJson: this.previewJson(item.id)
      })
      .width(146)
      .height(82)
      .borderRadius(10)
      .clip(true)

      Column({ space: 3 }) {
        Text(getTemplateDefinition(item.id).name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
        Text(getTemplateDefinition(item.id).subtitle)
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width(146)
    .onClick(() => {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/CoverEditor',
        params: {
          templateId: item.id
        }
      });
    })
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('一刻封面')
              .fontSize(27)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text('让每次制作都有固定章法')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text('模板库')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.brand_primary'))
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor($r('app.color.brand_soft'))
            .borderRadius(18)
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/TemplateLibrary'
              });
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Row() {
              this.heroCover(4)
            }
            .rotate({ angle: -7 })
            .translate({ x: -34, y: 9 })
            .opacity(0.58)

            Row() {
              this.heroCover(2)
            }
            .rotate({ angle: 5 })
            .translate({ x: 34, y: 3 })
            .opacity(0.78)

            Row() {
              this.heroCover(1)
            }
          }
          .width('100%')
          .height(180)

          Text('选择一个模板，开始做封面')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 2 })

          Text('选定版式后，只需替换图片和内容')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 7 })

          Button('选择模板', { type: ButtonType.Normal })
            .width('100%')
            .height(48)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(12)
            .margin({ top: 20 })
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/TemplateLibrary'
              });
            })
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 18, bottom: 18 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(20)
        .margin({ top: 24 })

        Row() {
          Text('常用模板')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Text('查看全部')
            .fontSize(13)
            .fontColor($r('app.color.brand_primary'))
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/TemplateLibrary'
              });
            })
        }
        .width('100%')
        .margin({ top: 28, bottom: 14 })

        Scroll() {
          Row({ space: 14 }) {
            ForEach(TEMPLATE_SHORTCUTS, (item: TemplateShortcut) => {
              this.templateCard(item)
            }, (item: TemplateShortcut) => item.id.toString())
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        Row({ space: 10 }) {
          Column({ space: 5 }) {
            Text('01')
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_primary'))
            Text('选模板')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Row()
            .width(24)
            .height(1)
            .backgroundColor($r('app.color.divider'))

          Column({ space: 5 }) {
            Text('02')
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_primary'))
            Text('换内容')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Row()
            .width(24)
            .height(1)
            .backgroundColor($r('app.color.divider'))

          Column({ space: 5 }) {
            Text('03')
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_primary'))
            Text('导出封面')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 17, bottom: 17, left: 14, right: 14 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(14)
        .margin({ top: 28, bottom: 28 })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 18 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.page_background'))
  }
}
