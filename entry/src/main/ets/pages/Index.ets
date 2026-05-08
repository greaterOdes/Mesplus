import { LoginNavDestination } from './navcomponent/LoginNavDestination';
import { MainHomeNavDestination } from './navcomponent/MainHomeNavDestination';
import { NavRouteName } from './navcomponent/NavRoutes';
import { SsoWebViewNavDestination } from './navcomponent/SsoWebViewNavDestination';

@Entry
@Component
struct Index {
  private pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  @Builder
  NavDestinationBuilder(name: string) {
    if (name === NavRouteName.MAIN_HOME) {
      MainHomeNavDestination({ pathStack: this.pathStack })
    } else if (name === NavRouteName.SSO_WEBVIEW) {
      SsoWebViewNavDestination({ pathStack: this.pathStack })
    }
  }

  build() {
    Navigation(this.pathStack) {
      LoginNavDestination({ pathStack: this.pathStack })
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .navDestination(this.NavDestinationBuilder)
  }
}
