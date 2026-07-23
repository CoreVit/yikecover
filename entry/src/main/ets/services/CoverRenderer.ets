import {
  CoverDraft,
  CoverTheme,
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  TemplateDefinition,
  resolvedEpisode
} from '../model/CoverModels';

export interface RenderResult {
  titleTooLong: boolean;
}

const RED: string = '#EB0000';
const ORANGE: string = '#F25601';
const GOLD: string = '#F7AB00';
const NAVY: string = '#16344E';

function roundedRect(ctx: CanvasRenderer, x: number, y: number, width: number, height: number,
  radius: number): void {
  const right: number = x + width;
  const bottom: number = y + height;
  ctx.beginPath();
  ctx.moveTo(x + radius, y);
  ctx.lineTo(right - radius, y);
  ctx.quadraticCurveTo(right, y, right, y + radius);
  ctx.lineTo(right, bottom - radius);
  ctx.quadraticCurveTo(right, bottom, right - radius, bottom);
  ctx.lineTo(x + radius, bottom);
  ctx.quadraticCurveTo(x, bottom, x, bottom - radius);
  ctx.lineTo(x, y + radius);
  ctx.quadraticCurveTo(x, y, x + radius, y);
  ctx.closePath();
}

function drawNeutralPhoto(ctx: CanvasRenderer): void {
  const base: CanvasGradient = ctx.createLinearGradient(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  base.addColorStop(0, '#34404C');
  base.addColorStop(0.55, '#1D252D');
  base.addColorStop(1, '#0F141A');
  ctx.fillStyle = base;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  ctx.globalAlpha = 0.23;
  for (let index: number = 0; index < 8; index++) {
    ctx.fillStyle = index % 2 === 0 ? '#98A7B5' : '#536675';
    const width: number = 210 + index * 22;
    const height: number = 360 + index * 24;
    roundedRect(ctx, 1160 + index * 62, 160 - index * 10, width, height, 90);
    ctx.fill();
  }
  ctx.globalAlpha = 1;

  ctx.fillStyle = '#B8C4CE';
  ctx.font = '500 42px sans-serif';
  ctx.textAlign = 'center';
  ctx.fillText('上传图片后在这里预览', DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2);
}

function drawCoverPhoto(ctx: CanvasRenderer, bitmap: ImageBitmap | undefined,
  grayscale: boolean): void {
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
    ctx.drawImage(bitmap, sx, sy, sw, sh, 0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  }
  ctx.restore();
}

function drawPhotoClipped(ctx: CanvasRenderer, bitmap: ImageBitmap | undefined,
  grayscale: boolean, inset: number, radius: number): void {
  ctx.save();
  roundedRect(ctx, inset, inset, DESIGN_WIDTH - inset * 2, DESIGN_HEIGHT - inset * 2, radius);
  ctx.clip();
  drawCoverPhoto(ctx, bitmap, grayscale);
  ctx.restore();
}

function drawBottomShade(ctx: CanvasRenderer, height: number): void {
  const shade: CanvasGradient = ctx.createLinearGradient(0, DESIGN_HEIGHT - height, 0, DESIGN_HEIGHT);
  shade.addColorStop(0, '#00000000');
  shade.addColorStop(0.5, '#8A000000');
  shade.addColorStop(1, '#EC000000');
  ctx.fillStyle = shade;
  ctx.fillRect(0, DESIGN_HEIGHT - height, DESIGN_WIDTH, height);
}

function drawLeftShade(ctx: CanvasRenderer): void {
  const shade: CanvasGradient = ctx.createLinearGradient(0, 0, 1000, 0);
  shade.addColorStop(0, '#D8000000');
  shade.addColorStop(0.65, '#72000000');
  shade.addColorStop(1, '#00000000');
  ctx.fillStyle = shade;
  ctx.fillRect(0, 0, 1050, DESIGN_HEIGHT);
}

function fitTwoLines(ctx: CanvasRenderer, first: string, second: string,
  maxWidth: number, preferred: number, minimum: number): number {
  let size: number = preferred;
  while (size > minimum) {
    ctx.font = `italic 800 ${size}px sans-serif`;
    if (ctx.measureText(first).width <= maxWidth && ctx.measureText(second).width <= maxWidth) {
      return size;
    }
    size -= 2;
  }
  return minimum;
}

function drawGradientText(ctx: CanvasRenderer, text: string, x: number, y: number,
  width: number, color1: string, color2: string): void {
  const gradient: CanvasGradient = ctx.createLinearGradient(x, y - 100, x + width, y);
  gradient.addColorStop(0, color1);
  gradient.addColorStop(1, color2);
  ctx.fillStyle = gradient;
  ctx.fillText(text, x, y);
}

function brandWidth(ctx: CanvasRenderer, brand: string, fontSize: number): number {
  ctx.font = `italic 800 ${fontSize}px sans-serif`;
  return Math.max(320, ctx.measureText(brand).width + 116);
}

function drawClassicBrand(ctx: CanvasRenderer, brand: string, color: string, fontColor: string): void {
  const width: number = brandWidth(ctx, brand, 76);
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(width, 0);
  ctx.lineTo(width - 42, 95);
  ctx.quadraticCurveTo(width - 55, 124, width - 98, 124);
  ctx.lineTo(0, 124);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = fontColor;
  ctx.font = 'italic 800 76px sans-serif';
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(brand, 60, 62);
}

function drawClassicFrame(ctx: CanvasRenderer, draft: CoverDraft, bitmap: ImageBitmap | undefined,
  goldStyle: boolean): void {
  let frame: CanvasGradient;
  if (goldStyle) {
    frame = ctx.createConicGradient(0, DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2);
    frame.addColorStop(0, '#FEF3A4');
    frame.addColorStop(0.22, '#E1C57C');
    frame.addColorStop(0.46, '#984C00');
    frame.addColorStop(0.7, '#F2C246');
    frame.addColorStop(1, '#FEF3A4');
  } else {
    frame = ctx.createLinearGradient(0, 0, 0, DESIGN_HEIGHT);
    frame.addColorStop(0, RED);
    frame.addColorStop(0.55, ORANGE);
    frame.addColorStop(1, GOLD);
  }
  ctx.fillStyle = frame;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  drawPhotoClipped(ctx, bitmap, draft.grayscale, 24, 72);
  drawBottomShade(ctx, 390);
  drawClassicBrand(ctx, draft.brand, goldStyle ? '#FFF0A0' : RED, goldStyle ? '#9A570C' : '#FFFFFF');
  if (goldStyle && draft.versionLabel.length > 0) {
    const offset: number = brandWidth(ctx, draft.brand, 76);
    ctx.fillStyle = '#F6D56D';
    ctx.font = 'italic 700 46px sans-serif';
    ctx.fillText(draft.versionLabel, offset + 12, 76);
  }
}

function drawClassicTitles(ctx: CanvasRenderer, draft: CoverDraft, goldStyle: boolean): boolean {
  const maxWidth: number = 1740;
  const size: number = fitTwoLines(ctx, draft.title1, draft.title2, maxWidth, 82, 52);
  const tooLong: boolean = ctx.measureText(draft.title1).width > maxWidth ||
    ctx.measureText(draft.title2).width > maxWidth;
  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
  ctx.shadowColor = '#B0000000';
  ctx.shadowBlur = 14;
  ctx.shadowOffsetX = 4;
  ctx.shadowOffsetY = 6;
  ctx.font = `italic 800 ${size}px sans-serif`;
  if (goldStyle) {
    drawGradientText(ctx, draft.title1, 78, 890, maxWidth, '#FBE17F', '#FCEC9A');
    drawGradientText(ctx, draft.title2, 78, 990, maxWidth, '#FBE17F', '#DDAE41');
  } else {
    drawGradientText(ctx, draft.title1, 78, 880, maxWidth, '#FADF3B', '#F5B924');
    drawGradientText(ctx, draft.title2, 78, 985, maxWidth, '#FFFFFF', '#D7DCE1');
  }
  ctx.shadowColor = '#00000000';
  ctx.shadowBlur = 0;
  return tooLong;
}

function drawClassicEpisode(ctx: CanvasRenderer, draft: CoverDraft): boolean {
  drawLeftShade(ctx);
  drawClassicBrand(ctx, draft.brand, RED, '#FFFFFF');

  const episode: string = resolvedEpisode(draft);
  ctx.fillStyle = RED;
  ctx.beginPath();
  ctx.moveTo(1710, 0);
  ctx.lineTo(DESIGN_WIDTH, 0);
  ctx.lineTo(DESIGN_WIDTH, 240);
  ctx.closePath();
  ctx.fill();
  ctx.save();
  ctx.translate(1838, 72);
  ctx.rotate(Math.PI / 4);
  ctx.fillStyle = '#FFFFFF';
  ctx.font = '800 76px sans-serif';
  ctx.textAlign = 'center';
  ctx.fillText(episode, 0, 0);
  ctx.restore();

  ctx.fillStyle = '#FFFFFF';
  ctx.textAlign = 'left';
  ctx.font = '500 44px sans-serif';
  ctx.fillText(draft.kicker, 120, 330);

  let nameSize: number = 152;
  ctx.font = `800 ${nameSize}px serif`;
  while (ctx.measureText(draft.personName).width > 770 && nameSize > 94) {
    nameSize -= 2;
    ctx.font = `800 ${nameSize}px serif`;
  }
  const personTooLong: boolean = ctx.measureText(draft.personName).width > 770;
  ctx.fillText(draft.personName, 110, 530);

  ctx.fillStyle = '#D90824';
  ctx.font = '500 60px sans-serif';
  ctx.globalAlpha = 0.9;
  ctx.fillText(draft.englishName, 104, 606);
  ctx.globalAlpha = 1;
  ctx.font = '700 32px sans-serif';
  ctx.letterSpacing = '18px';
  ctx.fillText('★★★★★', 230, 674);
  ctx.letterSpacing = '0px';

  const episodeTitle: string = episode.length > 0 ?
    `${draft.episodeTitle}（${episode}）` : draft.episodeTitle;
  ctx.fillStyle = '#FFFFFF';
  ctx.font = '600 68px sans-serif';
  ctx.fillText(episodeTitle, 150, 830);
  return personTooLong || ctx.measureText(episodeTitle).width > 820;
}

function drawFineFood(ctx: CanvasRenderer, draft: CoverDraft, bitmap: ImageBitmap | undefined): boolean {
  drawCoverPhoto(ctx, bitmap, false);
  drawBottomShade(ctx, 430);
  const outline: CanvasGradient = ctx.createLinearGradient(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  outline.addColorStop(0, '#F10D15');
  outline.addColorStop(0.55, '#F1260D');
  outline.addColorStop(1, '#F6B10C');
  ctx.strokeStyle = outline;
  ctx.lineWidth = 9;
  roundedRect(ctx, 34, 34, DESIGN_WIDTH - 68, DESIGN_HEIGHT - 68, 72);
  ctx.stroke();
  drawClassicBrand(ctx, draft.brand, '#0D0F12', '#F00B11');

  const maxWidth: number = 1580;
  const size: number = fitTwoLines(ctx, draft.title1, draft.title2, maxWidth, 78, 50);
  ctx.fillStyle = '#FFFFFF';
  ctx.font = `600 ${size}px serif`;
  ctx.shadowColor = '#B0000000';
  ctx.shadowBlur = 10;
  ctx.fillText(draft.title1, 95, 850);
  ctx.fillText(draft.title2, 95, 965);
  ctx.shadowBlur = 0;
  return ctx.measureText(draft.title1).width > maxWidth || ctx.measureText(draft.title2).width > maxWidth;
}

function drawExclusive(ctx: CanvasRenderer, draft: CoverDraft, bitmap: ImageBitmap | undefined): boolean {
  drawCoverPhoto(ctx, bitmap, false);
  drawBottomShade(ctx, 390);
  drawClassicBrand(ctx, draft.brand, RED, '#FFFFFF');
  ctx.strokeStyle = '#FFFFFF';
  ctx.lineWidth = 14;
  ctx.beginPath();
  ctx.arc(1470, 350, 260, 0, Math.PI * 2);
  ctx.stroke();
  ctx.fillStyle = '#F6DD1A';
  ctx.fillRect(92, 700, 10, 254);

  const maxWidth: number = 1320;
  const size: number = fitTwoLines(ctx, draft.title1, draft.title2, maxWidth, 76, 50);
  ctx.fillStyle = '#FFFFFF';
  ctx.font = `italic 800 ${size}px sans-serif`;
  ctx.shadowColor = '#A0000000';
  ctx.shadowBlur = 12;
  ctx.fillText(draft.title1, 135, 815);
  ctx.fillText(draft.title2, 135, 930);
  ctx.shadowBlur = 0;
  return ctx.measureText(draft.title1).width > maxWidth || ctx.measureText(draft.title2).width > maxWidth;
}

function seriesColors(draft: CoverDraft, goldStyle: boolean): string[] {
  if (goldStyle) {
    return ['#F6E49B', '#B97413', '#F5D86C'];
  }
  if (draft.theme === CoverTheme.CYAN) {
    return ['#05D28C', '#167AC7', '#EFFFFB'];
  }
  return ['#F10A16', '#D70008', '#FFFFFF'];
}

function drawSeries(ctx: CanvasRenderer, draft: CoverDraft, bitmap: ImageBitmap | undefined,
  goldStyle: boolean): boolean {
  drawCoverPhoto(ctx, bitmap, false);
  const colors: string[] = seriesColors(draft, goldStyle);
  const band: CanvasGradient = ctx.createLinearGradient(0, 0, 790, 0);
  band.addColorStop(0, colors[0]);
  band.addColorStop(1, colors[1]);
  ctx.fillStyle = band;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(760, 0);
  ctx.quadraticCurveTo(735, 118, 650, 132);
  ctx.lineTo(0, 132);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = goldStyle ? '#8C5210' : '#FFFFFF';
  ctx.font = 'italic 800 70px sans-serif';
  ctx.fillText(draft.brand, 40, 88);
  if (draft.versionLabel.length > 0) {
    ctx.font = 'italic 700 54px sans-serif';
    ctx.fillText(draft.versionLabel, 720, 86);
  }

  ctx.fillStyle = band;
  ctx.beginPath();
  ctx.moveTo(1650, 0);
  ctx.lineTo(DESIGN_WIDTH, 0);
  ctx.lineTo(DESIGN_WIDTH, 290);
  ctx.closePath();
  ctx.fill();
  ctx.fillStyle = goldStyle ? '#8C5210' : '#FFFFFF';
  ctx.font = '800 88px sans-serif';
  ctx.textAlign = 'right';
  ctx.fillText(resolvedEpisode(draft), 1860, 118);
  ctx.textAlign = 'left';

  drawBottomShade(ctx, 430);
  const maxWidth: number = 1740;
  const size: number = fitTwoLines(ctx, draft.title1, draft.title2, maxWidth, 90, 54);
  ctx.font = `italic 800 ${size}px sans-serif`;
  ctx.shadowColor = '#A0000000';
  ctx.shadowBlur = 12;
  drawGradientText(ctx, draft.title1, 76, 850, maxWidth,
    goldStyle ? '#FFF2A4' : '#FFF43B', goldStyle ? '#E3B746' : '#F2C426');
  drawGradientText(ctx, draft.title2, 76, 975, maxWidth,
    goldStyle ? '#F6D871' : '#FFFFFF', goldStyle ? '#B77311' : '#D6DBE0');
  ctx.shadowBlur = 0;
  return ctx.measureText(draft.title1).width > maxWidth || ctx.measureText(draft.title2).width > maxWidth;
}

function drawContourLines(ctx: CanvasRenderer, color: string): void {
  ctx.strokeStyle = color;
  ctx.lineWidth = 3;
  ctx.globalAlpha = 0.16;
  for (let index: number = 0; index < 7; index++) {
    ctx.beginPath();
    const offset: number = index * 48;
    ctx.moveTo(30 + offset, 170);
    ctx.bezierCurveTo(500 + offset, 30, 630 - offset, 550, 980, 300 + offset);
    ctx.bezierCurveTo(1320, 80 + offset, 1550, 380, 1900, 170 + offset);
    ctx.stroke();
  }
  ctx.globalAlpha = 1;
}

function drawWaveform(ctx: CanvasRenderer, color: string): void {
  ctx.fillStyle = color;
  ctx.globalAlpha = 0.48;
  for (let index: number = 0; index < 54; index++) {
    const x: number = index * 38;
    const value: number = 32 + ((index * 37) % 126);
    roundedRect(ctx, x, DESIGN_HEIGHT - value, 12, value, 6);
    ctx.fill();
  }
  ctx.globalAlpha = 1;
}

function wrapText(ctx: CanvasRenderer, text: string, maxWidth: number, maxLines: number): string[] {
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

function drawPodcastLogo(ctx: CanvasRenderer, draft: CoverDraft, color: string): void {
  ctx.strokeStyle = color;
  ctx.lineWidth = 14;
  roundedRect(ctx, 1320, 340, 430, 350, 42);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(1385, 690);
  ctx.lineTo(1360, 780);
  ctx.lineTo(1480, 700);
  ctx.stroke();
  ctx.fillStyle = color;
  ctx.font = '800 86px sans-serif';
  ctx.textAlign = 'center';
  const first: string = draft.brand.length > 4 ? draft.brand.slice(0, 4) : draft.brand;
  ctx.fillText(first, 1535, 500);
  ctx.font = '800 70px sans-serif';
  ctx.fillText('播客', 1535, 590);
  ctx.font = '500 24px sans-serif';
  ctx.save();
  ctx.translate(1740, 530);
  ctx.rotate(Math.PI / 2);
  ctx.fillText(draft.podcastEnglish, 0, 0);
  ctx.restore();

  ctx.strokeStyle = color;
  ctx.lineWidth = 8;
  roundedRect(ctx, 1512, 520, 46, 82, 20);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(1488, 570);
  ctx.quadraticCurveTo(1535, 640, 1582, 570);
  ctx.stroke();
  ctx.textAlign = 'left';
}

function drawPodcast(ctx: CanvasRenderer, draft: CoverDraft, goldStyle: boolean): boolean {
  const background: CanvasGradient = ctx.createLinearGradient(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  if (goldStyle) {
    background.addColorStop(0, '#17334A');
    background.addColorStop(1, '#0C263B');
  } else {
    background.addColorStop(0, NAVY);
    background.addColorStop(1, '#0D2A42');
  }
  ctx.fillStyle = background;
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  const accent: string = goldStyle ? '#E5CE83' : '#FFBF12';
  drawContourLines(ctx, accent);
  drawWaveform(ctx, goldStyle ? '#CDB978' : '#91A8BA');

  ctx.fillStyle = accent;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(500, 0);
  ctx.quadraticCurveTo(485, 132, 405, 132);
  ctx.lineTo(0, 132);
  ctx.closePath();
  ctx.fill();
  ctx.fillStyle = '#17344D';
  ctx.font = 'italic 800 70px sans-serif';
  ctx.fillText(draft.brand, 58, 88);
  if (goldStyle) {
    ctx.fillStyle = accent;
    ctx.font = 'italic 700 54px sans-serif';
    ctx.fillText(draft.versionLabel, 535, 88);
  }

  ctx.fillStyle = accent;
  ctx.beginPath();
  ctx.moveTo(1640, 0);
  ctx.lineTo(DESIGN_WIDTH, 0);
  ctx.lineTo(DESIGN_WIDTH, 265);
  ctx.closePath();
  ctx.fill();
  ctx.fillStyle = '#17344D';
  ctx.font = '800 78px sans-serif';
  ctx.textAlign = 'right';
  ctx.fillText(resolvedEpisode(draft), 1860, 100);
  ctx.textAlign = 'left';

  ctx.fillStyle = accent;
  ctx.font = '800 104px serif';
  ctx.fillText('“', 92, 315);
  ctx.fillStyle = accent;
  roundedRect(ctx, 106, 350, 600, 84, 0);
  ctx.fill();
  ctx.fillStyle = '#17344D';
  ctx.font = '700 50px sans-serif';
  ctx.fillText(draft.quoteLabel, 130, 410);

  let size: number = 62;
  let lines: string[] = [];
  while (size >= 42) {
    ctx.font = `700 ${size}px sans-serif`;
    lines = wrapText(ctx, draft.podcastBody, 950, 4);
    let consumed: string = '';
    for (let index: number = 0; index < lines.length; index++) {
      consumed += lines[index];
    }
    if (Array.from(consumed).length >= Array.from(draft.podcastBody).length) {
      break;
    }
    size -= 2;
  }
  ctx.fillStyle = '#FFFFFF';
  ctx.font = `700 ${size}px sans-serif`;
  for (let index: number = 0; index < lines.length; index++) {
    ctx.fillText(lines[index], 106, 540 + index * (size + 22));
  }
  drawPodcastLogo(ctx, draft, accent);
  let resultText: string = '';
  for (let index: number = 0; index < lines.length; index++) {
    resultText += lines[index];
  }
  return Array.from(resultText).length < Array.from(draft.podcastBody).length;
}

export class CoverRenderer {
  static render(ctx: CanvasRenderer, definition: TemplateDefinition, draft: CoverDraft,
    bitmap: ImageBitmap | undefined, scale: number): RenderResult {
    ctx.save();
    ctx.scale(scale, scale);
    ctx.clearRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
    ctx.textBaseline = 'alphabetic';
    ctx.textAlign = 'left';
    let tooLong: boolean = false;

    if (definition.id === 1) {
      drawClassicFrame(ctx, draft, bitmap, false);
      tooLong = drawClassicTitles(ctx, draft, false);
    } else if (definition.id === 2) {
      drawClassicFrame(ctx, draft, bitmap, false);
      tooLong = drawClassicEpisode(ctx, draft);
    } else if (definition.id === 3) {
      drawClassicFrame(ctx, draft, bitmap, true);
      tooLong = drawClassicTitles(ctx, draft, true);
    } else if (definition.id === 4) {
      tooLong = drawFineFood(ctx, draft, bitmap);
    } else if (definition.id === 5) {
      tooLong = drawExclusive(ctx, draft, bitmap);
    } else if (definition.id === 6) {
      tooLong = drawSeries(ctx, draft, bitmap, false);
    } else if (definition.id === 7) {
      tooLong = drawSeries(ctx, draft, bitmap, true);
    } else if (definition.id === 8) {
      tooLong = drawPodcast(ctx, draft, false);
    } else {
      tooLong = drawPodcast(ctx, draft, true);
    }
    ctx.restore();
    return { titleTooLong: tooLong };
  }
}
