/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-05-01 00-38-02
 * @Author: @greaterOdes
 */
@Component
export struct ProfileContent {
  onLogout: () => void = (): void => {};

  @Builder
  InfoRow(label: ResourceStr, value: ResourceStr) {
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

  @Builder
  UserCard() {
    Row() {
      Text($r('app.string.profile_avatar_text'))
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width(64)
        .height(64)
        .textAlign(TextAlign.Center)
        .backgroundColor('#07C160')
        .borderRadius(12)

      Column() {
        Text($r('app.string.profile_user_name'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text($r('app.string.industrial_platform'))
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
  }

  @Builder
  InfoGroup() {
    Column() {
      this.InfoRow($r('app.string.profile_channel_label'), $r('app.string.profile_channel_value'))
      this.InfoRow($r('app.string.profile_login_methods_label'), $r('app.string.profile_login_methods_value'))
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 6, bottom: 6 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 14 })
  }

  @Builder
  SettingGroup() {
    Column() {
      this.InfoRow($r('app.string.profile_settings_label'), $r('app.string.pending_integration'))
      this.InfoRow($r('app.string.profile_about_label'), $r('app.string.app_name'))
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 6, bottom: 6 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 14 })
  }

  @Builder
  LogoutButton() {
    Button($r('app.string.logout_button'))
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

  build() {
    Scroll() {
      Column() {
        this.UserCard()
        this.InfoGroup()
        this.SettingGroup()
        this.LogoutButton()
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7F9')
  }
}
