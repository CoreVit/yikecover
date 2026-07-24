import photoAccessHelper from '@ohos.file.photoAccessHelper';
import fileIo from '@ohos.file.fs';
import pasteboard from '@ohos.pasteboard';
import { LengthMetricsUnit } from '@kit.ArkUI';
import {
  CoverDraft,
  CoverTheme,
  EpisodePreset,
  ExportSettings,
  TemplateDefinition,
  VERSION_PRESETS,
  automaticCopy,
  createDefaultDraft,
  getTemplateDefinition,
  isValidCustomEpisode,
  todayText
} from '../model/CoverModels';
import { CoverPreview } from '../components/CoverPreview';
import { SystemBackButton } from '../components/SystemBackButton';
import { CoverRenderer, RenderResult } from '../services/CoverRenderer';
import { ExportService } from '../services/ExportService';
import { LocalStore } from '../services/LocalStore';

interface TemplateRouteParams {
  templateId: number;
}

@Entry
@Component
struct CoverEditor {
  private savedDraftJson: string = '';
  private sessionModified: boolean = false;
  private leaving: boolean = false;

  @State templateId: number = 1;
  @State photoUri: string = '';
  @State brand: string = '';
  @State title1: string = '';
  @State title2: string = '';
  @State kicker: string = '';
  @State personName: string = '';
  @State englishName: string = '';
  @State episodeTitle: string = '';
  @State episodePreset: string = EpisodePreset.UP;
  @State customEpisode: string = '';
  @State versionLabel: string = '';
  @State customVersion: boolean = false;
  @State photoGrayscale: boolean = false;
  @State theme: string = CoverTheme.RED;
  @State quoteLabel: string = '';
  @State podcastBody: string = '';
  @State podcastEnglish: string = '';
  @State tags: string[] = [];
  @State tagInput: string = '';
  @State publishDate: string = todayText();
  @State exportLabel: string = '1080P · PNG';
  @State exportSettings: ExportSettings = {
    resolution: '1080P',
    width: 1920,
    height: 1080,
    format: 'PNG',
    quality: 92,
    webpSupported: false
  };
  @State titleTooLong: boolean = false;
  @State exporting: boolean = false;
  @State exportStage: string = 'idle';
  @State photoLoading: boolean = false;
  @State photoLoadFailed: boolean = false;
  @State previewDraftJson: string = '';
  @State previewRevision: number = 0;

  aboutToAppear(): void {
    const hostContext: Context | undefined = this.getUIContext().getHostContext();
    if (hostContext !== undefined) {
      LocalStore.initialize(hostContext);
    }
    const params: TemplateRouteParams =
      this.getUIContext().getRouter().getParams() as TemplateRouteParams;
    if (params !== undefined && params.templateId !== undefined) {
      this.templateId = params.templateId;
    }
    this.loadDraft();
    this.refreshExportSettings();
  }

  onPageShow(): void {
    this.refreshExportSettings();
  }

  onPageHide(): void {
    this.saveDraftIfChanged();
  }

  onBackPress(): boolean {
    this.leaveEditor();
    return true;
  }

  private definition(): TemplateDefinition {
    return getTemplateDefinition(this.templateId);
  }

  private async loadDraft(): Promise<void> {
    const draft: CoverDraft = await LocalStore.loadDraft(this.templateId);
    this.photoUri = draft.photoUri;
    this.brand = draft.brand;
    this.title1 = draft.title1;
    this.title2 = draft.title2;
    this.kicker = draft.kicker;
    this.personName = draft.personName;
    this.englishName = draft.englishName;
    this.episodeTitle = draft.episodeTitle;
    this.episodePreset = draft.episodePreset;
    this.customEpisode = draft.customEpisode;
    this.versionLabel = draft.versionLabel;
    if (this.definition().capabilities.supportsVersion) {
      let isPreset: boolean = false;
      for (let index: number = 0; index < VERSION_PRESETS.length - 1; index++) {
        if (VERSION_PRESETS[index] === draft.versionLabel) {
          isPreset = true;
        }
      }
      this.customVersion = !isPreset;
    }
    this.photoGrayscale = draft.grayscale;
    this.theme = draft.theme;
    this.quoteLabel = draft.quoteLabel;
    this.podcastBody = draft.podcastBody;
    this.podcastEnglish = draft.podcastEnglish;
    this.tags = draft.tags;
    this.publishDate = draft.publishDate;
    this.requestPreview();
    this.savedDraftJson = JSON.stringify(this.draft());
  }

  private async refreshExportSettings(): Promise<void> {
    this.exportSettings = await LocalStore.loadExportSettings();
    this.exportLabel = `${this.exportSettings.resolution} · ${this.exportSettings.format}`;
  }

  private draft(): CoverDraft {
    return {
      templateId: this.templateId,
      photoUri: this.photoUri,
      brand: this.brand,
      title1: this.title1,
      title2: this.title2,
      kicker: this.kicker,
      personName: this.personName,
      englishName: this.englishName,
      episodeTitle: this.episodeTitle,
      episodePreset: this.episodePreset,
      customEpisode: this.customEpisode,
      versionLabel: this.versionLabel,
      grayscale: this.photoGrayscale,
      theme: this.theme,
      quoteLabel: this.quoteLabel,
      podcastBody: this.podcastBody,
      podcastEnglish: this.podcastEnglish,
      tags: this.tags,
      publishDate: this.publishDate
    };
  }

  private requestPreview(): void {
    this.previewDraftJson = JSON.stringify(this.draft());
    this.previewRevision += 1;
  }

  private validateRender(): boolean {
    const canvas: OffscreenCanvas = new OffscreenCanvas(1920, 1080,
      LengthMetricsUnit.PX);
    const context: OffscreenCanvasRenderingContext2D = canvas.getContext('2d');
    const result: RenderResult = CoverRenderer.render(context, this.definition(),
      this.draft(), undefined, 1);
    this.titleTooLong = result.titleTooLong;
    return !result.titleTooLong;
  }

  private async selectPhoto(): Promise<void> {
    try {
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const options: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      const result: photoAccessHelper.PhotoSelectResult = await picker.select(options);
      if (result.photoUris.length > 0) {
        this.photoLoading = true;
        this.photoLoadFailed = false;
        const hostContext: Context | undefined = this.getUIContext().getHostContext();
        if (hostContext === undefined) {
          throw new Error('无法访问应用目录');
        }
        const source: fileIo.File = fileIo.openSync(result.photoUris[0], fileIo.OpenMode.READ_ONLY);
        const localPath: string =
          `${hostContext.filesDir}/cover-photo-${this.templateId}-${Date.now()}.img`;
        fileIo.copyFileSync(source.fd, localPath);
        fileIo.closeSync(source);
        this.photoUri = localPath;
        this.requestPreview();
        this.showToast('已按 16:9 居中裁切');
      }
    } catch (error) {
      this.photoLoading = false;
      this.photoLoadFailed = true;
      this.showToast('未能读取所选图片');
    }
  }

  private showToast(message: string): void {
    this.getUIContext().getPromptAction().showToast({
      message: message,
      duration: 1800
    });
  }

  private validateEpisode(): boolean {
    if (!this.definition().capabilities.supportsEpisode) {
      return true;
    }
    if (this.episodePreset !== EpisodePreset.CUSTOM) {
      return true;
    }
    if (!isValidCustomEpisode(this.customEpisode)) {
      this.showToast('分集限 1–2 位数字或一个字符');
      return false;
    }
    return true;
  }

  private hasDraftChanges(): boolean {
    return this.savedDraftJson.length > 0 &&
      this.savedDraftJson !== JSON.stringify(this.draft());
  }

  private async saveDraftIfChanged(): Promise<boolean> {
    if (!this.hasDraftChanges()) {
      return false;
    }
    const draft: CoverDraft = this.draft();
    await LocalStore.saveDraft(draft);
    this.savedDraftJson = JSON.stringify(draft);
    this.sessionModified = true;
    return true;
  }

  private async leaveEditor(): Promise<void> {
    if (this.leaving) {
      return;
    }
    this.leaving = true;
    try {
      const changed: boolean = await this.saveDraftIfChanged();
      if (changed || this.sessionModified) {
        this.showToast('已保存到草稿');
      }
      this.getUIContext().getRouter().back();
    } catch (error) {
      this.leaving = false;
      this.showToast('草稿保存失败，请重试');
    }
  }

  private async copyAutomaticText(): Promise<void> {
    const text: string = automaticCopy(this.draft(), this.definition());
    const data: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    await pasteboard.getSystemPasteboard().setData(data);
    this.showToast('文案已复制');
  }

  private exportCover(): void {
    if (this.exporting) {
      return;
    }
    if (this.definition().capabilities.requiresPhoto && this.photoUri.length === 0) {
      this.showToast('请先上传图片');
      return;
    }
    if (this.photoLoading) {
      this.showToast('图片正在载入，请稍候');
      return;
    }
    if (this.photoLoadFailed) {
      this.showToast('图片未能载入，请重新选择');
      return;
    }
    if (!this.validateEpisode()) {
      return;
    }
    if (this.exportSettings.format === 'WebP' && !this.exportSettings.webpSupported) {
      this.showToast('当前设备暂不支持 WebP');
      return;
    }
    this.exporting = true;
    this.exportStage = 'rendering';
    // Return control to ArkUI first so the busy state is painted before
    // title validation, 4K rendering and image encoding begin.
    setTimeout(() => {
      this.performExport();
    }, 16);
  }

  private async performExport(): Promise<void> {
    try {
      if (!this.validateRender()) {
        this.showToast('标题过长，请精简后再导出');
        return;
      }
      const hostContext: Context | undefined = this.getUIContext().getHostContext();
      if (hostContext === undefined) {
        throw new Error('无法访问应用目录');
      }
      await ExportService.exportToGallery(this.definition(), this.draft(),
        this.exportSettings, hostContext, (): void => {
          this.exportStage = 'saving';
        });
      await LocalStore.markExported(this.draft());
      this.savedDraftJson = JSON.stringify(this.draft());
      this.sessionModified = false;
      this.showToast('封面已保存到相册');
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '导出失败，请稍后重试';
      this.showToast(message);
    } finally {
      this.exporting = false;
      this.exportStage = 'idle';
    }
  }

  private addTag(): void {
    const value: string = this.tagInput.trim();
    if (value.length === 0) {
      return;
    }
    if (this.tags.length >= 10) {
      this.showToast('最多添加 10 个标签');
      return;
    }
    for (let index: number = 0; index < this.tags.length; index++) {
      if (this.tags[index] === value) {
        this.showToast('这个标签已经添加');
        return;
      }
    }
    this.tags = this.tags.concat([value]);
    this.tagInput = '';
  }

  private selectedPublishDate(): Date {
    const values: string[] = this.publishDate.split('-');
    if (values.length === 3) {
      const year: number = Number(values[0]);
      const month: number = Number(values[1]);
      const day: number = Number(values[2]);
      if (year > 0 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        return new Date(year, month - 1, day);
      }
    }
    return new Date();
  }

  private updatePublishDate(value: Date): void {
    const month: string = (value.getMonth() + 1).toString().padStart(2, '0');
    const day: string = value.getDate().toString().padStart(2, '0');
    this.publishDate = `${value.getFullYear()}-${month}-${day}`;
  }

  private showPublishDatePicker(): void {
    this.getUIContext().showDatePickerDialog({
      selected: this.selectedPublishDate(),
      onDateAccept: (value: Date): void => {
        this.updatePublishDate(value);
      }
    });
  }

  @Builder
  private header() {
    Row() {
      SystemBackButton({
        onBack: (): void => {
          this.leaveEditor();
        }
      })
      Column({ space: 3 }) {
        Text(this.definition().name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('1920 × 1080 设计坐标')
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      Blank()
      Text(`模板 ${this.definition().code}`)
        .fontSize(11)
        .fontColor(this.definition().accent)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor($r('app.color.control_background'))
        .borderRadius(14)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor($r('app.color.nav_background'))
  }

  @Builder
  private sectionTitle(index: string, title: string, note: string) {
    Row() {
      Text(index)
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.brand_primary'))
        .width(26)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        if (note.length > 0) {
          Text(note)
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  private field(label: string, value: string, placeholder: string, action: (value: string) => void) {
    Column({ space: 6 }) {
      Text(label)
        .width('100%')
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
      TextInput({ text: value, placeholder: placeholder })
        .width('100%')
        .height(44)
        .fontSize(13)
        .fontColor($r('app.color.text_primary'))
        .placeholderColor($r('app.color.text_muted'))
        .backgroundColor($r('app.color.control_background'))
        .borderRadius(9)
        .padding({ left: 12, right: 12 })
        .onChange((text: string) => {
          action(text);
          this.requestPreview();
        })
    }
    .width('100%')
  }

  @Builder
  private episodeChoice(label: string) {
    Text(label)
      .layoutWeight(1)
      .height(38)
      .fontSize(12)
      .fontWeight(this.episodePreset === label ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.episodePreset === label ? '#FFFFFF' : $r('app.color.text_secondary'))
      .textAlign(TextAlign.Center)
      .backgroundColor(this.episodePreset === label ?
        $r('app.color.brand_primary') : $r('app.color.control_background'))
      .borderRadius(9)
      .onClick(() => {
        this.episodePreset = label;
        this.requestPreview();
      })
  }

  @Builder
  private preview() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        CoverPreview({
          templateId: this.templateId,
          draftJson: this.previewDraftJson,
          revision: this.previewRevision,
          onResult: (tooLong: boolean): void => {
            this.titleTooLong = tooLong;
          },
          onPhotoStateChanged: (state: string): void => {
            if (state === 'loading') {
              this.photoLoading = true;
              this.photoLoadFailed = false;
            } else if (state === 'ready') {
              this.photoLoading = false;
              this.photoLoadFailed = false;
            } else {
              this.photoLoading = false;
              this.photoLoadFailed = true;
              this.showToast('图片未能载入，请重新选择');
            }
          }
        })
        .width('100%')

        if (this.photoLoading) {
          Column({ space: 10 }) {
            LoadingProgress()
              .width(34)
              .height(34)
              .color('#FFFFFF')
            Text('正在载入图片')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Text('完成后会自动刷新')
              .fontSize(10)
              .fontColor('#CCFFFFFF')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#780B1016')
        } else if (this.photoLoadFailed) {
          Column({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.exclamationmark_triangle'))
              .fontSize(25)
              .fontColor(['#FFFFFF'])
            Text('图片未能载入，请重新选择')
              .fontSize(12)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#780B1016')
        }
      }
      .width('100%')
      .aspectRatio(16 / 9)
      .borderRadius(12)
      .clip(true)

      Row() {
        Row({ space: 7 }) {
          Row()
            .width(6)
            .height(6)
            .backgroundColor(this.titleTooLong ? '#FF574D' : '#47D889')
            .borderRadius(3)
          Text(this.titleTooLong ? '标题过长，请精简内容' : '预览与导出共用同一渲染函数')
            .fontSize(10)
            .fontColor(this.titleTooLong ? '#FF7A72' : $r('app.color.text_secondary'))
        }
        Blank()
        Text(this.exportLabel)
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
    }
    .width('100%')
    .padding({ bottom: 2 })
  }

  @Builder
  private photoSection() {
    Column() {
      this.sectionTitle('01', '背景图片', '上传后自动进行 16:9 居中裁切')
      Row() {
        Column({ space: 5 }) {
          if (this.photoLoading) {
            LoadingProgress()
              .width(25)
              .height(25)
              .color($r('app.color.brand_primary'))
          } else {
            SymbolGlyph(this.photoLoadFailed ? $r('sys.symbol.exclamationmark_triangle') :
              (this.photoUri.length > 0 ? $r('sys.symbol.checkmark') : $r('sys.symbol.plus')))
              .fontSize(24)
              .fontColor([this.photoLoadFailed ? $r('app.color.brand_primary') :
                (this.photoUri.length > 0 ? '#5AA77B' : $r('app.color.brand_primary'))])
          }
          Text(this.photoLoading ? '正在载入主图' :
            (this.photoLoadFailed ? '重新选择主图' :
              (this.photoUri.length > 0 ? '更换主图' : '上传主图')))
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Text(this.photoLoading ? '完成后预览会自动刷新' :
            (this.photoLoadFailed ? '上次图片没有成功载入' :
              (this.photoUri.length > 0 ? '已加载 · 点击可替换' : '支持系统相册中的图片')))
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
      }
      .height(105)
      .justifyContent(FlexAlign.Center)
      .border({ width: 1, color: $r('app.color.divider'), style: BorderStyle.Dashed })
      .borderRadius(12)
      .backgroundColor($r('app.color.control_background'))
      .onClick(() => {
        this.selectPhoto();
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  @Builder
  private contentSection() {
    Column({ space: 13 }) {
      this.sectionTitle(this.definition().capabilities.requiresPhoto ? '02' : '01',
        '封面内容', '字号、位置、颜色和阴影由模板自动确定')

      this.field('品牌', this.brand, '输入品牌', (value: string) => { this.brand = value; })

      if (this.definition().capabilities.supportsPersonFields) {
        this.field('人物说明', this.kicker, '例如：人物专题',
          (value: string) => { this.kicker = value; })
        this.field('人物主名', this.personName, '输入人物主名',
          (value: string) => { this.personName = value; })
        this.field('可选英文名', this.englishName, '例如：FEATURE STORY',
          (value: string) => { this.englishName = value; })
        this.field('分集标题', this.episodeTitle, '输入本集标题',
          (value: string) => { this.episodeTitle = value; })
      } else if (this.definition().capabilities.supportsPodcastFields) {
        this.field('引言标签', this.quoteLabel, '例如：本期话题',
          (value: string) => { this.quoteLabel = value; })
        Column({ space: 6 }) {
          Text('正文')
            .width('100%')
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
          TextArea({ text: this.podcastBody, placeholder: '输入播客正文' })
            .width('100%')
            .height(102)
            .fontSize(13)
            .fontColor($r('app.color.text_primary'))
            .placeholderColor($r('app.color.text_muted'))
            .backgroundColor($r('app.color.control_background'))
            .borderRadius(9)
            .padding(12)
            .onChange((value: string) => {
              this.podcastBody = value;
              this.requestPreview();
            })
        }
        this.field('可选英文名', this.podcastEnglish, '例如：Yike Podcast',
          (value: string) => { this.podcastEnglish = value; })
      } else {
        this.field('第一行', this.title1, '在这里输入第一行标题',
          (value: string) => { this.title1 = value; })
        this.field('第二行', this.title2, '在这里输入第二行标题',
          (value: string) => { this.title2 = value; })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  @Builder
  private optionsSection() {
    Column({ space: 13 }) {
      this.sectionTitle('03', '模板选项', '只显示当前模板支持的选项')

      if (this.definition().capabilities.supportsEpisode) {
        Text('分集字符')
          .width('100%')
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
        Row({ space: 7 }) {
          this.episodeChoice(EpisodePreset.UP)
          this.episodeChoice(EpisodePreset.MIDDLE)
          this.episodeChoice(EpisodePreset.DOWN)
          this.episodeChoice(EpisodePreset.CUSTOM)
        }
        .width('100%')
        if (this.episodePreset === EpisodePreset.CUSTOM) {
          this.field('自定义字符', this.customEpisode, '1–2 位数字或一个字符',
            (value: string) => { this.customEpisode = value; })
          if (this.customEpisode.length > 0 && !isValidCustomEpisode(this.customEpisode)) {
            Text('“字”“9”“10”有效；“特别”“100”无效')
              .width('100%')
              .fontSize(10)
              .fontColor('#FF746A')
          }
        }
      }

      if (this.definition().capabilities.supportsVersion) {
        Text('版本标识')
          .width('100%')
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(VERSION_PRESETS, (label: string) => {
            Text(label)
              .fontSize(11)
              .fontColor((!this.customVersion && this.versionLabel === label) ||
                (this.customVersion && label === '自定义') ? '#FFFFFF' : $r('app.color.text_secondary'))
              .padding({ left: 10, right: 10, top: 7, bottom: 7 })
              .backgroundColor((!this.customVersion && this.versionLabel === label) ||
                (this.customVersion && label === '自定义') ?
                $r('app.color.brand_primary') : $r('app.color.control_background'))
              .borderRadius(9)
              .margin({ right: 7, bottom: 7 })
              .onClick(() => {
                if (label === '自定义') {
                  this.customVersion = true;
                  this.versionLabel = '';
                } else {
                  this.customVersion = false;
                  this.versionLabel = label;
                }
                this.requestPreview();
              })
          })
        }
        .width('100%')
        if (this.customVersion) {
          this.field('自定义版本标识', this.versionLabel, '输入版本标识',
            (value: string) => { this.versionLabel = value; })
        }
        Text('金色只是视觉风格，不代表软件付费权限。')
          .width('100%')
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
      }

      if (this.definition().capabilities.supportsGrayscale) {
        Row() {
          Column({ space: 3 }) {
            Text('主图黑白')
              .fontSize(13)
              .fontColor($r('app.color.text_primary'))
            Text('仅影响上传的主图，不影响边框与文字')
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.photoGrayscale })
            .selectedColor($r('app.color.brand_primary'))
            .onChange((isOn: boolean) => {
              this.photoGrayscale = isOn;
              this.requestPreview();
            })
        }
        .width('100%')
      }

      if (this.definition().capabilities.supportsTheme) {
        Text('主题')
          .width('100%')
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
        Row({ space: 8 }) {
          Text('红色')
            .layoutWeight(1)
            .height(38)
            .fontSize(12)
            .fontColor(this.theme === CoverTheme.RED ?
              '#FFFFFF' : $r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .backgroundColor(this.theme === CoverTheme.RED ? '#E30A15' :
              $r('app.color.control_background'))
            .borderRadius(9)
            .onClick(() => {
              this.theme = CoverTheme.RED;
              this.requestPreview();
            })
          Text('青绿蓝')
            .layoutWeight(1)
            .height(38)
            .fontSize(12)
            .fontColor(this.theme === CoverTheme.CYAN ?
              '#FFFFFF' : $r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .backgroundColor(this.theme === CoverTheme.CYAN ? '#0B9EAF' :
              $r('app.color.control_background'))
            .borderRadius(9)
            .onClick(() => {
              this.theme = CoverTheme.CYAN;
              this.requestPreview();
            })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  @Builder
  private metadataSection() {
    Column({ space: 13 }) {
      this.sectionTitle('04', '发布信息', '仅作为草稿元数据，不绘制到封面')
      Row({ space: 8 }) {
        TextInput({ text: this.tagInput, placeholder: '输入标签，如：示例标签' })
          .layoutWeight(1)
          .height(42)
          .fontSize(12)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.control_background'))
          .borderRadius(9)
          .onChange((value: string) => {
            this.tagInput = value;
          })
        Button(`添加 ${this.tags.length}/10`, { type: ButtonType.Normal })
          .height(42)
          .fontSize(11)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.control_background'))
          .borderRadius(9)
          .onClick(() => {
            this.addTag();
          })
      }
      .width('100%')
      if (this.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.tags, (tag: string, index: number) => {
            Row({ space: 5 }) {
              Text(`# ${tag}`)
                .fontSize(10)
                .fontColor($r('app.color.text_secondary'))
              SymbolGlyph($r('sys.symbol.xmark'))
                .fontSize(9)
                .fontColor([$r('app.color.text_muted')])
            }
              .padding({ left: 9, right: 9, top: 6, bottom: 6 })
              .backgroundColor($r('app.color.control_background'))
              .borderRadius(12)
              .margin({ right: 6, bottom: 6 })
              .onClick(() => {
                this.tags = this.tags.filter((value: string, itemIndex: number) => itemIndex !== index);
              })
          }, (tag: string, index: number) => `${tag}-${index}`)
        }
        .width('100%')
      }
      Column({ space: 6 }) {
        Text('发布日期')
          .width('100%')
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
        Row() {
          Text(this.publishDate)
            .fontSize(13)
            .fontColor($r('app.color.text_primary'))
          Blank()
          SymbolGlyph($r('sys.symbol.calendar'))
            .fontSize(18)
            .fontColor([$r('app.color.text_secondary')])
        }
        .width('100%')
        .height(44)
        .padding({ left: 12, right: 12 })
        .backgroundColor($r('app.color.control_background'))
        .borderRadius(9)
        .onClick(() => {
          this.showPublishDatePicker();
        })
      }
      .width('100%')
      Column({ space: 8 }) {
        Row() {
          Text('自动整合结果')
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
          Blank()
          Text('只读')
            .fontSize(9)
            .fontColor($r('app.color.text_muted'))
        }
        .width('100%')
        Text(automaticCopy(this.draft(), this.definition()))
          .width('100%')
          .fontSize(12)
          .fontColor($r('app.color.text_primary'))
          .padding(12)
          .backgroundColor($r('app.color.control_background'))
          .borderRadius(9)
        Button('一键复制', { type: ButtonType.Normal })
          .width('100%')
          .height(40)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(9)
          .onClick(() => {
            this.copyAutomaticText();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  @Builder
  private exportSection() {
    Column({ space: 13 }) {
      this.sectionTitle('05', '导出封面', '按目标分辨率重新渲染')
      Row() {
        Column({ space: 3 }) {
          Text(this.exportLabel)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('全局设置 · 预览与导出构图一致')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Row({ space: 3 }) {
          Text('修改')
            .fontSize(12)
            .fontColor($r('app.color.brand_primary'))
          SymbolGlyph($r('sys.symbol.chevron_forward'))
            .fontSize(12)
            .fontColor([$r('app.color.brand_primary')])
        }
          .padding({ left: 10, right: 10, top: 7, bottom: 7 })
          .backgroundColor($r('app.color.brand_soft'))
          .borderRadius(14)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/ExportSettings'
            });
          })
      }
      .width('100%')
      .padding(12)
      .backgroundColor($r('app.color.control_background'))
      .borderRadius(11)

      if (this.definition().capabilities.requiresPhoto && this.photoUri.length === 0) {
        Button('请先上传图片', { type: ButtonType.Normal })
          .width('100%')
          .height(50)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#724037')
          .borderRadius(25)
          .enabled(false)
      } else {
        Button(this.photoLoading ? '图片载入中…' :
          (this.exportStage === 'saving' ? '等待确认保存…' :
            (this.exporting ? '正在生成…' : '保存到相册')),
          { type: ButtonType.Capsule })
          .width('100%')
          .height(50)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.brand_primary'))
          .enabled(!this.exporting && !this.photoLoading && !this.photoLoadFailed)
          .onClick(() => {
            this.exportCover();
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  build() {
    Column() {
      this.header()
      Scroll() {
        Column({ space: 14 }) {
          this.preview()
          if (this.definition().capabilities.requiresPhoto) {
            this.photoSection()
          }
          this.contentSection()
          if (this.definition().capabilities.supportsEpisode ||
            this.definition().capabilities.supportsVersion ||
            this.definition().capabilities.supportsGrayscale ||
            this.definition().capabilities.supportsTheme) {
            this.optionsSection()
          }
          this.metadataSection()
          this.exportSection()
        }
        .width('100%')
        .padding({ left: 14, right: 14, bottom: 28 })
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
