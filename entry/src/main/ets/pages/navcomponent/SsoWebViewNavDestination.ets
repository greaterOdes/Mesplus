import { SsoWebViewContent } from '../SsoWebViewPage';

@Component
export struct SsoWebViewNavDestination {
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  build() {
    NavDestination() {
      SsoWebViewContent()
    }
    .title('统一身份认证')
  }
}
