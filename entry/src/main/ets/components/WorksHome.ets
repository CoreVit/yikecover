import { HistoryRecord } from '../model/CoverModels';
import { LocalStore } from '../services/LocalStore';

interface SettingEntry {
  id: number;
  title: string;
  description: string;
}

const SETTINGS: SettingEntry[] = [
  {
    id: 1,
    title: '导出设置',
    description: '尺寸、格式与清晰度'
  },
  {
    id: 2,
    title: '历史记录',
    description: '管理草稿与已导出作品'
  },
  {
    id: 3,
    title: '使用帮助',
    description: '模板、编辑与导出说明'
  },
  {
    id: 4,
    title: '关于一刻封面',
    description: '开源信息、版本与项目地址'
  }
];

@Component
export struct WorksHome {
  @Link currentTab: number;
  @State currentFilter: number = 0;
  @State records: HistoryRecord[] = [];

  aboutToAppear(): void {
    const hostContext: Context | undefined = this.getUIContext().getHostContext();
    if (hostContext !== undefined) {
      LocalStore.initialize(hostContext);
    }
    this.loadHistory();
  }

  onPageShow(): void {
    this.loadHistory();
  }

  private async loadHistory(): Promise<void> {
    this.records = await LocalStore.loadHistory();
  }

  private filteredRecords(): HistoryRecord[] {
    if (this.currentFilter === 0) {
      return this.records;
    }
    const status: string = this.currentFilter === 1 ? '草稿' : '已导出';
    return this.records.filter((item: HistoryRecord) => item.status === status);
  }

  @Builder
  private filterButton(label: string, index: number) {
    Text(label)
      .fontSize(13)
      .fontWeight(this.currentFilter === index ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.currentFilter === index ?
        $r('app.color.text_primary') : $r('app.color.text_secondary'))
      .padding({ left: 15, right: 15, top: 8, bottom: 8 })
      .backgroundColor(this.currentFilter === index ?
        $r('app.color.control_selected') : Color.Transparent)
      .borderRadius(17)
      .onClick(() => {
        this.currentFilter = index;
      })
  }

  @Builder
  private emptyArtwork() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(118)
        .height(67)
        .backgroundColor('#242832')
        .border({
          width: 1,
          color: $r('app.color.divider')
        })
        .borderRadius(10)
        .rotate({ angle: -7 })
        .translate({ x: -18, y: 5 })

      Stack({ alignContent: Alignment.BottomStart }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#2B303B')
        Row()
          .width(42)
          .height(86)
          .backgroundColor($r('app.color.brand_primary'))
          .rotate({ angle: 18 })
          .translate({ x: -15, y: 0 })
        Text('一刻封面')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 10, bottom: 9 })
      }
      .width(126)
      .height(71)
      .borderRadius(10)
      .clip(true)
      .translate({ x: 15, y: 0 })
    }
    .width('100%')
    .height(105)
  }

  @Builder
  private settingRow(item: SettingEntry, isLast: boolean) {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Text(item.description)
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text('›')
          .fontSize(24)
          .fontColor($r('app.color.text_muted'))
      }
      .width('100%')
      .padding({ top: 15, bottom: 15 })

      if (!isLast) {
        Divider()
          .strokeWidth(1)
          .color($r('app.color.divider'))
      }
    }
    .width('100%')
    .onClick(() => {
      if (item.id === 1) {
        this.getUIContext().getRouter().pushUrl({
          url: 'pages/ExportSettings'
        });
      } else if (item.id === 4) {
        this.getUIContext().getRouter().pushUrl({
          url: 'pages/About'
        });
      }
    })
  }

  @Builder
  private historyCard(item: HistoryRecord) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#242A32')
        Row()
          .width(34)
          .height(66)
          .backgroundColor(item.status === '已导出' ? '#4D9E72' : $r('app.color.brand_primary'))
          .rotate({ angle: 16 })
          .translate({ x: -12, y: -3 })
        Text(item.templateId.toString().padStart(2, '0'))
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 7, bottom: 6 })
      }
      .width(88)
      .height(50)
      .borderRadius(8)
      .clip(true)

      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
        Text(`${item.templateName} · ${item.updatedAt}`)
          .fontSize(9)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(item.status)
        .fontSize(9)
        .fontColor(item.status === '已导出' ? '#66D89A' : $r('app.color.brand_primary'))
        .padding({ left: 8, right: 8, top: 5, bottom: 5 })
        .backgroundColor($r('app.color.control_background'))
        .borderRadius(10)
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(13)
    .onClick(() => {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/CoverEditor',
        params: {
          templateId: item.templateId
        }
      });
    })
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('作品')
              .fontSize(27)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text(`${this.records.length} 条记录`)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text('设置')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor($r('app.color.control_background'))
            .borderRadius(18)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Row({ space: 5 }) {
          this.filterButton('全部', 0)
          this.filterButton('草稿', 1)
          this.filterButton('已导出', 2)
        }
        .alignSelf(ItemAlign.Start)
        .padding(3)
        .backgroundColor($r('app.color.control_background'))
        .borderRadius(20)
        .margin({ top: 24 })

        if (this.filteredRecords().length === 0) {
          Column() {
            this.emptyArtwork()

            Text('还没有作品')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ top: 8 })

            Text('完成的封面和未完成的草稿会出现在这里')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .textAlign(TextAlign.Center)
              .margin({ top: 7 })

            Button('去制作', { type: ButtonType.Normal })
              .height(42)
              .padding({ left: 24, right: 24 })
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .backgroundColor($r('app.color.brand_primary'))
              .borderRadius(11)
              .margin({ top: 20 })
              .onClick(() => {
                this.currentTab = 0;
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 30, bottom: 28 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(18)
          .margin({ top: 18 })
        } else {
          Column({ space: 9 }) {
            ForEach(this.filteredRecords(), (item: HistoryRecord) => {
              this.historyCard(item)
            }, (item: HistoryRecord) => item.id)
          }
          .width('100%')
          .margin({ top: 18 })
        }

        Text('工具与设置')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 28, bottom: 12 })

        Column() {
          ForEach(SETTINGS, (item: SettingEntry, index: number) => {
            this.settingRow(item, index === SETTINGS.length - 1)
          }, (item: SettingEntry) => item.id.toString())
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(16)
        .margin({ bottom: 28 })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 18 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.page_background'))
  }
}
