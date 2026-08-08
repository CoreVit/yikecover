import { CreateHome } from '../components/CreateHome';
import { WorksHome } from '../components/WorksHome';

const FLOATING_TAB_WIDTH: number = 224;
const FLOATING_TAB_HEIGHT: number = 64;
const FLOATING_TAB_BOTTOM_MARGIN: number = 18;

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State worksRefreshToken: number = 0;

  onPageShow(): void {
    this.worksRefreshToken += 1;
  }

  private selectTab(index: number): void {
    if (this.currentTab === index) {
      return;
    }

    this.currentTab = index;
    if (index === 1) {
      this.worksRefreshToken += 1;
    }
  }

  @Builder
  private tabItem(index: number, label: string, symbol: Resource) {
    Column({ space: 2 }) {
      SymbolGlyph(symbol)
        .fontSize(22)
        .fontColor([
          this.currentTab === index ?
            $r('app.color.brand_primary') : $r('app.color.text_muted')
        ])

      Text(label)
        .fontSize(12)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentTab === index ?
          $r('app.color.brand_primary') : $r('app.color.text_muted'))
    }
    .width(102)
    .height(52)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.currentTab === index ?
      $r('app.color.brand_soft') : Color.Transparent)
    .borderRadius(24)
    .accessibilityText(label)
    .accessibilityDescription(this.currentTab === index ? '当前页面' : `切换到${label}`)
    .onClick(() => {
      this.selectTab(index);
    })
  }

  @Builder
  private floatingTabBar() {
    Row({ space: 4 }) {
      this.tabItem(0, '制作', $r('sys.symbol.plus'))
      this.tabItem(1, '作品', $r('sys.symbol.rectangle_on_rectangle'))
    }
    .width(FLOATING_TAB_WIDTH)
    .height(FLOATING_TAB_HEIGHT)
    .padding(5)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.nav_background'))
    .border({
      width: 1,
      color: $r('app.color.divider')
    })
    .borderRadius(FLOATING_TAB_HEIGHT / 2)
    .shadow({
      radius: 18,
      color: '#38000000',
      offsetX: 0,
      offsetY: 7
    })
    .margin({ bottom: FLOATING_TAB_BOTTOM_MARGIN })
    .zIndex(10)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.currentTab === 0) {
        CreateHome()
      } else {
        WorksHome({
          currentTab: $currentTab,
          refreshToken: this.worksRefreshToken
        })
      }

      this.floatingTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
