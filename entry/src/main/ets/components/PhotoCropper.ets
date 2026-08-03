import image from '@ohos.multimedia.image';
import fileIo from '@ohos.file.fs';
import { LengthMetricsUnit } from '@kit.ArkUI';

@Component
export struct PhotoCropper {
  private contextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(this.contextSettings, LengthMetricsUnit.PX);
  private bitmap: ImageBitmap | undefined = undefined;
  private pixelMap: PixelMap | undefined = undefined;
  private canvasReady: boolean = false;
  private drawScheduled: boolean = false;
  private cropWidth: number = 0;
  private cropHeight: number = 0;
  private dragStartX: number = 0;
  private dragStartY: number = 0;
  private pinchStartScale: number = 1;

  @Prop photoUri: string = '';
  @Prop @Watch('handleCropPropChanged') offsetX: number = 0;
  @Prop @Watch('handleCropPropChanged') offsetY: number = 0;
  @Prop @Watch('handleCropPropChanged') photoScale: number = 1;
  onCropChanged: (offsetX: number, offsetY: number, scale: number) => void =
    (_offsetX: number, _offsetY: number, _scale: number): void => {
    };
  onPhotoStateChanged: (state: string) => void = (_state: string): void => {
  };

  aboutToAppear(): void {
    this.loadBitmap();
  }

  private lengthValue(value: Length): number {
    if (typeof value === 'number') {
      return value;
    }
    if (typeof value === 'string') {
      return parseFloat(value);
    }
    return 0;
  }

  private clamp(value: number, minimum: number, maximum: number): number {
    return Math.max(minimum, Math.min(maximum, value));
  }

  private async loadBitmap(): Promise<void> {
    let sourceFile: fileIo.File | undefined = undefined;
    let imageSource: image.ImageSource | undefined = undefined;
    let decodedPixelMap: PixelMap | undefined = undefined;
    try {
      this.onPhotoStateChanged('loading');
      sourceFile = fileIo.openSync(this.photoUri, fileIo.OpenMode.READ_ONLY);
      imageSource = image.createImageSource(sourceFile.fd);
      decodedPixelMap = await imageSource.createPixelMap();
      this.bitmap = new ImageBitmap(decodedPixelMap);
      this.pixelMap = decodedPixelMap;
      decodedPixelMap = undefined;
      this.onPhotoStateChanged('ready');
      this.requestDraw();
    } catch (error) {
      this.onPhotoStateChanged('error');
    } finally {
      if (decodedPixelMap !== undefined) {
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

  private handleCropPropChanged(): void {
    this.requestDraw();
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

  private draw(): void {
    if (!this.canvasReady || this.context.width <= 0 ||
      this.bitmap === undefined || this.bitmap.width <= 0 || this.bitmap.height <= 0) {
      return;
    }
    const width: number = this.context.width;
    const height: number = this.context.height;
    const coverScale: number = Math.max(
      width / this.bitmap.width,
      height / this.bitmap.height
    );
    const scale: number = this.clamp(this.photoScale, 1, 4);
    const drawWidth: number = this.bitmap.width * coverScale * scale;
    const drawHeight: number = this.bitmap.height * coverScale * scale;
    const x: number = (width - drawWidth) / 2 +
      (drawWidth - width) * this.clamp(this.offsetX, -1, 1) / 2;
    const y: number = (height - drawHeight) / 2 +
      (drawHeight - height) * this.clamp(this.offsetY, -1, 1) / 2;

    this.context.clearRect(0, 0, width, height);
    this.context.fillStyle = '#202226';
    this.context.fillRect(0, 0, width, height);
    this.context.drawImage(this.bitmap, x, y, drawWidth, drawHeight);
  }

  private updatePan(deltaX: number, deltaY: number): void {
    if (this.bitmap === undefined || this.cropWidth <= 0 || this.cropHeight <= 0) {
      return;
    }
    const coverScale: number = Math.max(
      this.cropWidth / this.bitmap.width,
      this.cropHeight / this.bitmap.height
    );
    const drawWidth: number = this.bitmap.width * coverScale * this.photoScale;
    const drawHeight: number = this.bitmap.height * coverScale * this.photoScale;
    const overflowX: number = drawWidth - this.cropWidth;
    const overflowY: number = drawHeight - this.cropHeight;
    const nextX: number = overflowX > 0.5 ?
      this.clamp(this.dragStartX + deltaX * 2 / overflowX, -1, 1) : 0;
    const nextY: number = overflowY > 0.5 ?
      this.clamp(this.dragStartY + deltaY * 2 / overflowY, -1, 1) : 0;
    this.onCropChanged(nextX, nextY, this.photoScale);
  }

  private updateScale(gestureScale: number): void {
    const nextScale: number = this.clamp(this.pinchStartScale * gestureScale, 1, 4);
    this.onCropChanged(this.offsetX, this.offsetY, nextScale);
  }

  aboutToDisappear(): void {
    if (this.bitmap !== undefined) {
      this.bitmap.close();
      this.bitmap = undefined;
    }
    if (this.pixelMap !== undefined) {
      this.pixelMap.release();
      this.pixelMap = undefined;
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .aspectRatio(16 / 9)
      .backgroundColor('#202226')
      .border({ width: 2, color: '#FFFFFF', style: BorderStyle.Solid })
      .borderRadius(4)
      .clip(true)
      .onReady(() => {
        this.canvasReady = true;
        this.requestDraw();
      })
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        this.cropWidth = this.lengthValue(newValue.width);
        this.cropHeight = this.lengthValue(newValue.height);
        this.requestDraw();
      })
      .gesture(
        GestureGroup(GestureMode.Parallel,
          PanGesture({
            fingers: 1,
            direction: PanDirection.All,
            distance: 2
          })
            .onActionStart(() => {
              this.dragStartX = this.offsetX;
              this.dragStartY = this.offsetY;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.updatePan(event.offsetX, event.offsetY);
            }),
          PinchGesture({ fingers: 2, distance: 3 })
            .onActionStart(() => {
              this.pinchStartScale = this.photoScale;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.updateScale(event.scale);
            })
        )
      )
  }
}
