/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { LoginMode } from '../config/AppConstants';
import { LoginStrategy } from './LoginStrategy';

/**
 * @since: 2026-04-30 23-51-09
 * @Author: @greaterOdes
 */
export class LoginStrategyRegistry {
  private strategies: Map<LoginMode, LoginStrategy> = new Map<LoginMode, LoginStrategy>();

  /** 注册登录策略。 */
  register(strategy: LoginStrategy): void {
    this.strategies.set(strategy.mode, strategy);
  }

  /** 按登录方式获取登录策略。 */
  get(mode: LoginMode): LoginStrategy {
    const strategy = this.strategies.get(mode);
    if (strategy === undefined) {
      throw new Error(`login strategy for mode ${mode} is missing`);
    }
    return strategy;
  }
}
