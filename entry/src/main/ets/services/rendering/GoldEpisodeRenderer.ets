import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  resolvedEpisode
} from '../../model/CoverModels';
import {
  BRAND_LABEL_CENTER_Y,
  CORNER_LABEL_FONT_SIZE,
  CORNER_LABEL_MIN_FONT_SIZE,
  drawCoverPhoto,
  drawEditorialHeaderTabPath,
  drawEditorialEpisodeCornerPath,
  drawEditorialEpisodeNumber,
  drawGradientText,
  fitPhotoTitlePair,
  fitSingleText,
  isTextTooWide,
  PHOTO_TITLE_FIRST_BASELINE,
  PHOTO_TITLE_LEFT,
  PHOTO_TITLE_MAX_WIDTH,
  PHOTO_TITLE_SECOND_BASELINE,
  setPhotoTitleFont,
  setCanvasFont,
  EDITORIAL_HEADER_TAB_WIDTH,
  EDITORIAL_HEADER_VERSION_LEFT
} from './RenderSupport';

const VERSION_LABEL_FONT_SIZE: number = 60;
const VERSION_LABEL_MIN_FONT_SIZE: number = 42;

function goldBand(ctx: CanvasRenderer): CanvasGradient {
  const band: CanvasGradient = ctx.createLinearGradient(0, 0,
    EDITORIAL_HEADER_TAB_WIDTH, 0);
  band.addColorStop(0, '#FBD75F');
  band.addColorStop(0.52, '#F9E270');
  band.addColorStop(1, '#FFF0A0');
  return band;
}

function drawGoldHeader(ctx: CanvasRenderer, draft: CoverDraft): void {
  const brandSize: number = fitSingleText(ctx, draft.brand, 610,
    CORNER_LABEL_FONT_SIZE, CORNER_LABEL_MIN_FONT_SIZE,
    { bold: true, italic: true });
  setCanvasFont(ctx, brandSize, { bold: true, italic: true });
  ctx.fillStyle = goldBand(ctx);
  drawEditorialHeaderTabPath(ctx);
  ctx.fill();

  ctx.fillStyle = '#8B4E08';
  setCanvasFont(ctx, brandSize, { bold: true, italic: true });
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.brand, 58, BRAND_LABEL_CENTER_Y);

  if (draft.versionLabel.length > 0) {
    const versionLeft: number = EDITORIAL_HEADER_VERSION_LEFT;
    ctx.fillStyle = '#F4D572';
    const versionSize: number = fitSingleText(ctx, draft.versionLabel,
      1640 - versionLeft - 72, VERSION_LABEL_FONT_SIZE,
      VERSION_LABEL_MIN_FONT_SIZE, { bold: true, italic: true });
    setCanvasFont(ctx, versionSize, { bold: true, italic: true });
    ctx.fillText(draft.versionLabel, versionLeft,
      BRAND_LABEL_CENTER_Y);
  }
  ctx.textBaseline = 'alphabetic';
}

function drawGoldCorner(ctx: CanvasRenderer, episode: string): void {
  const corner: CanvasGradient = ctx.createLinearGradient(1634, 0,
    DESIGN_WIDTH, 286);
  corner.addColorStop(0, '#FFF8B0');
  corner.addColorStop(1, '#D7AC62');
  ctx.fillStyle = corner;
  drawEditorialEpisodeCornerPath(ctx);
  ctx.fill();

  drawEditorialEpisodeNumber(ctx, episode, '#A96512');
}

function drawGoldTitleContrast(ctx: CanvasRenderer): void {
  const shade: CanvasGradient = ctx.createLinearGradient(0, 0, 1180, 0);
  shade.addColorStop(0, '#78000000');
  shade.addColorStop(0.58, '#32000000');
  shade.addColorStop(1, '#00000000');
  ctx.fillStyle = shade;
  ctx.fillRect(0, 560, 1240, DESIGN_HEIGHT - 560);
}

function drawGoldTitles(ctx: CanvasRenderer, draft: CoverDraft): boolean {
  const maxWidth: number = PHOTO_TITLE_MAX_WIDTH;
  const size: number =
    fitPhotoTitlePair(ctx, draft.title1, draft.title2);
  setPhotoTitleFont(ctx, size);
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 10;
  ctx.shadowOffsetY = 4;
  drawGradientText(ctx, draft.title1, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_FIRST_BASELINE, maxWidth,
    '#FFF2A4', '#E3B746');
  drawGradientText(ctx, draft.title2, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_SECOND_BASELINE, maxWidth,
    '#F8DE79', '#B77311');
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderGoldEpisode(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  drawCoverPhoto(ctx, bitmap, false);
  drawGoldTitleContrast(ctx);
  drawGoldHeader(ctx, draft);
  drawGoldCorner(ctx, resolvedEpisode(draft));
  return drawGoldTitles(ctx, draft);
}
