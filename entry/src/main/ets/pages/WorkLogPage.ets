/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-05-01 00-38-02
 * @Author: @greaterOdes
 */
@Component
export struct WorkLogContent {
  @Builder
  LogItem(time: string, title: ResourceStr, status: ResourceStr, color: string) {
    Row() {
      Column() {
        Text(time)
          .fontSize(13)
          .fontColor('#6B7280')
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .margin({ top: 6 })
      }
      .layoutWeight(1)
      Text(status)
        .fontSize(13)
        .fontColor(color)
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor('#F3F4F6')
        .borderRadius(12)
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
  }

  @Builder
  HeaderBar() {
    Row() {
      Column() {
        Text($r('app.string.worklog_title'))
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text($r('app.string.worklog_date_record'))
          .fontSize(14)
          .fontColor('#6B7280')
          .margin({ top: 6 })
      }
      .layoutWeight(1)

      Button($r('app.string.worklog_add_button'))
        .height(38)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#07C160')
        .borderRadius(19)
    }
    .width('100%')
    .margin({ bottom: 18 })
  }

  @Builder
  LogList() {
    Column() {
      this.LogItem('08:30', $r('app.string.worklog_item_inspection'), $r('app.string.status_submitted'), '#07C160')
      this.LogItem('11:10', $r('app.string.worklog_item_changeover'), $r('app.string.status_pending_confirm'), '#D97706')
      this.LogItem('15:40', $r('app.string.worklog_item_issue_followup'), $r('app.string.status_processing'), '#2563EB')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 6 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Builder
  CreateLogPlaceholder() {
    Column() {
      Text($r('app.string.worklog_placeholder_title'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
      Text($r('app.string.worklog_placeholder_subtitle'))
        .fontSize(13)
        .fontColor('#6B7280')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 14 })
  }

  build() {
    Scroll() {
      Column() {
        this.HeaderBar()
        this.LogList()
        this.CreateLogPlaceholder()
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7F9')
  }
}
