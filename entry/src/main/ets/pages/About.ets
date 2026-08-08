import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { SystemBackButton } from '../components/SystemBackButton';
import { RepositoryService } from '../services/RepositoryService';

function currentVersionName(): string {
  try {
    const bundleInfo: bundleManager.BundleInfo =
      bundleManager.getBundleInfoForSelfSync(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
    if (bundleInfo.versionName.length > 0) {
      return bundleInfo.versionName;
    }
  } catch (error) {
  }
  return '未知';
}

@Entry
@Component
struct About {
  private readonly versionName: string = currentVersionName();

  private goBack(): void {
    this.getUIContext().getRouter().back();
  }

  private showCopyError(): void {
    this.getUIContext().getPromptAction().openToast({
      message: '复制失败，请手动复制页面中的网址'
    }).catch((_error: BusinessError) => {
    });
  }

  private copyRepositoryUrl(): void {
    RepositoryService.copyUrl()
      .then(() => {
        this.getUIContext().getPromptAction().openToast({
          message: 'GitHub 地址已复制，请到浏览器粘贴打开'
        }).catch((_error: BusinessError) => {
        });
      })
      .catch((_error: Error) => {
        this.showCopyError();
      });
  }

  @Builder
  private branchMark() {
    Stack() {
      Column()
        .width(2)
        .height(74)
        .backgroundColor($r('app.color.source_accent'))
        .position({ x: 26, y: 20 })

      Column()
        .width(2)
        .height(40)
        .backgroundColor($r('app.color.source_accent'))
        .rotate({ angle: 42 })
        .position({ x: 40, y: 31 })

      Row()
        .width(12)
        .height(12)
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(6)
        .position({ x: 21, y: 13 })

      Row()
        .width(12)
        .height(12)
        .backgroundColor($r('app.color.source_accent'))
        .borderRadius(6)
        .position({ x: 50, y: 32 })

      Row()
        .width(12)
        .height(12)
        .backgroundColor($r('app.color.card_background'))
        .border({
          width: 2,
          color: $r('app.color.source_accent')
        })
        .borderRadius(6)
        .position({ x: 21, y: 87 })

      Text('</>')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .position({ x: 68, y: 44 })
    }
    .width(120)
    .height(112)
  }

  @Builder
  private detailRow(label: string, value: string, showDivider: boolean) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Blank()
        Text(value)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding({ top: 15, bottom: 15 })

      if (showDivider) {
        Divider()
          .strokeWidth(1)
          .color($r('app.color.divider'))
      }
    }
    .width('100%')
  }

  @Builder
  private featureRow(code: string, title: string, description: string, showDivider: boolean) {
    Column() {
      Row({ space: 12 }) {
        Text(code)
          .width(28)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.brand_primary'))

        Column({ space: 4 }) {
          Text(title)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(description)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(20)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .padding({ top: 14, bottom: 14 })

      if (showDivider) {
        Divider()
          .strokeWidth(1)
          .color($r('app.color.divider'))
          .margin({ left: 40 })
      }
    }
    .width('100%')
  }

  build() {
    Column() {
      Row() {
        SystemBackButton({
          onBack: (): void => {
            this.goBack();
          }
        })

        Text('关于一刻封面')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ left: 13 })

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 18, right: 18 })

      Scroll() {
        Column() {
          Column() {
            Row() {
              Row({ space: 7 }) {
                Row()
                  .width(7)
                  .height(7)
                  .backgroundColor($r('app.color.source_accent'))
                  .borderRadius(4)
                Text('SOURCE AVAILABLE')
                  .fontSize(11)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.source_accent'))
                  .letterSpacing(1)
              }
              .padding({ left: 11, right: 11, top: 7, bottom: 7 })
              .backgroundColor($r('app.color.source_soft'))
              .borderRadius(16)

              Blank()

              this.branchMark()
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)

            Text('功能在更新，\n源码也公开。')
              .width('100%')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .lineHeight(39)
              .margin({ top: 4 })

              Text('一刻封面的项目源码公开托管在 GitHub。你可以查看实现、反馈问题，也可以参与改进。')
              .width('100%')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .lineHeight(22)
              .margin({ top: 14 })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 22 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(20)

          Column() {
            Row() {
              Column({ space: 4 }) {
                Text('GitHub 仓库')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                Text('CoreVit / yikecover')
                  .fontSize(19)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Text('PUBLIC')
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.source_accent'))
                .padding({ left: 8, right: 8, top: 5, bottom: 5 })
                .border({
                  width: 1,
                  color: $r('app.color.source_accent')
                })
                .borderRadius(12)
            }
            .width('100%')

            Text('github.com/CoreVit/yikecover')
              .width('100%')
              .fontSize(12)
              .fontColor($r('app.color.text_muted'))
              .margin({ top: 13 })

            Button({ type: ButtonType.Normal }) {
              Row({ space: 7 }) {
                Text('复制 GitHub 地址')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
                  .fontSize(16)
                  .fontColor(['#FFFFFF'])
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
            }
              .width('100%')
              .height(46)
              .backgroundColor($r('app.color.brand_primary'))
              .borderRadius(12)
              .margin({ top: 18 })
              .onClick(() => {
                this.copyRepositoryUrl();
              })

            Text('源码与使用说明以 GitHub 仓库中的最新内容为准。')
              .width('100%')
              .fontSize(11)
              .fontColor($r('app.color.text_muted'))
              .textAlign(TextAlign.Center)
              .margin({ top: 11 })
          }
          .width('100%')
          .padding(18)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(18)
          .margin({ top: 14 })

          Text('最新版功能')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          Column() {
            this.featureRow('01', '10 套封面模板',
              '涵盖双行、分集、会员、美食、现场、系列节目、播客和视频片尾等版式。', true)
            this.featureRow('02', '可视化编辑与裁剪',
              '替换图片和文字，按模板填写专属内容；图片支持 16:9 拖动与双指缩放裁剪。', true)
            this.featureRow('03', '多规格图片导出',
              '支持 720P、1080P、4K，以及 PNG、JPEG、WebP；非 PNG 格式可调整清晰度。', true)
            this.featureRow('04', '本机作品管理',
              '保存有修改的草稿并记录已导出作品；图片经系统确认保存到相册，业务数据仅留在本机。', false)
          }
          .width('100%')
          .padding({ left: 17, right: 17 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)

          Text('关于项目')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          Text('一刻封面是一款在本机运行的内容封面制作元服务。选择模板、替换图片和文字、调整裁剪，即可实时预览并按所选规格保存到系统相册。无需注册或登录。')
            .width('100%')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(23)
            .padding(18)
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(16)

          Text('项目信息')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          Column() {
            this.detailRow('版本', this.versionName, true)
            this.detailRow('模板数量', '10 套', true)
            this.detailRow('导出规格', '720P / 1080P / 4K', true)
            this.detailRow('数据存储', '仅当前设备', true)
            this.detailRow('运行平台', 'HarmonyOS', false)
          }
          .width('100%')
          .padding({ left: 17, right: 17 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)

          Text('© 2026 一刻封面')
            .width('100%')
            .fontSize(11)
            .fontColor($r('app.color.text_muted'))
            .textAlign(TextAlign.Center)
            .margin({ top: 28, bottom: 30 })
        }
        .width('100%')
        .constraintSize({ maxWidth: 960 })
        .alignSelf(ItemAlign.Center)
        .padding({ left: 18, right: 18, top: 10 })
      }
      .align(Alignment.TopStart)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
