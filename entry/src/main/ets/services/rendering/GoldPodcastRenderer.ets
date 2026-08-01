import { CoverDraft } from '../../model/CoverModels';
import {
  PodcastCardPalette,
  renderPodcastCard
} from './PodcastCardRenderer';

const GOLD_PODCAST_PALETTE: PodcastCardPalette = {
  backgroundTop: '#173B56',
  backgroundBottom: '#0D2D45',
  accent: '#E9D48A',
  contour: '#C5B876',
  equalizer: '#B3A574'
};

export function renderGoldPodcast(ctx: CanvasRenderer,
  draft: CoverDraft): boolean {
  return renderPodcastCard(ctx, draft, GOLD_PODCAST_PALETTE, true);
}
