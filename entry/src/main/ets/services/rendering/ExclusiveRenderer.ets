import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';
import {
  AdaptiveHeaderLayout,
  adaptiveHeaderLayout,
  drawCoverPhoto,
  EDITORIAL_HEADER_LABEL_FONT_SIZE,
  EDITORIAL_HEADER_LABEL_MIN_FONT_SIZE,
  EDITORIAL_HEADER_LABEL_CENTER_Y,
  EDITORIAL_HEADER_TAB_HEIGHT,
  fitPhotoTitlePair,
  isTextTooWide,
  PHOTO_TITLE_FIRST_BASELINE,
  PHOTO_TITLE_LEFT,
  PHOTO_TITLE_MAX_WIDTH,
  PHOTO_TITLE_SECOND_BASELINE,
  setPhotoTitleFont,
  setCanvasFont
} from './RenderSupport';

const EXCLUSIVE_LABEL_LEFT: number = 52;
const EXCLUSIVE_LABEL_RIGHT_GAP: number = 12;

function exclusiveTabLayout(ctx: CanvasRenderer,
  brand: string): AdaptiveHeaderLayout {
  return adaptiveHeaderLayout(ctx, brand, EXCLUSIVE_LABEL_LEFT,
    EDITORIAL_HEADER_LABEL_FONT_SIZE,
    EDITORIAL_HEADER_LABEL_MIN_FONT_SIZE,
    360, 850, EXCLUSIVE_LABEL_RIGHT_GAP, 104,
    EXCLUSIVE_LABEL_RIGHT_GAP,
    { bold: true, italic: true });
}

function drawExclusiveBrand(ctx: CanvasRenderer, brand: string): void {
  const layout: AdaptiveHeaderLayout = exclusiveTabLayout(ctx, brand);
  const width: number = layout.width;
  ctx.fillStyle = '#EB0000';
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width, 0);
  ctx.lineTo(width - 44, EDITORIAL_HEADER_TAB_HEIGHT - 32);
  ctx.quadraticCurveTo(width - 58, EDITORIAL_HEADER_TAB_HEIGHT,
    layout.curveStart, EDITORIAL_HEADER_TAB_HEIGHT);
  ctx.lineTo(0, EDITORIAL_HEADER_TAB_HEIGHT);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#FFFFFF';
  setCanvasFont(ctx, layout.fontSize, { bold: true, italic: true });
  ctx.textBaseline = 'middle';
  ctx.fillText(brand, EXCLUSIVE_LABEL_LEFT,
    EDITORIAL_HEADER_LABEL_CENTER_Y);
  ctx.textBaseline = 'alphabetic';
}

function drawExclusiveShade(ctx: CanvasRenderer): void {
  const shade: CanvasGradient =
    ctx.createLinearGradient(0, 650, 0, DESIGN_HEIGHT);
  shade.addColorStop(0, '#00000000');
  shade.addColorStop(0.58, '#5A000000');
  shade.addColorStop(1, '#B6000000');
  ctx.fillStyle = shade;
  ctx.fillRect(0, 650, DESIGN_WIDTH, DESIGN_HEIGHT - 650);
}

function drawExclusiveTitles(ctx: CanvasRenderer,
  draft: CoverDraft): boolean {
  const maxWidth: number = PHOTO_TITLE_MAX_WIDTH;
  const size: number =
    fitPhotoTitlePair(ctx, draft.title1, draft.title2);
  setPhotoTitleFont(ctx, size);
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.fillStyle = '#FFFFFF';
  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 10;
  ctx.shadowOffsetY = 4;
  ctx.fillText(draft.title1, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_FIRST_BASELINE);
  ctx.fillText(draft.title2, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_SECOND_BASELINE);
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderExclusive(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  drawCoverPhoto(ctx, bitmap, false);
  drawExclusiveShade(ctx);
  drawExclusiveBrand(ctx, draft.brand);
  return drawExclusiveTitles(ctx, draft);
}
