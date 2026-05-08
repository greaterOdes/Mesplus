import { describe, it, expect } from '@ohos/hypium';
import { LoginMode } from '../main/ets/config/AppConstants';
import { Channel, LoginMethodConfig } from '../main/ets/models/Channel';
import { ChannelUserInfoObject } from '../main/ets/models/UserProfile';
import { LoginStrategy } from '../main/ets/auth/LoginStrategy';
import { LoginStrategyRegistry } from '../main/ets/auth/LoginStrategyRegistry';
import { PasswordOnlyLoginStrategy } from '../main/ets/auth/PasswordOnlyLoginStrategy';
import { PasswordSmsFirstDeviceLoginStrategy } from '../main/ets/auth/PasswordSmsFirstDeviceLoginStrategy';
import { SsoWebViewLoginStrategy } from '../main/ets/auth/SsoWebViewLoginStrategy';

class StubStrategy implements LoginStrategy {
  mode: LoginMode = LoginMode.PASSWORD;

  login(_channel: Channel, _method: LoginMethodConfig, _input: ChannelUserInfoObject): Promise<ChannelUserInfoObject> {
    return Promise.resolve({ user_id: 'u-1001' });
  }

  autoLogin(_channel: Channel, _method: LoginMethodConfig): Promise<ChannelUserInfoObject> {
    return Promise.resolve({ user_id: 'u-1001' });
  }

  supportsAutoLogin(_method: LoginMethodConfig): boolean {
    return true;
  }
}

class StubExecutor {
  execute(_channel: Channel, _method: LoginMethodConfig, _input?: ChannelUserInfoObject): Promise<ChannelUserInfoObject> {
    return Promise.resolve({ user_id: 'u-1001' });
  }
}

function didGetThrow(registry: LoginStrategyRegistry, mode: LoginMode): boolean {
  try {
    registry.get(mode);
  } catch (error) {
    return true;
  }
  return false;
}

export default function loginStrategyRegistryTest() {
  describe('LoginStrategyRegistry', () => {
    it('registers and finds strategy by mode', 0, () => {
      const registry = new LoginStrategyRegistry();
      const strategy = new StubStrategy();

      registry.register(strategy);

      expect(registry.get(LoginMode.PASSWORD)).assertEqual(strategy);
    });

    it('throws when strategy is missing', 0, () => {
      const registry = new LoginStrategyRegistry();

      expect(didGetThrow(registry, LoginMode.SSO)).assertEqual(true);
    });

    it('supports password auto login only for RSA encrypted password policy and path', 0, () => {
      const strategy = new PasswordOnlyLoginStrategy(new StubExecutor());
      const method: LoginMethodConfig = {
        mode: LoginMode.PASSWORD,
        title: 'Password',
        credentialPolicy: 'rsa_encrypted_password',
        loginPath: '/login',
        autoLoginPath: '/auto-login'
      };
      const missingPath: LoginMethodConfig = {
        mode: LoginMode.PASSWORD,
        title: 'Password',
        credentialPolicy: 'rsa_encrypted_password',
        loginPath: '/login'
      };
      const wrongPolicy: LoginMethodConfig = {
        mode: LoginMode.PASSWORD,
        title: 'Password',
        credentialPolicy: 'password',
        loginPath: '/login',
        autoLoginPath: '/auto-login'
      };

      expect(strategy.supportsAutoLogin(method)).assertEqual(true);
      expect(strategy.supportsAutoLogin(missingPath)).assertEqual(false);
      expect(strategy.supportsAutoLogin(wrongPolicy)).assertEqual(false);
    });

    it('supports password sms first device auto login only for RSA encrypted password policy and path', 0, () => {
      const strategy = new PasswordSmsFirstDeviceLoginStrategy(new StubExecutor());
      const method: LoginMethodConfig = {
        mode: LoginMode.SMS,
        title: 'SMS',
        credentialPolicy: 'rsa_encrypted_password',
        loginPath: '/login',
        smsVerifyPath: '/sms/verify',
        autoLoginPath: '/auto-login'
      };
      const missingPath: LoginMethodConfig = {
        mode: LoginMode.SMS,
        title: 'SMS',
        credentialPolicy: 'rsa_encrypted_password',
        loginPath: '/login',
        smsVerifyPath: '/sms/verify'
      };
      const wrongPolicy: LoginMethodConfig = {
        mode: LoginMode.SMS,
        title: 'SMS',
        credentialPolicy: 'sms_ticket',
        loginPath: '/login',
        smsVerifyPath: '/sms/verify',
        autoLoginPath: '/auto-login'
      };

      expect(strategy.supportsAutoLogin(method)).assertEqual(true);
      expect(strategy.supportsAutoLogin(missingPath)).assertEqual(false);
      expect(strategy.supportsAutoLogin(wrongPolicy)).assertEqual(false);
    });

    it('supports SSO auto login only for renewal credential policy and path', 0, () => {
      const strategy = new SsoWebViewLoginStrategy(new StubExecutor());
      const method: LoginMethodConfig = {
        mode: LoginMode.SSO,
        title: 'SSO',
        credentialPolicy: 'sso_renewal_credential',
        loginPath: '/sso/login',
        renewalPath: '/sso/renewal'
      };
      const missingPath: LoginMethodConfig = {
        mode: LoginMode.SSO,
        title: 'SSO',
        credentialPolicy: 'sso_renewal_credential',
        loginPath: '/sso/login'
      };
      const wrongPolicy: LoginMethodConfig = {
        mode: LoginMode.SSO,
        title: 'SSO',
        credentialPolicy: 'ticket',
        loginPath: '/sso/login',
        renewalPath: '/sso/renewal'
      };

      expect(strategy.supportsAutoLogin(method)).assertEqual(true);
      expect(strategy.supportsAutoLogin(missingPath)).assertEqual(false);
      expect(strategy.supportsAutoLogin(wrongPolicy)).assertEqual(false);
    });
  });
}
