import { LoginMode } from '../config/AppConstants';
import { Channel, LoginMethodConfig } from '../models/Channel';
import { ChannelUserInfoObject } from '../models/UserProfile';
import { LoginStrategy, LoginStrategyExecutor } from './LoginStrategy';

export class PasswordSmsFirstDeviceLoginStrategy implements LoginStrategy {
  mode: LoginMode = LoginMode.SMS;
  private executor: LoginStrategyExecutor;

  constructor(executor: LoginStrategyExecutor) {
    this.executor = executor;
  }

  login(channel: Channel, method: LoginMethodConfig, input: ChannelUserInfoObject): Promise<ChannelUserInfoObject> {
    return this.executor.execute(channel, method, input);
  }

  autoLogin(channel: Channel, method: LoginMethodConfig): Promise<ChannelUserInfoObject> {
    return this.executor.execute(channel, method);
  }

  supportsAutoLogin(method: LoginMethodConfig): boolean {
    return method.autoLoginPath !== undefined && method.autoLoginPath.length > 0 && method.credentialPolicy === 'rsa_encrypted_password';
  }
}
