export interface PurviewLabel {
    id: string;
    name: string;
    description?: string;
    encryptionSettings?: EncryptionSettings;
}
export interface EncryptionSettings {
    encryptionMethod: string;
    keySize: number;
    permissions: string[];
}
export declare class MIPWrapper {
    applyLabel(content: Buffer, labelId: string): Promise<Buffer>;
    removeLabel(content: Buffer): Promise<Buffer>;
    getLabels(): Promise<PurviewLabel[]>;
}
export * from './types';
