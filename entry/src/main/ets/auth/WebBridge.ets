/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

type JsonValue = string | number | boolean | JsonObject | JsonValue[] | null;

/**
 * @since: 2026-05-01 00-21-18
 * @Author: @greaterOdes
 */
export interface JsonObject {
  [key: string]: JsonValue;
}

export const SSO_CALLBACK_NAME: string = 'MesplusSSOCallback';
export function parseSsoCallbackPayload(jsonText: string): JsonObject {
  if (jsonText.length === 0) {
    throw new Error('SSO callback payload must be non-empty');
  }
  const parsed: unknown = JSON.parse(jsonText);
  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) {
    throw new Error('SSO callback payload must be a JSON object');
  }
  return parsed as JsonObject;
}
