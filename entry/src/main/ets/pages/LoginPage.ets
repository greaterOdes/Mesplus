/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { LoginPanel } from '../components/LoginPanel';

/**
 * @since: 2026-05-01 00-34-42
 * @Author: @greaterOdes
 */
@Component
export struct LoginContent {
  onLoginSuccess: () => void = (): void => {};
  onSsoLogin: () => void = (): void => {};

  build() {
    RelativeContainer() {
      Circle()
        .width(210)
        .height(210)
        .fill('rgba(122,162,255,0.16)')
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        })
        .margin({ left: -76, bottom: -62 })

      Circle()
        .width(190)
        .height(190)
        .fill('rgba(255,255,255,0.78)')
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          top: { anchor: '__container__', align: VerticalAlign.Top }
        })
        .margin({ right: -58, top: -46 })

      Column() {
        Text('M')
          .width(58)
          .height(58)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5C6572')
          .textAlign(TextAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 18 })
        Text($r('app.string.app_name'))
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1D1D1F')
        Text($r('app.string.login_subtitle_precision_access'))
          .fontSize(14)
          .fontColor('#7A828D')
          .margin({ top: 8, bottom: 34 })
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
    .backgroundColor('#F4F6F9')
  }
}
