import { describe, it, expect } from '@ohos/hypium';
import { parseSsoCallbackPayload, SSO_CALLBACK_NAME } from '../main/ets/auth/WebBridge';

function didParseThrow(jsonText: string): boolean {
  try {
    parseSsoCallbackPayload(jsonText);
  } catch (error) {
    return true;
  }
  return false;
}

export default function webBridgeTest() {
  describe('WebBridge', () => {
    it('throws for empty SSO callback payload', 0, () => {
      expect(didParseThrow('')).assertEqual(true);
    });

    it('parses valid SSO callback payload', 0, () => {
      const payload = parseSsoCallbackPayload('{"mtoken":"m-1001","user":{"userId":"u-1001"}}');

      expect(SSO_CALLBACK_NAME).assertEqual('window.Loader.intoApp');
      expect(payload.mtoken).assertEqual('m-1001');
      expect(payload.user.userId).assertEqual('u-1001');
    });

    it('throws when SSO callback payload misses mtoken', 0, () => {
      expect(didParseThrow('{"user":{"userId":"u-1001"}}')).assertEqual(true);
    });

    it('throws for null SSO callback payload JSON', 0, () => {
      expect(didParseThrow('null')).assertEqual(true);
    });

    it('throws for array SSO callback payload JSON', 0, () => {
      expect(didParseThrow('[]')).assertEqual(true);
    });

    it('throws for string SSO callback payload JSON', 0, () => {
      expect(didParseThrow('"text"')).assertEqual(true);
    });
  });
}
