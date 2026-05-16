/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { DEFAULT_AUTO_LOGIN_INTERVAL_MINUTES, GatewayMode, LoginMode, ServiceType } from './AppConstants';
import { AutoLoginConfig, Channel, ChannelConfig, CookieMapping, FieldMapping, LoginMethodConfig, ServiceGatewayConfig, ServiceMap } from '../models/Channel';

type JsonValue = string | number | boolean | JsonObject | JsonValue[] | null;

/**
 * @since: 2026-04-30 23-13-58
 * @Author: @greaterOdes
 */
interface JsonObject {
  [key: string]: JsonValue;
}

export function parseChannelConfig(jsonText: string): ChannelConfig {
  const root = parseJsonObject(jsonText, 'channel config');
  const channelsValue = getJsonValue(root, 'channels');
  if (!Array.isArray(channelsValue) || channelsValue.length === 0) {
    throw new Error('channels must be a non-empty array');
  }
  const channels: Channel[] = [];
  channelsValue.forEach((value: JsonValue, index: number) => {
    channels.push(parseChannel(toJsonObject(value, `channels[${index}]`), index));
  });
  return { channels };
}

function parseJsonObject(jsonText: string, label: string): JsonObject {
  try {
    return toJsonObject(JSON.parse(jsonText) as JsonValue, label);
  } catch (error) {
    throw new Error(`${label} must be valid JSON object`);
  }
}

function parseChannel(value: JsonObject, index: number): Channel {
  const label = `channels[${index}]`;
  const loginMethodsValue = getJsonValue(value, 'loginMethods');
  if (!Array.isArray(loginMethodsValue) || loginMethodsValue.length === 0) {
    throw new Error(`${label}.loginMethods must be a non-empty array`);
  }
  const loginMethods: LoginMethodConfig[] = [];
  loginMethodsValue.forEach((methodValue: JsonValue, methodIndex: number) => {
    const methodLabel = `${label}.loginMethods[${methodIndex}]`;
    loginMethods.push(parseLoginMethod(toJsonObject(methodValue, methodLabel), methodLabel));
  });
  return {
    id: requireString(value, 'id', label),
    name: requireString(value, 'name', label),
    gatewayMode: parseGatewayMode(requireString(value, 'gatewayMode', label), `${label}.gatewayMode`),
    services: parseServices(toJsonObject(getJsonValue(value, 'services'), `${label}.services`), label),
    loginMethods,
    userMapping: parseFieldMappings(getJsonValue(value, 'userMapping'), `${label}.userMapping`),
    cookieMapping: parseCookieMappings(getJsonValue(value, 'cookieMapping'), `${label}.cookieMapping`),
    autoLogin: parseAutoLogin(toJsonObject(getJsonValue(value, 'autoLogin'), `${label}.autoLogin`), label)
  };
}

function parseServices(value: JsonObject, label: string): ServiceMap {
  return {
    auth: parseService(toJsonObject(getJsonValue(value, 'auth'), `${label}.services.auth`), `${label}.services.auth`),
    business: parseService(toJsonObject(getJsonValue(value, 'business'), `${label}.services.business`), `${label}.services.business`),
    sso: parseService(toJsonObject(getJsonValue(value, 'sso'), `${label}.services.sso`), `${label}.services.sso`),
    file: parseService(toJsonObject(getJsonValue(value, 'file'), `${label}.services.file`), `${label}.services.file`)
  };
}

function parseService(value: JsonObject, label: string): ServiceGatewayConfig {
  const service: ServiceGatewayConfig = {
    type: parseServiceType(requireString(value, 'type', label), `${label}.type`),
    baseUrl: requireString(value, 'baseUrl', label),
    magGateway: requireString(value, 'magGateway', label),
    originalGateway: requireString(value, 'originalGateway', label),
    gatewayMode: parseGatewayMode(requireString(value, 'gatewayMode', label), `${label}.gatewayMode`)
  };
  return service;
}

function parseLoginMethod(value: JsonObject, label: string): LoginMethodConfig {
  const method: LoginMethodConfig = {
    mode: parseLoginMode(requireString(value, 'mode', label), `${label}.mode`),
    title: requireString(value, 'title', label),
    credentialPolicy: requireString(value, 'credentialPolicy', label),
    loginPath: requireString(value, 'loginPath', label)
  };
  method.authService = parseOptionalService(value, 'authService', label);
  method.ssoService = parseOptionalService(value, 'ssoService', label);
  method.renewalService = parseOptionalService(value, 'renewalService', label);
  method.smsVerifyPath = parseOptionalString(value, 'smsVerifyPath', label);
  method.autoLoginPath = parseOptionalString(value, 'autoLoginPath', label);
  method.renewalPath = parseOptionalString(value, 'renewalPath', label);
  return method;
}

function parseFieldMappings(value: JsonValue | undefined, label: string): FieldMapping[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new Error(`${label} must be a non-empty array`);
  }
  const mappings: FieldMapping[] = [];
  value.forEach((mappingValue: JsonValue, index: number) => {
    const mapping = toJsonObject(mappingValue, `${label}[${index}]`);
    mappings.push({
      source: requireString(mapping, 'source', `${label}[${index}]`),
      target: requireString(mapping, 'target', `${label}[${index}]`)
    });
  });
  return mappings;
}

function parseCookieMappings(value: JsonValue | undefined, label: string): CookieMapping[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new Error(`${label} must be a non-empty array`);
  }
  const mappings: CookieMapping[] = [];
  value.forEach((mappingValue: JsonValue, index: number) => {
    const mapping = toJsonObject(mappingValue, `${label}[${index}]`);
    mappings.push({
      name: requireString(mapping, 'name', `${label}[${index}]`),
      target: requireString(mapping, 'target', `${label}[${index}]`)
    });
  });
  return mappings;
}

function parseAutoLogin(value: JsonObject, label: string): AutoLoginConfig {
  const enabled = getJsonValue(value, 'enabled');
  const intervalMinutes = getJsonValue(value, 'intervalMinutes');
  if (typeof enabled !== 'boolean') {
    throw new Error(`${label}.autoLogin.enabled must be boolean`);
  }
  if (intervalMinutes !== undefined && typeof intervalMinutes !== 'number') {
    throw new Error(`${label}.autoLogin.intervalMinutes must be number`);
  }
  return {
    enabled,
    intervalMinutes: typeof intervalMinutes === 'number' ? intervalMinutes : DEFAULT_AUTO_LOGIN_INTERVAL_MINUTES
  };
}

function parseGatewayMode(value: string, label: string): GatewayMode {
  if (value === GatewayMode.MAG) {
    return GatewayMode.MAG;
  }
  if (value === GatewayMode.ORIGINAL) {
    return GatewayMode.ORIGINAL;
  }
  throw new Error(`${label} must be MAG or ORIGINAL`);
}

function parseLoginMode(value: string, label: string): LoginMode {
  if (value === LoginMode.PASSWORD) {
    return LoginMode.PASSWORD;
  }
  if (value === LoginMode.SMS) {
    return LoginMode.SMS;
  }
  if (value === LoginMode.SSO) {
    return LoginMode.SSO;
  }
  throw new Error(`${label} is invalid`);
}

function parseServiceType(value: string, label: string): ServiceType {
  if (value === ServiceType.AUTH) {
    return ServiceType.AUTH;
  }
  if (value === ServiceType.BUSINESS) {
    return ServiceType.BUSINESS;
  }
  if (value === ServiceType.SSO) {
    return ServiceType.SSO;
  }
  if (value === ServiceType.FILE) {
    return ServiceType.FILE;
  }
  throw new Error(`${label} is invalid`);
}

function parseOptionalService(value: JsonObject, key: string, label: string): ServiceType | undefined {
  const service = getJsonValue(value, key);
  if (service === undefined) {
    return undefined;
  }
  if (typeof service !== 'string') {
    throw new Error(`${label}.${key} must be string`);
  }
  return parseServiceType(service, `${label}.${key}`);
}

function parseOptionalString(value: JsonObject, key: string, label: string): string | undefined {
  const text = getJsonValue(value, key);
  if (text === undefined) {
    return undefined;
  }
  if (typeof text !== 'string' || text.length === 0) {
    throw new Error(`${label}.${key} must be non-empty string`);
  }
  return text;
}

function requireString(value: JsonObject, key: string, label: string): string {
  const text = getJsonValue(value, key);
  if (typeof text !== 'string' || text.length === 0) {
    throw new Error(`${label}.${key} must be non-empty string`);
  }
  return text;
}

function getJsonValue(value: JsonObject, key: string): JsonValue | undefined {
  if (!Object.prototype.hasOwnProperty.call(value, key)) {
    return undefined;
  }
  return value[key];
}

function toJsonObject(value: JsonValue | undefined, label: string): JsonObject {
  if (value === undefined || value === null || Array.isArray(value) || typeof value !== 'object') {
    throw new Error(`${label} must be an object`);
  }
  return value as JsonObject;
}
