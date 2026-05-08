import { MiniProgramSearch } from '../components/MiniProgramSearch';

@Component
export struct HomeContent {
  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  @Builder
  IndustrialCard(title: string, content: string) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
        .width('100%')

      Text(content)
        .fontSize(13)
        .fontColor('#6B7280')
        .margin({ top: 8 })
        .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 12 })
  }

  build() {
    Scroll() {
      Column() {
        Text('Mesplus 工作台')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')

        Text('工业现场协同入口')
          .fontSize(14)
          .fontColor('#6B7280')
          .width('100%')
          .margin({ top: 6, bottom: 16 })

        MiniProgramSearch()

        this.IndustrialCard('今日生产', '产线运行平稳，关键设备待巡检 3 项')
        this.IndustrialCard('工单提醒', '待处理 5 条，已完成 18 条')
        this.IndustrialCard('异常跟进', '质量异常 1 条，安全异常 0 条')
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7F9')
  }
}
