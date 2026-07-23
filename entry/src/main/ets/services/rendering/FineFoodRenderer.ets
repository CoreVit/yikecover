import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';
import {
  drawCoverPhoto,
  fitSingleText,
  fitTextPair,
  isTextTooWide,
  roundedRect,
  setCanvasFont
} from './RenderSupport';

function foodTabWidth(ctx: CanvasRenderer, brand: string): number {
  const size: number = fitSingleText(ctx, brand, 650, 84, 48,
    { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  return Math.min(800, Math.max(310, ctx.measureText(brand).width + 118));
}

function drawFoodBorder(ctx: CanvasRenderer): void {
  const outline: CanvasGradient =
    ctx.createLinearGradient(30, 30, DESIGN_WIDTH - 30,
      DESIGN_HEIGHT - 30);
  outline.addColorStop(0, '#F00A13');
  outline.addColorStop(0.55, '#F12A0D');
  outline.addColorStop(1, '#F7B00C');
  ctx.strokeStyle = outline;
  ctx.lineWidth = 9;
  roundedRect(ctx, 34, 34, DESIGN_WIDTH - 68,
    DESIGN_HEIGHT - 68, 72);
  ctx.stroke();
}

function drawFoodBrand(ctx: CanvasRenderer, brand: string): void {
  const width: number = foodTabWidth(ctx, brand);
  const size: number = fitSingleText(ctx, brand, width - 118,
    84, 48, { bold: true, italic: true });
  ctx.fillStyle = '#0D0F12';
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width, 0);
  ctx.lineTo(width - 42, 94);
  ctx.quadraticCurveTo(width - 58, 126, width - 102, 126);
  ctx.lineTo(0, 126);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#F00B11';
  setCanvasFont(ctx, size, { bold: true, italic: true });
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(brand, 56, 62);
  ctx.textBaseline = 'alphabetic';
}

function drawFoodTitles(ctx: CanvasRenderer, draft: CoverDraft): boolean {
  const maxWidth: number = 1600;
  const size: number = fitTextPair(ctx, draft.title1, draft.title2,
    maxWidth, 108, 68, { bold: true, family: 'serif' });
  setCanvasFont(ctx, size, { bold: true, family: 'serif' });
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.fillStyle = '#FFFFFF';
  ctx.shadowColor = '#B8000000';
  ctx.shadowBlur = 8;
  ctx.shadowOffsetX = 3;
  ctx.shadowOffsetY = 4;
  ctx.fillText(draft.title1, 96, 840);
  ctx.fillText(draft.title2, 96, 982);
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderFineFood(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  drawCoverPhoto(ctx, bitmap, false);
  drawFoodBorder(ctx);
  drawFoodBrand(ctx, draft.brand);
  return drawFoodTitles(ctx, draft);
}
