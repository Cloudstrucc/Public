import { createAgent } from '@veramo/core';
import { CredentialPlugin } from '@veramo/credential-w3c';
import { DIDManager, MemoryDIDStore } from '@veramo/did-manager';
import { WebDIDProvider } from '@veramo/did-provider-web';
import { KeyDIDProvider } from '@veramo/did-provider-key';
import { KeyManager, MemoryKeyStore, MemoryPrivateKeyStore } from '@veramo/key-manager';
import { KeyManagementSystem } from '@veramo/kms-local';
import { DIDResolverPlugin } from '@veramo/did-resolver';
import { Resolver } from 'did-resolver';
import { getResolver as webDidResolver } from 'web-did-resolver';
import { getResolver as keyDidResolver } from 'key-did-resolver';
export const createDIDAgent = () => {
    // Support did:web and did:key resolution
    const resolver = new Resolver({
        ...webDidResolver(),
        ...keyDidResolver(),
    });
    return createAgent({
        plugins: [
            new KeyManager({
                store: new MemoryKeyStore(), // dev-only; replace with persistent store later
                kms: { local: new KeyManagementSystem(new MemoryPrivateKeyStore()) }
            }),
            new DIDManager({
                store: new MemoryDIDStore(), // dev-only; replace with persistent store later
                defaultProvider: 'did:key', // dev default (no hosting required)
                providers: {
                    'did:key': new KeyDIDProvider({ defaultKms: 'local' }),
                    'did:web': new WebDIDProvider({ defaultKms: 'local' })
                }
            }),
            new DIDResolverPlugin({ resolver }),
            new CredentialPlugin()
        ]
    });
};
export * from './types.js';
export * from './utils.js';
