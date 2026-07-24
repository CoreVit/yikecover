import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  resolvedEpisode
} from '../../model/CoverModels';
import {
  CORNER_LABEL_FONT_SIZE,
  CORNER_LABEL_MIN_FONT_SIZE,
  drawEpisodeCornerLabel,
  fitSingleText,
  roundedRect,
  setCanvasFont,
  wrapText
} from './RenderSupport';

const BACKGROUND: string = '#17334A';
const BACKGROUND_DARK: string = '#0C263B';
const GOLD: string = '#E5CE83';

function drawGoldPodcastBackground(ctx: CanvasRenderer): void {
  const background: CanvasGradient =
    ctx.createLinearGradient(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  background.addColorStop(0, BACKGROUND);
  background.addColorStop(1, BACKGROUND_DARK);
  ctx.fillStyle = background;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  ctx.strokeStyle = GOLD;
  ctx.lineWidth = 3;
  ctx.globalAlpha = 0.13;
  for (let index: number = 0; index < 7; index++) {
    ctx.beginPath();
    const offset: number = index * 48;
    ctx.moveTo(30 + offset, 170);
    ctx.bezierCurveTo(500 + offset, 30, 630 - offset,
      550, 980, 300 + offset);
    ctx.bezierCurveTo(1320, 80 + offset, 1550, 380,
      1900, 170 + offset);
    ctx.stroke();
  }
  ctx.globalAlpha = 1;

  ctx.fillStyle = '#CDB978';
  ctx.globalAlpha = 0.46;
  for (let index: number = 0; index < 54; index++) {
    const x: number = index * 38;
    const value: number = 32 + ((index * 37) % 126);
    roundedRect(ctx, x, DESIGN_HEIGHT - value, 12, value, 6);
    ctx.fill();
  }
  ctx.globalAlpha = 1;
}

function drawGoldPodcastHeader(ctx: CanvasRenderer,
  draft: CoverDraft): void {
  ctx.fillStyle = GOLD;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(500, 0);
  ctx.quadraticCurveTo(484, 132, 404, 132);
  ctx.lineTo(0, 132);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = BACKGROUND;
  const brandSize: number = fitSingleText(ctx, draft.brand, 340,
    CORNER_LABEL_FONT_SIZE, CORNER_LABEL_MIN_FONT_SIZE,
    { bold: true, italic: true });
  setCanvasFont(ctx, brandSize, { bold: true, italic: true });
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.brand, 58, 66);
  ctx.textBaseline = 'alphabetic';

  if (draft.versionLabel.length > 0) {
    ctx.fillStyle = GOLD;
    setCanvasFont(ctx, 56, { bold: true, italic: true });
    ctx.fillText(draft.versionLabel, 520, 88);
  }

  ctx.fillStyle = GOLD;
  ctx.beginPath();
  ctx.moveTo(1640, 0);
  ctx.lineTo(DESIGN_WIDTH, 0);
  ctx.lineTo(DESIGN_WIDTH, 264);
  ctx.closePath();
  ctx.fill();

  drawEpisodeCornerLabel(ctx, resolvedEpisode(draft), BACKGROUND);
}

function drawGoldPodcastLogo(ctx: CanvasRenderer,
  draft: CoverDraft): void {
  ctx.strokeStyle = GOLD;
  ctx.lineWidth = 14;
  roundedRect(ctx, 1320, 340, 430, 350, 42);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(1385, 690);
  ctx.lineTo(1360, 780);
  ctx.lineTo(1480, 700);
  ctx.stroke();

  ctx.fillStyle = GOLD;
  ctx.textAlign = 'center';
  setCanvasFont(ctx, 92, { bold: true });
  const brandUnits: string[] = Array.from(draft.brand);
  const brandText: string = brandUnits.length > 4 ?
    brandUnits.slice(0, 4).join('') : draft.brand;
  ctx.fillText(brandText, 1535, 500);
  setCanvasFont(ctx, 76, { bold: true });
  ctx.fillText('播客', 1535, 596);

  setCanvasFont(ctx, 25);
  ctx.save();
  ctx.translate(1740, 530);
  ctx.rotate(Math.PI / 2);
  ctx.fillText(draft.podcastEnglish, 0, 0);
  ctx.restore();

  ctx.strokeStyle = GOLD;
  ctx.lineWidth = 8;
  roundedRect(ctx, 1512, 520, 46, 82, 20);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(1488, 570);
  ctx.quadraticCurveTo(1535, 640, 1582, 570);
  ctx.stroke();
  ctx.textAlign = 'left';
}

function drawGoldPodcastCopy(ctx: CanvasRenderer,
  draft: CoverDraft): boolean {
  ctx.fillStyle = GOLD;
  setCanvasFont(ctx, 108, { bold: true, family: 'serif' });
  ctx.fillText('“', 92, 315);

  roundedRect(ctx, 106, 350, 600, 84, 0);
  ctx.fill();
  ctx.fillStyle = BACKGROUND;
  setCanvasFont(ctx, 52, { bold: true });
  ctx.fillText(draft.quoteLabel, 130, 411);

  let size: number = 70;
  let lines: string[] = [];
  while (size >= 46) {
    setCanvasFont(ctx, size, { bold: true });
    lines = wrapText(ctx, draft.podcastBody, 980, 4);
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
  for (let index: number = 0; index < lines.length; index++) {
    ctx.fillText(lines[index], 106, 548 + index * (size + 22));
  }

  let resultText: string = '';
  for (let index: number = 0; index < lines.length; index++) {
    resultText += lines[index];
  }
  return Array.from(resultText).length <
    Array.from(draft.podcastBody).length;
}

export function renderGoldPodcast(ctx: CanvasRenderer,
  draft: CoverDraft): boolean {
  drawGoldPodcastBackground(ctx);
  drawGoldPodcastHeader(ctx, draft);
  const tooLong: boolean = drawGoldPodcastCopy(ctx, draft);
  drawGoldPodcastLogo(ctx, draft);
  return tooLong;
}
