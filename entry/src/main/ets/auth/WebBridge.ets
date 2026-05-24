/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-05-01 00-21-18
 * @Author: @greaterOdes
 */
export interface IdassUserInfo {
  /** IDASS 用户标识。 */
  userId?: string;
}

export interface IdassCallbackPayload {
  /** IDASS Web 登录成功后返回的 MTOKEN。 */
  mtoken: string;
  /** IDASS Web 登录成功后返回的用户信息。 */
  user: IdassUserInfo;
}

export const SSO_CALLBACK_NAME: string = 'window.Loader.intoApp';
export function parseSsoCallbackPayload(jsonText: string): IdassCallbackPayload {
  if (jsonText.length === 0) {
    throw new Error('SSO callback payload must be non-empty');
  }
  const payload: IdassCallbackPayload = JSON.parse(jsonText) as IdassCallbackPayload;
  return validateIdassCallbackPayload(payload);
}

function validateIdassCallbackPayload(payload: IdassCallbackPayload): IdassCallbackPayload {
  if (payload === null || typeof payload.mtoken !== 'string' || payload.mtoken.length === 0) {
    throw new Error('SSO callback payload must include mtoken');
  }
  if (payload.user === null || typeof payload.user !== 'object' || Array.isArray(payload.user)) {
    throw new Error('SSO callback payload must include user object');
  }
  return payload;
}
