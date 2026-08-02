import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';
import {
  AdaptiveHeaderLayout,
  classicFrameHeaderLayout,
  drawCoverPhoto,
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

const INSET: number = 24;
const RADIUS: number = 78;
const MEMBER_LABEL_CENTER_Y: number = 80;
const VERSION_LABEL_FONT_SIZE: number = 60;
const VERSION_LABEL_MIN_FONT_SIZE: number = 42;

function memberMetalGradient(ctx: CanvasRenderer): CanvasGradient {
  const frame: CanvasGradient = ctx.createConicGradient(
    0, DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2);
  // The reference frame behaves like a continuous metal ribbon:
  // dark at the upper-right and bottom-center, bright at the other turns.
  frame.addColorStop(0, '#BE7E1D');
  frame.addColorStop(0.08, '#ECBB42');
  frame.addColorStop(0.25, '#984C00');
  frame.addColorStop(0.42, '#CB9F56');
  frame.addColorStop(0.5, '#FBF3AB');
  frame.addColorStop(0.58, '#FFF6AB');
  frame.addColorStop(0.75, '#E0C27A');
  frame.addColorStop(0.92, '#A15C11');
  frame.addColorStop(1, '#BE7E1D');
  return frame;
}

function memberTabLayout(ctx: CanvasRenderer,
  brand: string): AdaptiveHeaderLayout {
  return classicFrameHeaderLayout(ctx, brand);
}

function createMemberOpening(ctx: CanvasRenderer, brand: string): void {
  const right: number = DESIGN_WIDTH - INSET;
  const bottom: number = DESIGN_HEIGHT - INSET;
  const bottomJoin: number = DESIGN_WIDTH / 2;
  const layout: AdaptiveHeaderLayout = memberTabLayout(ctx, brand);
  const notchEnd: number = Math.min(layout.width, right - RADIUS * 2);
  ctx.beginPath();
  ctx.moveTo(bottomJoin, bottom);
  ctx.lineTo(INSET + RADIUS, bottom);
  ctx.quadraticCurveTo(INSET, bottom, INSET, bottom - RADIUS);
  ctx.lineTo(INSET, 192);
  ctx.quadraticCurveTo(INSET, 136, 82, 136);
  const shelfEnd: number = layout.curveStart;
  ctx.lineTo(shelfEnd, 136);
  ctx.bezierCurveTo(shelfEnd + 52, 136,
    notchEnd - 52, INSET, notchEnd, INSET);
  ctx.lineTo(right - RADIUS, INSET);
  ctx.quadraticCurveTo(right, INSET, right, INSET + RADIUS);
  ctx.lineTo(right, bottom - RADIUS);
  ctx.quadraticCurveTo(right, bottom, right - RADIUS, bottom);
  ctx.lineTo(bottomJoin, bottom);
  ctx.closePath();
}

function drawMemberFrame(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): void {
  ctx.fillStyle = memberMetalGradient(ctx);
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  const metalHighlight: CanvasGradient =
    ctx.createLinearGradient(0, 0, DESIGN_WIDTH, 0);
  metalHighlight.addColorStop(0, '#24FFFFFF');
  metalHighlight.addColorStop(0.24, '#12FFFFFF');
  metalHighlight.addColorStop(0.5, '#00FFFFFF');
  metalHighlight.addColorStop(0.76, '#08FFF2B2');
  metalHighlight.addColorStop(1, '#18FFF2B2');
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
  const layout: AdaptiveHeaderLayout = memberTabLayout(ctx, draft.brand);

  ctx.fillStyle = '#9A570C';
  setCanvasFont(ctx, layout.fontSize, { bold: true, italic: true });
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.brand, 58, MEMBER_LABEL_CENTER_Y);

  if (draft.versionLabel.length > 0) {
    const versionLeft: number = layout.trailingLabelLeft;
    const versionSize: number = fitSingleText(ctx, draft.versionLabel,
      DESIGN_WIDTH - versionLeft - 72, VERSION_LABEL_FONT_SIZE,
      VERSION_LABEL_MIN_FONT_SIZE, { bold: true, italic: true });
    setCanvasFont(ctx, versionSize, { bold: true, italic: true });
    const versionWidth: number =
      Math.max(1, ctx.measureText(draft.versionLabel).width);
    drawGradientText(ctx, draft.versionLabel, versionLeft,
      MEMBER_LABEL_CENTER_Y,
      versionWidth, '#FEF3A4', '#DFA83D');
  }
  ctx.textBaseline = 'alphabetic';
}

function drawMemberTitles(ctx: CanvasRenderer, draft: CoverDraft): boolean {
  const maxWidth: number = PHOTO_TITLE_MAX_WIDTH;
  const size: number =
    fitPhotoTitlePair(ctx, draft.title1, draft.title2);
  setPhotoTitleFont(ctx, size);
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
  drawGradientText(ctx, draft.title1, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_FIRST_BASELINE, title1Width,
    '#FBE17F', '#FCEC9A');
  drawGradientText(ctx, draft.title2, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_SECOND_BASELINE, title2Width,
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
