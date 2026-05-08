/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { LoginMode } from '../config/AppConstants';
import { UserProfile } from './UserProfile';

/**
 * @since: 2026-04-30 23-24-49
 * @Author: @greaterOdes
 */
export interface SessionCookie {
  /** 定义 name 字段。 */
  name: string;
  /** 定义 value 字段。 */
  value: string;
}

export interface Session {
  /** 定义 channelId 字段。 */
  channelId: string;
  /** 定义 loginMode 字段。 */
  loginMode: LoginMode;
  /** 定义 user 字段。 */
  user: UserProfile;
  /** 定义 cookies 字段。 */
  cookies: SessionCookie[];
  /** 定义 lastAuthAt 字段。 */
  lastAuthAt: number;
  /** 定义 createdAt 字段。 */
  createdAt: number;
}
