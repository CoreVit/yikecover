import { CoverDraft } from '../../model/CoverModels';
import {
  PodcastCardPalette,
  renderPodcastCard
} from './PodcastCardRenderer';

const PODCAST_PALETTE: PodcastCardPalette = {
  backgroundTop: '#173B56',
  backgroundBottom: '#0D2D45',
  accent: '#FFBE0B',
  contour: '#A8B6A0',
  equalizer: '#91A8BA'
};

export function renderPodcast(ctx: CanvasRenderer,
  draft: CoverDraft): boolean {
  return renderPodcastCard(ctx, draft, PODCAST_PALETTE, false);
}
