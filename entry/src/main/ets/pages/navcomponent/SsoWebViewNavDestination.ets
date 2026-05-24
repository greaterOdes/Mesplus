/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { SsoWebViewContent } from '../SsoWebViewPage';

/**
 * @since: 2026-05-08 21-35-32
 * @Author: @greaterOdes
 */
@Component
export struct SsoWebViewNavDestination {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      SsoWebViewContent()
    }
    .title('IDASS')
  }
}
