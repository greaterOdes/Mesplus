import { describe, it, expect } from '@ohos/hypium';
import { HttpClient, HttpRequestRecord, RequestSender } from '../main/ets/network/HttpClient';
import { AuthService } from '../main/ets/auth/AuthService';
import { LoginStrategyRegistry } from '../main/ets/auth/LoginStrategyRegistry';
import { SessionStore } from '../main/ets/app/SessionStore';
import { GatewayMode, LoginMode, ServiceType } from '../main/ets/config/AppConstants';
import { Channel, LoginMethodConfig, ServiceMap } from '../main/ets/models/Channel';
import { Session, SessionCookie } from '../main/ets/models/Session';

const METHOD: LoginMethodConfig = {
  mode: LoginMode.PASSWORD,
  title: 'Password',
  credentialPolicy: 'rsa_encrypted_password',
  loginPath: '/login'
};

const SERVICES: ServiceMap = {
  auth: {
    type: ServiceType.AUTH,
    baseUrl: 'https://auth.example.com',
    gatewayMode: GatewayMode.MAG,
    magGateway: 'https://mag.example.com/auth',
    originalGateway: 'https://origin.example.com/auth'
  },
  business: {
    type: ServiceType.BUSINESS,
    baseUrl: 'https://business.example.com',
    gatewayMode: GatewayMode.ORIGINAL,
    magGateway: 'https://mag.example.com/business',
    originalGateway: 'https://origin.example.com/business'
  },
  sso: {
    type: ServiceType.SSO,
    baseUrl: 'https://sso.example.com',
    gatewayMode: GatewayMode.MAG,
    magGateway: 'https://mag.example.com/sso',
    originalGateway: 'https://origin.example.com/sso'
  },
  file: {
    type: ServiceType.FILE,
    baseUrl: 'https://file.example.com',
    gatewayMode: GatewayMode.ORIGINAL,
    magGateway: 'https://mag.example.com/file',
    originalGateway: 'https://origin.example.com/file'
  }
};

const CHANNEL: Channel = {
  id: 'default',
  name: 'Default',
  gatewayMode: GatewayMode.MAG,
  services: SERVICES,
  loginMethods: [METHOD],
  userMapping: [
    { source: 'user_id', target: 'userId' },
    { source: 'realName', target: 'userName' }
  ],
  cookieMapping: [
    { name: 'setCookie', target: 'SESSION' }
  ],
  autoLogin: {
    enabled: true,
    intervalMinutes: 28
  }
};

class FakeSessionStore implements SessionStore {
  session?: Session;

  get(channelId: string): Session | undefined {
    if (this.session !== undefined && this.session.channelId === channelId) {
      return this.session;
    }
    return undefined;
  }

  save(session: Session): void {
    this.session = session;
  }

  clear(_channelId: string): void {
    this.session = undefined;
  }

  clearIfCurrent(expectedSession: Session): boolean {
    if (this.session !== expectedSession) {
      return false;
    }
    this.session = undefined;
    return true;
  }

  updateCookiesIfCurrent(expectedSession: Session, cookies: SessionCookie[], lastAuthAt: number): Session | undefined {
    if (this.session !== expectedSession) {
      return undefined;
    }
    const updated: Session = {
      channelId: expectedSession.channelId,
      loginMode: expectedSession.loginMode,
      user: expectedSession.user,
      cookies,
      lastAuthAt,
      createdAt: expectedSession.createdAt
    };
    this.session = updated;
    return updated;
  }
}

class FakeAuthService extends AuthService {
  ensureCalls: number = 0;
  ensureResult: boolean = true;
  refreshStore?: FakeSessionStore;
  refreshedCookies?: SessionCookie[];

  constructor() {
    super(new FakeSessionStore(), new LoginStrategyRegistry());
  }

  ensureSessionFresh(_channel: Channel, _method: LoginMethodConfig, _now: number): Promise<boolean> {
    this.ensureCalls += 1;
    if (this.refreshStore !== undefined && this.refreshStore.session !== undefined && this.refreshedCookies !== undefined) {
      this.refreshStore.save(createSession(this.refreshedCookies));
    }
    return Promise.resolve(this.ensureResult);
  }
}

class RecordingSender {
  calls: number = 0;
  request?: HttpRequestRecord;
  response: string = 'ok';

  send(request: HttpRequestRecord): Promise<string> {
    this.calls += 1;
    this.request = request;
    return Promise.resolve(this.response);
  }
}

function createSession(cookies: SessionCookie[]): Session {
  return {
    channelId: CHANNEL.id,
    loginMode: METHOD.mode,
    user: {
      userId: 'u-1001',
      userName: 'Ada',
      rawChannelUserInfo: {}
    },
    cookies,
    lastAuthAt: 1714464000000,
    createdAt: 1714464000000
  };
}

function didRejectWithExpiredSession(client: HttpClient, sender: RecordingSender): Promise<boolean> {
  return client.get(ServiceType.BUSINESS, '/orders').then((): boolean => {
    return false;
  }).catch((error: Error): boolean => {
    return error.message === '登录状态已过期，请重新登录' && sender.calls === 0;
  });
}

export default function httpClientTest() {
  describe('HttpClient', () => {
    it('get ensures session freshness before sending and attaches Cookie', 0, async () => {
      const store = new FakeSessionStore();
      store.save(createSession([{ name: 'SESSION', value: 'sid=abc123' }]));
      const authService = new FakeAuthService();
      const sender = new RecordingSender();
      const client = new HttpClient(SERVICES, CHANNEL, METHOD, store, authService, sender.send.bind(sender) as RequestSender);

      const response = await client.get(ServiceType.BUSINESS, '/orders', { headers: { 'X-Trace-Id': 'trace-1001' }, timeoutMs: 5000 });

      expect(authService.ensureCalls).assertEqual(1);
      expect(sender.calls).assertEqual(1);
      expect(response).assertEqual('ok');
      expect(sender.request !== undefined).assertEqual(true);
      if (sender.request !== undefined) {
        expect(sender.request.method).assertEqual('GET');
        expect(sender.request.url).assertEqual('https://origin.example.com/business/orders');
        expect(sender.request.body).assertEqual('');
        expect(sender.request.headers['Cookie']).assertEqual('sid=abc123');
        expect(sender.request.headers['X-Trace-Id']).assertEqual('trace-1001');
        expect(sender.request.timeoutMs).assertEqual(5000);
      }
    });

    it('uses cookies refreshed by ensureSessionFresh', 0, async () => {
      const store = new FakeSessionStore();
      store.save(createSession([{ name: 'SESSION', value: 'sid=old' }]));
      const authService = new FakeAuthService();
      authService.refreshStore = store;
      authService.refreshedCookies = [{ name: 'SESSION', value: 'sid=refresh' }];
      const sender = new RecordingSender();
      const client = new HttpClient(SERVICES, CHANNEL, METHOD, store, authService, sender.send.bind(sender) as RequestSender);

      await client.get(ServiceType.BUSINESS, '/orders');

      expect(sender.request !== undefined).assertEqual(true);
      if (sender.request !== undefined) {
        expect(sender.request.headers['Cookie']).assertEqual('sid=refresh');
      }
    });

    it('skipAutoLogin does not ensure session freshness', 0, async () => {
      const store = new FakeSessionStore();
      store.save(createSession([{ name: 'SESSION', value: 'sid=abc123' }]));
      const authService = new FakeAuthService();
      const sender = new RecordingSender();
      const client = new HttpClient(SERVICES, CHANNEL, METHOD, store, authService, sender.send.bind(sender) as RequestSender);

      await client.post(ServiceType.AUTH, '/login', '{"account":"ada"}', { skipAutoLogin: true });

      expect(authService.ensureCalls).assertEqual(0);
      expect(sender.calls).assertEqual(1);
    });

    it('skipAutoLogin without session sends no Cookie', 0, async () => {
      const store = new FakeSessionStore();
      const authService = new FakeAuthService();
      const sender = new RecordingSender();
      const client = new HttpClient(SERVICES, CHANNEL, METHOD, store, authService, sender.send.bind(sender) as RequestSender);

      await client.post(ServiceType.AUTH, '/login', '{"account":"ada"}', { skipAutoLogin: true });

      expect(authService.ensureCalls).assertEqual(0);
      expect(sender.request !== undefined).assertEqual(true);
      if (sender.request !== undefined) {
        expect(Object.keys(sender.request.headers).indexOf('Cookie')).assertEqual(-1);
      }
    });

    it('does not send when session freshness fails', 0, async () => {
      const store = new FakeSessionStore();
      const authService = new FakeAuthService();
      authService.ensureResult = false;
      const sender = new RecordingSender();
      const client = new HttpClient(SERVICES, CHANNEL, METHOD, store, authService, sender.send.bind(sender) as RequestSender);

      const rejected = await didRejectWithExpiredSession(client, sender);

      expect(rejected).assertEqual(true);
      expect(authService.ensureCalls).assertEqual(1);
      expect(sender.calls).assertEqual(0);
    });
  });
}
