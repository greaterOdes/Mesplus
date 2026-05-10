/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-05-01 00-38-02
 * @Author: @greaterOdes
 */
@Component
export struct SsoWebViewContent {
  build() {
    RelativeContainer() {
      Column() {
        Text($r('app.string.sso_title'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text($r('app.string.sso_placeholder_title'))
          .fontSize(15)
          .fontColor('#6B7280')
          .margin({ top: 12 })
        Text($r('app.string.sso_placeholder_subtitle'))
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
