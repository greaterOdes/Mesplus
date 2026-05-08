import { Channel } from '../models/Channel';
import { Session } from '../models/Session';

export class AppState {
  channels: Channel[] = [];
  currentChannel?: Channel = undefined;
  currentSession?: Session = undefined;

  get isLoggedIn(): boolean {
    return this.currentSession !== undefined && this.currentSession.cookies.length > 0;
  }
}

export const appState: AppState = new AppState();
