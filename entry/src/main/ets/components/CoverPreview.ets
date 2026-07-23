import image from '@ohos.multimedia.image';
import fileIo from '@ohos.file.fs';
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
  private pixelMap: PixelMap | undefined = undefined;
  private bitmapUri: string = '';
  private requestedBitmapUri: string = '';
  private imageLoadGeneration: number = 0;
  private canvasReady: boolean = false;
  private drawScheduled: boolean = false;

  @Prop templateId: number = 1;
  @Prop @Watch('onContentChanged') draftJson: string = '';
  @Prop @Watch('onContentChanged') revision: number = 0;
  onResult: (titleTooLong: boolean) => void = (_titleTooLong: boolean): void => {
  };
  onPhotoStateChanged: (state: string) => void = (_state: string): void => {
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

  private releaseActiveImage(): void {
    if (this.bitmap !== undefined) {
      this.bitmap.close();
      this.bitmap = undefined;
    }
    if (this.pixelMap !== undefined) {
      this.pixelMap.release();
      this.pixelMap = undefined;
    }
    this.bitmapUri = '';
  }

  private syncBitmap(draft: CoverDraft): void {
    if (draft.photoUri === this.requestedBitmapUri) {
      return;
    }
    this.requestedBitmapUri = draft.photoUri;
    this.imageLoadGeneration += 1;
    const generation: number = this.imageLoadGeneration;
    if (draft.photoUri.length === 0) {
      this.releaseActiveImage();
      this.onPhotoStateChanged('ready');
      return;
    }
    this.onPhotoStateChanged('loading');
    this.loadBitmap(draft.photoUri, generation);
  }

  private async loadBitmap(uri: string, generation: number): Promise<void> {
    let sourceFile: fileIo.File | undefined = undefined;
    let imageSource: image.ImageSource | undefined = undefined;
    let decodedPixelMap: PixelMap | undefined = undefined;
    let accepted: boolean = false;
    try {
      sourceFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      imageSource = image.createImageSource(sourceFile.fd);
      decodedPixelMap = await imageSource.createPixelMap();
      if (generation !== this.imageLoadGeneration ||
        uri !== this.requestedBitmapUri) {
        await decodedPixelMap.release();
        decodedPixelMap = undefined;
        return;
      }

      const decodedBitmap: ImageBitmap = new ImageBitmap(decodedPixelMap);
      const oldBitmap: ImageBitmap | undefined = this.bitmap;
      const oldPixelMap: PixelMap | undefined = this.pixelMap;
      this.bitmap = decodedBitmap;
      this.pixelMap = decodedPixelMap;
      this.bitmapUri = uri;
      accepted = true;
      decodedPixelMap = undefined;

      if (oldBitmap !== undefined) {
        oldBitmap.close();
      }
      if (oldPixelMap !== undefined) {
        try {
          await oldPixelMap.release();
        } catch (error) {
        }
      }
      this.requestDraw();
      this.onPhotoStateChanged('ready');
    } catch (error) {
      if (generation === this.imageLoadGeneration &&
        uri === this.requestedBitmapUri) {
        this.onPhotoStateChanged('error');
      }
    } finally {
      if (!accepted && decodedPixelMap !== undefined) {
        try {
          await decodedPixelMap.release();
        } catch (error) {
        }
      }
      if (sourceFile !== undefined) {
        try {
          fileIo.closeSync(sourceFile);
        } catch (error) {
        }
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
    this.imageLoadGeneration += 1;
    this.releaseActiveImage();
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
