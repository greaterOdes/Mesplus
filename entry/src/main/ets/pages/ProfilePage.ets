@Component
export struct ProfileContent {
  onLogout: () => void = (): void => {};

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#6B7280')

      Blank()

      Text(value)
        .fontSize(15)
        .fontColor('#111827')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('用')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width(64)
            .height(64)
            .textAlign(TextAlign.Center)
            .backgroundColor('#07C160')
            .borderRadius(12)

          Column() {
            Text('Mesplus 用户')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827')

            Text('工业协同平台')
              .fontSize(14)
              .fontColor('#6B7280')
              .margin({ top: 6 })
          }
          .margin({ left: 14 })
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 22, bottom: 22 })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)

        Column() {
          this.InfoRow('渠道', '企业微信渠道')
          this.InfoRow('登录方式', '账号 密码 短信 SSO')
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 6, bottom: 6 })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .margin({ top: 14 })

        Column() {
          this.InfoRow('设置', '待接入')
          this.InfoRow('关于', 'Mesplus')
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 6, bottom: 6 })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .margin({ top: 14 })

        Button('退出登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#EF4444')
          .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ top: 18 })
        .onClick(() => {
            this.onLogout();
        })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7F9')
  }
}
