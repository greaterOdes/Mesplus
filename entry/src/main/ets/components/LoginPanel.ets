@Component
export struct LoginPanel {
  @State account: string = '';
  @State password: string = '';
  @State smsCode: string = '';
  onLoginSuccess: () => void = (): void => {};
  onSsoLogin: () => void = (): void => {};

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  build() {
    Column() {
      Text('登录 Mesplus')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
        .width('100%')

      TextInput({ placeholder: '账号' })
        .height(48)
        .fontSize(15)
        .backgroundColor('#F7F7F7')
        .borderRadius(10)
        .padding({ left: 14, right: 14 })
        .margin({ top: 18 })
        .onChange((value: string) => {
          this.account = value;
        })

      TextInput({ placeholder: '密码' })
        .type(InputType.Password)
        .height(48)
        .fontSize(15)
        .backgroundColor('#F7F7F7')
        .borderRadius(10)
        .padding({ left: 14, right: 14 })
        .margin({ top: 12 })
        .onChange((value: string) => {
          this.password = value;
        })

      Row() {
        TextInput({ placeholder: '短信验证码' })
          .height(48)
          .fontSize(15)
          .backgroundColor('#F7F7F7')
          .borderRadius(10)
          .padding({ left: 14, right: 14 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.smsCode = value;
          })

        Button('获取')
          .height(48)
          .fontSize(14)
          .fontColor('#07C160')
          .backgroundColor('#E8F8EF')
          .borderRadius(10)
          .margin({ left: 10 })
      }
      .width('100%')
      .margin({ top: 12 })

      Text('统一身份认证登录')
        .fontSize(14)
        .fontColor('#07C160')
        .width('100%')
        .textAlign(TextAlign.End)
        .margin({ top: 16 })
        .onClick(() => {
          this.onSsoLogin();
        })

      Button('登录')
        .width('100%')
        .height(48)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .backgroundColor('#07C160')
        .borderRadius(10)
        .margin({ top: 24 })
        .onClick(() => {
          this.onLoginSuccess();
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 22, bottom: 22 })
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}
