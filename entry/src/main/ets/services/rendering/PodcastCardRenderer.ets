import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  resolvedEpisode
} from '../../model/CoverModels';
import {
  BRAND_LABEL_CENTER_Y,
  CORNER_LABEL_FONT_SIZE,
  CORNER_LABEL_MIN_FONT_SIZE,
  drawEpisodeCornerLabel,
  fitSingleText,
  setCanvasFont,
  wrapText
} from './RenderSupport';

export interface PodcastCardPalette {
  backgroundTop: string;
  backgroundBottom: string;
  accent: string;
  contour: string;
  equalizer: string;
}

const HEADER_LEFT: number = 72;
const HEADER_MAX_WIDTH: number = 360;
const COPY_LEFT: number = 106;
const COPY_WIDTH: number = 1010;
const VERSION_GAP: number = 30;
const HEADER_TAB_WIDTH: number = 420;
const HEADER_TAB_HEIGHT: number = 132;
const HEADER_CURVE_RADIUS_X: number = 95;
const ELLIPSE_KAPPA: number = 0.55228475;

function drawBackground(ctx: CanvasRenderer,
  palette: PodcastCardPalette): void {
  const background: CanvasGradient =
    ctx.createLinearGradient(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  background.addColorStop(0, palette.backgroundTop);
  background.addColorStop(1, palette.backgroundBottom);
  ctx.fillStyle = background;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  drawContourField(ctx, palette.contour);
  drawEqualizer(ctx, palette.equalizer);
}

// The reference cover uses a topographic field, not generic decorative waves.
// These nested Bézier paths are deterministic design-space formulae, so preview
// and export remain pixel-identical without depending on a background asset.
function drawContourField(ctx: CanvasRenderer, color: string): void {
  ctx.save();
  ctx.strokeStyle = color;
  ctx.lineWidth = 3;
  ctx.globalAlpha = 0.12;

  for (let index: number = 0; index < 11; index++) {
    const y: number = 36 + index * 42;
    const drift: number = index * 12;
    ctx.beginPath();
    ctx.moveTo(-40, y + 110);
    ctx.bezierCurveTo(230 + drift, y - 92, 430 - drift,
      y + 210, 720, y + 112);
    ctx.bezierCurveTo(1010, y + 12, 1225 + drift,
      y + 56, 1450, y + 10);
    ctx.bezierCurveTo(1640, y - 34, 1790,
      y + 70, 1980, y - 24);
    ctx.stroke();
  }

  for (let index: number = 0; index < 7; index++) {
    const inset: number = index * 33;
    ctx.beginPath();
    ctx.moveTo(1260 + inset, 176 + inset * 0.18);
    ctx.bezierCurveTo(1450 + inset * 0.35, 116 + inset,
      1776 - inset * 0.18, 168 + inset * 0.42,
      1810 - inset * 0.12, 348 + inset * 0.34);
    ctx.bezierCurveTo(1848 - inset * 0.16, 558 - inset * 0.12,
      1630 - inset * 0.32, 694 - inset * 0.16,
      1412 + inset * 0.12, 612 - inset * 0.12);
    ctx.bezierCurveTo(1230 + inset * 0.18, 544 - inset * 0.18,
      1118 + inset * 0.42, 290 + inset * 0.04,
      1260 + inset, 176 + inset * 0.18);
    ctx.stroke();
  }
  ctx.restore();
}

function drawEqualizer(ctx: CanvasRenderer, color: string): void {
  ctx.save();
  ctx.fillStyle = color;
  ctx.globalAlpha = 0.58;
  const barWidth: number = 13;
  const gap: number = 17;
  for (let index: number = 0; index < 65; index++) {
    const x: number = 8 + index * (barWidth + gap);
    const rhythm: number = (index * 47 + index * index * 11) % 128;
    const height: number = 34 + rhythm;
    ctx.beginPath();
    ctx.moveTo(x, DESIGN_HEIGHT);
    ctx.lineTo(x, DESIGN_HEIGHT - height + 7);
    ctx.quadraticCurveTo(x, DESIGN_HEIGHT - height,
      x + barWidth / 2, DESIGN_HEIGHT - height);
    ctx.quadraticCurveTo(x + barWidth, DESIGN_HEIGHT - height,
      x + barWidth, DESIGN_HEIGHT - height + 7);
    ctx.lineTo(x + barWidth, DESIGN_HEIGHT);
    ctx.closePath();
    ctx.fill();
  }
  ctx.restore();
}

function drawHeader(ctx: CanvasRenderer, draft: CoverDraft,
  palette: PodcastCardPalette, showVersion: boolean): void {
  const displayBrand: string =
    Array.from(draft.brand.trim()).slice(0, 4).join('');
  ctx.fillStyle = palette.accent;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(HEADER_TAB_WIDTH, 0);
  // Cubic approximation of one quarter ellipse. Keeping the first control
  // point vertical and the second horizontal removes the visible kink while
  // giving both podcast variants exactly the same reference curvature.
  ctx.bezierCurveTo(HEADER_TAB_WIDTH,
    HEADER_TAB_HEIGHT * ELLIPSE_KAPPA,
    HEADER_TAB_WIDTH - HEADER_CURVE_RADIUS_X +
      HEADER_CURVE_RADIUS_X * ELLIPSE_KAPPA,
    HEADER_TAB_HEIGHT,
    HEADER_TAB_WIDTH - HEADER_CURVE_RADIUS_X,
    HEADER_TAB_HEIGHT);
  ctx.lineTo(0, HEADER_TAB_HEIGHT);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = palette.backgroundTop;
  const brandSize: number = fitSingleText(ctx, displayBrand,
    HEADER_MAX_WIDTH, CORNER_LABEL_FONT_SIZE, CORNER_LABEL_MIN_FONT_SIZE,
    { bold: true, italic: true });
  setCanvasFont(ctx, brandSize, { bold: true, italic: true });
  ctx.textBaseline = 'middle';
  ctx.fillText(displayBrand, HEADER_LEFT, BRAND_LABEL_CENTER_Y);

  if (showVersion && draft.versionLabel.trim().length > 0) {
    const versionLeft: number = HEADER_TAB_WIDTH + VERSION_GAP;
    const versionSize: number = fitSingleText(ctx, draft.versionLabel,
      1560 - versionLeft, 62, 42, { bold: true, italic: true });
    ctx.fillStyle = palette.accent;
    setCanvasFont(ctx, versionSize, { bold: true, italic: true });
    ctx.fillText(draft.versionLabel, versionLeft, BRAND_LABEL_CENTER_Y);
  }
  ctx.textBaseline = 'alphabetic';

  ctx.fillStyle = palette.accent;
  ctx.beginPath();
  ctx.moveTo(1580, 0);
  ctx.lineTo(1778, 0);
  ctx.quadraticCurveTo(1828, 0, 1860, 38);
  ctx.lineTo(DESIGN_WIDTH, 106);
  ctx.lineTo(DESIGN_WIDTH, 332);
  ctx.closePath();
  ctx.fill();
  drawEpisodeCornerLabel(ctx, resolvedEpisode(draft),
    palette.backgroundTop, 1818, 82);
}

function drawQuoteAndCopy(ctx: CanvasRenderer, draft: CoverDraft,
  palette: PodcastCardPalette): boolean {
  ctx.fillStyle = palette.accent;
  setCanvasFont(ctx, 120, { bold: true, family: 'serif' });
  ctx.fillText('“', COPY_LEFT, 330);

  const labelSize: number = fitSingleText(ctx, draft.quoteLabel,
    580, 52, 38, { bold: true });
  setCanvasFont(ctx, labelSize, { bold: true });
  const labelWidth: number = Math.max(620,
    Math.min(820, ctx.measureText(draft.quoteLabel).width + 62));
  ctx.fillRect(COPY_LEFT, 372, labelWidth, 88);
  ctx.fillStyle = palette.backgroundTop;
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.quoteLabel, COPY_LEFT + 24, 416);
  ctx.textBaseline = 'alphabetic';

  let size: number = 76;
  let lines: string[] = [];
  while (size >= 48) {
    setCanvasFont(ctx, size, { bold: true });
    lines = wrapText(ctx, draft.podcastBody, COPY_WIDTH, 4);
    let consumed: string = '';
    for (let index: number = 0; index < lines.length; index++) {
      consumed += lines[index];
    }
    if (Array.from(consumed).length >=
      Array.from(draft.podcastBody).length) {
      break;
    }
    size -= 2;
  }

  ctx.fillStyle = '#FFFFFF';
  setCanvasFont(ctx, size, { bold: true });
  const lineHeight: number = size + 38;
  for (let index: number = 0; index < lines.length; index++) {
    ctx.fillText(lines[index], COPY_LEFT, 566 + index * lineHeight);
  }

  let resultText: string = '';
  for (let index: number = 0; index < lines.length; index++) {
    resultText += lines[index];
  }
  return Array.from(resultText).length <
    Array.from(draft.podcastBody).length;
}

function logoRows(brand: string): string[] {
  const units: string[] = Array.from(brand.trim()).slice(0, 4);
  const first: string = units.slice(0, 2).join('');
  const second: string = units.slice(2, 4).join('');
  return [first, second];
}

function drawMicrophone(ctx: CanvasRenderer, x: number, y: number,
  color: string): void {
  ctx.save();
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = 7;
  ctx.beginPath();
  ctx.moveTo(x - 13, y - 32);
  ctx.quadraticCurveTo(x, y - 44, x + 13, y - 32);
  ctx.lineTo(x + 13, y + 10);
  ctx.quadraticCurveTo(x, y + 24, x - 13, y + 10);
  ctx.closePath();
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(x - 25, y + 2);
  ctx.quadraticCurveTo(x, y + 42, x + 25, y + 2);
  ctx.stroke();
  ctx.fillRect(x - 4, y + 36, 8, 24);
  ctx.fillRect(x - 18, y + 58, 36, 7);
  ctx.restore();
}

function drawLogo(ctx: CanvasRenderer, draft: CoverDraft,
  palette: PodcastCardPalette): void {
  ctx.save();
  ctx.strokeStyle = palette.accent;
  ctx.lineWidth = 15;
  ctx.beginPath();
  ctx.moveTo(1352, 340);
  ctx.quadraticCurveTo(1352, 316, 1378, 312);
  ctx.lineTo(1696, 282);
  ctx.quadraticCurveTo(1732, 280, 1736, 316);
  ctx.lineTo(1762, 648);
  ctx.quadraticCurveTo(1765, 682, 1730, 690);
  ctx.lineTo(1452, 748);
  ctx.lineTo(1350, 826);
  ctx.lineTo(1354, 708);
  ctx.closePath();
  ctx.stroke();

  const rows: string[] = logoRows(draft.brand);
  ctx.fillStyle = palette.accent;
  ctx.textAlign = 'center';
  const firstSize: number = fitSingleText(ctx, rows[0], 300,
    118, 74, { bold: true });
  setCanvasFont(ctx, firstSize, { bold: true });
  ctx.fillText(rows[0], 1538, 474);
  const secondSize: number = fitSingleText(ctx, rows[1], 300,
    112, 72, { bold: true });
  setCanvasFont(ctx, secondSize, { bold: true });
  ctx.fillText(rows[1], 1538, 624);

  drawMicrophone(ctx, 1538, 531, '#FFFFFF');

  ctx.save();
  ctx.translate(1734, 448);
  ctx.rotate(Math.PI / 2);
  const englishSize: number = fitSingleText(ctx, draft.podcastEnglish,
    230, 27, 18, { bold: true });
  setCanvasFont(ctx, englishSize, { bold: true });
  ctx.textAlign = 'left';
  ctx.fillText(draft.podcastEnglish, 0, 0);
  ctx.restore();
  ctx.restore();
}

export function renderPodcastCard(ctx: CanvasRenderer, draft: CoverDraft,
  palette: PodcastCardPalette, showVersion: boolean): boolean {
  drawBackground(ctx, palette);
  drawHeader(ctx, draft, palette, showVersion);
  const tooLong: boolean = drawQuoteAndCopy(ctx, draft, palette);
  drawLogo(ctx, draft, palette);
  return tooLong;
}
