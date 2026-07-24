import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';
import {
  CORNER_LABEL_FONT_SIZE,
  CORNER_LABEL_MIN_FONT_SIZE,
  drawCoverPhoto,
  fitSingleText,
  fitTextPair,
  isTextTooWide,
  PHOTO_TITLE_FIRST_BASELINE,
  PHOTO_TITLE_LEFT,
  PHOTO_TITLE_MAX_WIDTH,
  PHOTO_TITLE_SECOND_BASELINE,
  setCanvasFont
} from './RenderSupport';

function exclusiveTabWidth(ctx: CanvasRenderer, brand: string): number {
  const size: number = fitSingleText(ctx, brand, 680,
    CORNER_LABEL_FONT_SIZE, CORNER_LABEL_MIN_FONT_SIZE,
    { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  return Math.min(830, Math.max(330, ctx.measureText(brand).width + 122));
}

function drawExclusiveBrand(ctx: CanvasRenderer, brand: string): void {
  const width: number = exclusiveTabWidth(ctx, brand);
  const size: number = fitSingleText(ctx, brand, width - 122,
    CORNER_LABEL_FONT_SIZE, CORNER_LABEL_MIN_FONT_SIZE,
    { bold: true, italic: true });
  ctx.fillStyle = '#EB0000';
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width, 0);
  ctx.lineTo(width - 44, 96);
  ctx.quadraticCurveTo(width - 58, 128, width - 104, 128);
  ctx.lineTo(0, 128);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#FFFFFF';
  setCanvasFont(ctx, size, { bold: true, italic: true });
  ctx.textBaseline = 'middle';
  ctx.fillText(brand, 56, 63);
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
  const size: number = fitTextPair(ctx, draft.title1, draft.title2,
    maxWidth, 104, 66, { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
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
