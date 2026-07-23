import { CoverPreview } from './CoverPreview';
import {
  TEMPLATE_DEFINITIONS,
  TemplateDefinition,
  createDefaultDraft,
  getTemplateDefinition
} from '../model/CoverModels';

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
  @State currentHeroIndex: number = 0;

  private previewJson(templateId: number): string {
    return JSON.stringify(createDefaultDraft(getTemplateDefinition(templateId)));
  }

  private currentHeroTemplate(): TemplateDefinition {
    return TEMPLATE_DEFINITIONS[this.currentHeroIndex];
  }

  private openTemplate(templateId: number): void {
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/CoverEditor',
      params: {
        templateId: templateId
      }
    });
  }

  @Builder
  private heroCover(item: TemplateDefinition) {
    Column() {
      CoverPreview({
        templateId: item.id,
        draftJson: this.previewJson(item.id)
      })
      .width('100%')
      .aspectRatio(16 / 9)
      .borderRadius(13)
      .clip(true)
      .shadow({
        radius: 16,
        color: '#44000000',
        offsetX: 0,
        offsetY: 8
      })
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 6, bottom: 24 })
    .onClick(() => {
      this.openTemplate(item.id);
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
      this.openTemplate(item.id);
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
          Swiper() {
            ForEach(TEMPLATE_DEFINITIONS, (item: TemplateDefinition) => {
              this.heroCover(item)
            }, (item: TemplateDefinition) => item.id.toString())
          }
          .index(this.currentHeroIndex)
          .loop(true)
          .autoPlay(false)
          .duration(360)
          .curve(Curve.Friction)
          .itemSpace(10)
          .prevMargin(22)
          .nextMargin(22)
          .indicator(
            new DotIndicator()
              .itemWidth(5)
              .itemHeight(5)
              .selectedItemWidth(16)
              .selectedItemHeight(5)
              .color($r('app.color.divider'))
              .selectedColor($r('app.color.brand_primary'))
              .bottom(2)
          )
          .onChange((index: number) => {
            this.currentHeroIndex = index;
          })
          .width('100%')
          .height(216)

          Row({ space: 6 }) {
            Text(this.currentHeroTemplate().code)
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentHeroTemplate().accent)
            Text(this.currentHeroTemplate().name)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
            Text(this.currentHeroTemplate().subtitle)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(22)

          Text('选择一个模板，开始做封面')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 5 })

          Text('选定版式后，只需替换图片和内容')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 7 })

          Button(`使用${this.currentHeroTemplate().name}`, { type: ButtonType.Normal })
            .width('100%')
            .height(48)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(12)
            .margin({ top: 20 })
            .onClick(() => {
              this.openTemplate(this.currentHeroTemplate().id);
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
