import {
  CoverDraft,
  DESIGN_WIDTH,
  createDefaultDraft,
  getTemplateDefinition
} from '../model/CoverModels';
import { CoverRenderer, RenderResult } from '../services/CoverRenderer';

@Component
export struct CoverPreview {
  private contextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(this.contextSettings);
  private bitmap: ImageBitmap | undefined = undefined;
  private bitmapUri: string = '';
  private canvasReady: boolean = false;
  private drawScheduled: boolean = false;

  @Prop templateId: number = 1;
  @Prop @Watch('onContentChanged') draftJson: string = '';
  @Prop @Watch('onContentChanged') revision: number = 0;
  onResult: (titleTooLong: boolean) => void = (_titleTooLong: boolean): void => {
  };

  private draft(): CoverDraft {
    if (this.draftJson.length > 0) {
      try {
        return JSON.parse(this.draftJson) as CoverDraft;
      } catch (error) {
      }
    }
    return createDefaultDraft(getTemplateDefinition(this.templateId));
  }

  private syncBitmap(draft: CoverDraft): void {
    if (draft.photoUri === this.bitmapUri) {
      return;
    }
    if (this.bitmap !== undefined) {
      this.bitmap.close();
      this.bitmap = undefined;
    }
    this.bitmapUri = draft.photoUri;
    if (draft.photoUri.length > 0) {
      try {
        this.bitmap = new ImageBitmap(draft.photoUri);
      } catch (error) {
        this.bitmap = undefined;
        this.bitmapUri = '';
      }
    }
  }

  private requestDraw(): void {
    if (this.drawScheduled) {
      return;
    }
    this.drawScheduled = true;
    setTimeout(() => {
      this.drawScheduled = false;
      this.draw();
    }, 0);
  }

  private onContentChanged(): void {
    this.requestDraw();
  }

  private draw(): void {
    if (!this.canvasReady || this.context.width <= 0) {
      return;
    }
    const draft: CoverDraft = this.draft();
    this.syncBitmap(draft);
    const scale: number = this.context.width / DESIGN_WIDTH;
    const result: RenderResult = CoverRenderer.render(this.context,
      getTemplateDefinition(this.templateId), draft, this.bitmap, scale);
    this.onResult(result.titleTooLong);
  }

  aboutToDisappear(): void {
    if (this.bitmap !== undefined) {
      this.bitmap.close();
      this.bitmap = undefined;
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .aspectRatio(16 / 9)
      .backgroundColor($r('app.color.preview_background'))
      .onReady(() => {
        this.canvasReady = true;
        this.requestDraw();
      })
  }
}
