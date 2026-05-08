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
