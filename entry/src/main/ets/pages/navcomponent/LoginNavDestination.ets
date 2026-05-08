/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { LoginContent } from '../LoginPage';
import { NavRouteName } from './NavRoutes';

/**
 * @since: 2026-05-08 21-35-32
 * @Author: @greaterOdes
 */
@Component
export struct LoginNavDestination {
  pathStack: NavPathStack = new NavPathStack();

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
