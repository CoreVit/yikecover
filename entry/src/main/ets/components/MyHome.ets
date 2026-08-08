import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

interface MyMenuItem {
  id: number;
  title: string;
  description: string;
}

const PAGE_CONTENT_MAX_WIDTH: number = 960;

const ACCOUNT_NOT_LOGGED_IN: number = 1001502001;
const ACCOUNT_REQUEST_REFUSED: number = 1001500002;
const ACCOUNT_NETWORK_ERROR: number = 1001502005;
const ACCOUNT_INTERNAL_ERROR: number = 1001502009;
const ACCOUNT_USER_CANCELLED: number = 1001502012;
const ACCOUNT_SYSTEM_ERROR: number = 12300001;

let runtimeSignedIn: boolean = false;
let runtimeAccountName: string = '';
let runtimeAvatarUri: string = '';

const MY_MENU_ITEMS: MyMenuItem[] = [
  {
    id: 1,
    title: '支持开发者',
    description: '购买永久支持徽记，全部功能仍然免费'
  },
  {
    id: 2,
    title: '支持记录',
    description: '查看当前账号拥有的支持徽记'
  },
  {
    id: 3,
    title: '关于一刻封面',
    description: '版本信息、开源地址与功能介绍'
  },
  {
    id: 4,
    title: '隐私政策',
    description: '了解账号与订单信息的使用方式'
  }
];

@Component
export struct MyHome {
  @State signedIn: boolean = false;
  @State accountName: string = '';
  @State avatarUri: string = '';
  @State loggingIn: boolean = false;

  aboutToAppear(): void {
    this.signedIn = runtimeSignedIn;
    this.accountName = runtimeAccountName;
    this.avatarUri = runtimeAvatarUri;
  }

  private showMessage(message: string): void {
    this.getUIContext().getPromptAction().showToast({
      message: message,
      duration: 1800
    });
  }

  private accountErrorMessage(code: number): string {
    if (code === ACCOUNT_NOT_LOGGED_IN) {
      return '请先在设备上登录华为账号';
    }
    if (code === ACCOUNT_NETWORK_ERROR) {
      return '网络异常，请检查网络后重试';
    }
    if (code === ACCOUNT_USER_CANCELLED) {
      return '已取消华为账号授权';
    }
    if (code === ACCOUNT_REQUEST_REFUSED) {
      return '登录请求正在处理中';
    }
    if (code === ACCOUNT_INTERNAL_ERROR || code === ACCOUNT_SYSTEM_ERROR) {
      return '华为账号服务暂不可用，请稍后重试';
    }
    return '登录失败，请稍后重试';
  }

  private async loginWithHuaweiID(): Promise<void> {
    if (this.loggingIn) {
      return;
    }

    this.loggingIn = true;
    try {
      const request = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
      request.scopes = ['profile'];
      request.supportAtomicService = true;
      request.forceAuthorization = true;
      request.state = util.generateRandomUUID();

      const controller = new authentication.AuthenticationController(this.getUIContext().getHostContext());
      const data = await controller.executeRequest(request);
      const response = data as authentication.AuthorizationWithHuaweiIDResponse;
      const requestState = request.state || '';
      const responseState = response.state || '';
      if (requestState !== responseState) {
        this.showMessage('登录校验失败，请重新尝试');
        return;
      }

      const credential = response.data;
      if (!credential) {
        this.showMessage('未获取到华为账号信息');
        return;
      }

      this.accountName = credential.nickName || '华为账号用户';
      this.avatarUri = credential.avatarUri || '';
      this.signedIn = true;
      runtimeAccountName = this.accountName;
      runtimeAvatarUri = this.avatarUri;
      runtimeSignedIn = true;
      this.showMessage('华为账号登录成功');
    } catch (error) {
      const accountError = error as BusinessError;
      this.showMessage(this.accountErrorMessage(accountError.code));
    } finally {
      this.loggingIn = false;
    }
  }

  private logout(): void {
    runtimeSignedIn = false;
    runtimeAccountName = '';
    runtimeAvatarUri = '';
    this.signedIn = false;
    this.accountName = '';
    this.avatarUri = '';
    this.showMessage('已退出当前登录');
  }

  private openMenuItem(item: MyMenuItem): void {
    if (item.id === 3) {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/About'
      });
      return;
    }

    if ((item.id === 1 || item.id === 2) && !this.signedIn) {
      this.showMessage('请先登录华为账号');
      return;
    }

    this.showMessage('该功能将在后续阶段接入');
  }

  @Builder
  private defaultAvatar() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(64)
        .height(64)
        .backgroundColor($r('app.color.control_background'))
        .borderRadius(32)

      Stack({ alignContent: Alignment.BottomStart }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.card_background'))
        Row()
          .width(24)
          .height(58)
          .backgroundColor($r('app.color.brand_primary'))
          .rotate({ angle: 18 })
          .translate({ x: -13, y: 0 })
        Text('一刻')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .padding({ left: 9, bottom: 8 })
      }
      .width(54)
      .height(54)
      .borderRadius(27)
      .clip(true)

      if (this.signedIn && this.avatarUri.length > 0) {
        Image(this.avatarUri)
          .width(54)
          .height(54)
          .objectFit(ImageFit.Cover)
          .borderRadius(27)
      }
    }
    .width(68)
    .height(68)
    .borderRadius(34)
  }

  @Builder
  private accountCard() {
    Column() {
      Row({ space: 14 }) {
        this.defaultAvatar()

        Column({ space: 5 }) {
          Text(this.signedIn ? this.accountName : '登录华为账号')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(this.signedIn ?
            '账号仅用于保存和恢复支持徽记' : '制作、保存和导出无需登录')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      if (!this.signedIn) {
        Button(this.loggingIn ? '正在登录…' : '登录华为账号', { type: ButtonType.Normal })
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(11)
          .margin({ top: 18 })
          .enabled(!this.loggingIn)
          .opacity(this.loggingIn ? 0.65 : 1)
          .onClick(() => {
            this.loginWithHuaweiID();
          })
      } else {
        Text('退出登录')
          .width('100%')
          .fontSize(12)
          .fontColor($r('app.color.text_muted'))
          .textAlign(TextAlign.Center)
          .padding({ top: 15, bottom: 2 })
          .onClick(() => {
            this.logout();
          })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
  }

  @Builder
  private freePromise() {
    Row({ space: 13 }) {
      Column() {
        Text('FREE')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .letterSpacing(1)
      }
      .width(50)
      .height(50)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.brand_primary'))
      .borderRadius(13)

      Column({ space: 4 }) {
        Text('全部功能始终免费')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('支持徽记只表达支持，不会解锁额外功能')
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(15)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }

  @Builder
  private menuRow(item: MyMenuItem, isLast: boolean) {
    Column() {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Text(item.description)
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.chevron_forward'))
          .fontSize(18)
          .fontColor([$r('app.color.text_muted')])
      }
      .width('100%')
      .padding({ top: 14, bottom: 14 })

      if (!isLast) {
        Divider()
          .strokeWidth(1)
          .color($r('app.color.divider'))
      }
    }
    .width('100%')
    .onClick(() => {
      this.openMenuItem(item);
    })
  }

  build() {
    Scroll() {
      Row() {
        Column() {
          Column({ space: 4 }) {
            Text('我的')
              .width('100%')
              .fontSize(27)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text('账号、支持徽记与应用信息')
              .width('100%')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 12 }) {
            this.accountCard()
            this.freePromise()
          }
          .width('100%')
          .margin({ top: 20 })

          Text('支持与信息')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 28, bottom: 12 })

          Column() {
            ForEach(MY_MENU_ITEMS, (item: MyMenuItem, index: number) => {
              this.menuRow(item, index === MY_MENU_ITEMS.length - 1)
            }, (item: MyMenuItem) => item.id.toString())
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ bottom: 110 })
        }
        .width('100%')
        .constraintSize({ maxWidth: PAGE_CONTENT_MAX_WIDTH })
        .padding({ left: 18, right: 18, top: 18 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)
    }
    .align(Alignment.TopStart)
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.page_background'))
  }
}
