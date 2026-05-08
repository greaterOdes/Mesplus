/*
 * Copyright (c) 2026 Huawei Machine Co., Ltd.
 */

/**
 * @since: 2026-04-30 23-51-09
 * @Author: @greaterOdes
 */
export interface PasswordCredential {
  /** 定义 channelId 字段。 */
  channelId: string;
  /** 定义 account 字段。 */
  account: string;
  /** 定义 encryptedPassword 字段。 */
  encryptedPassword: string;
}

export interface SsoRenewalCredential {
  /** 定义 channelId 字段。 */
  channelId: string;
  /** 定义 credential 字段。 */
  credential: string;
}

export interface CredentialStore {
  /** 获取账号密码凭据。 */
  getPasswordCredential(channelId: string): PasswordCredential | undefined;
  /** 保存账号密码凭据。 */
  savePasswordCredential(credential: PasswordCredential): void;
  /** 清除账号密码凭据。 */
  clearPasswordCredential(channelId: string): void;
  /** 获取 SSO 续期凭据。 */
  getSsoRenewalCredential(channelId: string): SsoRenewalCredential | undefined;
  /** 保存 SSO 续期凭据。 */
  saveSsoRenewalCredential(credential: SsoRenewalCredential): void;
  /** 清除 SSO 续期凭据。 */
  clearSsoRenewalCredential(channelId: string): void;
}

export class InMemoryCredentialStore implements CredentialStore {
  private passwordCredentials: Map<string, PasswordCredential> = new Map<string, PasswordCredential>();
  private ssoRenewalCredentials: Map<string, SsoRenewalCredential> = new Map<string, SsoRenewalCredential>();

  /** 获取账号密码凭据。 */
  getPasswordCredential(channelId: string): PasswordCredential | undefined {
    return this.passwordCredentials.get(channelId);
  }

  /** 保存账号密码凭据。 */
  savePasswordCredential(credential: PasswordCredential): void {
    this.passwordCredentials.set(credential.channelId, credential);
  }

  /** 清除账号密码凭据。 */
  clearPasswordCredential(channelId: string): void {
    this.passwordCredentials.delete(channelId);
  }

  /** 获取 SSO 续期凭据。 */
  getSsoRenewalCredential(channelId: string): SsoRenewalCredential | undefined {
    return this.ssoRenewalCredentials.get(channelId);
  }

  /** 保存 SSO 续期凭据。 */
  saveSsoRenewalCredential(credential: SsoRenewalCredential): void {
    this.ssoRenewalCredentials.set(credential.channelId, credential);
  }

  /** 清除 SSO 续期凭据。 */
  clearSsoRenewalCredential(channelId: string): void {
    this.ssoRenewalCredentials.delete(channelId);
  }
}
