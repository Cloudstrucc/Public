export interface KeyVaultConfig {
    vaultUrl: string;
    tenantId: string;
    clientId?: string;
    clientSecret?: string;
}
export interface EncryptionResult {
    ciphertext: string;
    keyId: string;
    iv: string;
    tag: string;
}
export declare class ManagedHSMClient {
    private config;
    private keyClient;
    private secretClient;
    constructor(config: KeyVaultConfig);
    generateKey(keyName: string): Promise<string>;
    encrypt(_data: string, _keyName: string): Promise<EncryptionResult>;
    decrypt(_encryptedData: EncryptionResult): Promise<string>;
}
export * from './types';
export * from './utils';
