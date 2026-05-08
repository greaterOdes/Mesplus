import { WechatTabBar } from '../components/WechatTabBar';
import { ContactsContent } from './ContactsPage';
import { HomeContent } from './HomePage';
import { ProfileContent } from './ProfilePage';
import { WorkLogContent } from './WorkLogPage';

@Component
export struct MainContent {
  @State currentIndex: number = 0;

  onLogout: () => void = (): void => {};

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  @Builder
  CurrentPage() {
    if (this.currentIndex === 0) {
      HomeContent()
    } else if (this.currentIndex === 1) {
      ContactsContent()
    } else if (this.currentIndex === 2) {
      WorkLogContent()
    } else {
      ProfileContent({ onLogout: this.onLogout })
    }
  }

  build() {
    RelativeContainer() {
      Column() {
        this.CurrentPage()
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 64 })
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
      })

      WechatTabBar({ currentIndex: $currentIndex })
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7F9')
  }
}
