@Component
export struct ContactsContent {
  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  @Builder
  ContactRow(name: string, role: string) {
    Row() {
      Text(name.substring(0, 1))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#07C160')
        .width(38)
        .height(38)
        .textAlign(TextAlign.Center)
        .backgroundColor('#E8F8EF')
        .borderRadius(19)

      Column() {
        Text(name)
          .fontSize(16)
          .fontColor('#111827')

        Text(role)
          .fontSize(13)
          .fontColor('#6B7280')
          .margin({ top: 3 })
      }
      .margin({ left: 12 })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  build() {
    Scroll() {
      Column() {
        Text('通讯录')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')

        Text('组织 部门 人员')
          .fontSize(14)
          .fontColor('#6B7280')
          .width('100%')
          .margin({ top: 6, bottom: 18 })

        Column() {
          Text('制造中心')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
            .width('100%')

          this.ContactRow('张工', '设备部 主管')
          this.ContactRow('李工', '生产一部 班长')
          this.ContactRow('王工', '质量部 工程师')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)

        Column() {
          Text('仓储物流')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
            .width('100%')

          this.ContactRow('赵工', '仓储部 调度')
          this.ContactRow('陈工', '物流部 现场协调')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .margin({ top: 14 })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7F9')
  }
}
