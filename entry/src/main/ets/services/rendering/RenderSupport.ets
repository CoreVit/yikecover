import {
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';

export interface FontOptions {
  bold?: boolean;
  italic?: boolean;
  family?: string;
}

export function setCanvasFont(ctx: CanvasRenderer, size: number,
  options?: FontOptions): void {
  const style: string = options?.italic === true ? 'italic' : 'normal';
  const weight: string = options?.bold === true ? 'bold' : 'normal';
  const family: string = options?.family ?? 'sans-serif';
  // HarmonyOS Canvas follows: font-style font-weight font-size font-family.
  // Numeric weights are not consistently parsed on device and fall back to 14px.
  ctx.font = `${style} ${weight} ${Math.round(size)}px ${family}`;
}

export function roundedRect(ctx: CanvasRenderer, x: number, y: number,
  width: number, height: number, radius: number): void {
  const safeRadius: number = Math.min(radius, Math.min(width, height) / 2);
  const right: number = x + width;
  const bottom: number = y + height;
  ctx.beginPath();
  ctx.moveTo(x + safeRadius, y);
  ctx.lineTo(right - safeRadius, y);
  ctx.quadraticCurveTo(right, y, right, y + safeRadius);
  ctx.lineTo(right, bottom - safeRadius);
  ctx.quadraticCurveTo(right, bottom, right - safeRadius, bottom);
  ctx.lineTo(x + safeRadius, bottom);
  ctx.quadraticCurveTo(x, bottom, x, bottom - safeRadius);
  ctx.lineTo(x, y + safeRadius);
  ctx.quadraticCurveTo(x, y, x + safeRadius, y);
  ctx.closePath();
}

export function drawNeutralPhoto(ctx: CanvasRenderer): void {
  const base: CanvasGradient =
    ctx.createLinearGradient(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  base.addColorStop(0, '#34404C');
  base.addColorStop(0.55, '#1D252D');
  base.addColorStop(1, '#0F141A');
  ctx.fillStyle = base;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  ctx.globalAlpha = 0.22;
  for (let index: number = 0; index < 6; index++) {
    ctx.fillStyle = index % 2 === 0 ? '#98A7B5' : '#536675';
    const width: number = 210 + index * 28;
    const height: number = 340 + index * 30;
    roundedRect(ctx, 1160 + index * 70, 170 - index * 12,
      width, height, 90);
    ctx.fill();
  }
  ctx.globalAlpha = 1;

  ctx.fillStyle = '#CAD3DA';
  setCanvasFont(ctx, 42);
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('上传图片后在这里预览', DESIGN_WIDTH / 2,
    DESIGN_HEIGHT / 2);
  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
}

export function drawCoverPhoto(ctx: CanvasRenderer,
  bitmap: ImageBitmap | undefined, grayscale: boolean): void {
  ctx.save();
  if (grayscale) {
    ctx.filter = 'grayscale(1)';
  }
  if (bitmap === undefined || bitmap.width <= 0 || bitmap.height <= 0) {
    drawNeutralPhoto(ctx);
  } else {
    const targetRatio: number = DESIGN_WIDTH / DESIGN_HEIGHT;
    const sourceRatio: number = bitmap.width / bitmap.height;
    let sx: number = 0;
    let sy: number = 0;
    let sw: number = bitmap.width;
    let sh: number = bitmap.height;
    if (sourceRatio > targetRatio) {
      sw = bitmap.height * targetRatio;
      sx = (bitmap.width - sw) / 2;
    } else {
      sh = bitmap.width / targetRatio;
      sy = (bitmap.height - sh) / 2;
    }
    ctx.drawImage(bitmap, sx, sy, sw, sh,
      0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  }
  ctx.restore();
}

export function measureTextWidth(ctx: CanvasRenderer, text: string,
  size: number, options?: FontOptions): number {
  setCanvasFont(ctx, size, options);
  return ctx.measureText(text).width;
}

export function fitTextPair(ctx: CanvasRenderer, first: string, second: string,
  maxWidth: number, preferred: number, minimum: number,
  options?: FontOptions): number {
  let size: number = preferred;
  while (size > minimum) {
    setCanvasFont(ctx, size, options);
    if (ctx.measureText(first).width <= maxWidth &&
      ctx.measureText(second).width <= maxWidth) {
      return size;
    }
    size -= 2;
  }
  setCanvasFont(ctx, minimum, options);
  return minimum;
}

export function fitSingleText(ctx: CanvasRenderer, text: string,
  maxWidth: number, preferred: number, minimum: number,
  options?: FontOptions): number {
  let size: number = preferred;
  while (size > minimum) {
    setCanvasFont(ctx, size, options);
    if (ctx.measureText(text).width <= maxWidth) {
      return size;
    }
    size -= 2;
  }
  setCanvasFont(ctx, minimum, options);
  return minimum;
}

export function drawGradientText(ctx: CanvasRenderer, text: string,
  x: number, y: number, width: number, firstColor: string,
  secondColor: string): void {
  const gradient: CanvasGradient =
    ctx.createLinearGradient(x, y - 120, x + width, y);
  gradient.addColorStop(0, firstColor);
  gradient.addColorStop(1, secondColor);
  ctx.fillStyle = gradient;
  ctx.fillText(text, x, y);
}

export function wrapText(ctx: CanvasRenderer, text: string,
  maxWidth: number, maxLines: number): string[] {
  const units: string[] = Array.from(text);
  const lines: string[] = [];
  let current: string = '';
  for (let index: number = 0; index < units.length; index++) {
    const next: string = current + units[index];
    if (ctx.measureText(next).width > maxWidth && current.length > 0) {
      lines.push(current);
      current = units[index];
      if (lines.length === maxLines) {
        return lines;
      }
    } else {
      current = next;
    }
  }
  if (current.length > 0 && lines.length < maxLines) {
    lines.push(current);
  }
  return lines;
}

export function isTextTooWide(ctx: CanvasRenderer, text: string,
  maxWidth: number): boolean {
  return ctx.measureText(text).width > maxWidth;
}
