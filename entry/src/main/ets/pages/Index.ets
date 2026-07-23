import {
  AtomicServiceTabs,
  SymbolGlyphModifier,
  TabBarOptions,
  TabBarPosition
} from '@kit.ArkUI';
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

  private tabSymbol(symbol: Resource): TabBarSymbol {
    const normal: SymbolGlyphModifier = new SymbolGlyphModifier(symbol);
    normal.fontSize(24);
    normal.fontColor([$r('app.color.text_muted')]);

    const selected: SymbolGlyphModifier = new SymbolGlyphModifier(symbol);
    selected.fontSize(24);
    selected.fontColor([$r('app.color.brand_primary')]);

    return {
      normal: normal,
      selected: selected
    };
  }

  @Builder
  createTabContent() {
    Column() {
      CreateHome()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  worksTabContent() {
    Column() {
      WorksHome({
        currentTab: $currentTab,
        refreshToken: this.worksRefreshToken
      })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  build() {
    Column() {
      AtomicServiceTabs({
        tabContents: [
          () => {
            this.createTabContent()
          },
          () => {
            this.worksTabContent()
          }
        ],
        tabBarOptionsArray: [
          new TabBarOptions(
            this.tabSymbol($r('sys.symbol.plus')),
            '制作',
            $r('app.color.text_muted'),
            $r('app.color.brand_primary')
          ),
          new TabBarOptions(
            this.tabSymbol($r('sys.symbol.rectangle_on_rectangle')),
            '作品',
            $r('app.color.text_muted'),
            $r('app.color.brand_primary')
          )
        ],
        tabBarPosition: TabBarPosition.BOTTOM,
        barBackgroundColor: $r('app.color.nav_background'),
        barOverlap: false,
        index: this.currentTab,
        onChange: (index: number): void => {
          this.currentTab = index;
          if (index === 1) {
            this.worksRefreshToken += 1;
          }
        }
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
