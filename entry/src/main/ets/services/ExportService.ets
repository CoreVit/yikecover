import fileIo from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import image from '@ohos.multimedia.image';
import { LengthMetricsUnit } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CoverDraft, ExportSettings, TemplateDefinition, DESIGN_WIDTH } from '../model/CoverModels';
import { CoverRenderer } from './CoverRenderer';

const SAVE_LOG_DOMAIN = 0x0000;
const SAVE_LOG_TAG = 'YikeCoverSave';

interface DecodedPhoto {
  bitmap: ImageBitmap;
  pixelMap: PixelMap;
}

interface ExportFormat {
  mime: string;
  extension: string;
}

export class ExportService {
  private static delay(milliseconds: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(resolve, milliseconds);
    });
  }

  private static async waitForSavedAsset(assetUri: string): Promise<number> {
    const maxAttempts: number = 10;
    for (let attempt: number = 1; attempt <= maxAttempts; attempt += 1) {
      let assetFile: fileIo.File | undefined = undefined;
      try {
        assetFile = fileIo.openSync(assetUri, fileIo.OpenMode.READ_ONLY);
        const savedSize: number = fileIo.statSync(assetFile.fd).size;
        if (savedSize > 0) {
          return savedSize;
        }
      } catch (error) {
        hilog.warn(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
          'VERIFY_WAIT attempt=%{public}d reason=%{public}s',
          attempt, ExportService.errorDetail(error));
      } finally {
        if (assetFile !== undefined) {
          try {
            fileIo.closeSync(assetFile);
          } catch (closeError) {
          }
        }
      }
      await ExportService.delay(300);
    }
    throw new Error('系统相册未完成图片写入');
  }

  private static exportFormat(format: string): ExportFormat {
    if (format === 'JPEG') {
      return { mime: 'image/jpeg', extension: 'jpg' };
    }
    if (format === 'WebP') {
      return { mime: 'image/webp', extension: 'webp' };
    }
    return { mime: 'image/png', extension: 'png' };
  }

  private static validateEncodedBuffer(buffer: ArrayBuffer, format: string): void {
    const bytes: Uint8Array = new Uint8Array(buffer);
    let valid: boolean = false;
    if (format === 'JPEG') {
      valid = bytes.length >= 3 &&
        bytes[0] === 0xFF && bytes[1] === 0xD8 && bytes[2] === 0xFF;
    } else if (format === 'WebP') {
      valid = bytes.length >= 12 &&
        bytes[0] === 0x52 && bytes[1] === 0x49 &&
        bytes[2] === 0x46 && bytes[3] === 0x46 &&
        bytes[8] === 0x57 && bytes[9] === 0x45 &&
        bytes[10] === 0x42 && bytes[11] === 0x50;
    } else {
      valid = bytes.length >= 8 &&
        bytes[0] === 0x89 && bytes[1] === 0x50 &&
        bytes[2] === 0x4E && bytes[3] === 0x47 &&
        bytes[4] === 0x0D && bytes[5] === 0x0A &&
        bytes[6] === 0x1A && bytes[7] === 0x0A;
    }
    if (!valid) {
      throw new Error(`${format} 编码结果格式不正确`);
    }
  }

  private static writeAll(fd: number, buffer: ArrayBuffer): void {
    let written: number = fileIo.writeSync(fd, buffer);
    while (written < buffer.byteLength) {
      const remaining: ArrayBuffer = buffer.slice(written);
      const count: number = fileIo.writeSync(fd, remaining);
      if (count <= 0) {
        throw new Error('临时图片写入不完整');
      }
      written += count;
    }
  }

  private static async decodePhoto(path: string): Promise<DecodedPhoto | undefined> {
    if (path.length === 0) {
      return undefined;
    }

    let sourceFile: fileIo.File | undefined = undefined;
    let imageSource: image.ImageSource | undefined = undefined;
    let pixelMap: PixelMap | undefined = undefined;
    try {
      sourceFile = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
      imageSource = image.createImageSource(sourceFile.fd);
      pixelMap = await imageSource.createPixelMap();
      return {
        bitmap: new ImageBitmap(pixelMap),
        pixelMap: pixelMap
      };
    } catch (error) {
      if (pixelMap !== undefined) {
        try {
          await pixelMap.release();
        } catch (releaseError) {
        }
      }
      throw new Error('上传图片解码失败，请重新选择图片');
    } finally {
      if (sourceFile !== undefined) {
        try {
          fileIo.closeSync(sourceFile);
        } catch (closeError) {
        }
      }
    }
  }

  private static errorDetail(error: Object): string {
    if (error instanceof Error && error.message.length > 0) {
      return error.message;
    }
    return '系统未返回具体原因';
  }

  static async exportToGallery(definition: TemplateDefinition, draft: CoverDraft,
    settings: ExportSettings, appContext: Context, onReadyToSave: () => void): Promise<string> {
    hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
      'SAVE_START resolution=%{public}s format=%{public}s',
      settings.resolution, settings.format);
    let canvas: OffscreenCanvas;
    try {
      canvas = new OffscreenCanvas(settings.width, settings.height,
        LengthMetricsUnit.PX);
    } catch (error) {
      if (settings.resolution === '4K') {
        throw new Error('4K 渲染失败，请在导出设置中切换为 1080P');
      }
      throw new Error('无法创建导出画布');
    }

    let decodedPhoto: DecodedPhoto | undefined = undefined;
    let outputPixelMap: PixelMap | undefined = undefined;
    let outputFile: fileIo.File | undefined = undefined;
    let path: string = '';
    const exportFormat: ExportFormat =
      ExportService.exportFormat(settings.format);
    const extension: string = exportFormat.extension;
    const mime: string = exportFormat.mime;
    let generated: boolean = false;
    let handedToSystem: boolean = false;
    let generatedSize: number = 0;

    try {
      if (definition.capabilities.requiresPhoto) {
        decodedPhoto = await ExportService.decodePhoto(draft.photoUri);
        if (decodedPhoto === undefined) {
          throw new Error('请先上传图片');
        }
      }

      const ctx: OffscreenCanvasRenderingContext2D = canvas.getContext('2d');
      CoverRenderer.render(ctx, definition, draft, decodedPhoto?.bitmap,
        settings.width / DESIGN_WIDTH);
      outputPixelMap = ctx.getPixelMap(0, 0, settings.width, settings.height);
      const packer: image.ImagePacker = image.createImagePacker();
      const buffer: ArrayBuffer = await packer.packToData(outputPixelMap, {
        format: mime,
        quality: settings.format === 'PNG' ? 100 : settings.quality
      });
      generatedSize = buffer.byteLength;
      if (generatedSize <= 0) {
        throw new Error('图片编码结果为空');
      }
      ExportService.validateEncodedBuffer(buffer, settings.format);
      path = `${appContext.cacheDir}/yikecover-${Date.now()}.${extension}`;
      outputFile = fileIo.openSync(path,
        fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY |
        fileIo.OpenMode.TRUNC);
      ExportService.writeAll(outputFile.fd, buffer);
      const tempSize: number = fileIo.statSync(outputFile.fd).size;
      if (tempSize !== generatedSize) {
        throw new Error(`临时图片写入不完整（${tempSize}/${generatedSize} 字节）`);
      }
      generated = true;
      hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
        'RENDER_DONE bytes=%{public}d', generatedSize);
    } catch (error) {
      hilog.error(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
        'RENDER_FAILED reason=%{public}s', ExportService.errorDetail(error));
      if (settings.resolution === '4K') {
        throw new Error(`4K 生成失败：${ExportService.errorDetail(error)}。请切换为 1080P 后重试`);
      }
      throw new Error(`封面生成失败：${ExportService.errorDetail(error)}`);
    } finally {
      if (outputFile !== undefined) {
        try {
          fileIo.closeSync(outputFile);
        } catch (closeError) {
        }
      }
      if (outputPixelMap !== undefined) {
        try {
          await outputPixelMap.release();
        } catch (releaseError) {
        }
      }
      if (decodedPhoto !== undefined) {
        decodedPhoto.bitmap.close();
        try {
          await decodedPhoto.pixelMap.release();
        } catch (releaseError) {
        }
      }
      if (!generated && path.length > 0) {
        try {
          fileIo.unlinkSync(path);
        } catch (unlinkError) {
        }
      }
    }

    try {
      onReadyToSave();
      const helper: photoAccessHelper.PhotoAccessHelper =
        photoAccessHelper.getPhotoAccessHelper(appContext);
      const creationConfig: photoAccessHelper.PhotoCreationConfig = {
        title: `YikeCover-${Date.now()}`,
        fileNameExtension: extension,
        photoType: photoAccessHelper.PhotoType.IMAGE
      };
      const sourceUri: string = fileUri.getUriFromPath(path);
      // Use the API 12 save dialog instead of the API 23 Ex dialog. The older
      // API is the compatibility path for atomic services and avoids a Photos
      // process crash observed on API 23 devices.
      hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG, 'DIALOG_OPEN');
      const assetUris: Array<string> = await helper.showAssetsCreationDialog(
        [sourceUri], [creationConfig]);
      if (assetUris.length !== 1 || assetUris[0].length === 0) {
        throw new Error('系统未返回相册文件');
      }
      hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG, 'DIALOG_AUTHORIZED');

      const assetUri: string = assetUris[0];
      const savedSize: number =
        await ExportService.waitForSavedAsset(assetUri);
      hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
        'VERIFY_DONE bytes=%{public}d', savedSize);
      handedToSystem = true;
      hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG, 'SAVE_DONE');
      return assetUri;
    } catch (error) {
      hilog.error(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
        'SAVE_FAILED reason=%{public}s', ExportService.errorDetail(error));
      throw new Error(`相册保存未完成：${ExportService.errorDetail(error)}`);
    } finally {
      if (!handedToSystem && path.length > 0) {
        try {
          fileIo.unlinkSync(path);
        } catch (unlinkError) {
        }
      }
    }
  }
}
