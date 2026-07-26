import {
  TemplateDefinition,
  TEMPLATE_DEFINITIONS,
  createDefaultDraft
} from '../model/CoverModels';
import { CoverPreview } from '../components/CoverPreview';
import { SystemBackButton } from '../components/SystemBackButton';

@Entry
@Component
struct TemplateLibrary {
  @Builder
  private preview(item: TemplateDefinition) {
    CoverPreview({
      templateId: item.id,
      draftJson: JSON.stringify(createDefaultDraft(item))
    })
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
    .width('100%')
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
        SystemBackButton({
          onBack: (): void => {
            this.getUIContext().getRouter().back();
          }
        })
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

          GridRow({
            columns: 12,
            gutter: { x: 12, y: 12 },
            breakpoints: {
              value: ['320vp', '600vp', '840vp'],
              reference: BreakpointsReference.ComponentSize
            }
          }) {
            ForEach(TEMPLATE_DEFINITIONS, (item: TemplateDefinition) => {
              GridCol({ span: { xs: 6, sm: 6, md: 4, lg: 4 } }) {
                this.templateCard(item)
              }
            }, (item: TemplateDefinition) => item.id.toString())
          }
          .width('100%')
        }
        .width('100%')
        .constraintSize({ maxWidth: 1120 })
        .alignSelf(ItemAlign.Center)
        .padding({ left: 16, right: 16, top: 14, bottom: 28 })
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
