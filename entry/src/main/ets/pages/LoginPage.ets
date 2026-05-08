import { ChannelPicker } from '../components/ChannelPicker';
import { LoginPanel } from '../components/LoginPanel';

@Component
export struct LoginContent {
  onLoginSuccess: () => void = (): void => {};
  onSsoLogin: () => void = (): void => {};

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  build() {
    RelativeContainer() {
      Column() {
        Text('Mesplus')
          .fontSize(38)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')

        Text('工业协同平台')
          .fontSize(16)
          .fontColor('#6B7280')
          .margin({ top: 8, bottom: 28 })

        ChannelPicker({ channelName: '企业微信渠道' })
          .margin({ bottom: 14 })

        LoginPanel({
          onLoginSuccess: this.onLoginSuccess,
          onSsoLogin: this.onSsoLogin
        })
      }
      .width('88%')
      .padding({ top: 24, bottom: 24 })
      .alignItems(HorizontalAlign.Center)
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F2F4')
  }
}
