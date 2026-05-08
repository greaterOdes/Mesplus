@Component
export struct MiniProgramSearch {
  @Builder
  FeatureEntry(title: string, desc: string) {
    Column() {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')

      Text(desc)
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ top: 4 })
    }
    .width('48%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#F7FDF9')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      Row() {
        Text('搜索')
          .fontSize(14)
          .fontColor('#9CA3AF')

        Text('设备 工单 看板 异常')
          .fontSize(14)
          .fontColor('#9CA3AF')
          .margin({ left: 10 })
      }
      .width('100%')
      .height(42)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#F3F4F6')
      .borderRadius(21)
      .alignItems(VerticalAlign.Center)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        this.FeatureEntry('设备巡检', '点检路线')
        this.FeatureEntry('工单处理', '待办任务')
        this.FeatureEntry('生产看板', '产线数据')
        this.FeatureEntry('异常上报', '现场反馈')
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 4 })
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}
