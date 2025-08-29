"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ManagedHSMClient = void 0;
const identity_1 = require("@azure/identity");
const keyvault_keys_1 = require("@azure/keyvault-keys");
const keyvault_secrets_1 = require("@azure/keyvault-secrets");
class ManagedHSMClient {
    constructor(config) {
        this.config = config;
        const credential = new identity_1.DefaultAzureCredential();
        this.keyClient = new keyvault_keys_1.KeyClient(config.vaultUrl, credential);
        this.secretClient = new keyvault_secrets_1.SecretClient(config.vaultUrl, credential);
    }
    async generateKey(keyName) {
        const keyResponse = await this.keyClient.createKey(keyName, 'RSA');
        return keyResponse.id;
    }
    async encrypt(_data, _keyName) {
        // Placeholder - integrate with Key Vault/HSM crypto if needed
        throw new Error("Encryption implementation needed");
    }
    async decrypt(_encryptedData) {
        // Placeholder
        throw new Error("Decryption implementation needed");
    }
}
exports.ManagedHSMClient = ManagedHSMClient;
__exportStar(require("./types"), exports);
__exportStar(require("./utils"), exports);
