import { CreateHome } from '../components/CreateHome';
import { WorksHome } from '../components/WorksHome';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;

  @Builder
  private createIcon(selected: boolean) {
    Stack() {
      Row()
        .width(18)
        .height(2)
        .borderRadius(1)
        .backgroundColor(selected ? $r('app.color.brand_primary') : $r('app.color.text_muted'))
      Row()
        .width(2)
        .height(18)
        .borderRadius(1)
        .backgroundColor(selected ? $r('app.color.brand_primary') : $r('app.color.text_muted'))
    }
    .width(24)
    .height(24)
  }

  @Builder
  private worksIcon(selected: boolean) {
    Stack() {
      Row()
        .width(17)
        .height(12)
        .border({
          width: 1.5,
          color: selected ? $r('app.color.brand_primary') : $r('app.color.text_muted')
        })
        .borderRadius(3)
        .position({ x: 4, y: 7 })
      Row()
        .width(14)
        .height(10)
        .border({
          width: 1.5,
          color: selected ? $r('app.color.brand_primary') : $r('app.color.text_muted')
        })
        .borderRadius(3)
        .position({ x: 7, y: 3 })
    }
    .width(28)
    .height(24)
  }

  @Builder
  private tabItem(label: string, index: number) {
    Column({ space: 4 }) {
      if (index === 0) {
        this.createIcon(this.currentTab === index)
      } else {
        this.worksIcon(this.currentTab === index)
      }
      Text(label)
        .fontSize(11)
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentTab === index ?
          $r('app.color.brand_primary') : $r('app.color.text_muted'))
    }
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
    .height('100%')
    .onClick(() => {
      this.currentTab = index;
    })
  }

  build() {
    Column() {
      if (this.currentTab === 0) {
        CreateHome()
      } else {
        WorksHome({ currentTab: $currentTab })
      }

      Row() {
        this.tabItem('制作', 0)
        this.tabItem('作品', 1)
      }
      .width('100%')
      .height(70)
      .padding({ left: 48, right: 48, top: 5, bottom: 7 })
      .backgroundColor($r('app.color.nav_background'))
      .borderWidth({ top: 1 })
      .borderColor($r('app.color.divider'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
