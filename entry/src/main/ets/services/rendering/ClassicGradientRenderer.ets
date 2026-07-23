import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';
import {
  drawCoverPhoto,
  drawGradientText,
  fitSingleText,
  fitTextPair,
  isTextTooWide,
  setCanvasFont
} from './RenderSupport';

const INSET: number = 24;
const RADIUS: number = 78;
const BRAND_SIZE: number = 96;

function brandTabWidth(ctx: CanvasRenderer, brand: string): number {
  const size: number = fitSingleText(ctx, brand, 760, BRAND_SIZE, 54,
    { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  return Math.min(920, Math.max(370, ctx.measureText(brand).width + 126));
}

function createClassicOpening(ctx: CanvasRenderer, brand: string): void {
  const right: number = DESIGN_WIDTH - INSET;
  const bottom: number = DESIGN_HEIGHT - INSET;
  const notchEnd: number =
    Math.min(brandTabWidth(ctx, brand) + 34, right - RADIUS * 2);
  ctx.beginPath();
  ctx.moveTo(notchEnd, INSET);
  ctx.lineTo(right - RADIUS, INSET);
  ctx.quadraticCurveTo(right, INSET, right, INSET + RADIUS);
  ctx.lineTo(right, bottom - RADIUS);
  ctx.quadraticCurveTo(right, bottom, right - RADIUS, bottom);
  ctx.lineTo(INSET + RADIUS, bottom);
  ctx.quadraticCurveTo(INSET, bottom, INSET, bottom - RADIUS);
  ctx.lineTo(INSET, 192);
  ctx.quadraticCurveTo(INSET, 136, 82, 136);
  ctx.lineTo(notchEnd - 116, 136);
  ctx.quadraticCurveTo(notchEnd - 54, 136, notchEnd - 32, 80);
  ctx.quadraticCurveTo(notchEnd - 12, INSET, notchEnd, INSET);
  ctx.closePath();
}

function drawFrameAndPhoto(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): void {
  const frame: CanvasGradient =
    ctx.createLinearGradient(0, 0, 0, DESIGN_HEIGHT);
  frame.addColorStop(0, '#EB0000');
  frame.addColorStop(0.54, '#F25601');
  frame.addColorStop(1, '#F7AB00');
  ctx.fillStyle = frame;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  ctx.save();
  createClassicOpening(ctx, draft.brand);
  ctx.clip();
  drawCoverPhoto(ctx, bitmap, false);

  // One continuous edge vignette creates the recessed frame effect without
  // introducing a separate black strip along the bottom.
  const insetShade: CanvasGradient =
    ctx.createRadialGradient(DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2, 360,
      DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2, 1110);
  insetShade.addColorStop(0, '#00000000');
  insetShade.addColorStop(0.7, '#08000000');
  insetShade.addColorStop(1, '#5C000000');
  ctx.fillStyle = insetShade;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  ctx.restore();
}

function drawBrandTab(ctx: CanvasRenderer, brand: string): void {
  const width: number = brandTabWidth(ctx, brand);
  const size: number = fitSingleText(ctx, brand, width - 126,
    BRAND_SIZE, 54, { bold: true, italic: true });
  ctx.fillStyle = '#EB0000';
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width, 0);
  ctx.lineTo(width - 44, 98);
  ctx.quadraticCurveTo(width - 58, 128, width - 102, 128);
  ctx.lineTo(0, 128);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#FFFFFF';
  setCanvasFont(ctx, size, { bold: true, italic: true });
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(brand, 58, 64);
  ctx.textBaseline = 'alphabetic';
}

function drawTitles(ctx: CanvasRenderer, draft: CoverDraft): boolean {
  const maxWidth: number = 1760;
  const size: number = fitTextPair(ctx, draft.title1, draft.title2,
    maxWidth, 108, 70, { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 12;
  ctx.shadowOffsetX = 4;
  ctx.shadowOffsetY = 5;
  drawGradientText(ctx, draft.title1, 72, 882, maxWidth,
    '#FADF3B', '#F5B924');
  drawGradientText(ctx, draft.title2, 72, 1005, maxWidth,
    '#FFFFFF', '#D7DCE1');
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderClassicGradient(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  drawFrameAndPhoto(ctx, draft, bitmap);
  drawBrandTab(ctx, draft.brand);
  return drawTitles(ctx, draft);
}
