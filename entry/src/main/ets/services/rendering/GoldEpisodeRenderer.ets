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
  setCanvasFont
} from './RenderSupport';

function goldBand(ctx: CanvasRenderer): CanvasGradient {
  const band: CanvasGradient = ctx.createLinearGradient(0, 0, 900, 0);
  band.addColorStop(0, '#FFF0A1');
  band.addColorStop(0.52, '#E7B84B');
  band.addColorStop(1, '#B86A0B');
  return band;
}

function drawGoldHeader(ctx: CanvasRenderer, draft: CoverDraft): void {
  ctx.fillStyle = goldBand(ctx);
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(780, 0);
  ctx.quadraticCurveTo(754, 112, 660, 132);
  ctx.lineTo(0, 132);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#8B4E08';
  const brandSize: number = fitSingleText(ctx, draft.brand, 610,
    82, 48, { bold: true, italic: true });
  setCanvasFont(ctx, brandSize, { bold: true, italic: true });
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.brand, 42, 66);

  if (draft.versionLabel.length > 0) {
    ctx.fillStyle = '#F4D572';
    const versionSize: number = fitSingleText(ctx, draft.versionLabel,
      600, 54, 36, { bold: true, italic: true });
    setCanvasFont(ctx, versionSize, { bold: true, italic: true });
    ctx.fillText(draft.versionLabel, 800, 66);
  }
  ctx.textBaseline = 'alphabetic';
}

function drawGoldCorner(ctx: CanvasRenderer, episode: string): void {
  ctx.fillStyle = goldBand(ctx);
  ctx.beginPath();
  ctx.moveTo(1640, 0);
  ctx.lineTo(DESIGN_WIDTH, 0);
  ctx.lineTo(DESIGN_WIDTH, 286);
  ctx.closePath();
  ctx.fill();

  if (episode.length === 0) {
    return;
  }
  ctx.fillStyle = '#86500A';
  setCanvasFont(ctx, 96, { bold: true });
  ctx.textAlign = 'right';
  ctx.fillText(episode, 1860, 126);
  ctx.textAlign = 'left';
}

function drawGoldTitleContrast(ctx: CanvasRenderer): void {
  const shade: CanvasGradient = ctx.createLinearGradient(0, 0, 1180, 0);
  shade.addColorStop(0, '#78000000');
  shade.addColorStop(0.58, '#32000000');
  shade.addColorStop(1, '#00000000');
  ctx.fillStyle = shade;
  ctx.fillRect(0, 560, 1240, DESIGN_HEIGHT - 560);
}

function drawGoldTitles(ctx: CanvasRenderer, draft: CoverDraft): boolean {
  const maxWidth: number = 1500;
  const size: number = fitTextPair(ctx, draft.title1, draft.title2,
    maxWidth, 116, 72, { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 10;
  ctx.shadowOffsetY = 4;
  drawGradientText(ctx, draft.title1, 74, 842, maxWidth,
    '#FFF2A4', '#E3B746');
  drawGradientText(ctx, draft.title2, 74, 986, maxWidth,
    '#F8DE79', '#B77311');
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderGoldEpisode(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  drawCoverPhoto(ctx, bitmap, false);
  drawGoldTitleContrast(ctx);
  drawGoldHeader(ctx, draft);
  drawGoldCorner(ctx, resolvedEpisode(draft));
  return drawGoldTitles(ctx, draft);
}
