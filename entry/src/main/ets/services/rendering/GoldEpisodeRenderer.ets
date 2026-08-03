import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  resolvedEpisode
} from '../../model/CoverModels';
import {
  AdaptiveHeaderLayout,
  editorialHeaderLayout,
  drawCoverPhoto,
  EDITORIAL_HEADER_LABEL_CENTER_Y,
  EDITORIAL_HEADER_LABEL_LEFT,
  EDITORIAL_HEADER_VERSION_CENTER_Y,
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
  setCanvasFont
} from './RenderSupport';

const VERSION_LABEL_FONT_SIZE: number = 76;
const VERSION_LABEL_MIN_FONT_SIZE: number = 52;

function goldBand(ctx: CanvasRenderer, width: number): CanvasGradient {
  const band: CanvasGradient = ctx.createLinearGradient(0, 0,
    width, 0);
  band.addColorStop(0, '#FBD75F');
  band.addColorStop(0.52, '#F9E270');
  band.addColorStop(1, '#FFF0A0');
  return band;
}

function drawGoldHeader(ctx: CanvasRenderer, draft: CoverDraft): void {
  const layout: AdaptiveHeaderLayout =
    editorialHeaderLayout(ctx, draft.brand, EDITORIAL_HEADER_LABEL_LEFT);
  ctx.fillStyle = goldBand(ctx, layout.width);
  drawEditorialHeaderTabPath(ctx, layout.width);
  ctx.fill();

  ctx.fillStyle = '#8B4E08';
  setCanvasFont(ctx, layout.fontSize, { bold: true, italic: true });
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.brand, EDITORIAL_HEADER_LABEL_LEFT,
    EDITORIAL_HEADER_LABEL_CENTER_Y);

  if (draft.versionLabel.length > 0) {
    const versionLeft: number = layout.trailingLabelLeft;
    ctx.fillStyle = '#F4D572';
    const versionSize: number = fitSingleText(ctx, draft.versionLabel,
      1620 - versionLeft - 28, VERSION_LABEL_FONT_SIZE,
      VERSION_LABEL_MIN_FONT_SIZE, { bold: true, italic: true });
    setCanvasFont(ctx, versionSize, { bold: true, italic: true });
    ctx.fillText(draft.versionLabel, versionLeft,
      EDITORIAL_HEADER_VERSION_CENTER_Y);
  }
  ctx.textBaseline = 'alphabetic';
}

function drawGoldCorner(ctx: CanvasRenderer, episode: string): void {
  const corner: CanvasGradient = ctx.createLinearGradient(1620, 0,
    DESIGN_WIDTH, 300);
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
  drawCoverPhoto(ctx, bitmap, false, draft.photoOffsetX,
    draft.photoOffsetY, draft.photoScale);
  drawGoldTitleContrast(ctx);
  drawGoldHeader(ctx, draft);
  drawGoldCorner(ctx, resolvedEpisode(draft));
  return drawGoldTitles(ctx, draft);
}
