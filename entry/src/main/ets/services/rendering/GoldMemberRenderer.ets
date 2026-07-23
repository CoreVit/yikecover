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
const BRAND_SIZE: number = 92;

function memberTabWidth(ctx: CanvasRenderer, brand: string): number {
  const size: number = fitSingleText(ctx, brand, 760,
    BRAND_SIZE, 54, { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  return Math.min(930, Math.max(380, ctx.measureText(brand).width + 132));
}

function createMemberOpening(ctx: CanvasRenderer, brand: string): void {
  const right: number = DESIGN_WIDTH - INSET;
  const bottom: number = DESIGN_HEIGHT - INSET;
  const notchEnd: number =
    Math.min(memberTabWidth(ctx, brand) + 38, right - RADIUS * 2);
  ctx.beginPath();
  ctx.moveTo(notchEnd, INSET);
  ctx.lineTo(right - RADIUS, INSET);
  ctx.quadraticCurveTo(right, INSET, right, INSET + RADIUS);
  ctx.lineTo(right, bottom - RADIUS);
  ctx.quadraticCurveTo(right, bottom, right - RADIUS, bottom);
  ctx.lineTo(INSET + RADIUS, bottom);
  ctx.quadraticCurveTo(INSET, bottom, INSET, bottom - RADIUS);
  ctx.lineTo(INSET, 196);
  ctx.quadraticCurveTo(INSET, 140, 82, 140);
  ctx.lineTo(notchEnd - 118, 140);
  ctx.quadraticCurveTo(notchEnd - 56, 140, notchEnd - 34, 82);
  ctx.quadraticCurveTo(notchEnd - 12, INSET, notchEnd, INSET);
  ctx.closePath();
}

function drawMemberFrame(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): void {
  const frame: CanvasGradient =
    ctx.createConicGradient(0, DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2);
  frame.addColorStop(0, '#FEF3A4');
  frame.addColorStop(0.2, '#E1C57C');
  frame.addColorStop(0.43, '#A1590D');
  frame.addColorStop(0.64, '#984C00');
  frame.addColorStop(0.82, '#F2C246');
  frame.addColorStop(1, '#FEF3A4');
  ctx.fillStyle = frame;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  ctx.save();
  createMemberOpening(ctx, draft.brand);
  ctx.clip();
  drawCoverPhoto(ctx, bitmap, draft.grayscale);

  const insetShade: CanvasGradient =
    ctx.createRadialGradient(DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2, 370,
      DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2, 1110);
  insetShade.addColorStop(0, '#00000000');
  insetShade.addColorStop(0.72, '#06000000');
  insetShade.addColorStop(1, '#56000000');
  ctx.fillStyle = insetShade;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  ctx.restore();
}

function drawMemberHeader(ctx: CanvasRenderer, draft: CoverDraft): void {
  const width: number = memberTabWidth(ctx, draft.brand);
  const brandSize: number = fitSingleText(ctx, draft.brand, width - 132,
    BRAND_SIZE, 54, { bold: true, italic: true });
  const tab: CanvasGradient = ctx.createLinearGradient(0, 0, width, 130);
  tab.addColorStop(0, '#FEF3A4');
  tab.addColorStop(0.5, '#F4D678');
  tab.addColorStop(1, '#D39A2D');
  ctx.fillStyle = tab;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width, 0);
  ctx.lineTo(width - 46, 100);
  ctx.quadraticCurveTo(width - 60, 132, width - 106, 132);
  ctx.lineTo(0, 132);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#9A570C';
  setCanvasFont(ctx, brandSize, { bold: true, italic: true });
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.brand, 58, 65);
  ctx.textBaseline = 'alphabetic';

  if (draft.versionLabel.length > 0) {
    ctx.fillStyle = '#F6D56D';
    const versionSize: number = fitSingleText(ctx, draft.versionLabel,
      DESIGN_WIDTH - width - 100, 48, 32, { bold: true, italic: true });
    setCanvasFont(ctx, versionSize, { bold: true, italic: true });
    ctx.fillText(draft.versionLabel, width + 18, 82);
  }
}

function drawMemberTitles(ctx: CanvasRenderer, draft: CoverDraft): boolean {
  const maxWidth: number = 1760;
  const size: number = fitTextPair(ctx, draft.title1, draft.title2,
    maxWidth, 108, 70, { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 13;
  ctx.shadowOffsetX = 4;
  ctx.shadowOffsetY = 5;
  drawGradientText(ctx, draft.title1, 72, 882, maxWidth,
    '#FBE17F', '#FCEC9A');
  drawGradientText(ctx, draft.title2, 72, 1005, maxWidth,
    '#FCEC9A', '#DDAE41');
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderGoldMember(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  drawMemberFrame(ctx, draft, bitmap);
  drawMemberHeader(ctx, draft);
  return drawMemberTitles(ctx, draft);
}
