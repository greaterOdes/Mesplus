@Component
export struct WechatTabBar {
  @Link currentIndex: number;

  tabTitle(index: number): string {
    if (index === 0) {
      return '首页';
    }
    if (index === 1) {
      return '通讯录';
    }
    if (index === 2) {
      return '日志';
    }
    return '我';
  }

  tabIcon(index: number): string {
    if (index === 0) {
      return '首';
    }
    if (index === 1) {
      return '录';
    }
    if (index === 2) {
      return '志';
    }
    return '我';
  }

  @Builder
  TabItem(index: number) {
    Column() {
      Text(this.tabIcon(index))
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === index ? '#07C160' : '#666666')
        .width(28)
        .height(24)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.currentIndex === index ? '#E8F8EF' : '#FFFFFF')
        .borderRadius(12)

      Text(this.tabTitle(index))
        .fontSize(11)
        .fontColor(this.currentIndex === index ? '#07C160' : '#666666')
        .margin({ top: 3 })
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
    })
  }

  build() {
    Row() {
      this.TabItem(0)
      this.TabItem(1)
      this.TabItem(2)
      this.TabItem(3)
    }
    .width('100%')
    .height(64)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E5E7EB' })
  }
}
