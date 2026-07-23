export const DESIGN_WIDTH: number = 1920;
export const DESIGN_HEIGHT: number = 1080;

export enum TemplateSkeleton {
  FRAME = 0,
  PHOTO_OVERLAY = 1,
  PODCAST = 2
}

export enum CoverTheme {
  RED = 'red',
  CYAN = 'cyan',
  GOLD = 'gold'
}

export enum EpisodePreset {
  UP = '上',
  MIDDLE = '中',
  DOWN = '下',
  CUSTOM = '自定义'
}

export interface TemplateCapabilities {
  requiresPhoto: boolean;
  supportsEpisode: boolean;
  supportsVersion: boolean;
  supportsGrayscale: boolean;
  supportsTheme: boolean;
  supportsPersonFields: boolean;
  supportsPodcastFields: boolean;
}

export interface TemplateDefinition {
  id: number;
  name: string;
  subtitle: string;
  code: string;
  accent: string;
  skeleton: TemplateSkeleton;
  capabilities: TemplateCapabilities;
  defaultBrand: string;
  defaultTitle1: string;
  defaultTitle2: string;
}

export interface ExportSettings {
  resolution: string;
  width: number;
  height: number;
  format: string;
  quality: number;
  webpSupported: boolean;
}

export interface CoverDraft {
  templateId: number;
  photoUri: string;
  brand: string;
  title1: string;
  title2: string;
  kicker: string;
  personName: string;
  englishName: string;
  episodeTitle: string;
  episodePreset: string;
  customEpisode: string;
  versionLabel: string;
  grayscale: boolean;
  theme: string;
  quoteLabel: string;
  podcastBody: string;
  podcastEnglish: string;
  tags: string[];
  publishDate: string;
}

export interface HistoryRecord {
  id: string;
  templateId: number;
  templateName: string;
  title: string;
  status: string;
  updatedAt: string;
  draftJson?: string;
}

function capabilities(requiresPhoto: boolean, episode: boolean, version: boolean,
  grayscale: boolean, theme: boolean, person: boolean, podcast: boolean): TemplateCapabilities {
  return {
    requiresPhoto: requiresPhoto,
    supportsEpisode: episode,
    supportsVersion: version,
    supportsGrayscale: grayscale,
    supportsTheme: theme,
    supportsPersonFields: person,
    supportsPodcastFields: podcast
  };
}

export const TEMPLATE_DEFINITIONS: TemplateDefinition[] = [
  {
    id: 1,
    code: '01',
    name: '经典渐变框',
    subtitle: '红橙金异形边框',
    accent: '#F25601',
    skeleton: TemplateSkeleton.FRAME,
    capabilities: capabilities(true, false, false, false, false, false, false),
    defaultBrand: '一刻封面',
    defaultTitle1: '在这里输入第一行标题',
    defaultTitle2: '在这里输入第二行标题'
  },
  {
    id: 2,
    code: '02',
    name: '经典分集框',
    subtitle: '人物主名与右上分集',
    accent: '#E60012',
    skeleton: TemplateSkeleton.FRAME,
    capabilities: capabilities(true, true, false, false, false, true, false),
    defaultBrand: '一刻封面',
    defaultTitle1: '人物专题',
    defaultTitle2: '浮沉'
  },
  {
    id: 3,
    code: '03',
    name: '金色会员框',
    subtitle: '金属渐变与可选黑白',
    accent: '#D5A52C',
    skeleton: TemplateSkeleton.FRAME,
    capabilities: capabilities(true, false, true, true, false, false, false),
    defaultBrand: '一刻封面',
    defaultTitle1: '在这里输入第一行标题',
    defaultTitle2: '在这里输入第二行标题'
  },
  {
    id: 4,
    code: '04',
    name: '美食细线框',
    subtitle: '暖色细边与宋体标题',
    accent: '#EE3425',
    skeleton: TemplateSkeleton.PHOTO_OVERLAY,
    capabilities: capabilities(true, false, false, false, false, false, false),
    defaultBrand: '吃点好的',
    defaultTitle1: '在这里输入第一行标题',
    defaultTitle2: '在这里输入第二行标题'
  },
  {
    id: 5,
    code: '05',
    name: '独家放大框',
    subtitle: '圆形强调与黄色竖线',
    accent: '#F3DD18',
    skeleton: TemplateSkeleton.PHOTO_OVERLAY,
    capabilities: capabilities(true, false, false, false, false, false, false),
    defaultBrand: '独家现场',
    defaultTitle1: '在这里输入第一行标题',
    defaultTitle2: '在这里输入第二行标题'
  },
  {
    id: 6,
    code: '06',
    name: '系列分集框',
    subtitle: '红色或青蓝双色主题',
    accent: '#00BBA4',
    skeleton: TemplateSkeleton.PHOTO_OVERLAY,
    capabilities: capabilities(true, true, false, false, true, false, false),
    defaultBrand: '系列特别节目',
    defaultTitle1: '在这里输入第一行标题',
    defaultTitle2: '在这里输入第二行标题'
  },
  {
    id: 7,
    code: '07',
    name: '金色分集框',
    subtitle: '金色主题与版本标识',
    accent: '#D7B557',
    skeleton: TemplateSkeleton.PHOTO_OVERLAY,
    capabilities: capabilities(true, true, true, false, false, false, false),
    defaultBrand: '特别节目',
    defaultTitle1: '在这里输入第一行标题',
    defaultTitle2: '在这里输入第二行标题'
  },
  {
    id: 8,
    code: '08',
    name: '播客信息卡',
    subtitle: '代码生成声波与播客标志',
    accent: '#1F5274',
    skeleton: TemplateSkeleton.PODCAST,
    capabilities: capabilities(false, true, false, false, false, false, true),
    defaultBrand: '一刻播客',
    defaultTitle1: '行业观察',
    defaultTitle2: '在这里输入播客正文'
  },
  {
    id: 9,
    code: '09',
    name: '金色播客卡',
    subtitle: '金色播客加长版本',
    accent: '#D4B366',
    skeleton: TemplateSkeleton.PODCAST,
    capabilities: capabilities(false, true, true, false, false, false, true),
    defaultBrand: '一刻播客',
    defaultTitle1: '行业观察',
    defaultTitle2: '在这里输入播客正文'
  }
];

export const VERSION_PRESETS: string[] = [
  '会员专享',
  '会员抢鲜版',
  '会员抢先版',
  '会员加长版',
  '自定义'
];

export function getTemplateDefinition(id: number): TemplateDefinition {
  for (let index: number = 0; index < TEMPLATE_DEFINITIONS.length; index++) {
    if (TEMPLATE_DEFINITIONS[index].id === id) {
      return TEMPLATE_DEFINITIONS[index];
    }
  }
  return TEMPLATE_DEFINITIONS[0];
}

export function todayText(): string {
  const date: Date = new Date();
  const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
  const day: string = date.getDate().toString().padStart(2, '0');
  return `${date.getFullYear()}-${month}-${day}`;
}

export function createDefaultDraft(definition: TemplateDefinition): CoverDraft {
  return {
    templateId: definition.id,
    photoUri: '',
    brand: definition.defaultBrand,
    title1: definition.defaultTitle1,
    title2: definition.defaultTitle2,
    kicker: '人物专题',
    personName: '示例人物',
    englishName: 'PORTRAIT',
    episodeTitle: '本期主题',
    episodePreset: EpisodePreset.UP,
    customEpisode: '',
    versionLabel: definition.capabilities.supportsVersion ? '会员专享' : '',
    grayscale: false,
    theme: definition.id === 6 ? CoverTheme.RED : CoverTheme.GOLD,
    quoteLabel: '本期话题',
    podcastBody: '在这里输入播客正文，支持自动换行与字号适配。',
    podcastEnglish: 'Yike Podcast',
    tags: [],
    publishDate: todayText()
  };
}

export function resolvedEpisode(draft: CoverDraft): string {
  if (draft.episodePreset === EpisodePreset.CUSTOM) {
    return draft.customEpisode.trim();
  }
  return draft.episodePreset;
}

export function isValidCustomEpisode(value: string): boolean {
  const normalized: string = value.trim();
  if (normalized.length === 0) {
    return false;
  }
  if (/^\d{1,2}$/.test(normalized)) {
    return true;
  }
  return Array.from(normalized).length === 1;
}

export function automaticCopy(draft: CoverDraft, definition: TemplateDefinition): string {
  let mainText: string;
  if (definition.capabilities.supportsPersonFields) {
    mainText = `${draft.personName}${draft.episodeTitle}`;
  } else if (definition.capabilities.supportsPodcastFields) {
    mainText = `${draft.quoteLabel}${draft.podcastBody}`;
  } else {
    mainText = `${draft.title1}${draft.title2}`;
  }
  let result: string = mainText;
  for (let index: number = 0; index < draft.tags.length; index++) {
    result += `｜${draft.tags[index]}`;
  }
  return `${result}｜${draft.brand}${draft.publishDate.replace(/-/g, '')}`;
}
