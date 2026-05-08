import { LoginContent } from '../LoginPage';
import { NavRouteName } from './NavRoutes';

@Component
export struct LoginNavDestination {
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  private goToMainHome(): void {
    this.pathStack.clear();
    this.pathStack.pushPathByName(NavRouteName.MAIN_HOME, null);
  }

  private goToSsoWebView(): void {
    this.pathStack.pushPathByName(NavRouteName.SSO_WEBVIEW, null);
  }

  build() {
    NavDestination() {
      LoginContent({
        onLoginSuccess: (): void => {
          this.goToMainHome();
        },
        onSsoLogin: (): void => {
          this.goToSsoWebView();
        }
      })
    }
    .hideTitleBar(true)
  }
}
