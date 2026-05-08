import { LoginMode } from '../config/AppConstants';
import { UserProfile } from './UserProfile';

export interface SessionCookie {
  name: string;
  value: string;
}

export interface Session {
  channelId: string;
  loginMode: LoginMode;
  user: UserProfile;
  cookies: SessionCookie[];
  lastAuthAt: number;
  createdAt: number;
}
