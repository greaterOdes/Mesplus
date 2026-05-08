import { LoginMode } from '../config/AppConstants';
import { CookieMapping, FieldMapping } from '../models/Channel';
import { Session, SessionCookie } from '../models/Session';
import { ChannelUserInfoObject, ChannelUserInfoValue, UserProfile } from '../models/UserProfile';

export function normalizeLoginResult(
  channelId: string,
  loginMode: LoginMode,
  raw: ChannelUserInfoObject,
  userMapping: FieldMapping[],
  cookieMapping: CookieMapping[],
  now: number
): Session {
  const user: UserProfile = {
    userId: requireMappedString(raw, userMapping, 'userId'),
    userName: requireMappedString(raw, userMapping, 'userName'),
    rawChannelUserInfo: raw
  };

  user.mobile = optionalMappedString(raw, userMapping, 'mobile');
  user.department = optionalMappedString(raw, userMapping, 'department');
  user.avatarUrl = optionalMappedString(raw, userMapping, 'avatarUrl');

  const cookies = extractCookies(raw, cookieMapping);
  if (cookies.length === 0) {
    throw new Error('cookies must be non-empty');
  }

  return {
    channelId,
    loginMode,
    user,
    cookies,
    lastAuthAt: now,
    createdAt: now
  };
}

function extractCookies(raw: ChannelUserInfoObject, cookieMapping: CookieMapping[]): SessionCookie[] {
  const cookies: SessionCookie[] = [];
  cookieMapping.forEach((mapping: CookieMapping) => {
    const value = requireStringValue(raw, mapping.name, `cookie target ${mapping.target} source ${mapping.name}`);
    cookies.push({
      name: mapping.target,
      value
    });
  });
  return cookies;
}

function requireMappedString(raw: ChannelUserInfoObject, mappings: FieldMapping[], target: string): string {
  const source = findSource(mappings, target);
  if (source === undefined) {
    throw new Error(`user field target ${target} has no source mapping`);
  }
  return requireStringValue(raw, source, `user field target ${target} source ${source}`);
}

function optionalMappedString(raw: ChannelUserInfoObject, mappings: FieldMapping[], target: string): string | undefined {
  const source = findSource(mappings, target);
  if (source === undefined) {
    return undefined;
  }
  return getString(raw, source);
}

function findSource(mappings: FieldMapping[], target: string): string | undefined {
  for (let index = 0; index < mappings.length; index++) {
    if (mappings[index].target === target) {
      return mappings[index].source;
    }
  }
  return undefined;
}

function getString(raw: ChannelUserInfoObject, key: string): string | undefined {
  const value: ChannelUserInfoValue | undefined = raw[key];
  if (typeof value !== 'string') {
    return undefined;
  }
  return value;
}

function requireStringValue(raw: ChannelUserInfoObject, key: string, label: string): string {
  if (!Object.prototype.hasOwnProperty.call(raw, key)) {
    throw new Error(`${label} is missing`);
  }

  const value: ChannelUserInfoValue = raw[key];
  if (typeof value !== 'string') {
    throw new Error(`${label} must be string`);
  }
  if (value.length === 0) {
    throw new Error(`${label} must be non-empty string`);
  }
  return value;
}
