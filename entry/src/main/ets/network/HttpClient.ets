/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { SessionStore } from '../app/SessionStore';
import { AuthService } from '../auth/AuthService';
import { ServiceType } from '../config/AppConstants';
import { Channel, LoginMethodConfig, ServiceMap } from '../models/Channel';
import { SessionCookie } from '../models/Session';
import { mergeSafeHeaders, RequestHeaders } from './HeaderGuard';
import { resolveServiceUrl } from './ServiceResolver';

/**
 * @since: 2026-05-01 00-21-18
 * @Author: @greaterOdes
 */
export interface HttpClientOptions {
  /** 自定义请求头。 */
  headers?: RequestHeaders;
  /** 请求超时时间。 */
  timeoutMs?: number;
  /** 是否跳过自动登录检查。 */
  skipAutoLogin?: boolean;
}

export interface HttpRequestRecord {
  /** HTTP 方法。 */
  method: string;
  /** 请求地址。 */
  url: string;
  /** 请求头。 */
  headers: RequestHeaders;
  /** 请求体。 */
  body: string;
  /** 请求超时时间。 */
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

  /** 发送 GET 请求。 */
  get(serviceType: ServiceType, apiPath: string, options?: HttpClientOptions): Promise<string> {
    return this.send('GET', serviceType, apiPath, '', options);
  }

  /** 发送 POST 请求。 */
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
