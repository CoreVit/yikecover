import { common } from '@kit.AbilityKit';
import { pasteboard } from '@kit.BasicServicesKit';

export class RepositoryService {
  static readonly URL: string = 'https://github.com/CoreVit/yikecover';

  static async open(context: common.UIAbilityContext): Promise<boolean> {
    try {
      await context.openLink(RepositoryService.URL, {
        appLinkingOnly: false,
        hideFailureTipDialog: true
      });
      return true;
    } catch (error) {
      const data: pasteboard.PasteData =
        pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, RepositoryService.URL);
      await pasteboard.getSystemPasteboard().setData(data);
      return false;
    }
  }
}
