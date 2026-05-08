@Component
export struct SsoWebViewContent {
  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  build() {
    RelativeContainer() {
      Column() {
        Text('统一身份认证')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')

        Text('SSO WebView 页面待接入')
          .fontSize(15)
          .fontColor('#6B7280')
          .margin({ top: 12 })

        Text('后续将在这里加载企业统一身份认证地址')
          .fontSize(13)
          .fontColor('#9CA3AF')
          .textAlign(TextAlign.Center)
          .margin({ top: 8 })
      }
      .width('84%')
      .padding({ left: 20, right: 20, top: 30, bottom: 30 })
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .alignItems(HorizontalAlign.Center)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7F9')
  }
}
