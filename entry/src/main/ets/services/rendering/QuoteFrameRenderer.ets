import {
  CoverDraft,
  CoverTheme,
  DESIGN_HEIGHT,
  DESIGN_WIDTH
} from '../../model/CoverModels';
import { setCanvasFont } from './RenderSupport';

const FRAME_RED: string = '#F0000D';
const BODY_MAX_WIDTH: number = 1160;
const BODY_LEFT: number = (DESIGN_WIDTH - BODY_MAX_WIDTH) / 2;
const BODY_CENTER_Y: number = 530;
const BODY_DEFAULT_SIZE: number = 46;
const BODY_MIN_SIZE: number = 30;
const BODY_DEFAULT_LINE_HEIGHT: number = 70;
const BODY_MAX_LINES: number = 8;
const FOOTER_RIGHT: number = 1678;
const FOOTER_BASELINE: number = 936;

interface QuoteLayout {
  lines: string[];
  fontSize: number;
  lineHeight: number;
}

function isClosingPunctuation(character: string): boolean {
  return '，。！？；：、）》】”’'.includes(character);
}

function wrapQuote(ctx: CanvasRenderer, text: string,
  maxWidth: number): string[] {
  const paragraphs: string[] = text.replace(/\r/g, '').split('\n');
  const lines: string[] = [];
  for (let paragraphIndex: number = 0;
    paragraphIndex < paragraphs.length; paragraphIndex++) {
    const units: string[] = Array.from(paragraphs[paragraphIndex]);
    let current: string = '';
    for (let index: number = 0; index < units.length; index++) {
      const next: string = current + units[index];
      if (current.length > 0 && ctx.measureText(next).width > maxWidth &&
        !isClosingPunctuation(units[index])) {
        lines.push(current);
        current = units[index];
      } else {
        current = next;
      }
    }
    if (current.length > 0) {
      lines.push(current);
    } else if (paragraphIndex < paragraphs.length - 1) {
      lines.push('');
    }
  }
  return lines.length > 0 ? lines : [''];
}

function quoteLayout(ctx: CanvasRenderer, text: string): QuoteLayout {
  let fontSize: number = BODY_DEFAULT_SIZE;
  setCanvasFont(ctx, fontSize, { bold: true, italic: true });
  let lines: string[] = wrapQuote(ctx, text, BODY_MAX_WIDTH);
  // Preserve the reference type scale for one through eight lines. Only text
  // that would create a ninth line is allowed to reduce the font size.
  while (lines.length > BODY_MAX_LINES && fontSize > BODY_MIN_SIZE) {
    fontSize -= 2;
    setCanvasFont(ctx, fontSize, { bold: true, italic: true });
    lines = wrapQuote(ctx, text, BODY_MAX_WIDTH);
  }
  const lineHeight: number = fontSize === BODY_DEFAULT_SIZE ?
    BODY_DEFAULT_LINE_HEIGHT : Math.round(fontSize * 1.52);
  return {
    lines: lines,
    fontSize: fontSize,
    lineHeight: lineHeight
  };
}

function drawPrimaryFrame(ctx: CanvasRenderer): void {
  ctx.beginPath();
  ctx.moveTo(225, 260);
  ctx.lineTo(225, 210);
  ctx.bezierCurveTo(225, 194, 236, 183, 252, 183);
  ctx.lineTo(1668, 183);
  ctx.bezierCurveTo(1684, 183, 1695, 194, 1695, 210);
  ctx.lineTo(1695, 648);

  ctx.moveTo(1695, 758);
  ctx.lineTo(1695, 827);
  ctx.bezierCurveTo(1695, 843, 1684, 855, 1668, 855);
  ctx.lineTo(300, 855);
  ctx.lineTo(225, 930);
  ctx.lineTo(225, 371);
  ctx.stroke();
}

function drawSecondaryFrame(ctx: CanvasRenderer): void {
  ctx.beginPath();
  ctx.moveTo(1695, 199);
  ctx.bezierCurveTo(1705, 199, 1711, 207, 1711, 218);
  ctx.lineTo(1711, 648);

  ctx.moveTo(1711, 758);
  ctx.lineTo(1711, 843);
  ctx.bezierCurveTo(1711, 859, 1700, 871, 1684, 871);
  ctx.lineTo(306, 871);
  ctx.lineTo(241, 936);
  ctx.lineTo(241, 916);
  ctx.stroke();
}

function drawFixedArtwork(ctx: CanvasRenderer, light: boolean): void {
  ctx.fillStyle = light ? '#FFFFFF' : '#000000';
  ctx.fillRect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);

  ctx.strokeStyle = FRAME_RED;
  ctx.lineWidth = 4;
  ctx.lineCap = 'round';
  ctx.lineJoin = 'round';
  drawPrimaryFrame(ctx);
  drawSecondaryFrame(ctx);

  ctx.fillStyle = FRAME_RED;
  setCanvasFont(ctx, 112, { bold: true });
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('“', 225, 322);
  ctx.fillText('”', 1700, 704);
}

function drawQuoteBody(ctx: CanvasRenderer, text: string,
  light: boolean): boolean {
  const layout: QuoteLayout = quoteLayout(ctx, text);
  setCanvasFont(ctx, layout.fontSize, { bold: true, italic: true });
  ctx.fillStyle = light ? '#111111' : '#FFFFFF';
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  const firstCenterY: number = BODY_CENTER_Y -
    (layout.lines.length - 1) * layout.lineHeight / 2;
  for (let index: number = 0; index < layout.lines.length; index++) {
    ctx.fillText(layout.lines[index], BODY_LEFT,
      firstCenterY + index * layout.lineHeight);
  }
  return layout.lines.length > BODY_MAX_LINES;
}

function drawFooterTitle(ctx: CanvasRenderer, title: string,
  light: boolean): void {
  ctx.fillStyle = light ? '#111111' : '#FFFFFF';
  setCanvasFont(ctx, 30);
  ctx.textAlign = 'right';
  ctx.textBaseline = 'alphabetic';
  ctx.fillText(title, FOOTER_RIGHT, FOOTER_BASELINE);
}

export function renderQuoteFrame(ctx: CanvasRenderer,
  draft: CoverDraft): boolean {
  const light: boolean = draft.theme === CoverTheme.LIGHT;
  drawFixedArtwork(ctx, light);
  const tooLong: boolean = drawQuoteBody(ctx, draft.title2, light);
  drawFooterTitle(ctx, draft.title1, light);
  return tooLong;
}
