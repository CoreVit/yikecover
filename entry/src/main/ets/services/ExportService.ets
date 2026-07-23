import fileIo from '@ohos.file.fs';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import image from '@ohos.multimedia.image';
import { CoverDraft, ExportSettings, TemplateDefinition, DESIGN_WIDTH } from '../model/CoverModels';
import { CoverRenderer } from './CoverRenderer';

export class ExportService {
  static async exportToGallery(definition: TemplateDefinition, draft: CoverDraft,
    settings: ExportSettings, bitmap: ImageBitmap | undefined, appContext: Context): Promise<string> {
    let canvas: OffscreenCanvas;
    try {
      canvas = new OffscreenCanvas(settings.width, settings.height);
    } catch (error) {
      if (settings.resolution === '4K') {
        throw new Error('4K 渲染失败，请在导出设置中切换为 1080P');
      }
      throw new Error('无法创建导出画布');
    }

    try {
      const ctx: OffscreenCanvasRenderingContext2D = canvas.getContext('2d');
      CoverRenderer.render(ctx, definition, draft, bitmap, settings.width / DESIGN_WIDTH);
      const pixelMap: PixelMap = ctx.getPixelMap(0, 0, settings.width, settings.height);
      const packer: image.ImagePacker = image.createImagePacker();
      let mime: string = 'image/png';
      let extension: string = 'png';
      if (settings.format === 'JPEG') {
        mime = 'image/jpeg';
        extension = 'jpg';
      } else if (settings.format === 'WebP') {
        mime = 'image/webp';
        extension = 'webp';
      }
      const buffer: ArrayBuffer = await packer.packToData(pixelMap, {
        format: mime,
        quality: settings.format === 'PNG' ? 100 : settings.quality
      });
      const path: string = `${appContext.cacheDir}/一刻封面-${Date.now()}.${extension}`;
      const file: fileIo.File = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY |
        fileIo.OpenMode.TRUNC);
      fileIo.writeSync(file.fd, buffer);
      fileIo.closeSync(file);

      const helper: photoAccessHelper.PhotoAccessHelper =
        photoAccessHelper.getPhotoAccessHelper(appContext);
      const request: photoAccessHelper.MediaAssetChangeRequest =
        photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(appContext, path);
      await helper.applyChanges(request);
      return path;
    } catch (error) {
      if (settings.resolution === '4K') {
        throw new Error('4K 渲染失败或设备内存不足，请切换为 1080P');
      }
      const message: string = error instanceof Error ? error.message : '未知错误';
      throw new Error(`保存失败：${message}`);
    }
  }
}
