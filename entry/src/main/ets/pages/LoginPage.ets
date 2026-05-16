/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { ChannelPicker } from '../components/ChannelPicker';
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
      Column() {
        Text($r('app.string.app_name'))
          .fontSize(38)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text($r('app.string.industrial_platform'))
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
