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

const HERO_SWIPE_DISTANCE: number = 150;
const HERO_MAX_DRAG: number = 190;
const HERO_SWITCH_THRESHOLD: number = 54;
const HERO_VELOCITY_THRESHOLD: number = 680;

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
  @State heroDragOffset: number = 0;
  private heroSettling: boolean = false;

  private previewJson(templateId: number): string {
    return JSON.stringify(createDefaultDraft(getTemplateDefinition(templateId)));
  }

  private currentHeroTemplate(): TemplateDefinition {
    return TEMPLATE_DEFINITIONS[this.currentHeroIndex];
  }

  private relativeHeroIndex(index: number): number {
    let relative: number = index - this.currentHeroIndex;
    const half: number = Math.floor(TEMPLATE_DEFINITIONS.length / 2);
    if (relative > half) {
      relative -= TEMPLATE_DEFINITIONS.length;
    } else if (relative < -half) {
      relative += TEMPLATE_DEFINITIONS.length;
    }
    return relative;
  }

  private heroPosition(index: number): number {
    return this.relativeHeroIndex(index) + this.heroDragOffset / HERO_SWIPE_DISTANCE;
  }

  private heroTranslateX(index: number): number {
    const position: number = this.heroPosition(index);
    const direction: number = position < 0 ? -1 : 1;
    const distance: number = Math.min(Math.abs(position), 2.2);
    return direction * (distance * 47 + Math.max(0, distance - 1) * 12);
  }

  private heroTranslateY(index: number): number {
    return Math.min(Math.abs(this.heroPosition(index)), 2) * 10 + 4;
  }

  private heroScale(index: number): number {
    return 1 - Math.min(Math.abs(this.heroPosition(index)), 2) * 0.09;
  }

  private heroOpacity(index: number): number {
    return Math.max(0.3, 1 - Math.min(Math.abs(this.heroPosition(index)), 2.2) * 0.24);
  }

  private heroRotation(index: number): number {
    return Math.max(-9, Math.min(9, this.heroPosition(index) * 6.5));
  }

  private heroZIndex(index: number): number {
    return 100 - Math.round(Math.min(Math.abs(this.heroPosition(index)), 3) * 10);
  }

  private settleHero(direction: number): void {
    if (this.heroSettling) {
      return;
    }
    this.heroSettling = true;
    if (direction === 0) {
      this.getUIContext().animateTo({
        duration: 300,
        curve: Curve.Friction,
        onFinish: () => {
          this.heroSettling = false;
        }
      }, () => {
        this.heroDragOffset = 0;
      });
      return;
    }

    const targetOffset: number = direction > 0 ? -HERO_SWIPE_DISTANCE : HERO_SWIPE_DISTANCE;
    this.getUIContext().animateTo({
      duration: 340,
      curve: Curve.Friction,
      onFinish: () => {
        this.currentHeroIndex =
          (this.currentHeroIndex + direction + TEMPLATE_DEFINITIONS.length) % TEMPLATE_DEFINITIONS.length;
        this.heroDragOffset = 0;
        this.heroSettling = false;
      }
    }, () => {
      this.heroDragOffset = targetOffset;
    });
  }

  private handleHeroRelease(event: GestureEvent): void {
    const shouldSwitch: boolean =
      Math.abs(this.heroDragOffset) >= HERO_SWITCH_THRESHOLD ||
        Math.abs(event.velocityX) >= HERO_VELOCITY_THRESHOLD;
    if (!shouldSwitch) {
      this.settleHero(0);
      return;
    }
    const direction: number = Math.abs(event.velocityX) >= HERO_VELOCITY_THRESHOLD
      ? (event.velocityX < 0 ? 1 : -1)
      : (this.heroDragOffset < 0 ? 1 : -1);
    this.settleHero(direction);
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
  private heroCover(item: TemplateDefinition, index: number) {
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
        radius: index === this.currentHeroIndex ? 18 : 10,
        color: index === this.currentHeroIndex ? '#4D000000' : '#2E000000',
        offsetX: 0,
        offsetY: index === this.currentHeroIndex ? 9 : 5
      })
    }
    .width('82%')
    .translate({
      x: this.heroTranslateX(index),
      y: this.heroTranslateY(index)
    })
    .rotate({
      angle: this.heroRotation(index),
      centerX: '50%',
      centerY: '50%'
    })
    .scale({
      x: this.heroScale(index),
      y: this.heroScale(index)
    })
    .opacity(this.heroOpacity(index))
    .zIndex(this.heroZIndex(index))
    .onClick(() => {
      if (index === this.currentHeroIndex && Math.abs(this.heroDragOffset) < 4 && !this.heroSettling) {
        this.openTemplate(item.id);
      }
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
          Stack({ alignContent: Alignment.Center }) {
            ForEach(TEMPLATE_DEFINITIONS, (item: TemplateDefinition, index: number) => {
              if (Math.abs(this.relativeHeroIndex(index)) <= 2) {
                this.heroCover(item, index)
              }
            }, (item: TemplateDefinition) => item.id.toString())
          }
          .width('100%')
          .height(190)
          .clip(false)
          .gesture(
            PanGesture({
              fingers: 1,
              direction: PanDirection.Horizontal,
              distance: 8
            })
              .onActionUpdate((event: GestureEvent) => {
                if (!this.heroSettling) {
                  this.heroDragOffset =
                    Math.max(-HERO_MAX_DRAG, Math.min(HERO_MAX_DRAG, event.offsetX));
                }
              })
              .onActionEnd((event: GestureEvent) => {
                if (!this.heroSettling) {
                  this.handleHeroRelease(event);
                }
              })
              .onActionCancel(() => {
                if (!this.heroSettling) {
                  this.settleHero(0);
                }
              })
          )

          Row() {
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

            Blank()

            Text(`${this.currentHeroIndex + 1} / ${TEMPLATE_DEFINITIONS.length}`)
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor($r('app.color.page_background'))
              .borderRadius(10)
          }
          .width('100%')
          .height(26)
          .padding({ left: 8, right: 8 })

          Text('选择一个模板，开始做封面')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 5 })

          Text('左右滑动预览全部模板，选定后替换图片和内容')
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
        .align(Alignment.Start)
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
    .align(Alignment.TopStart)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.page_background'))
  }
}
