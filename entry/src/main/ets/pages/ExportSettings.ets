import { ExportSettings } from '../model/CoverModels';
import { LocalStore } from '../services/LocalStore';
import { SystemBackButton } from '../components/SystemBackButton';

@Entry
@Component
struct ExportSettingsPage {
  @State resolution: string = '1080P';
  @State format: string = 'PNG';
  @State quality: number = 92;
  @State webpSupported: boolean = false;
  @State probing: boolean = true;
  @State savedHint: string = '';
  private saveTask: Promise<void> = Promise.resolve();
  private saveFailed: boolean = false;

  aboutToAppear(): void {
    const hostContext: Context | undefined = this.getUIContext().getHostContext();
    if (hostContext !== undefined) {
      LocalStore.initialize(hostContext);
    }
    this.restoreSettings();
  }

  private async restoreSettings(): Promise<void> {
    const settings: ExportSettings = await LocalStore.loadExportSettings();
    this.resolution = settings.resolution;
    this.format = settings.format;
    this.quality = settings.quality;
    if (!this.probing) {
      this.webpSupported = settings.webpSupported;
      return;
    }
    this.webpSupported = await LocalStore.probeWebpSupport();
    if (!this.webpSupported && this.format === 'WebP') {
      this.format = 'PNG';
      await this.queueSave();
    }
    this.probing = false;
  }

  private buildSettings(): ExportSettings {
    let width: number = 1920;
    let height: number = 1080;
    if (this.resolution === '720P') {
      width = 1280;
      height = 720;
    } else if (this.resolution === '4K') {
      width = 3840;
      height = 2160;
    }
    return {
      resolution: this.resolution,
      width: width,
      height: height,
      format: this.format,
      quality: this.quality,
      webpSupported: this.webpSupported
    };
  }

  private async persistSettings(settings: ExportSettings): Promise<void> {
    try {
      await LocalStore.saveExportSettings(settings);
      this.saveFailed = false;
      this.savedHint = '已保存为全局导出设置';
    } catch (error) {
      this.saveFailed = true;
      this.savedHint = '保存失败，请重试';
    }
  }

  private queueSave(): Promise<void> {
    const settings: ExportSettings = this.buildSettings();
    this.saveTask = this.saveTask.then(() => {
      return this.persistSettings(settings);
    });
    return this.saveTask;
  }

  private async goBack(): Promise<void> {
    await this.queueSave();
    if (this.saveFailed) {
      return;
    }
    this.getUIContext().getRouter().back();
  }

  private selectChoice(group: string, value: string, enabled: boolean): void {
    if (!enabled) {
      return;
    }
    if (group === 'resolution') {
      if (this.resolution === value) {
        return;
      }
      this.resolution = value;
    } else {
      if (this.format === value) {
        return;
      }
      this.format = value;
    }
    this.queueSave();
  }

  @Builder
  private choice(label: string, description: string, selected: boolean, enabled: boolean,
    group: string, value: string) {
    Row() {
      Column({ space: 3 }) {
        Text(label)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(enabled ? $r('app.color.text_primary') : $r('app.color.text_muted'))
        Text(description)
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Radio({ value: value, group: group })
        .checked(selected)
        .enabled(enabled)
        .radioStyle({
          checkedBackgroundColor: $r('app.color.brand_primary'),
          uncheckedBorderColor: $r('app.color.divider'),
          indicatorColor: '#FFFFFF'
        })
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.selectChoice(group, value, enabled);
          }
        })
    }
    .width('100%')
    .padding({ top: 13, bottom: 13 })
    .opacity(enabled ? 1 : 0.46)
    .onClick(() => {
      this.selectChoice(group, value, enabled);
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
          Text('导出设置')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('所有封面共用这一套参数')
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
        Column({ space: 16 }) {
          Column() {
            Text('导出分辨率')
              .width('100%')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 5 })
            this.choice('720P · 1280 × 720', '体积较小，适合快速分享',
              this.resolution === '720P', true, 'resolution', '720P')
            Divider().color($r('app.color.divider'))
            this.choice('1080P · 1920 × 1080', '推荐 · 与设计坐标一一对应',
              this.resolution === '1080P', true, 'resolution', '1080P')
            Divider().color($r('app.color.divider'))
            this.choice('4K · 3840 × 2160', '更清晰，对设备内存要求较高',
              this.resolution === '4K', true, 'resolution', '4K')
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)

          Column() {
            Text('图片格式')
              .width('100%')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 5 })
            this.choice('PNG', '无损，文字边缘最清晰，文件较大',
              this.format === 'PNG', true, 'format', 'PNG')
            Divider().color($r('app.color.divider'))
            this.choice('JPEG', '文件较小，不支持透明',
              this.format === 'JPEG', true, 'format', 'JPEG')
            Divider().color($r('app.color.divider'))
            this.choice('WebP', this.probing ? '正在进行设备编码测试…' :
              (this.webpSupported ? '压缩效率较高，部分目标兼容性有限' : '当前设备暂不支持 · 待开发'),
              this.format === 'WebP', this.webpSupported && !this.probing,
              'format', 'WebP')
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)

          if (this.format !== 'PNG') {
            Column({ space: 10 }) {
              Row() {
                Text('图片质量')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                Blank()
                Text(`${Math.round(this.quality)}`)
                  .fontSize(14)
                  .fontColor($r('app.color.brand_primary'))
              }
              .width('100%')
              Slider({
                value: this.quality,
                min: 60,
                max: 100,
                step: 1,
                style: SliderStyle.InSet
              })
                .selectedColor($r('app.color.brand_primary'))
                .trackColor($r('app.color.control_background'))
                .onChange((value: number) => {
                  this.quality = value;
                  this.queueSave();
                })
              Text('建议 90–95；默认 92。质量越高，文件通常越大。')
                .width('100%')
                .fontSize(11)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(16)
          }

          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.checkmark'))
              .fontSize(12)
              .fontColor(['#5AA77B'])
            Text(this.savedHint.length > 0 ? this.savedHint : '修改后自动保存，仅存储在本机')
              .fontSize(11)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding({ left: 4, bottom: 22 })
        }
        .padding({ left: 16, right: 16, top: 16 })
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
