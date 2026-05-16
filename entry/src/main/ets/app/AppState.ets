/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { Channel } from '../models/Channel';
import { Session } from '../models/Session';

/**
 * @since: 2026-04-30 23-51-09
 * @Author: @greaterOdes
 */
export class AppState {
  channels: Channel[] = [];
  currentChannel?: Channel = undefined;
  currentSession?: Session = undefined;

  get isLoggedIn(): boolean {
    return this.currentSession !== undefined && this.currentSession.cookies.length > 0;
  }
}

export const appState: AppState = new AppState();
