/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-04-30 23-13-58
 * @Author: @greaterOdes
 */
export enum LoginMode {
  PASSWORD = 'PASSWORD',
  SMS = 'SMS',
  SSO = 'SSO'
}

export enum ServiceType {
  AUTH = 'auth',
  BUSINESS = 'business',
  SSO = 'sso',
  FILE = 'file'
}

export enum GatewayMode {
  MAG = 'MAG',
  ORIGINAL = 'ORIGINAL'
}

export const DEFAULT_AUTO_LOGIN_INTERVAL_MINUTES: number = 28;
