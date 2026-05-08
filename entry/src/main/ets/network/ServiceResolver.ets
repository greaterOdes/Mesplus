/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

import { GatewayMode, ServiceType } from '../config/AppConstants';
import { ServiceGatewayConfig, ServiceMap } from '../models/Channel';

/**
 * @since: 2026-04-30 23-35-10
 * @Author: @greaterOdes
 */
export function resolveServiceUrl(services: ServiceMap, serviceType: ServiceType, apiPath: string): string {
  if (!apiPath.startsWith('/')) {
    throw new Error('apiPath must start with /');
  }
  const service = getService(services, serviceType);
  const gateway = resolveGateway(service, serviceType);
  if (gateway.length === 0) {
    throw new Error(`service ${serviceType} gateway must be non-empty`);
  }
  return gateway + apiPath;
}

function resolveGateway(service: ServiceGatewayConfig, serviceType: ServiceType): string {
  if (service.gatewayMode === GatewayMode.MAG) {
    return service.magGateway;
  }
  if (service.gatewayMode === GatewayMode.ORIGINAL) {
    return service.originalGateway;
  }
  throw new Error(`service ${serviceType} gatewayMode is invalid`);
}

function getService(services: ServiceMap, serviceType: ServiceType): ServiceGatewayConfig {
  let service: ServiceGatewayConfig | undefined = undefined;
  if (serviceType === ServiceType.AUTH) {
    service = services.auth;
  } else if (serviceType === ServiceType.BUSINESS) {
    service = services.business;
  } else if (serviceType === ServiceType.SSO) {
    service = services.sso;
  } else if (serviceType === ServiceType.FILE) {
    service = services.file;
  }
  if (service === undefined) {
    throw new Error(`service ${serviceType} is missing`);
  }
  return service;
}
