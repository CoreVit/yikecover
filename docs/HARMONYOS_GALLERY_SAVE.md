# HarmonyOS 元服务导出图片并保存到系统相册

本文记录 HarmonyOS 元服务将内存中的图片导出到系统相册的完整流程，适合封面、海报、长图、二维码等本地生成图片的场景。

本文针对以下约束：

- 元服务不申请持续读取或修改整个相册的权限。
- 用户点击“保存到相册”后，由系统弹窗完成单次授权。
- 兼容本项目实际测试过的 API 23 和 API 24 设备。
- 只有图片数据确实写入系统返回的相册资源后，界面才提示保存成功。

## 1. 最重要的结论

`showAssetsCreationDialog()` 返回的 URI 只是系统为本次操作授权的目标资源 URI，不代表系统已经把源图片复制进相册。

正确流程是：

1. 在应用缓存目录生成完整的临时图片。
2. 把临时图片的 `file://` URI 交给系统相册创建弹窗。
3. 用户确认后，取得系统返回的目标资源 URI。
4. 分别打开临时源文件和目标资源。
5. 使用两个文件描述符执行 `fileIo.copyFile()`。
6. 等待复制完成，并关闭目标文件。
7. 此时才能提示“已保存到相册”。
8. 最后删除临时图片。

可以把它理解为：

```text
内存图片
   │ 编码
   ▼
应用缓存目录中的临时文件
   │ 请求用户单次授权
   ▼
系统返回一个可写的相册目标 URI
   │ 打开源 FD 和目标 FD，再复制字节
   ▼
关闭目标 FD，完成相册资源写入
```

## 2. 所需模块

```ts
import fileIo from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { hilog } from '@kit.PerformanceAnalysisKit';
```

这种由用户主动触发、通过系统弹窗进行单次授权的保存方式，不需要为了写入一张新图片而申请持续访问整个公共相册的权限。不要仅仅为了实现“保存到相册”就增加宽泛的相册读写权限。

## 3. 可复用的完整保存函数

下面的函数假设图片已经编码并完整写入 `tempImagePath`。调用者需要保证路径位于应用可访问的目录，例如 `context.cacheDir`。

```ts
import fileIo from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { hilog } from '@kit.PerformanceAnalysisKit';

const SAVE_LOG_DOMAIN = 0x0000;
const SAVE_LOG_TAG = 'GallerySave';

function errorMessage(error: Object): string {
  if (error instanceof Error && error.message.length > 0) {
    return error.message;
  }
  return '系统未返回具体原因';
}

/**
 * 将已经存在于应用私有目录的图片保存到系统相册。
 *
 * @param context UIAbility 或组件可用的 Context
 * @param tempImagePath 应用私有目录中的临时图片绝对路径
 * @param extension 不带点的扩展名，例如 png 或 jpg
 * @param title 相册资源标题，不包含扩展名
 * @returns 系统创建并授权的相册资源 URI
 */
export async function saveImageFileToGallery(
  context: Context,
  tempImagePath: string,
  extension: string,
  title: string
): Promise<string> {
  try {
    // 先确认临时文件确实存在且不是空文件。
    const sourceSize: number = fileIo.statSync(tempImagePath).size;
    if (sourceSize <= 0) {
      throw new Error('待保存的临时图片为空');
    }

    const helper: photoAccessHelper.PhotoAccessHelper =
      photoAccessHelper.getPhotoAccessHelper(context);
    const sourceUri: string = fileUri.getUriFromPath(tempImagePath);
    const creationConfig: photoAccessHelper.PhotoCreationConfig = {
      title: title,
      fileNameExtension: extension,
      photoType: photoAccessHelper.PhotoType.IMAGE
    };

    hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
      'DIALOG_OPEN bytes=%{public}d', sourceSize);

    // API 12 起可用的元服务兼容路径。本项目在 API 23/24 设备使用此接口。
    const assetUris: Array<string> = await helper.showAssetsCreationDialog(
      [sourceUri], [creationConfig]);

    if (assetUris.length !== 1 || assetUris[0].length === 0) {
      throw new Error('系统未返回相册目标文件');
    }

    const destinationUri: string = assetUris[0];
    hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG, 'DIALOG_AUTHORIZED');

    // 关键：弹窗只返回已授权的目标 URI，不会替应用复制图片数据。
    let sourceFile: fileIo.File | undefined = undefined;
    let destinationFile: fileIo.File | undefined = undefined;
    try {
      sourceFile = fileIo.openSync(tempImagePath, fileIo.OpenMode.READ_ONLY);
      destinationFile = fileIo.openSync(destinationUri,
        fileIo.OpenMode.WRITE_ONLY);

      hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
        'COPY_START bytes=%{public}d', sourceSize);
      await fileIo.copyFile(sourceFile.fd, destinationFile.fd);
      hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
        'COPY_DONE bytes=%{public}d', sourceSize);
    } finally {
      // 目标文件优先关闭，让系统完成本次资源写入。
      if (destinationFile !== undefined) {
        try {
          fileIo.closeSync(destinationFile);
        } catch (closeError) {
        }
      }
      if (sourceFile !== undefined) {
        try {
          fileIo.closeSync(sourceFile);
        } catch (closeError) {
        }
      }
    }

    hilog.info(SAVE_LOG_DOMAIN, SAVE_LOG_TAG, 'SAVE_DONE');
    return destinationUri;
  } catch (error) {
    hilog.error(SAVE_LOG_DOMAIN, SAVE_LOG_TAG,
      'SAVE_FAILED reason=%{public}s', errorMessage(error));
    throw new Error(`相册保存未完成：${errorMessage(error)}`);
  }
}
```

## 4. 调用端：生成临时图片、保存、清理

临时文件必须在复制结束后再删除。无论保存成功、用户取消还是发生异常，最终都应清理临时文件。

```ts
function writeAll(fd: number, buffer: ArrayBuffer): void {
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

async function exportCover(context: Context, encoded: ArrayBuffer): Promise<void> {
  const extension: string = 'png';
  const tempPath: string =
    `${context.cacheDir}/cover-${Date.now()}.${extension}`;
  let tempFile: fileIo.File | undefined = undefined;

  try {
    tempFile = fileIo.openSync(tempPath,
      fileIo.OpenMode.CREATE |
      fileIo.OpenMode.WRITE_ONLY |
      fileIo.OpenMode.TRUNC);
    writeAll(tempFile.fd, encoded);
    const actualSize: number = fileIo.statSync(tempFile.fd).size;
    if (actualSize !== encoded.byteLength) {
      throw new Error(`临时图片写入不完整（${actualSize}/${encoded.byteLength} 字节）`);
    }
    fileIo.closeSync(tempFile);
    tempFile = undefined;

    await saveImageFileToGallery(
      context,
      tempPath,
      extension,
      `Cover-${Date.now()}`
    );

    // 只能放在 await 成功之后。
    showToast('封面已保存到相册');
  } catch (error) {
    showToast(errorMessage(error));
  } finally {
    if (tempFile !== undefined) {
      try {
        fileIo.closeSync(tempFile);
      } catch (closeError) {
      }
    }
    try {
      fileIo.unlinkSync(tempPath);
    } catch (unlinkError) {
      // 文件可能尚未创建，或已经被清理；不覆盖真正的保存结果。
    }
  }
}
```

示例同时处理了 `writeSync()` 只写入部分数据的情况，并用 `statSync()` 校验临时文件大小。

## 5. 为什么之前的写法会失败

### 5.1 弹窗返回 URI 后立刻提示成功

错误认识：系统弹窗会自动把传入的临时文件复制到相册。

实际情况：弹窗返回的是本次授权的目标 URI。此时只完成了资源创建和授权，应用仍需写入数据。因此这种写法会出现“提示保存成功，但相册里没有图片”。

### 5.2 不写入，只轮询目标 URI 是否出现内容

这相当于等待一个从未开始的复制过程。目标资源不会自己获得临时文件的数据，轮询只会超时或得到空内容。

### 5.3 把目标 URI 字符串直接作为 `copyFile()` 的目标路径

相册目标是媒体资源 URI，不是普通文件系统路径。在不同系统版本上，这种写法可能报：

- `Invalid argument`
- `No such file or directory`
- 或者没有明显异常但最终没有图片

应先用 `fileIo.openSync(destinationUri, WRITE_ONLY)` 打开资源，再把得到的目标文件描述符传给 `copyFile()`。

### 5.4 提前删除临时文件

系统弹窗可能已经完成授权，但真正复制时源文件已不存在，于是出现 `No such file or directory`。临时文件必须保留到 `copyFile()` 完成之后。

### 5.5 用目标 URI 做只读验证

本流程取得的是本次写入授权。不同系统版本对随后读取该 URI 的授权行为可能不同，不应把“能否立即只读打开目标 URI”当作保存成功的必要条件。

成功边界应是：

1. `copyFile()` 正常完成；
2. 目标文件描述符正常关闭；
3. 没有抛出异常。

### 5.6 为单次保存申请公共相册写权限

这会扩大应用权限范围，也不是本流程的必要条件。系统创建弹窗已经为用户选择的这一次操作提供目标资源授权。

### 5.7 直接切换到较新的 `Ex` 接口

更新的接口不一定更适合全部目标系统。本项目曾在 API 23 设备上观察到相册进程异常和兼容性问题，因此最终采用 `showAssetsCreationDialog()`。选择接口时必须以应用的最低 API、元服务可用性和真实设备测试结果为准。

## 6. 图片生成阶段的注意事项

相册保存只能保证“把已有字节写进相册”，不能修复上游渲染问题。保存前应单独验证：

- 编码结果不是空缓冲区；
- PNG、JPEG 或 WebP 文件头与所选格式一致；
- 临时文件大小等于编码缓冲区大小；
- 目标扩展名与实际编码格式一致；
- 高分辨率图片不会因内存不足导致画布或编码失败；
- 居中裁切、缩放和方向处理在渲染阶段已经正确。

不要把“图片裁切错误”和“相册写入失败”混在一个修复逻辑中。前者属于渲染，后者属于文件授权和复制。

## 7. 推荐日志

至少记录以下阶段：

```text
SAVE_START       用户开始导出
RENDER_DONE      图片编码和临时文件写入完成，附字节数
DIALOG_OPEN      已调起系统创建弹窗
DIALOG_AUTHORIZED 用户确认，系统返回目标 URI
COPY_START       开始从临时文件复制到相册资源
COPY_DONE        copyFile 已完成，附字节数
SAVE_DONE        目标文件已关闭，可以向用户提示成功
SAVE_FAILED      任意阶段失败，附原始错误信息
```

排查时优先按应用包名或自定义标签过滤 HiLog。例如本项目使用 `YikeCoverSave`。仅看系统相册进程的通用错误，往往无法判断应用究竟停在了授权、打开文件还是复制阶段。

## 8. 真机验收清单

不要以 Toast 为验收依据。每一种目标设备至少完成以下检查：

- 点击保存后出现系统确认界面；
- 取消确认时不提示保存成功；
- 确认后相册中确实出现新图片；
- 打开图片后内容完整，不是空白或损坏文件；
- 图片尺寸、格式和方向正确；
- 16:9 等裁切结果以预期中心点输出；
- 连续保存三次都能得到三张可打开的图片；
- 1080P 和最高支持分辨率各测试一次；
- PNG 和 JPEG 各测试一次（如果产品开放两种格式）；
- API 23、API 24，以及手机和平板分别覆盖；
- 失败时只提示失败，绝不提前提示成功；
- 保存结束后应用缓存目录没有长期残留临时导出文件。

## 9. 本项目实现位置

一刻封面的实际实现位于：

```text
entry/src/main/ets/services/ExportService.ets
```

核心调用顺序应始终保持为：

```text
编码 → 临时文件 → 系统授权弹窗 → 打开源 FD → 打开目标 FD
→ copyFile → 关闭目标 FD → 提示成功 → 删除临时文件
```

以后复用这套逻辑时，可以替换图片编码和 UI 提示部分，但不要改变授权、复制、关闭和清理的先后关系。
