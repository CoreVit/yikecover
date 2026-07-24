import {
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';

export interface FontOptions {
  bold?: boolean;
  italic?: boolean;
  family?: string;
}

// Photo templates 01–07 share one editorial title block. Keeping these
// coordinates in design space prevents individual renderers from drifting.
export const PHOTO_TITLE_LEFT: number = 72;
export const PHOTO_TITLE_FIRST_BASELINE: number = 858;
export const PHOTO_TITLE_SECOND_BASELINE: number = 992;
export const PHOTO_TITLE_MAX_WIDTH: number =
  DESIGN_WIDTH - PHOTO_TITLE_LEFT * 2;

export function setCanvasFont(ctx: CanvasRenderer, size: number,
  options?: FontOptions): void {
  const roundedSize: number = Math.max(1, Math.round(size));
  const family: string = options?.family ?? 'sans-serif';
  const sizeToken: string = `${roundedSize}px`;
  let candidate: string = `${sizeToken} ${family}`;
  if (options?.bold === true) {
    candidate += ' bold';
  }
  if (options?.italic === true) {
    candidate += ' italic';
  }

  // HarmonyOS device implementations reliably parse the size-first form used
  // by the official Canvas examples. An unsupported shorthand is ignored and
  // leaves Canvas at its 14px default, so verify the applied size explicitly.
  ctx.font = candidate;
  if (ctx.font.indexOf(sizeToken) >= 0) {
    return;
  }

  // Some devices reject the italic suffix while accepting the weight suffix.
  if (options?.bold === true && options?.italic === true) {
    ctx.font = `${sizeToken} ${family} bold`;
    if (ctx.font.indexOf(sizeToken) >= 0) {
      return;
    }
  }

  // Size is more important than synthetic weight/style: this final form is the
  // documented baseline and prevents every template from falling back to 14px.
  ctx.font = `${sizeToken} ${family}`;
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
  ctx.save();
  const base: CanvasGradient =
    ctx.createLinearGradient(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  base.addColorStop(0, '#40515D');
  base.addColorStop(0.48, '#273640');
  base.addColorStop(1, '#10171D');
  ctx.fillStyle = base;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  const glow: CanvasGradient =
    ctx.createRadialGradient(1510, 370, 20, 1510, 370, 610);
  glow.addColorStop(0, '#7CA9AC');
  glow.addColorStop(0.46, '#42616B');
  glow.addColorStop(1, '#00303A43');
  ctx.fillStyle = glow;
  ctx.fillRect(880, 0, 1040, 980);

  // Quiet architectural planes make the placeholder read as an editorial
  // photograph without introducing any real location or sensitive content.
  ctx.globalAlpha = 0.24;
  ctx.fillStyle = '#B9C8C8';
  roundedRect(ctx, 116, 132, 660, 430, 28);
  ctx.fill();
  ctx.fillStyle = '#26363F';
  roundedRect(ctx, 152, 168, 588, 358, 18);
  ctx.fill();

  ctx.strokeStyle = '#A9BABB';
  ctx.lineWidth = 5;
  for (let index: number = 0; index < 5; index++) {
    const x: number = 198 + index * 112;
    ctx.beginPath();
    ctx.moveTo(x, 184);
    ctx.lineTo(x, 510);
    ctx.stroke();
  }
  for (let index: number = 0; index < 3; index++) {
    const y: number = 250 + index * 86;
    ctx.beginPath();
    ctx.moveTo(166, y);
    ctx.lineTo(724, y);
    ctx.stroke();
  }

  ctx.globalAlpha = 0.18;
  ctx.strokeStyle = '#D6E1DE';
  ctx.lineWidth = 4;
  for (let index: number = 0; index < 4; index++) {
    ctx.beginPath();
    ctx.arc(520, 770, 150 + index * 62, Math.PI * 1.08, Math.PI * 1.88);
    ctx.stroke();
  }

  ctx.globalAlpha = 0.28;
  ctx.fillStyle = '#93A8A8';
  ctx.beginPath();
  ctx.moveTo(0, 810);
  ctx.lineTo(830, 610);
  ctx.lineTo(1050, 1080);
  ctx.lineTo(0, 1080);
  ctx.closePath();
  ctx.fill();

  ctx.globalAlpha = 1;

  // Geometric half-length portrait. The simplified planes deliberately avoid
  // resembling a real person while still testing right-weighted composition.
  ctx.fillStyle = '#172129';
  ctx.beginPath();
  ctx.moveTo(1030, DESIGN_HEIGHT);
  ctx.bezierCurveTo(1060, 842, 1208, 730, 1372, 700);
  ctx.bezierCurveTo(1532, 672, 1718, 718, DESIGN_WIDTH, 878);
  ctx.lineTo(DESIGN_WIDTH, DESIGN_HEIGHT);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#303D45';
  ctx.beginPath();
  ctx.moveTo(1138, DESIGN_HEIGHT);
  ctx.bezierCurveTo(1182, 850, 1290, 766, 1398, 736);
  ctx.lineTo(1515, 806);
  ctx.lineTo(1398, DESIGN_HEIGHT);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#C9D0CD';
  ctx.beginPath();
  ctx.moveTo(1390, 724);
  ctx.lineTo(1512, 762);
  ctx.lineTo(1588, DESIGN_HEIGHT);
  ctx.lineTo(1422, DESIGN_HEIGHT);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#987163';
  ctx.beginPath();
  ctx.moveTo(1394, 632);
  ctx.lineTo(1572, 620);
  ctx.lineTo(1592, 770);
  ctx.bezierCurveTo(1530, 814, 1450, 805, 1382, 744);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#B98B76';
  ctx.beginPath();
  ctx.moveTo(1328, 292);
  ctx.bezierCurveTo(1374, 178, 1518, 122, 1644, 176);
  ctx.bezierCurveTo(1778, 234, 1806, 402, 1756, 548);
  ctx.bezierCurveTo(1712, 675, 1598, 730, 1480, 692);
  ctx.bezierCurveTo(1368, 656, 1308, 526, 1312, 392);
  ctx.bezierCurveTo(1314, 354, 1318, 318, 1328, 292);
  ctx.closePath();
  ctx.fill();

  const faceLight: CanvasGradient =
    ctx.createLinearGradient(1330, 330, 1750, 580);
  faceLight.addColorStop(0, '#D5A58C');
  faceLight.addColorStop(0.58, '#B78572');
  faceLight.addColorStop(1, '#845E55');
  ctx.fillStyle = faceLight;
  ctx.beginPath();
  ctx.moveTo(1382, 292);
  ctx.bezierCurveTo(1470, 214, 1610, 214, 1704, 300);
  ctx.bezierCurveTo(1750, 402, 1718, 576, 1612, 646);
  ctx.bezierCurveTo(1518, 690, 1404, 616, 1370, 500);
  ctx.bezierCurveTo(1350, 420, 1354, 344, 1382, 292);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#293038';
  ctx.beginPath();
  ctx.moveTo(1322, 330);
  ctx.bezierCurveTo(1312, 194, 1414, 104, 1562, 112);
  ctx.bezierCurveTo(1706, 120, 1788, 214, 1774, 358);
  ctx.bezierCurveTo(1698, 304, 1622, 276, 1534, 270);
  ctx.bezierCurveTo(1450, 264, 1386, 286, 1322, 330);
  ctx.closePath();
  ctx.fill();

  ctx.strokeStyle = '#5B403C';
  ctx.lineWidth = 10;
  ctx.lineCap = 'round';
  ctx.beginPath();
  ctx.moveTo(1442, 412);
  ctx.lineTo(1496, 404);
  ctx.moveTo(1608, 402);
  ctx.lineTo(1660, 414);
  ctx.stroke();

  ctx.fillStyle = '#253038';
  ctx.beginPath();
  ctx.arc(1472, 426, 10, 0, Math.PI * 2);
  ctx.arc(1634, 428, 10, 0, Math.PI * 2);
  ctx.fill();

  ctx.strokeStyle = '#7A554C';
  ctx.lineWidth = 7;
  ctx.beginPath();
  ctx.moveTo(1558, 438);
  ctx.quadraticCurveTo(1540, 496, 1576, 520);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(1492, 578);
  ctx.quadraticCurveTo(1560, 612, 1624, 570);
  ctx.stroke();

  ctx.fillStyle = '#A95447';
  ctx.beginPath();
  ctx.moveTo(1510, 774);
  ctx.lineTo(1552, 846);
  ctx.lineTo(1518, DESIGN_HEIGHT);
  ctx.lineTo(1456, 846);
  ctx.closePath();
  ctx.fill();

  ctx.globalAlpha = 0.22;
  ctx.strokeStyle = '#D4DEDB';
  ctx.lineWidth = 3;
  for (let index: number = 0; index < 5; index++) {
    ctx.beginPath();
    ctx.moveTo(950 + index * 82, 120);
    ctx.lineTo(780 + index * 132, 720);
    ctx.stroke();
  }
  ctx.restore();
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
