export interface PasswordCredential {
  channelId: string;
  account: string;
  encryptedPassword: string;
}

export interface SsoRenewalCredential {
  channelId: string;
  credential: string;
}

export interface CredentialStore {
  getPasswordCredential(channelId: string): PasswordCredential | undefined;
  savePasswordCredential(credential: PasswordCredential): void;
  clearPasswordCredential(channelId: string): void;
  getSsoRenewalCredential(channelId: string): SsoRenewalCredential | undefined;
  saveSsoRenewalCredential(credential: SsoRenewalCredential): void;
  clearSsoRenewalCredential(channelId: string): void;
}

export class InMemoryCredentialStore implements CredentialStore {
  private passwordCredentials: Map<string, PasswordCredential> = new Map<string, PasswordCredential>();
  private ssoRenewalCredentials: Map<string, SsoRenewalCredential> = new Map<string, SsoRenewalCredential>();

  getPasswordCredential(channelId: string): PasswordCredential | undefined {
    return this.passwordCredentials.get(channelId);
  }

  savePasswordCredential(credential: PasswordCredential): void {
    this.passwordCredentials.set(credential.channelId, credential);
  }

  clearPasswordCredential(channelId: string): void {
    this.passwordCredentials.delete(channelId);
  }

  getSsoRenewalCredential(channelId: string): SsoRenewalCredential | undefined {
    return this.ssoRenewalCredentials.get(channelId);
  }

  saveSsoRenewalCredential(credential: SsoRenewalCredential): void {
    this.ssoRenewalCredentials.set(credential.channelId, credential);
  }

  clearSsoRenewalCredential(channelId: string): void {
    this.ssoRenewalCredentials.delete(channelId);
  }
}
