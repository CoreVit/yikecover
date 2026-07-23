import {
  CoverDraft,
  CoverTheme,
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

interface SeriesPalette {
  start: string;
  end: string;
  foreground: string;
}

function paletteFor(draft: CoverDraft): SeriesPalette {
  if (draft.theme === CoverTheme.CYAN) {
    return {
      start: '#05D28C',
      end: '#167AC7',
      foreground: '#FFFFFF'
    };
  }
  return {
    start: '#F10A16',
    end: '#D70008',
    foreground: '#FFFFFF'
  };
}

function makeBand(ctx: CanvasRenderer, palette: SeriesPalette): CanvasGradient {
  const band: CanvasGradient = ctx.createLinearGradient(0, 0, 790, 0);
  band.addColorStop(0, palette.start);
  band.addColorStop(1, palette.end);
  return band;
}

function drawSeriesHeader(ctx: CanvasRenderer, draft: CoverDraft,
  palette: SeriesPalette): void {
  ctx.fillStyle = makeBand(ctx, palette);
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(760, 0);
  ctx.quadraticCurveTo(736, 112, 654, 132);
  ctx.lineTo(0, 132);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = palette.foreground;
  const brandSize: number = fitSingleText(ctx, draft.brand, 620,
    84, 48, { bold: true, italic: true });
  setCanvasFont(ctx, brandSize, { bold: true, italic: true });
  ctx.textBaseline = 'middle';
  ctx.fillText(draft.brand, 42, 66);
  ctx.textBaseline = 'alphabetic';
}

function drawSeriesCorner(ctx: CanvasRenderer, episode: string,
  palette: SeriesPalette): void {
  ctx.fillStyle = makeBand(ctx, palette);
  ctx.beginPath();
  ctx.moveTo(1650, 0);
  ctx.lineTo(DESIGN_WIDTH, 0);
  ctx.lineTo(DESIGN_WIDTH, 286);
  ctx.closePath();
  ctx.fill();

  if (episode.length === 0) {
    return;
  }
  ctx.fillStyle = palette.foreground;
  setCanvasFont(ctx, 96, { bold: true });
  ctx.textAlign = 'right';
  ctx.fillText(episode, 1860, 126);
  ctx.textAlign = 'left';
}

function drawSeriesShade(ctx: CanvasRenderer): void {
  const shade: CanvasGradient =
    ctx.createLinearGradient(0, 630, 0, DESIGN_HEIGHT);
  shade.addColorStop(0, '#00000000');
  shade.addColorStop(0.6, '#52000000');
  shade.addColorStop(1, '#A6000000');
  ctx.fillStyle = shade;
  ctx.fillRect(0, 630, DESIGN_WIDTH, DESIGN_HEIGHT - 630);
}

function drawSeriesTitles(ctx: CanvasRenderer,
  draft: CoverDraft): boolean {
  const maxWidth: number = 1760;
  const size: number = fitTextPair(ctx, draft.title1, draft.title2,
    maxWidth, 110, 70, { bold: true, italic: true });
  setCanvasFont(ctx, size, { bold: true, italic: true });
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.shadowColor = '#A8000000';
  ctx.shadowBlur = 11;
  ctx.shadowOffsetY = 4;
  drawGradientText(ctx, draft.title1, 74, 858, maxWidth,
    '#FFF43B', '#F2C426');
  drawGradientText(ctx, draft.title2, 74, 992, maxWidth,
    '#FFFFFF', '#D6DBE0');
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderSeriesEpisode(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  const palette: SeriesPalette = paletteFor(draft);
  drawCoverPhoto(ctx, bitmap, false);
  drawSeriesShade(ctx);
  drawSeriesHeader(ctx, draft, palette);
  drawSeriesCorner(ctx, resolvedEpisode(draft), palette);
  return drawSeriesTitles(ctx, draft);
}
