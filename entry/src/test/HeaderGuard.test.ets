import { describe, it, expect } from '@ohos/hypium';
import { mergeSafeHeaders, RequestHeaders } from '../main/ets/network/HeaderGuard';

function didMergeThrow(customHeaders: RequestHeaders | undefined, cookies: string): boolean {
  try {
    mergeSafeHeaders(customHeaders, cookies);
  } catch (error) {
    return true;
  }
  return false;
}

export default function headerGuardTest() {
  describe('HeaderGuard', () => {
    it('allows business header and appends Cookie', 0, () => {
      const headers = mergeSafeHeaders({ 'X-Trace-Id': 'trace-1001' }, 'sid=abc123');

      expect(headers['Content-Type']).assertEqual('application/json');
      expect(headers['X-Trace-Id']).assertEqual('trace-1001');
      expect(headers['Cookie']).assertEqual('sid=abc123');
    });

    it('allows omitted custom headers', 0, () => {
      const headers = mergeSafeHeaders(undefined, 'sid=abc123');

      expect(headers['Content-Type']).assertEqual('application/json');
      expect(headers['Cookie']).assertEqual('sid=abc123');
    });

    it('omits Cookie header when cookies are empty', 0, () => {
      const headers = mergeSafeHeaders(undefined, '');

      expect(Object.keys(headers).indexOf('Cookie')).assertEqual(-1);
    });

    it('rejects Cookie override', 0, () => {
      expect(didMergeThrow({ 'Cookie': 'sid=evil' }, 'sid=abc123')).assertEqual(true);
    });

    it('rejects newline injection in header value', 0, () => {
      expect(didMergeThrow({ 'X-Trace-Id': 'trace\nInjected: value' }, 'sid=abc123')).assertEqual(true);
    });

    it('rejects newline injection in Cookie value', 0, () => {
      expect(didMergeThrow({}, 'a=1\r\nb=2')).assertEqual(true);
    });

    it('rejects invalid header name characters', 0, () => {
      expect(didMergeThrow({ 'X_Trace_Id': 'trace-1001' }, 'sid=abc123')).assertEqual(true);
    });

    it('rejects protected header name case variants', 0, () => {
      expect(didMergeThrow({ 'authorization': 'Bearer token' }, 'sid=abc123')).assertEqual(true);
    });

    it('rejects mixed case protected header names', 0, () => {
      expect(didMergeThrow({ 'AuThOrIzAtIoN': 'Bearer token' }, 'sid=abc123')).assertEqual(true);
    });
  });
}
