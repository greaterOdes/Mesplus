import { GatewayMode, LoginMode, ServiceType } from '../config/AppConstants';

export interface FieldMapping {
  source: string;
  target: string;
}

export interface CookieMapping {
  name: string;
  target: string;
}

export interface ServiceGatewayConfig {
  type: ServiceType;
  baseUrl: string;
  magGateway: string;
  originalGateway: string;
  gatewayMode: GatewayMode;
}

export interface ServiceMap {
  auth: ServiceGatewayConfig;
  business: ServiceGatewayConfig;
  sso: ServiceGatewayConfig;
  file: ServiceGatewayConfig;
}

export interface AutoLoginConfig {
  enabled: boolean;
  intervalMinutes: number;
}

export interface LoginMethodConfig {
  mode: LoginMode;
  title: string;
  credentialPolicy: string;
  loginPath: string;
  authService?: ServiceType;
  ssoService?: ServiceType;
  renewalService?: ServiceType;
  smsVerifyPath?: string;
  autoLoginPath?: string;
  renewalPath?: string;
}

export interface Channel {
  id: string;
  name: string;
  gatewayMode: GatewayMode;
  services: ServiceMap;
  loginMethods: LoginMethodConfig[];
  userMapping: FieldMapping[];
  cookieMapping: CookieMapping[];
  autoLogin: AutoLoginConfig;
}

export interface ChannelConfig {
  channels: Channel[];
}
