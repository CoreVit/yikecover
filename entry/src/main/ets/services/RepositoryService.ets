import { pasteboard } from '@kit.BasicServicesKit';

export class RepositoryService {
  static readonly URL: string = 'https://github.com/CoreVit/yikecover';

  static async copyUrl(): Promise<void> {
    const data: pasteboard.PasteData =
      pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, RepositoryService.URL);
    await pasteboard.getSystemPasteboard().setData(data);
  }
}
