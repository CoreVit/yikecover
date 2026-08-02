import preferences from '@ohos.data.preferences';
import fileIo from '@ohos.file.fs';
import {
  CoverDraft,
  DEFAULT_PHOTO_TITLE_FIRST,
  DEFAULT_PHOTO_TITLE_SECOND,
  DEFAULT_QUOTE_BODY,
  DEFAULT_QUOTE_TITLE,
  ExportSettings,
  HistoryRecord,
  EpisodePreset,
  createDefaultDraft,
  getTemplateDefinition,
  isValidCustomEpisode,
  isValidPodcastEpisode
} from '../model/CoverModels';
const SETTINGS_STORE: string = 'yikecover_settings';
const CONTENT_STORE: string = 'yikecover_content';

let applicationContext: Context | undefined = undefined;

const LEGACY_QUOTE_DEFAULT_CHECKSUM: number = 157451345;

function quoteDefaultChecksum(title: string, body: string): number {
  const units: string[] = Array.from(`${title}\n${body}`);
  let checksum: number = 0;
  for (let index: number = 0; index < units.length; index++) {
    checksum = (checksum * 131 + units[index].charCodeAt(0)) % 2147483647;
  }
  return checksum;
}

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

function migrateDraftDefaults(draft: CoverDraft): CoverDraft {
  if (draft.templateId >= 1 && draft.templateId <= 7) {
    if (draft.title1 === '在这里输入第一行标题') {
      draft.title1 = DEFAULT_PHOTO_TITLE_FIRST;
    }
    if (draft.title2 === '在这里输入第二行标题') {
      draft.title2 = DEFAULT_PHOTO_TITLE_SECOND;
    }
  }
  if (draft.templateId === 8 || draft.templateId === 9) {
    draft.episodePreset = EpisodePreset.CUSTOM;
    if (!isValidPodcastEpisode(draft.customEpisode)) {
      draft.customEpisode = '01';
    }
  }
  if (draft.templateId === 10 &&
    quoteDefaultChecksum(draft.title1, draft.title2) ===
      LEGACY_QUOTE_DEFAULT_CHECKSUM) {
    draft.title1 = DEFAULT_QUOTE_TITLE;
    draft.title2 = DEFAULT_QUOTE_BODY;
  }
  if (draft.templateId === 6 || draft.templateId === 7) {
    if (draft.episodePreset !== EpisodePreset.CUSTOM &&
      draft.customEpisode.trim().length === 0) {
      draft.customEpisode = draft.episodePreset;
    }
    draft.episodePreset = EpisodePreset.CUSTOM;
    if (!isValidCustomEpisode(draft.customEpisode)) {
      draft.customEpisode = '1';
    }
  }
  return draft;
}

function deleteGeneratedFiles(directory: string, prefix: string): void {
  const names: string[] = fileIo.listFileSync(directory);
  for (let index: number = 0; index < names.length; index++) {
    if (names[index].startsWith(prefix)) {
      const path: string = `${directory}/${names[index]}`;
      if (fileIo.statSync(path).isFile()) {
        fileIo.unlinkSync(path);
      }
    }
  }
}

function normalizedResolution(value: string): string {
  if (value === '720P' || value === '4K') {
    return value;
  }
  return '1080P';
}

function normalizedFormat(value: string): string {
  if (value === 'JPEG' || value === 'WebP') {
    return value;
  }
  return 'PNG';
}

function normalizedQuality(value: number): number {
  if (!Number.isFinite(value)) {
    return 92;
  }
  return Math.min(100, Math.max(60, Math.round(value)));
}

export class LocalStore {
  static initialize(hostContext: Context): void {
    applicationContext = hostContext;
  }

  static async loadExportSettings(): Promise<ExportSettings> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), SETTINGS_STORE);
    const resolution: string = normalizedResolution(
      store.getSync('resolution', '1080P') as string);
    const format: string = normalizedFormat(
      store.getSync('format', 'PNG') as string);
    const quality: number = normalizedQuality(
      store.getSync('quality', 92) as number);
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
      quality: quality
    };
  }

  static async saveExportSettings(settings: ExportSettings): Promise<void> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), SETTINGS_STORE);
    store.putSync('resolution', normalizedResolution(settings.resolution));
    store.putSync('format', normalizedFormat(settings.format));
    store.putSync('quality', normalizedQuality(settings.quality));
    await store.flush();
  }

  static async loadDraft(templateId: number): Promise<CoverDraft> {
    const store: preferences.Preferences = await preferences.getPreferences(context(), CONTENT_STORE);
    const raw: string = store.getSync(`draft_${templateId}`, '') as string;
    if (raw.length > 0) {
      try {
        return migrateDraftDefaults(JSON.parse(raw) as CoverDraft);
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
      updatedAt: new Date().toLocaleString(),
      draftJson: JSON.stringify(draft)
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
    store.putSync(`draft_${draft.templateId}`, JSON.stringify(draft));
    store.putSync(`brand_${draft.templateId}`, draft.brand);
    store.putSync(`version_${draft.templateId}`, draft.versionLabel);
    store.putSync(`theme_${draft.templateId}`, draft.theme);
    const history: HistoryRecord[] = await LocalStore.loadHistory();
    const records: HistoryRecord[] = history.filter((item: HistoryRecord) =>
      item.id !== `draft-${draft.templateId}`);
    records.unshift({
      id: `export-${Date.now()}`,
      templateId: draft.templateId,
      templateName: definition.name,
      title: recordTitle(draft),
      status: '已导出',
      updatedAt: new Date().toLocaleString(),
      draftJson: JSON.stringify(draft)
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

  static async clearAllLocalData(): Promise<void> {
    const appContext: Context = context();
    deleteGeneratedFiles(appContext.filesDir, 'cover-photo-');
    deleteGeneratedFiles(appContext.cacheDir, '一刻封面-');

    const settings: preferences.Preferences =
      await preferences.getPreferences(appContext, SETTINGS_STORE);
    const content: preferences.Preferences =
      await preferences.getPreferences(appContext, CONTENT_STORE);
    await settings.clear();
    await content.clear();
    await settings.flush();
    await content.flush();

    if (settings.hasSync('resolution') || settings.hasSync('format') ||
      settings.hasSync('quality') || content.hasSync('history')) {
      throw new Error('本机数据清理后仍有残留');
    }
  }
}
