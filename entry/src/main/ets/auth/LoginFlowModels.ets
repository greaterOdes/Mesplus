/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-05-20 00-00-00
 * @Author: @greaterOdes
 */
export enum MagLoginStep {
  CREDENTIALS = 'CREDENTIALS',
  MFA = 'MFA'
}

export enum MagMfaMethod {
  SMS = 'SMS',
  EMAIL = 'EMAIL'
}

export interface MagMfaOption {
  /** 二次认证方式。 */
  method: MagMfaMethod;
  /** 服务端返回的脱敏联系方式。 */
  maskedTarget: string;
}

export interface MagLoginState {
  /** 当前 MAG 登录步骤。 */
  step: MagLoginStep;
  /** 当前可用的二次认证方式。 */
  availableMethods: MagMfaOption[];
  /** 当前选中的二次认证方式。 */
  selectedMethod?: MagMfaMethod;
}

export function createInitialMagState(): MagLoginState {
  return {
    step: MagLoginStep.CREDENTIALS,
    availableMethods: []
  };
}

export function createMagMfaState(maskedMobile?: string, maskedEmail?: string): MagLoginState {
  const availableMethods: MagMfaOption[] = [];
  addMfaOption(availableMethods, MagMfaMethod.SMS, maskedMobile);
  addMfaOption(availableMethods, MagMfaMethod.EMAIL, maskedEmail);
  if (availableMethods.length === 0) {
    throw new Error('MAG MFA requires at least one masked contact');
  }
  return {
    step: MagLoginStep.MFA,
    availableMethods,
    selectedMethod: availableMethods[0].method
  };
}

export function selectMagMfaMethod(state: MagLoginState, method: MagMfaMethod): MagLoginState {
  if (!state.availableMethods.some((option: MagMfaOption) => option.method === method)) {
    throw new Error(`MAG MFA method ${method} is unavailable`);
  }
  return {
    step: state.step,
    availableMethods: state.availableMethods,
    selectedMethod: method
  };
}

function addMfaOption(options: MagMfaOption[], method: MagMfaMethod, maskedTarget?: string): void {
  if (maskedTarget !== undefined && maskedTarget.length > 0) {
    options.push({ method, maskedTarget });
  }
}
