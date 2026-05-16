/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { Session, SessionCookie } from '../models/Session';

/**
 * @since: 2026-04-30 23-51-09
 * @Author: @greaterOdes
 */
export interface SessionStore {
  /** 获取指定渠道的会话。 */
  get(channelId: string): Session | undefined;
  /** 保存会话。 */
  save(session: Session): void;
  /** 清除指定渠道的会话。 */
  clear(channelId: string): void;
  /** 当前会话匹配时清除会话。 */
  clearIfCurrent(expectedSession: Session): boolean;
  /** 当前会话匹配时更新 Cookie。 */
  updateCookiesIfCurrent(expectedSession: Session, cookies: SessionCookie[], lastAuthAt: number): Session | undefined;
}

export class InMemorySessionStore implements SessionStore {
  private sessions: Map<string, Session> = new Map<string, Session>();

  /** 获取指定渠道的会话。 */
  get(channelId: string): Session | undefined {
    return this.sessions.get(channelId);
  }

  /** 保存会话。 */
  save(session: Session): void {
    this.sessions.set(session.channelId, session);
  }

  /** 清除指定渠道的会话。 */
  clear(channelId: string): void {
    this.sessions.delete(channelId);
  }

  /** 当前会话匹配时清除会话。 */
  clearIfCurrent(expectedSession: Session): boolean {
    if (this.sessions.get(expectedSession.channelId) !== expectedSession) {
      return false;
    }
    this.sessions.delete(expectedSession.channelId);
    return true;
  }

  /** 当前会话匹配时更新 Cookie。 */
  updateCookiesIfCurrent(expectedSession: Session, cookies: SessionCookie[], lastAuthAt: number): Session | undefined {
    if (this.sessions.get(expectedSession.channelId) !== expectedSession) {
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
    this.sessions.set(expectedSession.channelId, updated);
    return updated;
  }
}
