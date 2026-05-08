import { SessionStore } from '../app/SessionStore';
import { AuthService } from '../auth/AuthService';
import { ServiceType } from '../config/AppConstants';
import { Channel, LoginMethodConfig, ServiceMap } from '../models/Channel';
import { SessionCookie } from '../models/Session';
import { mergeSafeHeaders, RequestHeaders } from './HeaderGuard';
import { resolveServiceUrl } from './ServiceResolver';

export interface HttpClientOptions {
  headers?: RequestHeaders;
  timeoutMs?: number;
  skipAutoLogin?: boolean;
}

export interface HttpRequestRecord {
  method: string;
  url: string;
  headers: RequestHeaders;
  body: string;
  timeoutMs?: number;
}

export type RequestSender = (record: HttpRequestRecord) => Promise<string>;

export class HttpClient {
  private services: ServiceMap;
  private channel: Channel;
  private loginMethod: LoginMethodConfig;
  private sessionStore: SessionStore;
  private authService: AuthService;
  private sender: RequestSender;

  constructor(
    services: ServiceMap,
    channel: Channel,
    loginMethod: LoginMethodConfig,
    sessionStore: SessionStore,
    authService: AuthService,
    sender: RequestSender
  ) {
    this.services = services;
    this.channel = channel;
    this.loginMethod = loginMethod;
    this.sessionStore = sessionStore;
    this.authService = authService;
    this.sender = sender;
  }

  get(serviceType: ServiceType, apiPath: string, options?: HttpClientOptions): Promise<string> {
    return this.send('GET', serviceType, apiPath, '', options);
  }

  post(serviceType: ServiceType, apiPath: string, body: string, options?: HttpClientOptions): Promise<string> {
    return this.send('POST', serviceType, apiPath, body, options);
  }

  private async send(method: string, serviceType: ServiceType, apiPath: string, body: string, options?: HttpClientOptions): Promise<string> {
    if (options?.skipAutoLogin !== true) {
      const isFresh = await this.authService.ensureSessionFresh(this.channel, this.loginMethod, Date.now());
      if (!isFresh) {
        throw new Error('登录状态已过期，请重新登录');
      }
    }

    const latestSession = this.sessionStore.get(this.channel.id);
    const url = resolveServiceUrl(this.services, serviceType, apiPath);
    const headers = mergeSafeHeaders(options?.headers, this.joinCookies(latestSession?.cookies ?? []));
    return this.sender({ method, url, headers, body, timeoutMs: options?.timeoutMs });
  }

  private joinCookies(cookies: SessionCookie[]): string {
    const values: string[] = [];
    cookies.forEach((cookie: SessionCookie) => {
      if (cookie.value.length > 0) {
        values.push(cookie.value);
      }
    });
    return values.join('; ');
  }
}
