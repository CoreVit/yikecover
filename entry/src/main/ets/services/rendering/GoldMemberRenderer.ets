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
  const bottomJoin: number = DESIGN_WIDTH / 2;
  const notchEnd: number =
    Math.min(memberTabWidth(ctx, brand) + 38, right - RADIUS * 2);
  ctx.beginPath();
  ctx.moveTo(bottomJoin, bottom);
  ctx.lineTo(INSET + RADIUS, bottom);
  ctx.quadraticCurveTo(INSET, bottom, INSET, bottom - RADIUS);
  ctx.lineTo(INSET, 192);
  ctx.quadraticCurveTo(INSET, 136, 82, 136);
  ctx.lineTo(notchEnd - 116, 136);
  ctx.quadraticCurveTo(notchEnd - 54, 136, notchEnd - 32, 80);
  ctx.quadraticCurveTo(notchEnd - 12, INSET, notchEnd, INSET);
  ctx.lineTo(right - RADIUS, INSET);
  ctx.quadraticCurveTo(right, INSET, right, INSET + RADIUS);
  ctx.lineTo(right, bottom - RADIUS);
  ctx.quadraticCurveTo(right, bottom, right - RADIUS, bottom);
  ctx.lineTo(bottomJoin, bottom);
  ctx.closePath();
}

function drawMemberFrame(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): void {
  const frame: CanvasGradient =
    ctx.createLinearGradient(0, 0, DESIGN_WIDTH, 0);
  frame.addColorStop(0, '#FEF3A4');
  frame.addColorStop(0.28, '#F8E69A');
  frame.addColorStop(0.52, '#E1C57C');
  frame.addColorStop(0.76, '#A1590D');
  frame.addColorStop(1, '#984C00');
  ctx.fillStyle = frame;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  const lowerWarmth: CanvasGradient =
    ctx.createLinearGradient(0, 0, 0, DESIGN_HEIGHT);
  lowerWarmth.addColorStop(0, '#00F2C246');
  lowerWarmth.addColorStop(0.58, '#0CF2C246');
  lowerWarmth.addColorStop(1, '#78F2C246');
  ctx.fillStyle = lowerWarmth;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  const metalHighlight: CanvasGradient =
    ctx.createLinearGradient(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  metalHighlight.addColorStop(0, '#32FFFFFF');
  metalHighlight.addColorStop(0.24, '#08FFFFFF');
  metalHighlight.addColorStop(0.48, '#28FFFFFF');
  metalHighlight.addColorStop(0.7, '#00FFFFFF');
  metalHighlight.addColorStop(1, '#16FFF2B2');
  ctx.fillStyle = metalHighlight;
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

  ctx.fillStyle = '#9A570C';
  setCanvasFont(ctx, brandSize, { bold: true, italic: true });
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.brand, 58, 65);
  ctx.textBaseline = 'alphabetic';

  if (draft.versionLabel.length > 0) {
    const versionSize: number = fitSingleText(ctx, draft.versionLabel,
      DESIGN_WIDTH - width - 100, 48, 32, { bold: true, italic: true });
    setCanvasFont(ctx, versionSize, { bold: true, italic: true });
    const versionWidth: number =
      Math.max(1, ctx.measureText(draft.versionLabel).width);
    drawGradientText(ctx, draft.versionLabel, width + 18, 82,
      versionWidth, '#FEF3A4', '#DFA83D');
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
  const title1Width: number =
    Math.max(1, Math.min(maxWidth, ctx.measureText(draft.title1).width));
  const title2Width: number =
    Math.max(1, Math.min(maxWidth, ctx.measureText(draft.title2).width));

  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 13;
  ctx.shadowOffsetX = 4;
  ctx.shadowOffsetY = 5;
  drawGradientText(ctx, draft.title1, 72, 882, title1Width,
    '#FBE17F', '#FCEC9A');
  drawGradientText(ctx, draft.title2, 72, 1005, title2Width,
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
