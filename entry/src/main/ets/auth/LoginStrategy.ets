import { LoginMode } from '../config/AppConstants';
import { Channel, LoginMethodConfig } from '../models/Channel';
import { ChannelUserInfoObject } from '../models/UserProfile';

export interface LoginStrategy {
  mode: LoginMode;
  login(channel: Channel, method: LoginMethodConfig, input: ChannelUserInfoObject): Promise<ChannelUserInfoObject>;
  autoLogin(channel: Channel, method: LoginMethodConfig): Promise<ChannelUserInfoObject>;
  supportsAutoLogin(method: LoginMethodConfig): boolean;
}

export interface LoginStrategyExecutor {
  execute(channel: Channel, method: LoginMethodConfig, input?: ChannelUserInfoObject): Promise<ChannelUserInfoObject>;
}
