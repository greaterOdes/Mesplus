/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { LoginMode } from '../config/AppConstants';

/**
 * @since: 2026-05-01 00-48-18
 * @Author: @greaterOdes
 */
@Component
export struct LoginPanel {
  @State account: string = '';
  @State password: string = '';
  @State verifyCode: string = '';
  @State currentMode: LoginMode = LoginMode.MAG;
  @State mfaVisible: boolean = false;
  @State mfaTarget: ResourceStr = $r('app.string.masked_mobile_label');
  onLoginSuccess: () => void = (): void => {};
  onSsoLogin: () => void = (): void => {};

  private selectMode(mode: LoginMode): void {
    this.currentMode = mode;
    this.mfaVisible = false;
  }

  @Builder
  ChannelSegment() {
    Row() {
      this.SegmentButton(LoginMode.MAG, $r('app.string.mag_login_label'))
      this.SegmentButton(LoginMode.IDASS, $r('app.string.idass_login_label'))
    }
    .width('100%')
    .padding(4)
    .backgroundColor('rgba(118,118,128,0.12)')
    .borderRadius(22)
    .margin({ top: 22 })
  }

  @Builder
  SegmentButton(mode: LoginMode, text: ResourceStr) {
    Text(text)
      .fontSize(13)
      .fontWeight(this.currentMode === mode ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.currentMode === mode ? '#1D1D1F' : '#777D86')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(36)
      .borderRadius(18)
      .backgroundColor(this.currentMode === mode ? '#FFFFFF' : 'rgba(255,255,255,0)')
      .onClick(() => {
        this.selectMode(mode);
      })
  }

  @Builder
  MagForm() {
    Column() {
      this.InputField($r('app.string.account_placeholder'), false)
      this.InputField($r('app.string.password_placeholder'), true)
      if (this.mfaVisible) {
        this.MfaPanel()
      }
      this.PrimaryButton()
    }
    .width('100%')
    .margin({ top: 20 })
  }

  @Builder
  InputField(placeholder: ResourceStr, secure: boolean) {
    TextInput({ placeholder })
      .type(secure ? InputType.Password : InputType.Normal)
      .height(46)
      .fontSize(15)
      .fontColor('#1D1D1F')
      .backgroundColor('rgba(246,247,249,0.86)')
      .border({ width: 0.5, color: '#D9DEE7' })
      .borderRadius(14)
      .padding({ left: 14, right: 14 })
      .margin({ top: 10 })
      .onChange((value: string) => {
        secure ? this.password = value : this.account = value;
      })
  }

  @Builder
  MfaPanel() {
    Column() {
      Text($r('app.string.two_factor_title'))
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1D1D1F')
        .width('100%')
      Text($r('app.string.two_factor_subtitle'))
        .fontSize(12)
        .fontColor('#7A828D')
        .width('100%')
        .margin({ top: 4, bottom: 10 })
      this.MfaOptions()
      this.VerifyInput()
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('rgba(255,255,255,0.62)')
    .border({ width: 0.5, color: '#D9DEE7' })
    .borderRadius(18)
    .margin({ top: 14 })
  }

  @Builder
  MfaOptions() {
    Row() {
      this.MfaChip($r('app.string.masked_mobile_label'))
      this.MfaChip($r('app.string.masked_email_label'))
    }
    .width('100%')
  }

  @Builder
  MfaChip(text: ResourceStr) {
    Text(text)
      .fontSize(12)
      .fontColor(this.mfaTarget === text ? '#FFFFFF' : '#4B5563')
      .textAlign(TextAlign.Center)
      .height(32)
      .layoutWeight(1)
      .borderRadius(16)
      .backgroundColor(this.mfaTarget === text ? '#1D1D1F' : '#EEF1F5')
      .margin({ right: 8 })
      .onClick(() => {
        this.mfaTarget = text;
      })
  }

  @Builder
  VerifyInput() {
    Row() {
      TextInput({ placeholder: $r('app.string.sms_code_placeholder') })
        .height(42)
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')
        .borderRadius(13)
        .onChange((value: string) => {
          this.verifyCode = value;
        })
      Button($r('app.string.get_sms_code'))
        .height(42)
        .fontSize(13)
        .fontColor('#1D1D1F')
        .backgroundColor('#EEF1F5')
        .borderRadius(13)
        .margin({ left: 8 })
    }
    .width('100%')
    .margin({ top: 10 })
  }

  @Builder
  IdassPanel() {
    Column() {
      Text($r('app.string.idass_web_prompt'))
        .fontSize(14)
        .fontColor('#6B7280')
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ top: 28, bottom: 18 })
      Button($r('app.string.sso_login'))
        .width('100%')
        .height(46)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#1D1D1F')
        .borderRadius(14)
        .onClick(() => {
          this.onSsoLogin();
        })
    }
  }

  @Builder
  PrimaryButton() {
    Button(this.mfaVisible ? $r('app.string.login_button') : $r('app.string.mag_login_label'))
      .width('100%')
      .height(46)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .backgroundColor('#1D1D1F')
      .borderRadius(14)
      .margin({ top: 18 })
      .onClick(() => {
        this.mfaVisible ? this.onLoginSuccess() : this.mfaVisible = true;
      })
  }

  build() {
    Column() {
      Text($r('app.string.login_title'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1D1D1F')
        .width('100%')
      Text($r('app.string.device_secure_hint'))
        .fontSize(12)
        .fontColor('#7A828D')
        .width('100%')
        .margin({ top: 6 })
      this.ChannelSegment()
      if (this.currentMode === LoginMode.MAG) {
        this.MagForm()
      } else {
        this.IdassPanel()
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 24, bottom: 24 })
    .backgroundColor('rgba(255,255,255,0.72)')
    .border({ width: 0.5, color: '#FFFFFF' })
    .borderRadius(28)
  }
}
