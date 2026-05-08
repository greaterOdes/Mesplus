/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { SessionStore } from '../app/SessionStore';
import { Channel, CookieMapping, FieldMapping, LoginMethodConfig } from '../models/Channel';
import { Session } from '../models/Session';
import { ChannelUserInfoObject } from '../models/UserProfile';
import { normalizeLoginResult } from './UserNormalizer';
import { LoginStrategyRegistry } from './LoginStrategyRegistry';

/**
 * @since: 2026-04-30 23-51-09
 * @Author: @greaterOdes
 */
export class AuthService {
  private refreshPromises: Map<string, Promise<boolean>> = new Map<string, Promise<boolean>>();
  private sessionStore: SessionStore;
  private registry: LoginStrategyRegistry;

  constructor(sessionStore: SessionStore, registry: LoginStrategyRegistry) {
    this.sessionStore = sessionStore;
    this.registry = registry;
  }

  async login(channel: Channel, method: LoginMethodConfig, input: ChannelUserInfoObject, now: number): Promise<Session> {
    const strategy = this.registry.get(method.mode);
    const raw = await strategy.login(channel, method, input);
    const session = normalizeLoginResult(
      channel.id,
      method.mode,
      raw,
      this.getUserMappings(channel),
      this.getCookieMappings(channel),
      now
    );
    this.sessionStore.save(session);
    return session;
  }

  async ensureSessionFresh(channel: Channel, method: LoginMethodConfig, now: number): Promise<boolean> {
    const session = this.sessionStore.get(channel.id);
    if (session === undefined) {
      return false;
    }
    if (session.channelId !== channel.id || session.loginMode !== method.mode) {
      this.sessionStore.clear(channel.id);
      return false;
    }
    if (now - session.lastAuthAt <= channel.autoLogin.intervalMinutes * 60 * 1000) {
      return true;
    }
    if (!channel.autoLogin.enabled) {
      this.sessionStore.clear(channel.id);
      return false;
    }
    const refreshKey = this.createRefreshKey(channel, method);
    const existingRefresh = this.refreshPromises.get(refreshKey);
    if (existingRefresh !== undefined) {
      return existingRefresh;
    }
    const refresh = this.refreshSession(channel, method, session, now);
    this.refreshPromises.set(refreshKey, refresh);
    try {
      return await refresh;
    } finally {
      this.refreshPromises.delete(refreshKey);
    }
  }

  private async refreshSession(channel: Channel, method: LoginMethodConfig, refreshSession: Session, now: number): Promise<boolean> {
    try {
      const strategy = this.registry.get(method.mode);
      if (!strategy.supportsAutoLogin(method)) {
        this.clearRefreshSession(refreshSession);
        return false;
      }

      const raw = await strategy.autoLogin(channel, method);
      // First version expects auto-login renewal to return a full normalizable login result.
      // If a backend later returns cookies only, split that into a cookie-only renewal path.
      const refreshed = normalizeLoginResult(
        channel.id,
        method.mode,
        raw,
        this.getUserMappings(channel),
        this.getCookieMappings(channel),
        now
      );
      return this.sessionStore.updateCookiesIfCurrent(refreshSession, refreshed.cookies, now) !== undefined;
    } catch (error) {
      this.clearRefreshSession(refreshSession);
      return false;
    }
  }

  private clearRefreshSession(session: Session): boolean {
    return this.sessionStore.clearIfCurrent(session);
  }

  private createRefreshKey(channel: Channel, method: LoginMethodConfig): string {
    return `${channel.id}:${method.mode}`;
  }

  private getUserMappings(channel: Channel): FieldMapping[] {
    return channel.userMapping;
  }

  private getCookieMappings(channel: Channel): CookieMapping[] {
    return channel.cookieMapping;
  }
}
