import { TemplateDefinition, TEMPLATE_DEFINITIONS } from '../model/CoverModels';

@Entry
@Component
struct TemplateLibrary {
  @Builder
  private backButton() {
    Text('‹')
      .width(40)
      .height(40)
      .fontSize(32)
      .fontColor($r('app.color.text_primary'))
      .textAlign(TextAlign.Center)
      .backgroundColor($r('app.color.control_background'))
      .borderRadius(20)
      .onClick(() => {
        this.getUIContext().getRouter().back();
      })
  }

  @Builder
  private preview(item: TemplateDefinition) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor(item.id >= 8 ? '#16344E' : '#2A3038')

      if (item.id <= 3) {
        Row()
          .width('100%')
          .height(7)
          .backgroundColor(item.accent)
          .position({ x: 0, y: 0 })
        Row()
          .width(7)
          .height('100%')
          .backgroundColor(item.accent)
          .position({ x: 0, y: 0 })
        Row()
          .width(58)
          .height(22)
          .backgroundColor(item.id === 3 ? '#F3E399' : '#EA0911')
          .position({ x: 0, y: 0 })
      } else if (item.id === 4) {
        Row()
          .width('92%')
          .height('84%')
          .border({ width: 2, color: '#F04419' })
          .borderRadius(10)
          .align(Alignment.Center)
      } else if (item.id === 5) {
        Row()
          .width(45)
          .height(45)
          .border({ width: 2, color: '#FFFFFF' })
          .borderRadius(23)
          .position({ x: 90, y: 12 })
      } else if (item.id === 6 || item.id === 7) {
        Row()
          .width(74)
          .height(20)
          .backgroundColor(item.accent)
          .position({ x: 0, y: 0 })
        Text('上')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .position({ x: 132, y: 5 })
      } else {
        Row()
          .width(56)
          .height(18)
          .backgroundColor(item.id === 9 ? '#D4B366' : '#FFBF12')
          .position({ x: 0, y: 0 })
        Row({ space: 3 }) {
          ForEach([1, 2, 3, 4, 5, 6, 7], (value: number) => {
            Row()
              .width(3)
              .height(5 + value * 2)
              .backgroundColor('#879EB0')
              .borderRadius(2)
          })
        }
        .position({ x: 10, y: 65 })
      }

      Column({ space: 3 }) {
        Text(item.name)
          .fontSize(item.id >= 8 ? 12 : 11)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.id === 3 || item.id === 7 || item.id === 9 ? '#F5D977' : '#FFFFFF')
          .maxLines(1)
        Text(item.id >= 8 ? '声音值得被看见' : '替换图片与标题')
          .fontSize(7)
          .fontColor('#D7DCE2')
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 12, bottom: 9 })

      Text(item.code)
        .fontSize(8)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .padding({ left: 5, right: 5, top: 3, bottom: 3 })
        .backgroundColor('#A8000000')
        .borderRadius(8)
        .position({ x: 132, y: 65 })
    }
    .width('100%')
    .aspectRatio(16 / 9)
    .borderRadius(12)
    .clip(true)
  }

  @Builder
  private templateCard(item: TemplateDefinition) {
    Column({ space: 10 }) {
      this.preview(item)
      Column({ space: 3 }) {
        Row() {
          Text(item.name)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Text(item.code)
            .fontSize(10)
            .fontColor(item.accent)
        }
        .width('100%')
        Text(item.subtitle)
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
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
    Column() {
      Row() {
        this.backButton()
        Column({ space: 3 }) {
          Text('模板库')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('九套代码模板 · 1920 × 1080')
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        Blank()
        Text('9 套')
          .fontSize(12)
          .fontColor($r('app.color.brand_primary'))
          .padding({ left: 11, right: 11, top: 6, bottom: 6 })
          .backgroundColor($r('app.color.brand_soft'))
          .borderRadius(16)
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 14, bottom: 14 })
      .backgroundColor($r('app.color.nav_background'))

      Scroll() {
        Column({ space: 12 }) {
          Text('每套模板只固定版式，品牌、图片与内容都可替换。')
            .width('100%')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .padding({ top: 4, bottom: 4 })

          ForEach([0, 2, 4, 6, 8], (start: number) => {
            Row({ space: 12 }) {
              this.templateCard(TEMPLATE_DEFINITIONS[start])
              if (start + 1 < TEMPLATE_DEFINITIONS.length) {
                this.templateCard(TEMPLATE_DEFINITIONS[start + 1])
              } else {
                Column()
                  .layoutWeight(1)
              }
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 28 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}

