/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { LoginMode } from '../config/AppConstants';
import { Channel, LoginMethodConfig } from '../models/Channel';
import { ChannelUserInfoObject } from '../models/UserProfile';
import { LoginStrategy, LoginStrategyExecutor } from './LoginStrategy';

/**
 * @since: 2026-04-30 23-51-09
 * @Author: @greaterOdes
 */
export class SsoWebViewLoginStrategy implements LoginStrategy {
  mode: LoginMode = LoginMode.SSO;
  private executor: LoginStrategyExecutor;

  constructor(executor: LoginStrategyExecutor) {
    this.executor = executor;
  }

  /** 使用 SSO 回调数据执行登录。 */
  login(channel: Channel, method: LoginMethodConfig, input: ChannelUserInfoObject): Promise<ChannelUserInfoObject> {
    return this.executor.execute(channel, method, input);
  }

  /** 使用 SSO 续期凭据执行自动登录。 */
  autoLogin(channel: Channel, method: LoginMethodConfig): Promise<ChannelUserInfoObject> {
    return this.executor.execute(channel, method);
  }

  /** 判断 SSO 登录是否支持自动登录。 */
  supportsAutoLogin(method: LoginMethodConfig): boolean {
    return method.renewalPath !== undefined && method.renewalPath.length > 0 && method.credentialPolicy === 'sso_renewal_credential';
  }
}
