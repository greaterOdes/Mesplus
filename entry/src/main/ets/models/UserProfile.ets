/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

export type ChannelUserInfoValue = string | number | boolean | null | ChannelUserInfoObject | ChannelUserInfoValue[];

/**
 * @since: 2026-04-30 23-24-49
 * @Author: @greaterOdes
 */
export interface ChannelUserInfoObject {
  [key: string]: ChannelUserInfoValue;
}

export interface UserProfile {
  /** 定义 userId 字段。 */
  userId: string;
  /** 定义 userName 字段。 */
  userName: string;
  /** 定义 mobile 字段。 */
  mobile?: string;
  /** 定义 department 字段。 */
  department?: string;
  /** 定义 avatarUrl 字段。 */
  avatarUrl?: string;
  /** 定义 rawChannelUserInfo 字段。 */
  rawChannelUserInfo: ChannelUserInfoObject;
}
