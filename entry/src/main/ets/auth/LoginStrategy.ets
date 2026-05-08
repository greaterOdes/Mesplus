/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { LoginMode } from '../config/AppConstants';
import { Channel, LoginMethodConfig } from '../models/Channel';
import { ChannelUserInfoObject } from '../models/UserProfile';

/**
 * @since: 2026-04-30 23-51-09
 * @Author: @greaterOdes
 */
export interface LoginStrategy {
  /** 登录方式。 */
  mode: LoginMode;
  /** 执行主动登录。 */
  login(channel: Channel, method: LoginMethodConfig, input: ChannelUserInfoObject): Promise<ChannelUserInfoObject>;
  /** 执行自动登录续期。 */
  autoLogin(channel: Channel, method: LoginMethodConfig): Promise<ChannelUserInfoObject>;
  /** 判断当前配置是否支持自动登录。 */
  supportsAutoLogin(method: LoginMethodConfig): boolean;
}

export interface LoginStrategyExecutor {
  /** 执行登录请求。 */
  execute(channel: Channel, method: LoginMethodConfig, input?: ChannelUserInfoObject): Promise<ChannelUserInfoObject>;
}
