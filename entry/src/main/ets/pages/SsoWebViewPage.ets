/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { SSO_CALLBACK_NAME } from '../auth/WebBridge';

/**
 * @since: 2026-05-01 00-38-02
 * @Author: @greaterOdes
 */
@Component
export struct SsoWebViewContent {
  @Builder
  BridgeRow(label: ResourceStr, value: ResourceStr | string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#8A919D')
        .width('100%')
      Text(value)
        .fontSize(13)
        .fontColor('#1D1D1F')
        .width('100%')
        .margin({ top: 6 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#F6F7F9')
    .borderRadius(14)
    .margin({ top: 10 })
  }

  build() {
    RelativeContainer() {
      Column() {
        Text($r('app.string.sso_title'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1D1D1F')
        Text($r('app.string.idass_bridge_title'))
          .fontSize(15)
          .fontColor('#5F6673')
          .margin({ top: 12 })
        Text($r('app.string.idass_bridge_subtitle'))
          .fontSize(13)
          .fontColor('#8A919D')
          .textAlign(TextAlign.Center)
          .margin({ top: 8 })
        this.BridgeRow($r('app.string.idass_callback_label'), SSO_CALLBACK_NAME)
        this.BridgeRow($r('app.string.idass_payload_label'), $r('app.string.idass_payload_example'))
      }
      .width('84%')
      .padding({ left: 20, right: 20, top: 30, bottom: 30 })
      .backgroundColor('rgba(255,255,255,0.76)')
      .border({ width: 0.5, color: '#FFFFFF' })
      .borderRadius(26)
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
