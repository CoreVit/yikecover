import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  resolvedEpisode
} from '../../model/CoverModels';
import {
  drawCoverPhoto,
  fitSingleText,
  isTextTooWide,
  setCanvasFont
} from './RenderSupport';

const INSET: number = 24;
const RADIUS: number = 78;
const BRAND_SIZE: number = 96;

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

function drawEpisodeCorner(ctx: CanvasRenderer, episode: string): void {
  const innerRight: number = DESIGN_WIDTH - INSET;
  ctx.fillStyle = '#EB0000';
  ctx.beginPath();
  ctx.moveTo(1628, 0);
  ctx.lineTo(DESIGN_WIDTH, 0);
  ctx.lineTo(DESIGN_WIDTH, 286);
  ctx.lineTo(innerRight, 260);
  ctx.quadraticCurveTo(innerRight, 210, innerRight - 38, 172);
  ctx.lineTo(1780, 84);
  ctx.quadraticCurveTo(1722, 26, 1658, INSET);
  ctx.lineTo(1644, INSET);
  ctx.closePath();
  ctx.fill();

  if (episode.length === 0) {
    return;
  }
  ctx.save();
  ctx.translate(1842, 82);
  ctx.rotate(Math.PI / 4);
  ctx.fillStyle = '#FFFFFF';
  setCanvasFont(ctx, 86, { bold: true });
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(episode, 0, 0);
  ctx.restore();
}

function drawEpisodeContent(ctx: CanvasRenderer, draft: CoverDraft,
  episode: string): boolean {
  ctx.fillStyle = '#FFFFFF';
  ctx.textAlign = 'left';
  setCanvasFont(ctx, 48);
  ctx.fillText(draft.kicker, 120, 340);

  let nameSize: number = 176;
  setCanvasFont(ctx, nameSize, { bold: true, family: 'serif' });
  while (ctx.measureText(draft.personName).width > 800 && nameSize > 104) {
    nameSize -= 2;
    setCanvasFont(ctx, nameSize, { bold: true, family: 'serif' });
  }
  const personTooLong: boolean =
    isTextTooWide(ctx, draft.personName, 800);
  ctx.fillText(draft.personName, 108, 560);

  if (draft.englishName.length > 0) {
    ctx.fillStyle = '#D90824';
    setCanvasFont(ctx, 64);
    ctx.globalAlpha = 0.92;
    ctx.fillText(draft.englishName, 106, 638);
    ctx.globalAlpha = 1;
  }

  ctx.fillStyle = '#D90824';
  setCanvasFont(ctx, 38, { bold: true });
  ctx.letterSpacing = '17px';
  ctx.fillText('★★★★★', 220, 712);
  ctx.letterSpacing = '0px';

  const title: string = episode.length > 0 ?
    `${draft.episodeTitle}（${episode}）` : draft.episodeTitle;
  ctx.fillStyle = '#FFFFFF';
  setCanvasFont(ctx, 82, { bold: true });
  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 10;
  ctx.shadowOffsetY = 4;
  ctx.fillText(title, 136, 888);
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetY = 0;
  return personTooLong || isTextTooWide(ctx, title, 860);
}

export function renderClassicEpisode(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  const episode: string = resolvedEpisode(draft);
  drawEpisodeBackground(ctx, draft, bitmap);
  drawEpisodeBrand(ctx, draft.brand);
  drawEpisodeCorner(ctx, episode);
  return drawEpisodeContent(ctx, draft, episode);
}
