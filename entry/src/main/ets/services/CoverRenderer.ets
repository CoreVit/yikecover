import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  TemplateDefinition
} from '../model/CoverModels';
import { renderClassicGradient } from './rendering/ClassicGradientRenderer';
import { renderClassicEpisode } from './rendering/ClassicEpisodeRenderer';
import { renderGoldMember } from './rendering/GoldMemberRenderer';
import { renderFineFood } from './rendering/FineFoodRenderer';
import { renderExclusive } from './rendering/ExclusiveRenderer';
import { renderSeriesEpisode } from './rendering/SeriesEpisodeRenderer';
import { renderGoldEpisode } from './rendering/GoldEpisodeRenderer';
import { renderPodcast } from './rendering/PodcastRenderer';
import { renderGoldPodcast } from './rendering/GoldPodcastRenderer';

export interface RenderResult {
  titleTooLong: boolean;
}

export class CoverRenderer {
  static render(ctx: CanvasRenderer, definition: TemplateDefinition,
    draft: CoverDraft, bitmap: ImageBitmap | undefined,
    scale: number): RenderResult {
    ctx.save();
    ctx.scale(scale, scale);
    ctx.clearRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
    ctx.textBaseline = 'alphabetic';
    ctx.textAlign = 'left';
    ctx.globalAlpha = 1;
    ctx.shadowColor = '#00000000';
    ctx.shadowBlur = 0;
    ctx.shadowOffsetX = 0;
    ctx.shadowOffsetY = 0;
    ctx.letterSpacing = '0px';

    let tooLong: boolean = false;
    switch (definition.id) {
      case 1:
        tooLong = renderClassicGradient(ctx, draft, bitmap);
        break;
      case 2:
        tooLong = renderClassicEpisode(ctx, draft, bitmap);
        break;
      case 3:
        tooLong = renderGoldMember(ctx, draft, bitmap);
        break;
      case 4:
        tooLong = renderFineFood(ctx, draft, bitmap);
        break;
      case 5:
        tooLong = renderExclusive(ctx, draft, bitmap);
        break;
      case 6:
        tooLong = renderSeriesEpisode(ctx, draft, bitmap);
        break;
      case 7:
        tooLong = renderGoldEpisode(ctx, draft, bitmap);
        break;
      case 8:
        tooLong = renderPodcast(ctx, draft);
        break;
      case 9:
        tooLong = renderGoldPodcast(ctx, draft);
        break;
      default:
        tooLong = renderClassicGradient(ctx, draft, bitmap);
        break;
    }
    ctx.restore();
    return { titleTooLong: tooLong };
  }
}
