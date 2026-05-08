export type ChannelUserInfoValue = string | number | boolean | null | ChannelUserInfoObject | ChannelUserInfoValue[];

export interface ChannelUserInfoObject {
  [key: string]: ChannelUserInfoValue;
}

export interface UserProfile {
  userId: string;
  userName: string;
  mobile?: string;
  department?: string;
  avatarUrl?: string;
  rawChannelUserInfo: ChannelUserInfoObject;
}
