import {
  CoverDraft,
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';
import {
  AdaptiveHeaderLayout,
  adaptiveHeaderLayout,
  drawCoverPhoto,
  fitPhotoTitlePair,
  isTextTooWide,
  PHOTO_TITLE_FIRST_BASELINE,
  PHOTO_TITLE_LEFT,
  PHOTO_TITLE_MAX_WIDTH,
  PHOTO_TITLE_SECOND_BASELINE,
  setPhotoTitleFont,
  setCanvasFont
} from './RenderSupport';

const FOOD_BRAND_LEFT: number = 54;
const FOOD_BRAND_CENTER_Y: number = 78;
const FOOD_BRAND_FONT_SIZE: number = 88;
const FOOD_BRAND_MIN_FONT_SIZE: number = 48;
const FOOD_BRAND_RIGHT_GAP: number = 28;
const FOOD_SHELF_CURVE_WIDTH: number = 112;

function foodTabLayout(ctx: CanvasRenderer,
  brand: string): AdaptiveHeaderLayout {
  return adaptiveHeaderLayout(ctx, brand, FOOD_BRAND_LEFT,
    FOOD_BRAND_FONT_SIZE, FOOD_BRAND_MIN_FONT_SIZE,
    470, 920, FOOD_BRAND_RIGHT_GAP, FOOD_SHELF_CURVE_WIDTH,
    FOOD_BRAND_RIGHT_GAP,
    { bold: true, italic: true });
}

function drawFoodBorder(ctx: CanvasRenderer, brand: string): void {
  const inset: number = 32;
  const radius: number = 64;
  const shelfRadius: number = 38;
  const circleControl: number = radius * 0.55228475;
  const shelfControl: number = shelfRadius * 0.55228475;
  const shelfY: number = 150;
  const right: number = DESIGN_WIDTH - inset;
  const bottom: number = DESIGN_HEIGHT - inset;
  const bottomJoin: number = DESIGN_WIDTH / 2;
  const layout: AdaptiveHeaderLayout = foodTabLayout(ctx, brand);
  const topJoin: number = Math.min(layout.width, right - radius - 120);
  const shelfEnd: number = layout.curveStart;
  const outline: CanvasGradient =
    ctx.createLinearGradient(0, inset, 0, bottom);
  outline.addColorStop(0, '#EF0010');
  outline.addColorStop(0.42, '#F10C0D');
  outline.addColorStop(0.72, '#F24B05');
  outline.addColorStop(1, '#F6B10A');
  ctx.strokeStyle = outline;
  ctx.lineWidth = 8;
  ctx.lineJoin = 'round';
  ctx.beginPath();
  ctx.moveTo(bottomJoin, bottom);
  ctx.lineTo(inset + radius, bottom);
  ctx.bezierCurveTo(inset + radius - circleControl, bottom,
    inset, bottom - radius + circleControl, inset, bottom - radius);
  ctx.lineTo(inset, shelfY + shelfRadius);
  ctx.bezierCurveTo(inset, shelfY + shelfRadius - shelfControl,
    inset + shelfRadius - shelfControl, shelfY,
    inset + shelfRadius, shelfY);
  ctx.lineTo(shelfEnd, shelfY);
  ctx.bezierCurveTo(shelfEnd + 54, shelfY,
    topJoin - 54, inset, topJoin, inset);
  ctx.lineTo(right - radius, inset);
  ctx.bezierCurveTo(right - radius + circleControl, inset,
    right, inset + radius - circleControl, right, inset + radius);
  ctx.lineTo(right, bottom - radius);
  ctx.bezierCurveTo(right, bottom - radius + circleControl,
    right - radius + circleControl, bottom, right - radius, bottom);
  ctx.lineTo(bottomJoin, bottom);
  ctx.closePath();
  ctx.stroke();
}

function drawFoodBrand(ctx: CanvasRenderer, brand: string): void {
  const layout: AdaptiveHeaderLayout = foodTabLayout(ctx, brand);
  ctx.fillStyle = '#F00B11';
  setCanvasFont(ctx, layout.fontSize, { bold: true, italic: true });
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(brand, FOOD_BRAND_LEFT, FOOD_BRAND_CENTER_Y);
  ctx.textBaseline = 'alphabetic';
}

function drawFoodTitles(ctx: CanvasRenderer, draft: CoverDraft): boolean {
  const maxWidth: number = PHOTO_TITLE_MAX_WIDTH;
  const size: number =
    fitPhotoTitlePair(ctx, draft.title1, draft.title2);
  setPhotoTitleFont(ctx, size);
  const tooLong: boolean =
    isTextTooWide(ctx, draft.title1, maxWidth) ||
    isTextTooWide(ctx, draft.title2, maxWidth);

  ctx.fillStyle = '#FFFFFF';
  ctx.shadowColor = '#B8000000';
  ctx.shadowBlur = 8;
  ctx.shadowOffsetX = 3;
  ctx.shadowOffsetY = 4;
  ctx.fillText(draft.title1, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_FIRST_BASELINE);
  ctx.fillText(draft.title2, PHOTO_TITLE_LEFT,
    PHOTO_TITLE_SECOND_BASELINE);
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = 0;
  return tooLong;
}

export function renderFineFood(ctx: CanvasRenderer, draft: CoverDraft,
  bitmap: ImageBitmap | undefined): boolean {
  drawCoverPhoto(ctx, bitmap, false, draft.photoOffsetX,
    draft.photoOffsetY, draft.photoScale);
  drawFoodBorder(ctx, draft.brand);
  drawFoodBrand(ctx, draft.brand);
  return drawFoodTitles(ctx, draft);
}
