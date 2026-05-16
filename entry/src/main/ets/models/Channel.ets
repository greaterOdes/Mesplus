/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { GatewayMode, LoginMode, ServiceType } from '../config/AppConstants';

/**
 * @since: 2026-04-30 23-13-58
 * @Author: @greaterOdes
 */
export interface FieldMapping {
  /** 定义 source 字段。 */
  source: string;
  /** 定义 target 字段。 */
  target: string;
}

export interface CookieMapping {
  /** 定义 name 字段。 */
  name: string;
  /** 定义 target 字段。 */
  target: string;
}

export interface ServiceGatewayConfig {
  /** 定义 type 字段。 */
  type: ServiceType;
  /** 定义 baseUrl 字段。 */
  baseUrl: string;
  /** 定义 magGateway 字段。 */
  magGateway: string;
  /** 定义 originalGateway 字段。 */
  originalGateway: string;
  /** 定义 gatewayMode 字段。 */
  gatewayMode: GatewayMode;
}

export interface ServiceMap {
  /** 定义 auth 字段。 */
  auth: ServiceGatewayConfig;
  /** 定义 business 字段。 */
  business: ServiceGatewayConfig;
  /** 定义 sso 字段。 */
  sso: ServiceGatewayConfig;
  /** 定义 file 字段。 */
  file: ServiceGatewayConfig;
}

export interface AutoLoginConfig {
  /** 定义 enabled 字段。 */
  enabled: boolean;
  /** 定义 intervalMinutes 字段。 */
  intervalMinutes: number;
}

export interface LoginMethodConfig {
  /** 定义 mode 字段。 */
  mode: LoginMode;
  /** 定义 title 字段。 */
  title: string;
  /** 定义 credentialPolicy 字段。 */
  credentialPolicy: string;
  /** 定义 loginPath 字段。 */
  loginPath: string;
  /** 定义 authService 字段。 */
  authService?: ServiceType;
  /** 定义 ssoService 字段。 */
  ssoService?: ServiceType;
  /** 定义 renewalService 字段。 */
  renewalService?: ServiceType;
  /** 定义 smsVerifyPath 字段。 */
  smsVerifyPath?: string;
  /** 定义 autoLoginPath 字段。 */
  autoLoginPath?: string;
  /** 定义 renewalPath 字段。 */
  renewalPath?: string;
}

export interface Channel {
  /** 定义 id 字段。 */
  id: string;
  /** 定义 name 字段。 */
  name: string;
  /** 定义 gatewayMode 字段。 */
  gatewayMode: GatewayMode;
  /** 定义 services 字段。 */
  services: ServiceMap;
  /** 定义 loginMethods 字段。 */
  loginMethods: LoginMethodConfig[];
  /** 定义 userMapping 字段。 */
  userMapping: FieldMapping[];
  /** 定义 cookieMapping 字段。 */
  cookieMapping: CookieMapping[];
  /** 定义 autoLogin 字段。 */
  autoLogin: AutoLoginConfig;
}

export interface ChannelConfig {
  /** 定义 channels 字段。 */
  channels: Channel[];
}
