import { describe, it, expect } from '@ohos/hypium';
import { AuthService } from '../main/ets/auth/AuthService';
import { LoginStrategy } from '../main/ets/auth/LoginStrategy';
import { LoginStrategyRegistry } from '../main/ets/auth/LoginStrategyRegistry';
import { InMemorySessionStore } from '../main/ets/app/SessionStore';
import { GatewayMode, LoginMode, ServiceType } from '../main/ets/config/AppConstants';
import { Channel, LoginMethodConfig } from '../main/ets/models/Channel';
import { ChannelUserInfoObject } from '../main/ets/models/UserProfile';

const NOW: number = 1714464000000;

const METHOD: LoginMethodConfig = {
  mode: LoginMode.PASSWORD,
  title: 'Password',
  credentialPolicy: 'rsa_encrypted_password',
  loginPath: '/login',
  autoLoginPath: '/auto-login'
};

const SSO_METHOD: LoginMethodConfig = {
  mode: LoginMode.SSO,
  title: 'SSO',
  credentialPolicy: 'sso_renewal_credential',
  loginPath: '/sso/login',
  renewalPath: '/sso/renewal'
};

const CHANNEL: Channel = {
  id: 'default',
  name: 'Default',
  gatewayMode: GatewayMode.MAG,
  services: {
    auth: {
      type: ServiceType.AUTH,
      baseUrl: 'https://auth.example.com',
      magGateway: 'https://mag.example.com/auth',
      originalGateway: 'https://origin.example.com/auth',
      gatewayMode: GatewayMode.MAG
    },
    business: {
      type: ServiceType.BUSINESS,
      baseUrl: 'https://business.example.com',
      magGateway: 'https://mag.example.com/business',
      originalGateway: 'https://origin.example.com/business',
      gatewayMode: GatewayMode.ORIGINAL
    },
    sso: {
      type: ServiceType.SSO,
      baseUrl: 'https://sso.example.com',
      magGateway: 'https://mag.example.com/sso',
      originalGateway: 'https://origin.example.com/sso',
      gatewayMode: GatewayMode.MAG
    },
    file: {
      type: ServiceType.FILE,
      baseUrl: 'https://file.example.com',
      magGateway: 'https://mag.example.com/file',
      originalGateway: 'https://origin.example.com/file',
      gatewayMode: GatewayMode.ORIGINAL
    }
  },
  userMapping: [
    { source: 'user_id', target: 'userId' },
    { source: 'realName', target: 'userName' }
  ],
  cookieMapping: [
    { name: 'setCookie', target: 'SESSION' }
  ],
  loginMethods: [METHOD],
  autoLogin: {
    enabled: true,
    intervalMinutes: 28
  }
};

class RecordingStrategy implements LoginStrategy {
  mode: LoginMode = LoginMode.PASSWORD;
  loginCalls: number = 0;
  autoLoginCalls: number = 0;
  failAutoLogin: boolean = false;
  loginCookie: string = 'sid=login';
  autoLoginCookie: string = 'sid=refresh';
  userIdSource: string = 'user_id';
  userNameSource: string = 'realName';
  cookieSource: string = 'setCookie';
  clearSessionStoreOnAutoLogin?: InMemorySessionStore;

  login(_channel: Channel, _method: LoginMethodConfig, _input: ChannelUserInfoObject): Promise<ChannelUserInfoObject> {
    this.loginCalls += 1;
    const raw: ChannelUserInfoObject = {};
    raw[this.userIdSource] = 'u-1001';
    raw[this.userNameSource] = 'Ada Wong';
    raw[this.cookieSource] = this.loginCookie;
    return Promise.resolve(raw);
  }

  autoLogin(_channel: Channel, _method: LoginMethodConfig): Promise<ChannelUserInfoObject> {
    this.autoLoginCalls += 1;
    if (this.failAutoLogin) {
      return Promise.reject(new Error('refresh failed'));
    }
    if (this.clearSessionStoreOnAutoLogin !== undefined) {
      this.clearSessionStoreOnAutoLogin.clear(CHANNEL.id);
    }
    const raw: ChannelUserInfoObject = {};
    raw[this.userIdSource] = 'u-1001';
    raw[this.userNameSource] = 'Ada Wong';
    raw[this.cookieSource] = this.autoLoginCookie;
    return Promise.resolve(raw);
  }

  supportsAutoLogin(_method: LoginMethodConfig): boolean {
    return true;
  }
}

class DeferredLoginResult {
  promise: Promise<ChannelUserInfoObject>;
  private resolver?: (value: ChannelUserInfoObject) => void;
  private rejecter?: (reason: Error) => void;

  constructor() {
    this.promise = new Promise<ChannelUserInfoObject>((resolve: (value: ChannelUserInfoObject) => void, reject: (reason: Error) => void) => {
      this.resolver = resolve;
      this.rejecter = reject;
    });
  }

  resolve(value: ChannelUserInfoObject): void {
    if (this.resolver !== undefined) {
      this.resolver(value);
    }
  }

  reject(error: Error): void {
    if (this.rejecter !== undefined) {
      this.rejecter(error);
    }
  }
}

class DeferredRecordingStrategy extends RecordingStrategy {
  deferred: DeferredLoginResult = new DeferredLoginResult();

  autoLogin(_channel: Channel, _method: LoginMethodConfig): Promise<ChannelUserInfoObject> {
    this.autoLoginCalls += 1;
    return this.deferred.promise;
  }
}

function createService(strategy: RecordingStrategy, store: InMemorySessionStore): AuthService {
  const registry = new LoginStrategyRegistry();
  registry.register(strategy);
  return new AuthService(store, registry);
}

export default function authServiceTest() {
  describe('AuthService', () => {
    it('login saves normalized session', 0, async () => {
      const strategy = new RecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);

      const session = await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      const saved = store.get(CHANNEL.id);

      expect(strategy.loginCalls).assertEqual(1);
      expect(session.user.userId).assertEqual('u-1001');
      expect(session.user.userName).assertEqual('Ada Wong');
      expect(session.cookies[0].value).assertEqual('sid=login');
      expect(session.lastAuthAt).assertEqual(NOW);
      expect(saved !== undefined).assertEqual(true);
      if (saved !== undefined) {
        expect(saved.cookies[0].value).assertEqual('sid=login');
      }
    });

    it('login normalizes rawfile-shaped channel mapping fields and cookies', 0, async () => {
      const strategy = new RecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);
      const channel: Channel = {
        id: CHANNEL.id,
        name: CHANNEL.name,
        gatewayMode: CHANNEL.gatewayMode,
        services: CHANNEL.services,
        loginMethods: CHANNEL.loginMethods,
        userMapping: [
          { source: 'empNo', target: 'userId' },
          { source: 'displayName', target: 'userName' }
        ],
        cookieMapping: [
          { name: 'accessToken', target: 'ACCESS_TOKEN' }
        ],
        autoLogin: CHANNEL.autoLogin
      };
      strategy.userIdSource = 'empNo';
      strategy.userNameSource = 'displayName';
      strategy.cookieSource = 'accessToken';

      const session = await service.login(channel, METHOD, { account: 'ada' }, NOW);

      expect(session.user.userId).assertEqual('u-1001');
      expect(session.user.userName).assertEqual('Ada Wong');
      expect(session.cookies[0].name).assertEqual('ACCESS_TOKEN');
      expect(session.cookies[0].value).assertEqual('sid=login');
    });

    it('does not refresh within 28 minutes', 0, async () => {
      const strategy = new RecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);

      await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      const fresh = await service.ensureSessionFresh(CHANNEL, METHOD, NOW + 27 * 60 * 1000);

      expect(fresh).assertEqual(true);
      expect(strategy.autoLoginCalls).assertEqual(0);
      const saved = store.get(CHANNEL.id);
      expect(saved !== undefined).assertEqual(true);
      if (saved !== undefined) {
        expect(saved.cookies[0].value).assertEqual('sid=login');
      }
    });

    it('refreshes after 28 minutes and updates cookies and lastAuthAt', 0, async () => {
      const strategy = new RecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);
      const refreshAt = NOW + 29 * 60 * 1000;

      await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      const fresh = await service.ensureSessionFresh(CHANNEL, METHOD, refreshAt);
      const saved = store.get(CHANNEL.id);

      expect(fresh).assertEqual(true);
      expect(strategy.autoLoginCalls).assertEqual(1);
      expect(saved !== undefined).assertEqual(true);
      if (saved !== undefined) {
        expect(saved.cookies[0].value).assertEqual('sid=refresh');
        expect(saved.lastAuthAt).assertEqual(refreshAt);
        expect(saved.createdAt).assertEqual(NOW);
      }
    });

    it('clears session and returns false when auto login fails', 0, async () => {
      const strategy = new RecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);

      await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      strategy.failAutoLogin = true;
      const fresh = await service.ensureSessionFresh(CHANNEL, METHOD, NOW + 29 * 60 * 1000);

      expect(fresh).assertEqual(false);
      expect(store.get(CHANNEL.id) === undefined).assertEqual(true);
    });

    it('clears expired session without calling strategy when auto login is disabled', 0, async () => {
      const strategy = new RecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);
      const channel: Channel = {
        id: CHANNEL.id,
        name: CHANNEL.name,
        gatewayMode: CHANNEL.gatewayMode,
        services: CHANNEL.services,
        loginMethods: CHANNEL.loginMethods,
        userMapping: CHANNEL.userMapping,
        cookieMapping: CHANNEL.cookieMapping,
        autoLogin: {
          enabled: false,
          intervalMinutes: CHANNEL.autoLogin.intervalMinutes
        }
      };

      await service.login(channel, METHOD, { account: 'ada' }, NOW);
      const fresh = await service.ensureSessionFresh(channel, METHOD, NOW + 29 * 60 * 1000);

      expect(fresh).assertEqual(false);
      expect(strategy.autoLoginCalls).assertEqual(0);
      expect(store.get(channel.id) === undefined).assertEqual(true);
    });

    it('clears session without calling strategy when session login mode differs from method', 0, async () => {
      const passwordStrategy = new RecordingStrategy();
      const ssoStrategy = new RecordingStrategy();
      ssoStrategy.mode = LoginMode.SSO;
      const store = new InMemorySessionStore();
      const registry = new LoginStrategyRegistry();
      registry.register(passwordStrategy);
      registry.register(ssoStrategy);
      const service = new AuthService(store, registry);

      await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      const fresh = await service.ensureSessionFresh(CHANNEL, SSO_METHOD, NOW + 29 * 60 * 1000);

      expect(fresh).assertEqual(false);
      expect(store.get(CHANNEL.id) === undefined).assertEqual(true);
      expect(passwordStrategy.autoLoginCalls).assertEqual(0);
      expect(ssoStrategy.autoLoginCalls).assertEqual(0);
    });

    it('shares one refresh for concurrent same channel and method calls', 0, async () => {
      const strategy = new DeferredRecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);
      const refreshAt = NOW + 29 * 60 * 1000;

      await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      const first = service.ensureSessionFresh(CHANNEL, METHOD, refreshAt);
      expect(strategy.autoLoginCalls).assertEqual(1);
      const second = service.ensureSessionFresh(CHANNEL, METHOD, refreshAt);
      strategy.deferred.resolve({
        user_id: 'u-1001',
        realName: 'Ada Wong',
        setCookie: strategy.autoLoginCookie
      });
      const firstResult = await first;
      const secondResult = await second;

      expect(firstResult).assertEqual(true);
      expect(secondResult).assertEqual(true);
      expect(strategy.autoLoginCalls).assertEqual(1);
    });

    it('does not let stale refresh overwrite a newer same-channel same-createdAt session', 0, async () => {
      const strategy = new DeferredRecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);
      const refreshAt = NOW + 29 * 60 * 1000;

      await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      const refresh = service.ensureSessionFresh(CHANNEL, METHOD, refreshAt);
      expect(strategy.autoLoginCalls).assertEqual(1);
      store.save({
        channelId: CHANNEL.id,
        loginMode: LoginMode.PASSWORD,
        user: {
          userId: 'u-2002',
          userName: 'Leon Kennedy',
          rawChannelUserInfo: {}
        },
        cookies: [
          { name: 'SESSION', value: 'sid=new-login' }
        ],
        lastAuthAt: refreshAt,
        createdAt: NOW
      });
      strategy.deferred.resolve({
        user_id: 'u-1001',
        realName: 'Ada Wong',
        setCookie: 'sid=old-refresh'
      });

      const fresh = await refresh;
      const saved = store.get(CHANNEL.id);

      expect(fresh).assertEqual(false);
      expect(saved !== undefined).assertEqual(true);
      if (saved !== undefined) {
        expect(saved.cookies[0].value).assertEqual('sid=new-login');
        expect(saved.createdAt).assertEqual(NOW);
      }
    });

    it('does not let stale failed refresh clear a newer same-channel same-createdAt session', 0, async () => {
      const strategy = new DeferredRecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);
      const refreshAt = NOW + 29 * 60 * 1000;

      await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      const refresh = service.ensureSessionFresh(CHANNEL, METHOD, refreshAt);
      expect(strategy.autoLoginCalls).assertEqual(1);
      store.save({
        channelId: CHANNEL.id,
        loginMode: LoginMode.PASSWORD,
        user: {
          userId: 'u-2002',
          userName: 'Leon Kennedy',
          rawChannelUserInfo: {}
        },
        cookies: [
          { name: 'SESSION', value: 'sid=new-login' }
        ],
        lastAuthAt: refreshAt,
        createdAt: NOW
      });
      strategy.deferred.reject(new Error('old refresh failed'));

      const fresh = await refresh;
      const saved = store.get(CHANNEL.id);

      expect(fresh).assertEqual(false);
      expect(saved !== undefined).assertEqual(true);
      if (saved !== undefined) {
        expect(saved.loginMode).assertEqual(LoginMode.PASSWORD);
        expect(saved.cookies[0].value).assertEqual('sid=new-login');
        expect(saved.createdAt).assertEqual(NOW);
      }
    });

    it('returns false when session is cleared before refreshed cookies are saved', 0, async () => {
      const strategy = new RecordingStrategy();
      const store = new InMemorySessionStore();
      const service = createService(strategy, store);

      await service.login(CHANNEL, METHOD, { account: 'ada' }, NOW);
      strategy.clearSessionStoreOnAutoLogin = store;
      const fresh = await service.ensureSessionFresh(CHANNEL, METHOD, NOW + 29 * 60 * 1000);

      expect(fresh).assertEqual(false);
      expect(strategy.autoLoginCalls).assertEqual(1);
      expect(store.get(CHANNEL.id) === undefined).assertEqual(true);
    });
  });
}
