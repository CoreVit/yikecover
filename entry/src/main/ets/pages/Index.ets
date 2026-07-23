import { CreateHome } from '../components/CreateHome';
import { WorksHome } from '../components/WorksHome';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State worksRefreshToken: number = 0;

  onPageShow(): void {
    this.worksRefreshToken += 1;
  }

  @Builder
  private tabItem(label: string, index: number) {
    Column({ space: 4 }) {
      if (index === 0) {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(24)
          .fontColor([this.currentTab === index ?
            $r('app.color.brand_primary') : $r('app.color.text_muted')])
      } else {
        SymbolGlyph($r('sys.symbol.rectangle_on_rectangle'))
          .fontSize(24)
          .fontColor([this.currentTab === index ?
            $r('app.color.brand_primary') : $r('app.color.text_muted')])
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
        WorksHome({
          currentTab: $currentTab,
          refreshToken: this.worksRefreshToken
        })
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
