import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  resolvedEpisode
} from '../../model/CoverModels';
import {
  drawCoverPhoto,
  drawGradientText,
  fitSingleText,
  fitTextPair,
  isTextTooWide,
  PHOTO_TITLE_FIRST_BASELINE,
  PHOTO_TITLE_LEFT,
  PHOTO_TITLE_MAX_WIDTH,
  PHOTO_TITLE_SECOND_BASELINE,
  setCanvasFont
} from './RenderSupport';

const INSET: number = 24;
const RADIUS: number = 64;
// Brand and episode marks are supporting information, not headline text.
const BRAND_SIZE: number = 88;
const CIRCLE_CONTROL: number = RADIUS * 0.55228475;

function tabWidth(ctx: CanvasRenderer, brand: string): number {
  const size: number = fitSingleText(ctx, brand, 760,
    BRAND_SIZE, 54, { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  return Math.min(920, Math.max(370, ctx.measureText(brand).width + 126));
}

function createEpisodeOpening(ctx: CanvasRenderer, brand: string): void {
  const right: number = DESIGN_WIDTH - INSET;
  const bottom: number = DESIGN_HEIGHT - INSET;
  const bottomJoin: number = DESIGN_WIDTH / 2;
  const notchEnd: number =
    Math.min(tabWidth(ctx, brand) + 34, right - RADIUS * 2);
  ctx.beginPath();
  ctx.moveTo(bottomJoin, bottom);
  ctx.lineTo(INSET + RADIUS, bottom);
  ctx.bezierCurveTo(INSET + RADIUS - CIRCLE_CONTROL, bottom,
    INSET, bottom - RADIUS + CIRCLE_CONTROL, INSET, bottom - RADIUS);
  ctx.lineTo(INSET, 192);
  ctx.quadraticCurveTo(INSET, 136, 82, 136);
  const shelfEnd: number = notchEnd - 116;
  ctx.lineTo(shelfEnd, 136);
  ctx.bezierCurveTo(shelfEnd + 52, 136,
    notchEnd - 52, INSET, notchEnd, INSET);

  // The episode corner is part of the photo opening itself. It enters and
  // leaves the diagonal with tangent-continuous curves instead of covering a
  // rounded rectangle with a straight triangular patch.
  ctx.lineTo(1668, INSET);
  ctx.bezierCurveTo(1700, INSET, 1718, 38, 1742, 62);
  ctx.lineTo(1862, 182);
  ctx.bezierCurveTo(1884, 204, right, 228, right, 260);
  ctx.lineTo(right, bottom - RADIUS);
  ctx.bezierCurveTo(right, bottom - RADIUS + CIRCLE_CONTROL,
    right - RADIUS + CIRCLE_CONTROL, bottom, right - RADIUS, bottom);
  ctx.lineTo(bottomJoin, bottom);
  ctx.closePath();
}

function drawEpisodeBackground(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): void {
  const frame: CanvasGradient =
    ctx.createLinearGradient(0, 0, 0, DESIGN_HEIGHT);
  frame.addColorStop(0, '#EB0000');
  frame.addColorStop(0.54, '#F25601');
  frame.addColorStop(1, '#F7AB00');
  ctx.fillStyle = frame;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  ctx.save();
  createEpisodeOpening(ctx, draft.brand);
  ctx.clip();
  drawCoverPhoto(ctx, bitmap, false);

  const leftShade: CanvasGradient = ctx.createLinearGradient(0, 0, 1050, 0);
  leftShade.addColorStop(0, '#E0000000');
  leftShade.addColorStop(0.62, '#75000000');
  leftShade.addColorStop(1, '#00000000');
  ctx.fillStyle = leftShade;
  ctx.fillRect(0, 0, 1080, DESIGN_HEIGHT);

  const edgeShade: CanvasGradient =
    ctx.createRadialGradient(DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2, 430,
      DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2, 1110);
  edgeShade.addColorStop(0, '#00000000');
  edgeShade.addColorStop(0.78, '#00000000');
  edgeShade.addColorStop(1, '#4A000000');
  ctx.fillStyle = edgeShade;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  ctx.restore();
}

function drawEpisodeBrand(ctx: CanvasRenderer, brand: string): void {
  const width: number = tabWidth(ctx, brand);
  const size: number = fitSingleText(ctx, brand, width - 126,
    BRAND_SIZE, 54, { bold: true, italic: true });
  ctx.fillStyle = '#FFFFFF';
  setCanvasFont(ctx, size, { bold: true, italic: true });
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(brand, 58, 64);
  ctx.textBaseline = 'alphabetic';
}

function drawEpisodeCorner(ctx: CanvasRenderer, episode: string): void {
  if (episode.length === 0) {
    return;
  }
  ctx.save();
  ctx.translate(1842, 82);
  ctx.rotate(Math.PI / 4);
  ctx.fillStyle = '#FFFFFF';
  setCanvasFont(ctx, 78, { bold: true });
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(episode, 0, 0);
  ctx.restore();
}

function drawEpisodeContent(ctx: CanvasRenderer,
  draft: CoverDraft): boolean {
  const maxWidth: number = PHOTO_TITLE_MAX_WIDTH;
  const size: number = fitTextPair(ctx, draft.title1, draft.title2,
    maxWidth, 96, 64, { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 12;
  ctx.shadowOffsetX = 4;
  ctx.shadowOffsetY = 4;
  drawGradientText(ctx, draft.title1, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_FIRST_BASELINE, maxWidth, '#FADF3B', '#F5B924');
  drawGradientText(ctx, draft.title2, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_SECOND_BASELINE, maxWidth, '#FFFFFF', '#D7DCE1');
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderClassicEpisode(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  const episode: string = resolvedEpisode(draft);
  drawEpisodeBackground(ctx, draft, bitmap);
  drawEpisodeBrand(ctx, draft.brand);
  drawEpisodeCorner(ctx, episode);
  return drawEpisodeContent(ctx, draft);
}
