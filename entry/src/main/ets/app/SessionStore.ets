import { Session, SessionCookie } from '../models/Session';

export interface SessionStore {
  get(channelId: string): Session | undefined;
  save(session: Session): void;
  clear(channelId: string): void;
  clearIfCurrent(expectedSession: Session): boolean;
  updateCookiesIfCurrent(expectedSession: Session, cookies: SessionCookie[], lastAuthAt: number): Session | undefined;
}

export class InMemorySessionStore implements SessionStore {
  private sessions: Map<string, Session> = new Map<string, Session>();

  get(channelId: string): Session | undefined {
    return this.sessions.get(channelId);
  }

  save(session: Session): void {
    this.sessions.set(session.channelId, session);
  }

  clear(channelId: string): void {
    this.sessions.delete(channelId);
  }

  clearIfCurrent(expectedSession: Session): boolean {
    if (this.sessions.get(expectedSession.channelId) !== expectedSession) {
      return false;
    }
    this.sessions.delete(expectedSession.channelId);
    return true;
  }

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
