import { describe, it, expect } from '@ohos/hypium';
import { AppState, appState } from '../main/ets/app/AppState';
import { LoginMode } from '../main/ets/config/AppConstants';
import { Session } from '../main/ets/models/Session';

const SESSION_WITHOUT_COOKIES: Session = {
  channelId: 'default',
  loginMode: LoginMode.PASSWORD,
  user: {
    userId: 'u-1001',
    userName: 'Ada Wong',
    rawChannelUserInfo: {}
  },
  cookies: [],
  lastAuthAt: 1714464000000,
  createdAt: 1714464000000
};

const SESSION_WITH_COOKIES: Session = {
  channelId: 'default',
  loginMode: LoginMode.PASSWORD,
  user: {
    userId: 'u-1001',
    userName: 'Ada Wong',
    rawChannelUserInfo: {}
  },
  cookies: [
    { name: 'SESSION', value: 'sid=login' }
  ],
  lastAuthAt: 1714464000000,
  createdAt: 1714464000000
};

export default function appStateTest() {
  describe('AppState', () => {
    it('initializes empty state and exposes singleton instance', 0, () => {
      const state = new AppState();

      expect(state.channels.length).assertEqual(0);
      expect(state.currentChannel === undefined).assertEqual(true);
      expect(state.currentSession === undefined).assertEqual(true);
      expect(state.isLoggedIn).assertEqual(false);
      expect(appState instanceof AppState).assertEqual(true);
    });

    it('treats login as active only when current session has cookies', 0, () => {
      const state = new AppState();

      state.currentSession = SESSION_WITHOUT_COOKIES;
      expect(state.isLoggedIn).assertEqual(false);

      state.currentSession = SESSION_WITH_COOKIES;
      expect(state.isLoggedIn).assertEqual(true);
    });
  });
}
