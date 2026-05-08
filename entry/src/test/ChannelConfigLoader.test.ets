import { describe, it, expect } from '@ohos/hypium';
import { parseChannelConfig } from '../main/ets/config/ChannelConfigLoader';
import { GatewayMode, LoginMode, ServiceType } from '../main/ets/config/AppConstants';
import { PasswordOnlyLoginStrategy } from '../main/ets/auth/PasswordOnlyLoginStrategy';
import { SsoWebViewLoginStrategy } from '../main/ets/auth/SsoWebViewLoginStrategy';
import { Channel, LoginMethodConfig } from '../main/ets/models/Channel';
import { ChannelUserInfoObject } from '../main/ets/models/UserProfile';

const VALID_CONFIG: string = '{' +
  '"channels":[{' +
  '"id":"default",' +
  '"name":"Default Channel",' +
  '"gatewayMode":"MAG",' +
  '"services":{' +
  '"auth":{"type":"auth","baseUrl":"https://auth.example.com","magGateway":"https://mag.example.com/auth","originalGateway":"https://origin.example.com/auth","gatewayMode":"MAG"},' +
  '"business":{"type":"business","baseUrl":"https://business.example.com","magGateway":"https://mag.example.com/business","originalGateway":"https://origin.example.com/business","gatewayMode":"ORIGINAL"},' +
  '"sso":{"type":"sso","baseUrl":"https://sso.example.com","magGateway":"https://mag.example.com/sso","originalGateway":"https://origin.example.com/sso","gatewayMode":"MAG"},' +
  '"file":{"type":"file","baseUrl":"https://file.example.com","magGateway":"https://mag.example.com/file","originalGateway":"https://origin.example.com/file","gatewayMode":"ORIGINAL"}' +
  '},' +
  '"loginMethods":[{' +
  '"mode":"PASSWORD",' +
  '"title":"Password Login",' +
  '"credentialPolicy":"rsa_encrypted_password",' +
  '"loginPath":"/auth/login",' +
  '"authService":"auth",' +
  '"smsVerifyPath":"/auth/sms/verify",' +
  '"autoLoginPath":"/auth/auto-login"' +
  '},{' +
  '"mode":"SSO",' +
  '"title":"SSO Login",' +
  '"credentialPolicy":"sso_renewal_credential",' +
  '"loginPath":"/sso/login",' +
  '"ssoService":"sso",' +
  '"renewalService":"sso",' +
  '"renewalPath":"/sso/renewal"' +
  '}],' +
  '"userMapping":[' +
  '{"source":"empNo","target":"userId"},' +
  '{"source":"displayName","target":"userName"},' +
  '{"source":"phone","target":"mobile"}' +
  '],' +
  '"cookieMapping":[' +
  '{"name":"accessToken","target":"ACCESS_TOKEN"},' +
  '{"name":"refreshToken","target":"REFRESH_TOKEN"}' +
  '],' +
  '"autoLogin":{"enabled":true,"intervalMinutes":28}' +
  '}]}';

class StubExecutor {
  execute(_channel: Channel, _method: LoginMethodConfig, _input?: ChannelUserInfoObject): Promise<ChannelUserInfoObject> {
    return Promise.resolve({ empNo: 'u-1001' });
  }
}

function didParseThrow(jsonText: string): boolean {
  try {
    parseChannelConfig(jsonText);
  } catch (error) {
    return true;
  }
  return false;
}

export default function channelConfigLoaderTest() {
  describe('ChannelConfigLoader', () => {
    it('parses valid channel config', 0, () => {
      const config = parseChannelConfig(VALID_CONFIG);

      expect(config.channels.length).assertEqual(1);
      expect(config.channels[0].id).assertEqual('default');
      expect(config.channels[0].gatewayMode).assertEqual(GatewayMode.MAG);
      expect(config.channels[0].services.auth.type).assertEqual(ServiceType.AUTH);
      expect(config.channels[0].services.auth.gatewayMode).assertEqual(GatewayMode.MAG);
    });

    it('throws for invalid gatewayMode', 0, () => {
      const invalidGatewayMode = VALID_CONFIG.replace('"gatewayMode":"MAG"', '"gatewayMode":"PROXY"');

      expect(didParseThrow(invalidGatewayMode)).assertEqual(true);
    });

    it('throws when service gatewayMode is missing', 0, () => {
      const missingServiceGatewayMode = VALID_CONFIG.replace(',"gatewayMode":"MAG"},"business"', '},"business"');

      expect(didParseThrow(missingServiceGatewayMode)).assertEqual(true);
    });

    it('parses loginMethods', 0, () => {
      const config = parseChannelConfig(VALID_CONFIG);

      expect(config.channels[0].loginMethods.length).assertEqual(2);
      expect(config.channels[0].loginMethods[0].mode).assertEqual(LoginMode.PASSWORD);
      expect(config.channels[0].loginMethods[0].authService).assertEqual(ServiceType.AUTH);
      expect(config.channels[0].loginMethods[1].mode).assertEqual(LoginMode.SSO);
      expect(config.channels[0].loginMethods[1].renewalPath).assertEqual('/sso/renewal');
    });

    it('parses rawfile credential policies that support auto login', 0, () => {
      const config = parseChannelConfig(VALID_CONFIG);
      const passwordStrategy = new PasswordOnlyLoginStrategy(new StubExecutor());
      const ssoStrategy = new SsoWebViewLoginStrategy(new StubExecutor());

      expect(passwordStrategy.supportsAutoLogin(config.channels[0].loginMethods[0])).assertEqual(true);
      expect(ssoStrategy.supportsAutoLogin(config.channels[0].loginMethods[1])).assertEqual(true);
    });

    it('parses channel user and cookie mappings', 0, () => {
      const config = parseChannelConfig(VALID_CONFIG);

      expect(config.channels[0].userMapping.length).assertEqual(3);
      expect(config.channels[0].userMapping[0].source).assertEqual('empNo');
      expect(config.channels[0].userMapping[0].target).assertEqual('userId');
      expect(config.channels[0].cookieMapping.length).assertEqual(2);
      expect(config.channels[0].cookieMapping[0].name).assertEqual('accessToken');
      expect(config.channels[0].cookieMapping[0].target).assertEqual('ACCESS_TOKEN');
    });

    it('parses autoLogin intervalMinutes as 28', 0, () => {
      const config = parseChannelConfig(VALID_CONFIG);

      expect(config.channels[0].autoLogin.enabled).assertEqual(true);
      expect(config.channels[0].autoLogin.intervalMinutes).assertEqual(28);
    });

    it('throws when services object is missing', 0, () => {
      const missingServices = VALID_CONFIG.replace('"services":{"auth":{"type":"auth","baseUrl":"https://auth.example.com","magGateway":"https://mag.example.com/auth","originalGateway":"https://origin.example.com/auth","gatewayMode":"MAG"},"business":{"type":"business","baseUrl":"https://business.example.com","magGateway":"https://mag.example.com/business","originalGateway":"https://origin.example.com/business","gatewayMode":"ORIGINAL"},"sso":{"type":"sso","baseUrl":"https://sso.example.com","magGateway":"https://mag.example.com/sso","originalGateway":"https://origin.example.com/sso","gatewayMode":"MAG"},"file":{"type":"file","baseUrl":"https://file.example.com","magGateway":"https://mag.example.com/file","originalGateway":"https://origin.example.com/file","gatewayMode":"ORIGINAL"}},', '');

      expect(didParseThrow(missingServices)).assertEqual(true);
    });

    it('throws when autoLogin object is missing', 0, () => {
      const missingAutoLogin = VALID_CONFIG.replace(',"autoLogin":{"enabled":true,"intervalMinutes":28}', '');

      expect(didParseThrow(missingAutoLogin)).assertEqual(true);
    });

    it('throws when loginMethods is empty', 0, () => {
      const emptyLoginMethods = VALID_CONFIG.replace('"loginMethods":[{"mode":"PASSWORD","title":"Password Login","credentialPolicy":"rsa_encrypted_password","loginPath":"/auth/login","authService":"auth","smsVerifyPath":"/auth/sms/verify","autoLoginPath":"/auth/auto-login"},{"mode":"SSO","title":"SSO Login","credentialPolicy":"sso_renewal_credential","loginPath":"/sso/login","ssoService":"sso","renewalService":"sso","renewalPath":"/sso/renewal"}]', '"loginMethods":[]');

      expect(didParseThrow(emptyLoginMethods)).assertEqual(true);
    });

    it('uses default autoLogin intervalMinutes when omitted', 0, () => {
      const missingIntervalMinutes = VALID_CONFIG.replace(',"intervalMinutes":28', '');
      const config = parseChannelConfig(missingIntervalMinutes);

      expect(config.channels[0].autoLogin.intervalMinutes).assertEqual(28);
    });
  });
}
