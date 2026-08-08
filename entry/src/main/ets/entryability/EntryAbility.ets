import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import auth from '@hw-agconnect/auth';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private initAgcAuth(): void {
    try {
      const config = this.context.resourceManager.getRawFileContentSync('agconnect-services.json');
      const configJson = buffer.from(config.buffer).toString();
      auth.init(this.context, configJson);
      hilog.info(DOMAIN, 'AgcAuth', '%{public}s', 'AGC Auth initialized');
    } catch (error) {
      const initError = error as Error;
      hilog.error(DOMAIN, 'AgcAuth', 'Failed to initialize AGC Auth: %{public}s', initError.message);
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    this.initAgcAuth();
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
