export interface CryptoKeyPair {
    publicKey: string;
    privateKey: string;
    keyId: string;
}
export interface EncryptionOptions {
    algorithm: string;
    keySize: number;
}
