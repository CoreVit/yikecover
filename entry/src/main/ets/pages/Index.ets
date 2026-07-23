import {
  AtomicServiceTabs,
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

  @Builder
  createTabContent() {
    CreateHome()
  }

  @Builder
  worksTabContent() {
    WorksHome({
      currentTab: $currentTab,
      refreshToken: this.worksRefreshToken
    })
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
            $r('sys.symbol.plus'),
            '制作',
            $r('app.color.text_muted'),
            $r('app.color.brand_primary')
          ),
          new TabBarOptions(
            $r('sys.symbol.rectangle_on_rectangle'),
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
