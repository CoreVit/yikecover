import preferences from '@ohos.data.preferences';
import image from '@ohos.multimedia.image';
import { CoverDraft, ExportSettings, HistoryRecord, createDefaultDraft, getTemplateDefinition } from '../model/CoverModels';

const SETTINGS_STORE: string = 'yikecover_settings';
const CONTENT_STORE: string = 'yikecover_content';

let applicationContext: Context | undefined = undefined;

function context(): Context {
  if (applicationContext === undefined) {
    throw new Error('应用上下文尚未初始化');
  }
  return applicationContext;
}

function recordTitle(draft: CoverDraft): string {
  const definition = getTemplateDefinition(draft.templateId);
  if (definition.capabilities.supportsPersonFields) {
    return `${draft.personName} ${draft.episodeTitle}`;
  }
  if (definition.capabilities.supportsPodcastFields) {
    return draft.quoteLabel;
  }
  return draft.title1;
}

export class LocalStore {
  static initialize(hostContext: Context): void {
    applicationContext = hostContext;
  }

  static async loadExportSettings(): Promise<ExportSettings> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), SETTINGS_STORE);
    const resolution: string = store.getSync('resolution', '1080P') as string;
    const format: string = store.getSync('format', 'PNG') as string;
    const quality: number = store.getSync('quality', 92) as number;
    const webpSupported: boolean = store.getSync('webpSupported', false) as boolean;
    let width: number = 1920;
    let height: number = 1080;
    if (resolution === '720P') {
      width = 1280;
      height = 720;
    } else if (resolution === '4K') {
      width = 3840;
      height = 2160;
    }
    return {
      resolution: resolution,
      width: width,
      height: height,
      format: format,
      quality: quality,
      webpSupported: webpSupported
    };
  }

  static async saveExportSettings(settings: ExportSettings): Promise<void> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), SETTINGS_STORE);
    store.putSync('resolution', settings.resolution);
    store.putSync('format', settings.format);
    store.putSync('quality', settings.quality);
    store.putSync('webpSupported', settings.webpSupported);
    await store.flush();
  }

  static async probeWebpSupport(): Promise<boolean> {
    try {
      const canvas: OffscreenCanvas = new OffscreenCanvas(2, 2);
      const canvasContext: OffscreenCanvasRenderingContext2D = canvas.getContext('2d');
      canvasContext.fillStyle = '#FF4F3F';
      canvasContext.fillRect(0, 0, 2, 2);
      const pixelMap: PixelMap = canvasContext.getPixelMap(0, 0, 2, 2);
      const packer: image.ImagePacker = image.createImagePacker();
      const encoded: ArrayBuffer = await packer.packToData(pixelMap, {
        format: 'image/webp',
        quality: 80
      });
      const supported: boolean = encoded.byteLength > 0;
      const store: preferences.Preferences = await preferences.getPreferences(context(), SETTINGS_STORE);
      store.putSync('webpSupported', supported);
      await store.flush();
      return supported;
    } catch (error) {
      const store: preferences.Preferences = await preferences.getPreferences(context(), SETTINGS_STORE);
      store.putSync('webpSupported', false);
      await store.flush();
      return false;
    }
  }

  static async loadDraft(templateId: number): Promise<CoverDraft> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), CONTENT_STORE);
    const raw: string = store.getSync(`draft_${templateId}`, '') as string;
    if (raw.length > 0) {
      try {
        return JSON.parse(raw) as CoverDraft;
      } catch (error) {
      }
    }
    const draft: CoverDraft = createDefaultDraft(getTemplateDefinition(templateId));
    const brand: string = store.getSync(`brand_${templateId}`, draft.brand) as string;
    const version: string = store.getSync(`version_${templateId}`, draft.versionLabel) as string;
    const theme: string = store.getSync(`theme_${templateId}`, draft.theme) as string;
    draft.brand = brand;
    draft.versionLabel = version;
    draft.theme = theme;
    return draft;
  }

  static async saveDraft(draft: CoverDraft): Promise<void> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), CONTENT_STORE);
    store.putSync(`draft_${draft.templateId}`, JSON.stringify(draft));
    store.putSync(`brand_${draft.templateId}`, draft.brand);
    store.putSync(`version_${draft.templateId}`, draft.versionLabel);
    store.putSync(`theme_${draft.templateId}`, draft.theme);
    const definition = getTemplateDefinition(draft.templateId);
    const records: HistoryRecord[] = await LocalStore.loadHistory();
    const id: string = `draft-${draft.templateId}`;
    const record: HistoryRecord = {
      id: id,
      templateId: draft.templateId,
      templateName: definition.name,
      title: recordTitle(draft),
      status: '草稿',
      updatedAt: new Date().toLocaleString()
    };
    let found: boolean = false;
    for (let index: number = 0; index < records.length; index++) {
      if (records[index].id === id) {
        records[index] = record;
        found = true;
      }
    }
    if (!found) {
      records.unshift(record);
    }
    store.putSync('history', JSON.stringify(records));
    await store.flush();
  }

  static async markExported(draft: CoverDraft): Promise<void> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), CONTENT_STORE);
    const definition = getTemplateDefinition(draft.templateId);
    const records: HistoryRecord[] = await LocalStore.loadHistory();
    records.unshift({
      id: `export-${Date.now()}`,
      templateId: draft.templateId,
      templateName: definition.name,
      title: recordTitle(draft),
      status: '已导出',
      updatedAt: new Date().toLocaleString()
    });
    store.putSync('history', JSON.stringify(records.slice(0, 50)));
    await store.flush();
  }

  static async loadHistory(): Promise<HistoryRecord[]> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), CONTENT_STORE);
    const raw: string = store.getSync('history', '[]') as string;
    try {
      return JSON.parse(raw) as HistoryRecord[];
    } catch (error) {
      return [];
    }
  }
}
