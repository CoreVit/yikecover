interface TemplateShortcut {
  id: number;
  title: string;
  subtitle: string;
  number: string;
  accent: string;
}

const TEMPLATE_SHORTCUTS: TemplateShortcut[] = [
  {
    id: 1,
    title: '经典拍案',
    subtitle: '异形红橙底板',
    number: '01',
    accent: '#F03A2B'
  },
  {
    id: 2,
    title: '经典分集',
    subtitle: '同母版右上分集',
    number: '02',
    accent: '#D12722'
  },
  {
    id: 3,
    title: '美食分集',
    subtitle: '明亮暖色构图',
    number: '04',
    accent: '#F2A526'
  }
];

@Component
export struct CreateHome {
  @Builder
  private heroCover(title: string, label: string, accent: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#252A34')

      Row()
        .width(74)
        .height(120)
        .backgroundColor(accent)
        .rotate({ angle: 18 })
        .translate({ x: -22, y: -6 })

      Column({ space: 3 }) {
        Text(label)
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 14, bottom: 12 })

      Text('一刻封面')
        .fontSize(8)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .padding({ left: 6, right: 6, top: 3, bottom: 3 })
        .backgroundColor(accent)
        .borderRadius(3)
        .position({ x: 10, y: 9 })
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
      Stack({ alignContent: Alignment.BottomStart }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#242832')

        Row()
          .width(48)
          .height(96)
          .backgroundColor(item.accent)
          .rotate({ angle: 16 })
          .translate({ x: -16, y: -4 })

        Text(item.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 10, bottom: 9 })

        Text(item.number)
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 5, right: 5, top: 3, bottom: 3 })
          .backgroundColor('#B8000000')
          .borderRadius(4)
          .position({ x: 118, y: 55 })
      }
      .width(146)
      .height(82)
      .borderRadius(10)
      .clip(true)

      Column({ space: 3 }) {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
        Text(item.subtitle)
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width(146)
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
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Row() {
              this.heroCover('美食分集', '当期推荐', '#E7A322')
            }
            .rotate({ angle: -7 })
            .translate({ x: -34, y: 9 })
            .opacity(0.58)

            Row() {
              this.heroCover('经典分集', '系列内容', '#C8322B')
            }
            .rotate({ angle: 5 })
            .translate({ x: 34, y: 3 })
            .opacity(0.78)

            Row() {
              this.heroCover('经典拍案', '今日封面', '#F04A32')
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
