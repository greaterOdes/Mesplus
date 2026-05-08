/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { MainContent } from '../MainPage';

/**
 * @since: 2026-05-08 21-35-32
 * @Author: @greaterOdes
 */
@Component
export struct MainHomeNavDestination {
  pathStack: NavPathStack = new NavPathStack();

  private logout(): void {
    this.pathStack.clear();
  }

  build() {
    NavDestination() {
      MainContent({
        onLogout: (): void => {
          this.logout();
        }
      })
    }
    .hideTitleBar(true)
  }
}
