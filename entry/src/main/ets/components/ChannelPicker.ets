/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-05-01 00-48-18
 * @Author: @greaterOdes
 */
@Component
export struct ChannelPicker {
  channelName: string = '企业微信渠道';

  build() {
    Row() {
      Text($r('app.string.current_channel'))
        .fontSize(14)
        .fontColor('#6B7280')
      Blank()
      Button(this.channelName)
        .height(36)
        .fontSize(14)
        .fontColor('#07C160')
        .backgroundColor('#E8F8EF')
        .borderRadius(18)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }
}
