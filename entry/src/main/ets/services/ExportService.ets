import fileIo from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import image from '@ohos.multimedia.image';
import { LengthMetricsUnit } from '@kit.ArkUI';
import { CoverDraft, ExportSettings, TemplateDefinition, DESIGN_WIDTH } from '../model/CoverModels';
import { CoverRenderer } from './CoverRenderer';

interface DecodedPhoto {
  bitmap: ImageBitmap;
  pixelMap: PixelMap;
}

export class ExportService {
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
    let extension: string = 'png';
    let mime: string = 'image/png';
    let generated: boolean = false;

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
      if (settings.format === 'JPEG') {
        mime = 'image/jpeg';
        extension = 'jpg';
      } else if (settings.format === 'WebP') {
        mime = 'image/webp';
        extension = 'webp';
      }

      const buffer: ArrayBuffer = await packer.packToData(outputPixelMap, {
        format: mime,
        quality: settings.format === 'PNG' ? 100 : settings.quality
      });
      path = `${appContext.cacheDir}/一刻封面-${Date.now()}.${extension}`;
      outputFile = fileIo.openSync(path,
        fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY |
        fileIo.OpenMode.TRUNC);
      ExportService.writeAll(outputFile.fd, buffer);
      generated = true;
    } catch (error) {
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
      const creationSetting: photoAccessHelper.CreationSetting = {
        title: `一刻封面-${Date.now()}`,
        fileNameExtension: extension,
        photoType: photoAccessHelper.PhotoType.IMAGE
      };
      // Atomic services use the system creation dialog for one-time,
      // user-authorized media-library writes.
      const assetUri: string = await helper.showSingleAssetCreationDialogEx(
        fileUri.getUriFromPath(path), creationSetting, true);
      if (assetUri.length === 0) {
        throw new Error('系统未返回相册文件');
      }
      return assetUri;
    } catch (error) {
      throw new Error(`相册保存未完成：${ExportService.errorDetail(error)}`);
    } finally {
      if (path.length > 0) {
        try {
          fileIo.unlinkSync(path);
        } catch (unlinkError) {
        }
      }
    }
  }
}
