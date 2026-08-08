interface MyMenuItem {
  id: number;
  mark: string;
  title: string;
  description: string;
}

const PAGE_CONTENT_MAX_WIDTH: number = 960;
const STATE_SIGNED_OUT: number = 0;
const STATE_SIGNED_IN: number = 1;
const STATE_SUPPORTER: number = 2;

const MY_MENU_ITEMS: MyMenuItem[] = [
  {
    id: 1,
    mark: '徽',
    title: '支持开发者',
    description: '购买永久支持徽记，全部功能仍然免费'
  },
  {
    id: 2,
    mark: '记',
    title: '支持记录',
    description: '查看当前账号拥有的支持徽记'
  },
  {
    id: 3,
    mark: '关',
    title: '关于一刻封面',
    description: '版本信息、开源地址与功能介绍'
  },
  {
    id: 4,
    mark: '隐',
    title: '隐私政策',
    description: '了解账号与订单信息的使用方式'
  }
];

@Component
export struct MyHome {
  @State previewState: number = STATE_SIGNED_OUT;

  private isSignedIn(): boolean {
    return this.previewState !== STATE_SIGNED_OUT;
  }

  private isSupporter(): boolean {
    return this.previewState === STATE_SUPPORTER;
  }

  private previewLabel(): string {
    if (this.previewState === STATE_SIGNED_IN) {
      return '已登录 · 未购买';
    }
    if (this.previewState === STATE_SUPPORTER) {
      return '已登录 · 支持者';
    }
    return '未登录';
  }

  private showPreviewMessage(message: string): void {
    this.getUIContext().getPromptAction().showToast({
      message: message,
      duration: 1800
    });
  }

  private openMenuItem(item: MyMenuItem): void {
    if (item.id === 3) {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/About'
      });
      return;
    }

    if ((item.id === 1 || item.id === 2) && !this.isSignedIn()) {
      this.showPreviewMessage('下一阶段接入华为账号登录');
      return;
    }

    this.showPreviewMessage('前端预览完成，下一阶段接入真实能力');
  }

  @Builder
  private previewButton(label: string, state: number) {
    Text(label)
      .layoutWeight(1)
      .height(34)
      .fontSize(11)
      .fontWeight(this.previewState === state ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.previewState === state ?
        $r('app.color.brand_primary') : $r('app.color.text_secondary'))
      .textAlign(TextAlign.Center)
      .backgroundColor(this.previewState === state ?
        $r('app.color.brand_soft') : Color.Transparent)
      .borderRadius(17)
      .onClick(() => {
        this.previewState = state;
      })
  }

  @Builder
  private statePreview() {
    Column({ space: 10 }) {
      Row() {
        Text('状态预览')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(this.previewLabel())
          .fontSize(10)
          .fontColor($r('app.color.text_muted'))
      }
      .width('100%')

      Row({ space: 3 }) {
        this.previewButton('未登录', STATE_SIGNED_OUT)
        this.previewButton('已登录', STATE_SIGNED_IN)
        this.previewButton('支持者', STATE_SUPPORTER)
      }
      .width('100%')
      .padding(3)
      .backgroundColor($r('app.color.control_background'))
      .borderRadius(20)
    }
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  @Builder
  private defaultAvatar() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(64)
        .height(64)
        .backgroundColor(this.isSupporter() ?
          $r('app.color.support_soft') : $r('app.color.control_background'))
        .borderRadius(32)

      Stack({ alignContent: Alignment.BottomStart }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.card_background'))
        Row()
          .width(24)
          .height(58)
          .backgroundColor($r('app.color.brand_primary'))
          .rotate({ angle: 18 })
          .translate({ x: -13, y: 0 })
        Text('一刻')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .padding({ left: 9, bottom: 8 })
      }
      .width(54)
      .height(54)
      .borderRadius(27)
      .clip(true)
    }
    .width(68)
    .height(68)
    .border({
      width: this.isSupporter() ? 2 : 0,
      color: $r('app.color.support_gold')
    })
    .borderRadius(34)
  }

  @Builder
  private supporterStatus() {
    Row({ space: 8 }) {
      Text('支持者')
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.support_gold'))
        .padding({ left: 9, right: 9, top: 5, bottom: 5 })
        .backgroundColor($r('app.color.support_soft'))
        .borderRadius(12)

      Text('累计支持 ¥25')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
    }
  }

  @Builder
  private accountCard() {
    Column() {
      Row({ space: 14 }) {
        this.defaultAvatar()

        Column({ space: 5 }) {
          Text(this.isSignedIn() ? '华为账号已登录' : '登录华为账号')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(this.isSignedIn() ?
            '账号仅用于保存和恢复支持徽记' : '制作、保存和导出无需登录')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      if (this.isSupporter()) {
        Row() {
          this.supporterStatus()
        }
        .width('100%')
        .margin({ top: 16 })
      }

      if (!this.isSignedIn()) {
        Button('登录华为账号', { type: ButtonType.Normal })
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(11)
          .margin({ top: 18 })
          .onClick(() => {
            this.previewState = STATE_SIGNED_IN;
            this.showPreviewMessage('当前为前端假数据预览');
          })
      } else {
        Text('退出登录')
          .width('100%')
          .fontSize(12)
          .fontColor($r('app.color.text_muted'))
          .textAlign(TextAlign.Center)
          .padding({ top: 15, bottom: 2 })
          .onClick(() => {
            this.previewState = STATE_SIGNED_OUT;
          })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
  }

  @Builder
  private freePromise() {
    Row({ space: 13 }) {
      Column() {
        Text('FREE')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .letterSpacing(1)
      }
      .width(50)
      .height(50)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.brand_primary'))
      .borderRadius(13)

      Column({ space: 4 }) {
        Text('全部功能始终免费')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('支持徽记只表达支持，不会解锁额外功能')
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(15)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  @Builder
  private menuRow(item: MyMenuItem, isLast: boolean) {
    Column() {
      Row({ space: 12 }) {
        Text(item.mark)
          .width(34)
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.id <= 2 ?
            $r('app.color.brand_primary') : $r('app.color.source_accent'))
          .textAlign(TextAlign.Center)
          .backgroundColor(item.id <= 2 ?
            $r('app.color.brand_soft') : $r('app.color.source_soft'))
          .borderRadius(10)

        Column({ space: 4 }) {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Text(item.description)
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.chevron_forward'))
          .fontSize(18)
          .fontColor([$r('app.color.text_muted')])
      }
      .width('100%')
      .padding({ top: 14, bottom: 14 })

      if (!isLast) {
        Divider()
          .strokeWidth(1)
          .color($r('app.color.divider'))
          .margin({ left: 46 })
      }
    }
    .width('100%')
    .onClick(() => {
      this.openMenuItem(item);
    })
  }

  build() {
    Scroll() {
      Row() {
        Column() {
          Column({ space: 4 }) {
            Text('我的')
              .width('100%')
              .fontSize(27)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text('账号、支持徽记与应用信息')
              .width('100%')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 12 }) {
            this.statePreview()
            this.accountCard()
            this.freePromise()
          }
          .width('100%')
          .margin({ top: 20 })

          Text('支持与信息')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          Column() {
            ForEach(MY_MENU_ITEMS, (item: MyMenuItem, index: number) => {
              this.menuRow(item, index === MY_MENU_ITEMS.length - 1)
            }, (item: MyMenuItem) => item.id.toString())
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ bottom: 110 })
        }
        .width('100%')
        .constraintSize({ maxWidth: PAGE_CONTENT_MAX_WIDTH })
        .padding({ left: 18, right: 18, top: 18 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)
    }
    .align(Alignment.TopStart)
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.page_background'))
  }
}
