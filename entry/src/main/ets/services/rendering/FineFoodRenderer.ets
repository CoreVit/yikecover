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
  setCanvasFont
} from './RenderSupport';

function foodTabWidth(ctx: CanvasRenderer, brand: string): number {
  const size: number = fitSingleText(ctx, brand, 660, 92, 52,
    { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  return Math.min(820, Math.max(410, ctx.measureText(brand).width + 140));
}

function drawFoodBorder(ctx: CanvasRenderer, brand: string): void {
  const inset: number = 32;
  const radius: number = 64;
  const shelfRadius: number = 8;
  const circleControl: number = radius * 0.55228475;
  const shelfY: number = 144;
  const right: number = DESIGN_WIDTH - inset;
  const bottom: number = DESIGN_HEIGHT - inset;
  const bottomJoin: number = DESIGN_WIDTH / 2;
  const topJoin: number =
    Math.min(foodTabWidth(ctx, brand), right - radius - 120);
  const shelfEnd: number = topJoin - 94;
  const outline: CanvasGradient =
    ctx.createLinearGradient(0, inset, 0, bottom);
  outline.addColorStop(0, '#EF0010');
  outline.addColorStop(0.42, '#F10C0D');
  outline.addColorStop(0.72, '#F24B05');
  outline.addColorStop(1, '#F6B10A');
  ctx.strokeStyle = outline;
  ctx.lineWidth = 8;
  ctx.lineJoin = 'round';
  ctx.beginPath();
  ctx.moveTo(bottomJoin, bottom);
  ctx.lineTo(inset + radius, bottom);
  ctx.bezierCurveTo(inset + radius - circleControl, bottom,
    inset, bottom - radius + circleControl, inset, bottom - radius);
  ctx.lineTo(inset, shelfY + shelfRadius);
  ctx.quadraticCurveTo(inset, shelfY, inset + shelfRadius, shelfY);
  ctx.lineTo(shelfEnd, shelfY);
  ctx.bezierCurveTo(shelfEnd + 42, shelfY,
    topJoin - 30, inset, topJoin, inset);
  ctx.lineTo(right - radius, inset);
  ctx.bezierCurveTo(right - radius + circleControl, inset,
    right, inset + radius - circleControl, right, inset + radius);
  ctx.lineTo(right, bottom - radius);
  ctx.bezierCurveTo(right, bottom - radius + circleControl,
    right - radius + circleControl, bottom, right - radius, bottom);
  ctx.lineTo(bottomJoin, bottom);
  ctx.closePath();
  ctx.stroke();
}

function drawFoodBrand(ctx: CanvasRenderer, brand: string): void {
  const width: number = foodTabWidth(ctx, brand);
  const size: number = fitSingleText(ctx, brand, width - 140,
    92, 52, { bold: true, italic: true });
  ctx.fillStyle = '#F00B11';
  setCanvasFont(ctx, size, { bold: true, italic: true });
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(brand, 62, 72);
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
  drawFoodBorder(ctx, draft.brand);
  drawFoodBrand(ctx, draft.brand);
  return drawFoodTitles(ctx, draft);
}
