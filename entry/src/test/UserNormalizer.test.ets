import { describe, it, expect } from '@ohos/hypium';
import { normalizeLoginResult } from '../main/ets/auth/UserNormalizer';
import { LoginMode } from '../main/ets/config/AppConstants';
import { CookieMapping, FieldMapping } from '../main/ets/models/Channel';
import { ChannelUserInfoObject } from '../main/ets/models/UserProfile';

const USER_MAPPING: FieldMapping[] = [
  { source: 'user_id', target: 'userId' },
  { source: 'realName', target: 'userName' },
  { source: 'phone', target: 'mobile' },
  { source: 'deptName', target: 'department' },
  { source: 'avatar', target: 'avatarUrl' }
];

const COOKIE_MAPPING: CookieMapping[] = [
  { name: 'setCookie', target: 'SESSION' }
];

function didNormalizeThrow(raw: ChannelUserInfoObject): boolean {
  try {
    normalizeLoginResult('default', LoginMode.PASSWORD, raw, USER_MAPPING, COOKIE_MAPPING, 1714464000000);
  } catch (error) {
    return true;
  }
  return false;
}

function normalizeErrorMessage(raw: ChannelUserInfoObject): string {
  try {
    normalizeLoginResult('default', LoginMode.PASSWORD, raw, USER_MAPPING, COOKIE_MAPPING, 1714464000000);
  } catch (error) {
    return `${error}`;
  }
  return '';
}

export default function userNormalizerTest() {
  describe('UserNormalizer', () => {
    it('normalizes different user field names', 0, () => {
      const raw: ChannelUserInfoObject = {
        user_id: 'u-1001',
        realName: 'Ada Wong',
        phone: '13800138000',
        deptName: 'Manufacturing',
        avatar: 'https://example.com/avatar.png',
        setCookie: 'sid=abc123'
      };

      const session = normalizeLoginResult('default', LoginMode.PASSWORD, raw, USER_MAPPING, COOKIE_MAPPING, 1714464000000);

      expect(session.channelId).assertEqual('default');
      expect(session.loginMode).assertEqual(LoginMode.PASSWORD);
      expect(session.user.userId).assertEqual('u-1001');
      expect(session.user.userName).assertEqual('Ada Wong');
      expect(session.user.mobile).assertEqual('13800138000');
      expect(session.user.department).assertEqual('Manufacturing');
      expect(session.user.avatarUrl).assertEqual('https://example.com/avatar.png');
      expect(session.user.rawChannelUserInfo['user_id']).assertEqual('u-1001');
      expect(session.user.rawChannelUserInfo['realName']).assertEqual('Ada Wong');
      expect(session.user.rawChannelUserInfo['setCookie']).assertEqual('sid=abc123');
      expect(session.lastAuthAt).assertEqual(1714464000000);
      expect(session.createdAt).assertEqual(1714464000000);
    });

    it('extracts cookies using cookie mapping', 0, () => {
      const raw: ChannelUserInfoObject = {
        user_id: 'u-1001',
        realName: 'Ada Wong',
        setCookie: 'sid=abc123'
      };

      const session = normalizeLoginResult('default', LoginMode.PASSWORD, raw, USER_MAPPING, COOKIE_MAPPING, 1714464000000);

      expect(session.cookies.length).assertEqual(1);
      expect(session.cookies[0].name).assertEqual('SESSION');
      expect(session.cookies[0].value).assertEqual('sid=abc123');
    });

    it('throws when cookie is missing', 0, () => {
      const raw: ChannelUserInfoObject = {
        user_id: 'u-1001',
        realName: 'Ada Wong'
      };

      expect(didNormalizeThrow(raw)).assertEqual(true);
      expect(normalizeErrorMessage(raw).indexOf('cookie target SESSION source setCookie is missing') > -1).assertEqual(true);
    });

    it('throws when userId is missing', 0, () => {
      const raw: ChannelUserInfoObject = {
        realName: 'Ada Wong',
        setCookie: 'sid=abc123'
      };

      expect(didNormalizeThrow(raw)).assertEqual(true);
      expect(normalizeErrorMessage(raw).indexOf('user field target userId source user_id is missing') > -1).assertEqual(true);
    });

    it('throws when userName is missing', 0, () => {
      const raw: ChannelUserInfoObject = {
        user_id: 'u-1001',
        setCookie: 'sid=abc123'
      };

      expect(didNormalizeThrow(raw)).assertEqual(true);
      expect(normalizeErrorMessage(raw).indexOf('user field target userName source realName is missing') > -1).assertEqual(true);
    });

    it('throws with clear error when required user field is not string', 0, () => {
      const raw: ChannelUserInfoObject = {
        user_id: 1001,
        realName: 'Ada Wong',
        setCookie: 'sid=abc123'
      };

      expect(normalizeErrorMessage(raw).indexOf('user field target userId source user_id must be string') > -1).assertEqual(true);
    });

    it('throws with clear error when required user field is empty', 0, () => {
      const raw: ChannelUserInfoObject = {
        user_id: '',
        realName: 'Ada Wong',
        setCookie: 'sid=abc123'
      };

      expect(normalizeErrorMessage(raw).indexOf('user field target userId source user_id must be non-empty string') > -1).assertEqual(true);
    });
  });
}
