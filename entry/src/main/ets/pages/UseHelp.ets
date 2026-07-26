import { SystemBackButton } from '../components/SystemBackButton';

interface HelpStep {
  code: string;
  title: string;
  description: string;
}

interface HelpQuestion {
  question: string;
  answer: string;
}

const HELP_STEPS: HelpStep[] = [
  {
    code: '01',
    title: '选择模板',
    description: '在制作页左右滑动预览九套模板，或进入模板库查看全部版式。模板只固定设计，品牌、图片和内容都可以替换。'
  },
  {
    code: '02',
    title: '上传主图',
    description: '需要主图的模板会显示上传区域。通过系统相册选择图片后，应用会按 16:9 居中裁切并刷新预览。'
  },
  {
    code: '03',
    title: '填写封面内容',
    description: '按照当前模板显示的字段填写品牌和标题。文字会实时预览，字号、颜色、位置与阴影由模板自动确定。'
  },
  {
    code: '04',
    title: '补充发布信息',
    description: '可以添加最多十个标签并选择发布日期。标签和日期用于自动整合文案，不会绘制到封面图片中。'
  },
  {
    code: '05',
    title: '检查导出设置',
    description: '编辑页会显示当前分辨率与格式。需要修改时进入导出设置；新的参数会自动保存，并供所有封面共用。'
  },
  {
    code: '06',
    title: '保存到相册',
    description: '点击保存后先等待封面生成，再在系统确认窗口中选择“允许”。保存成功的封面会同时出现在作品页的已导出列表。'
  }
];

const HELP_QUESTIONS: HelpQuestion[] = [
  {
    question: '什么情况下会生成草稿？',
    answer: '只打开编辑页不会生成草稿。修改过品牌、标题、图片或其他内容后返回，应用才会保存草稿并显示提示。'
  },
  {
    question: '为什么有些模板没有主图或分集选项？',
    answer: '编辑器只显示当前模板真正支持的能力。播客信息卡不需要主图；没有分集设计的模板也不会显示分集控件。'
  },
  {
    question: '保存成功后在哪里查看？',
    answer: '图片保存在系统相册中，作品页的“已导出”也会保留一条本机记录。如果系统询问是否允许保存，请选择“允许”。'
  },
  {
    question: '图片、草稿和设置存在哪里？',
    answer: '上传图片副本、草稿、历史记录与导出设置都保存在当前设备。可在“历史记录”页面清空全部本机数据并恢复默认设置。'
  }
];

@Entry
@Component
struct UseHelp {
  private goBack(): void {
    this.getUIContext().getRouter().back();
  }

  private openTemplateLibrary(): void {
    try {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/TemplateLibrary'
      });
    } catch (_error) {
    }
  }

  private openExportSettings(): void {
    try {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/ExportSettings'
      });
    } catch (_error) {
    }
  }

  @Builder
  private processNode(code: string, label: string) {
    Column({ space: 5 }) {
      Text(code)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.brand_primary'))
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
    }
    .layoutWeight(1)
  }

  @Builder
  private stepCard(step: HelpStep) {
    Column() {
      Row() {
        Text(step.code)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.brand_primary'))
          .padding({ left: 9, right: 9, top: 6, bottom: 6 })
          .backgroundColor($r('app.color.brand_soft'))
          .borderRadius(12)
        Blank()
      }
      .width('100%')

      Text(step.title)
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 14 })

      Text(step.description)
        .width('100%')
        .fontSize(13)
        .lineHeight(21)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(17)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  @Builder
  private questionCard(item: HelpQuestion) {
    Column({ space: 8 }) {
      Text(item.question)
        .width('100%')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text(item.answer)
        .width('100%')
        .fontSize(12)
        .lineHeight(20)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(15)
  }

  @Builder
  private actionButton(label: string, primary: boolean, action: () => void) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 7 }) {
        Text(label)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(primary ? '#FFFFFF' : $r('app.color.text_primary'))
        SymbolGlyph($r('sys.symbol.chevron_forward'))
          .fontSize(15)
          .fontColor([primary ? '#FFFFFF' : $r('app.color.text_secondary')])
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .height(46)
    .backgroundColor(primary ?
      $r('app.color.brand_primary') : $r('app.color.control_background'))
    .borderRadius(12)
    .onClick(() => {
      action();
    })
  }

  build() {
    Column() {
      Row() {
        SystemBackButton({
          onBack: (): void => {
            this.goBack();
          }
        })
        Column({ space: 3 }) {
          Text('使用帮助')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('从选择模板到保存相册')
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
          Column() {
            Text('三步完成一张封面')
              .width('100%')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text('模板负责版式，你只需要替换图片和内容。')
              .width('100%')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })

            Row({ space: 10 }) {
              this.processNode('01', '选模板')
              Divider()
                .width(30)
                .color($r('app.color.divider'))
              this.processNode('02', '换内容')
              Divider()
                .width(30)
                .color($r('app.color.divider'))
              this.processNode('03', '存相册')
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .padding({ top: 17, bottom: 17, left: 12, right: 12 })
            .backgroundColor($r('app.color.control_background'))
            .borderRadius(14)
            .margin({ top: 20 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(20)

          Text('制作步骤')
            .width('100%')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          GridRow({
            columns: 12,
            gutter: { x: 14, y: 14 },
            breakpoints: {
              value: ['320vp', '600vp', '840vp'],
              reference: BreakpointsReference.ComponentSize
            }
          }) {
            ForEach(HELP_STEPS, (step: HelpStep) => {
              GridCol({ span: { xs: 12, sm: 12, md: 6, lg: 4 } }) {
                this.stepCard(step)
              }
            }, (step: HelpStep) => step.code)
          }
          .width('100%')

          Text('常见问题')
            .width('100%')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          GridRow({
            columns: 12,
            gutter: { x: 14, y: 14 },
            breakpoints: {
              value: ['320vp', '600vp', '840vp'],
              reference: BreakpointsReference.ComponentSize
            }
          }) {
            ForEach(HELP_QUESTIONS, (item: HelpQuestion, index: number) => {
              GridCol({ span: { xs: 12, sm: 12, md: 6, lg: 6 } }) {
                this.questionCard(item)
              }
            }, (_item: HelpQuestion, index: number) => index.toString())
          }
          .width('100%')

          Text('继续操作')
            .width('100%')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          GridRow({
            columns: 12,
            gutter: { x: 12, y: 12 },
            breakpoints: {
              value: ['320vp', '600vp', '840vp'],
              reference: BreakpointsReference.ComponentSize
            }
          }) {
            GridCol({ span: { xs: 12, sm: 12, md: 6, lg: 6 } }) {
              this.actionButton('浏览全部模板', true, (): void => {
                this.openTemplateLibrary();
              })
            }
            GridCol({ span: { xs: 12, sm: 12, md: 6, lg: 6 } }) {
              this.actionButton('查看导出设置', false, (): void => {
                this.openExportSettings();
              })
            }
          }
          .width('100%')
          .margin({ bottom: 28 })
        }
        .width('100%')
        .constraintSize({ maxWidth: 1040 })
        .alignSelf(ItemAlign.Center)
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
