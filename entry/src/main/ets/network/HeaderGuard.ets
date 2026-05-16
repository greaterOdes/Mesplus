/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-04-30 23-35-10
 * @Author: @greaterOdes
 */
export interface RequestHeaders {
  [key: string]: string;
}

const PROTECTED_HEADER_NAMES: string[] = [
  'cookie',
  'set-cookie',
  'authorization',
  'host',
  'origin',
  'referer',
  'content-length',
  'connection'
];

const HEADER_NAME_PATTERN: RegExp = /^[A-Za-z0-9-]+$/;

export function mergeSafeHeaders(customHeaders: RequestHeaders | undefined, cookies: string): RequestHeaders {
  const headers: RequestHeaders = {
    'Content-Type': 'application/json'
  };
  if (customHeaders !== undefined) {
    Object.keys(customHeaders).forEach((name: string) => {
      validateHeaderName(name);
      const value = customHeaders[name];
      validateHeaderValue(value);
      headers[name] = value;
    });
  }
  if (cookies.length > 0) {
    validateHeaderValue(cookies);
    headers['Cookie'] = cookies;
  }
  return headers;
}

function validateHeaderName(name: string): void {
  if (!HEADER_NAME_PATTERN.test(name)) {
    throw new Error(`header name ${name} is invalid`);
  }
  if (PROTECTED_HEADER_NAMES.indexOf(name.toLowerCase()) > -1) {
    throw new Error(`header ${name} is protected`);
  }
}

function validateHeaderValue(value: string): void {
  if (value.indexOf('\n') > -1 || value.indexOf('\r') > -1) {
    throw new Error('header value must not contain newline');
  }
}
