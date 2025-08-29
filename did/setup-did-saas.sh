#!/usr/bin/env bash
# DID + Cloud Signature SaaS - Complete Setup Script for Mac Pro M4 (Updated with Fixes)
# Sets up tools, scaffolded monorepo, workspaces, env files, Docker compose, and helper scripts.

set -Eeuo pipefail

# --------------- Colors ---------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --------------- Helpers ---------------
print_status()   { echo -e "${BLUE}[INFO]${NC} $*"; }
print_success()  { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
print_warning()  { echo -e "${YELLOW}[WARNING]${NC} $*"; }
print_error()    { echo -e "${RED}[ERROR]${NC} $*"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

print_status "Starting DID + Cloud Signature SaaS setup…"

# --------------- OS Checks ---------------
if [[ "$OSTYPE" != "darwin"* ]]; then
  print_error "This script is designed for macOS. Detected OS: $OSTYPE"
  exit 1
fi
ARCH="$(uname -m)"

# --------------- Homebrew ---------------
if ! command_exists brew; then
  print_status "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is in PATH (especially on arm64)
if [[ "$ARCH" == "arm64" ]]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if ! grep -q '/opt/homebrew/bin' <<<"$PATH"; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    fi
  fi
fi

print_status "Updating Homebrew…"
brew update

# --------------- Node.js ---------------
print_status "Checking Node.js installation…"
if ! command_exists node; then
  print_error "Node.js not found. Please install Node 20.x (e.g., 'brew install node@20') and re-run."
  exit 1
fi
NODE_VERSION="$(node -v)"
print_success "Node.js found: $NODE_VERSION"
# Basic version check (string compare ok for major check)
if [[ "${NODE_VERSION#v}" < "18.0.0" ]]; then
  print_warning "Detected Node $NODE_VERSION; recommended Node >= 20.x"
fi

# --------------- npm global dir (safe) ---------------
print_status "Setting up npm permissions…"
mkdir -p ~/.npm-global || true
npm config set prefix "$HOME/.npm-global" >/dev/null 2>&1 || true
if ! echo "$PATH" | grep -q "$HOME/.npm-global/bin"; then
  echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> ~/.zshrc
  export PATH="$HOME/.npm-global/bin:$PATH"
fi

# --------------- Yarn / Corepack ---------------
# Prefer Corepack to manage Yarn versions reliably
if command_exists corepack; then
  print_status "Enabling Corepack (Yarn manager)…"
  corepack enable || true
fi

if ! command_exists yarn; then
  # Fallback if Yarn not available via Corepack (installs classic)
  print_status "Installing Yarn globally (fallback)…"
  npm install -g yarn
  print_success "Yarn installed: $(yarn -v)"
else
  print_success "Yarn already installed ($(yarn -v))"
fi

# --------------- Dotnet ---------------
if ! command_exists dotnet; then
  print_status "Installing .NET SDK…"
  brew install --cask dotnet-sdk
else
  print_success ".NET SDK already installed ($(dotnet --version))"
fi

# --------------- Azure CLI ---------------
if ! command_exists az; then
  print_status "Installing Azure CLI…"
  brew install azure-cli
else
  print_success "Azure CLI already installed"
fi

# --------------- Docker Desktop ---------------
if ! command_exists docker; then
  print_status "Installing Docker Desktop…"
  brew install --cask docker
  print_warning "Docker Desktop installed. Please start Docker Desktop before continuing."
  read -r -p "Press Enter after Docker Desktop is running…"
else
  print_success "Docker already installed"
fi

# Verify Docker is running
if ! docker info >/dev/null 2>&1; then
  print_warning "Docker daemon not responding yet. Please ensure Docker Desktop is running."
  read -r -p "Press Enter to retry Docker check…"
  if ! docker info >/dev/null 2>&1; then
    print_error "Docker daemon not available. Start Docker Desktop and re-run."
    exit 1
  fi
fi

# --------------- Git ---------------
if ! command_exists git; then
  print_status "Installing Git…"
  brew install git
else
  print_success "Git already installed"
fi

# --------------- jq (safe JSON edits) ---------------
if ! command_exists jq; then
  print_status "Installing jq…"
  brew install jq
else
  print_success "jq already installed"
fi

# --------------- MongoDB ---------------
print_status "Installing MongoDB Community…"
if ! brew list mongodb-community >/dev/null 2>&1; then
  brew tap mongodb/brew || true
  brew install mongodb-community || {
    print_warning "MongoDB install hit an issue; retrying tap/install…"
    brew untap mongodb/brew || true
    brew tap mongodb/brew
    brew install mongodb-community
  }
else
  print_success "MongoDB already installed"
fi

print_success "All core tools installed!"

# --------------- Project Scaffolding ---------------
PROJECT_NAME="did-cloud-signature-saas"
print_status "Creating project structure: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Directories
print_status "Creating directory structure…"
mkdir -p apps/{teams-ext,secure-note-a,secure-note-b,issuer-api,verifier-api,signing-adapter,admin-portal}
mkdir -p packages/{agent,policy-engine,mip-wrapper,kv-hsm}
mkdir -p docs/architecture/{api-specs,diagrams,deployment}
mkdir -p infrastructure/{terraform,docker,k8s}
mkdir -p tools/{scripts,migrations}

# --------------- Root package.json ---------------
print_status "Creating root package.json…"
cat > package.json << 'EOF'
{
  "name": "did-cloud-signature-saas",
  "version": "1.0.0",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "packageManager": "yarn@1.22.22",
  "scripts": {
    "dev": "concurrently \"yarn workspace @saas/admin-portal dev\" \"yarn workspace @saas/teams-ext dev\" \"yarn workspace @saas/secure-note-a dev\" \"yarn workspace @saas/secure-note-b dev\" \"yarn workspace @saas/issuer-api dev\" \"yarn workspace @saas/verifier-api dev\"",
    "build:packages": "yarn workspace @saas/kv-hsm build && yarn workspace @saas/policy-engine build && yarn workspace @saas/agent build && yarn workspace @saas/mip-wrapper build",
    "build:apps": "yarn workspaces run build",
    "build": "yarn build:packages && yarn build:apps",
    "test": "yarn workspaces run test",
    "lint": "yarn workspaces run lint",
    "clean": "yarn workspaces run clean",
    "setup": "yarn install && yarn build:packages"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0",
    "prettier": "^3.0.0",
    "eslint": "^8.0.0",
    "concurrently": "^8.2.0",
    "ts-node-dev": "^2.0.0",
    "jest": "^29.0.0"
  }
}
EOF

# --------------- packages/kv-hsm ---------------
print_status "Creating kv-hsm package…"
mkdir -p packages/kv-hsm/src
cat > packages/kv-hsm/package.json << 'EOF'
{
  "name": "@saas/kv-hsm",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@azure/keyvault-keys": "^4.7.0",
    "@azure/keyvault-secrets": "^4.7.0",
    "@azure/identity": "^4.0.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^20.0.0",
    "jest": "^29.0.0"
  }
}
EOF

cat > packages/kv-hsm/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

cat > packages/kv-hsm/src/index.ts << 'EOF'
import { DefaultAzureCredential } from '@azure/identity';
import { KeyClient } from '@azure/keyvault-keys';
import { SecretClient } from '@azure/keyvault-secrets';

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

export class ManagedHSMClient {
  private keyClient: KeyClient;
  private secretClient: SecretClient;

  constructor(private config: KeyVaultConfig) {
    const credential = new DefaultAzureCredential();
    this.keyClient = new KeyClient(config.vaultUrl, credential);
    this.secretClient = new SecretClient(config.vaultUrl, credential);
  }
  
  async generateKey(keyName: string): Promise<string> {
    const keyResponse = await this.keyClient.createKey(keyName, 'RSA');
    return keyResponse.id!;
  }
  
  async encrypt(_data: string, _keyName: string): Promise<EncryptionResult> {
    // Placeholder - integrate with Key Vault/HSM crypto if needed
    throw new Error("Encryption implementation needed");
  }
  
  async decrypt(_encryptedData: EncryptionResult): Promise<string> {
    // Placeholder
    throw new Error("Decryption implementation needed");
  }
}

export * from './types';
export * from './utils';
EOF

cat > packages/kv-hsm/src/types.ts << 'EOF'
export interface CryptoKeyPair {
  publicKey: string;
  privateKey: string;
  keyId: string;
}

export interface EncryptionOptions {
  algorithm: string;
  keySize: number;
}
EOF

cat > packages/kv-hsm/src/utils.ts << 'EOF'
import * as crypto from 'crypto';

export function generateRandomBytes(size: number): Buffer {
  return crypto.randomBytes(size);
}

export function createHash(data: string, algorithm: string = 'sha256'): string {
  return crypto.createHash(algorithm).update(data).digest('hex');
}
EOF

# --------------- packages/policy-engine ---------------
print_status "Creating policy-engine package…"
mkdir -p packages/policy-engine/src
cat > packages/policy-engine/package.json << 'EOF'
{
  "name": "@saas/policy-engine",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "jsonpath": "^1.1.1",
    "joi": "^17.11.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^20.0.0",
    "jest": "^29.0.0"
  }
}
EOF

cat > packages/policy-engine/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

cat > packages/policy-engine/src/index.ts << 'EOF'
export interface PolicyRule {
  id: string;
  name: string;
  condition: string;
  action: 'allow' | 'deny';
  resources: string[];
  claims?: Record<string, any>;
}

export interface PolicyContext {
  user: {
    id: string;
    email: string;
    roles: string[];
  };
  resource: string;
  action: string;
  claims?: Record<string, any>;
}

export class PolicyEngine {
  private rules: PolicyRule[] = [];
  
  addRule(rule: PolicyRule): void {
    this.rules.push(rule);
  }
  
  async evaluate(context: PolicyContext): Promise<boolean> {
    for (const rule of this.rules) {
      if (this.matchesRule(rule, context)) {
        return rule.action === 'allow';
      }
    }
    return false;
  }
  
  private matchesRule(rule: PolicyRule, context: PolicyContext): boolean {
    // Simple implementation - enhance as needed
    return rule.resources.includes(context.resource) || rule.resources.includes('*');
  }
}

export * from './types';
export * from './rules';
EOF

cat > packages/policy-engine/src/types.ts << 'EOF'
export interface ClaimRequirement {
  claim: string;
  value: any;
  operator: 'equals' | 'contains' | 'greaterThan' | 'lessThan';
}

export interface PolicyEvaluationResult {
  allowed: boolean;
  reason: string;
  appliedRules: string[];
}
EOF

cat > packages/policy-engine/src/rules.ts << 'EOF'
import { PolicyRule } from './index';

export const defaultRules: PolicyRule[] = [
  {
    id: 'allow-admin',
    name: 'Allow Admin Access',
    condition: 'user.roles.includes("admin")',
    action: 'allow',
    resources: ['*']
  },
  {
    id: 'deny-guest',
    name: 'Deny Guest Access',
    condition: 'user.roles.includes("guest")',
    action: 'deny',
    resources: ['secure-notes']
  }
];
EOF

# --------------- packages/agent ---------------
print_status "Creating agent package…"
mkdir -p packages/agent/src
cat > packages/agent/package.json << 'EOF'
{
  "name": "@saas/agent",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@veramo/core": "^4.2.0",
    "@veramo/credential-w3c": "^4.2.0",
    "@veramo/did-manager": "^4.2.0",
    "@veramo/did-provider-web": "^4.2.0",
    "@veramo/key-manager": "^4.2.0",
    "@veramo/kms-local": "^4.2.0",
    "@veramo/data-store": "^4.2.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^20.0.0"
  }
}
EOF

cat > packages/agent/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

cat > packages/agent/src/index.ts << 'EOF'
import { createAgent, IKeyManager, IDIDManager, IResolver, ICredentialPlugin } from '@veramo/core'
import { CredentialPlugin } from '@veramo/credential-w3c'
import { DIDManager } from '@veramo/did-manager'
import { WebDIDProvider } from '@veramo/did-provider-web'
import { KeyManager } from '@veramo/key-manager'
import { KeyManagementSystem } from '@veramo/kms-local'

export const createDIDAgent = () => {
  return createAgent<IKeyManager & IDIDManager & IResolver & ICredentialPlugin>({
    plugins: [
      new KeyManager({
        store: {} as any, // Placeholder - implement proper store
        kms: { local: new KeyManagementSystem() }
      }),
      new DIDManager({
        store: {} as any, // Placeholder - implement proper store
        defaultProvider: 'did:web',
        providers: {
          'did:web': new WebDIDProvider({ defaultKms: 'local' })
        }
      }),
      new CredentialPlugin()
    ]
  })
}

export * from './types';
export * from './utils';
EOF

cat > packages/agent/src/types.ts << 'EOF'
export interface DIDDocument {
  id: string;
  controller: string;
  verificationMethod: any[];
  authentication: any[];
}

export interface VerifiableCredential {
  "@context": string[];
  type: string[];
  issuer: string;
  credentialSubject: any;
  proof: any;
}
EOF

cat > packages/agent/src/utils.ts << 'EOF'
export function generateDID(method: string, identifier: string): string {
  return `did:${method}:${identifier}`;
}

export function parseDID(did: string): { method: string; identifier: string } {
  const parts = did.split(':');
  return { method: parts[1], identifier: parts.slice(2).join(':') };
}
EOF

# --------------- packages/mip-wrapper ---------------
print_status "Creating mip-wrapper package…"
mkdir -p packages/mip-wrapper/src
cat > packages/mip-wrapper/package.json << 'EOF'
{
  "name": "@saas/mip-wrapper",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@azure/msal-node": "^2.5.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^20.0.0"
  }
}
EOF

cat > packages/mip-wrapper/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

cat > packages/mip-wrapper/src/index.ts << 'EOF'
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

export class MIPWrapper {
  async applyLabel(content: Buffer, labelId: string): Promise<Buffer> {
    console.log(`Applying label ${labelId} to content`);
    return content;
  }

  async removeLabel(content: Buffer): Promise<Buffer> {
    console.log('Removing label from content');
    return content;
  }

  async getLabels(): Promise<PurviewLabel[]> {
    return [{ id: 'confidential', name: 'Confidential', description: 'Confidential information' }];
  }
}

export * from './types';
EOF

cat > packages/mip-wrapper/src/types.ts << 'EOF'
export interface LabelingOptions {
  justification?: string;
  metadata?: Record<string, string>;
  watermarkText?: string;
}

export interface LabelingResult {
  success: boolean;
  labelId: string;
  protectedContent: Buffer;
  metadata: Record<string, any>;
}
EOF

# --------------- apps/teams-ext ---------------
print_status "Creating Teams extension app…"
mkdir -p apps/teams-ext/pages/api apps/teams-ext/public
cat > apps/teams-ext/package.json << 'EOF'
{
  "name": "@saas/teams-ext",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev -p 3001",
    "build": "next build",
    "start": "next start -p 3001",
    "test": "jest",
    "clean": "rm -rf .next"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "@microsoft/teams-js": "^2.15.0",
    "@microsoft/teamsfx": "^2.3.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0"
  }
}
EOF

cat > apps/teams-ext/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true
}
module.exports = nextConfig
EOF

cat > apps/teams-ext/pages/api/encrypt.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).json({ message: 'Method not allowed' });

  try {
    const { text, audiences, design, labelId } = req.body;

    const adaptiveCard = {
      type: "AdaptiveCard",
      version: "1.4",
      body: [
        { type: "TextBlock", text: "Secure Note Created", weight: "Bolder", size: "Medium" },
        { type: "TextBlock", text: "Click to view encrypted content", wrap: true }
      ],
      actions: [
        { type: "Action.Submit", title: design === 'A' ? "Open Secure Note" : "Decrypt", data: { action: "view", noteId: "generated-note-id" } }
      ]
    };

    res.status(200).json({ card: adaptiveCard, meta: { audiences, labelId } });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
}
EOF

cat > apps/teams-ext/pages/index.tsx << 'EOF'
export default function Home() {
  return (
    <div>
      <h1>Teams Extension</h1>
      <p>Secure messaging extension for Microsoft Teams</p>
    </div>
  );
}
EOF

cat > apps/teams-ext/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

# --------------- apps/secure-note-a ---------------
print_status "Creating Secure Note A service…"
mkdir -p apps/secure-note-a/src
cat > apps/secure-note-a/package.json << 'EOF'
{
  "name": "@saas/secure-note-a",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev --respawn src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "@azure/msal-node": "^2.5.0",
    "@azure/msal-common": "^13.0.0",
    "@saas/kv-hsm": "workspace:*",
    "@saas/mip-wrapper": "workspace:*",
    "puppeteer": "^21.0.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/express": "^4.17.0",
    "@types/cors": "^2.8.0",
    "ts-node-dev": "^2.0.0"
  }
}
EOF

cat > apps/secure-note-a/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > apps/secure-note-a/src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import { MIPWrapper } from '@saas/mip-wrapper';

const app = express();
const PORT = process.env.PORT || 3002;

app.use(cors());
app.use(express.json());

const mipWrapper = new MIPWrapper();

app.post('/secure-note-a', async (req, res) => {
  try {
    const { text, labelId, audiences } = req.body;
    const htmlContent = await renderToHtml(text);
    const protectedFile = await mipWrapper.applyLabel(Buffer.from(htmlContent), labelId);
    const fileUrl = await uploadToSharePoint(protectedFile);
    res.json({ fileUrl, fileId: 'generated-file-id', title: 'Secure Note', audiences });
  } catch (error) {
    console.error('Error creating secure note:', error);
    res.status(500).json({ error: 'Failed to create secure note' });
  }
});

async function renderToHtml(text: string): Promise<string> {
  return `<!DOCTYPE html>
<html>
<head><title>Secure Note</title></head>
<body>
  <div style="padding: 20px; font-family: Arial, sans-serif;">
    <h2>Secure Note</h2>
    <p>${text}</p>
    <small>Created: ${new Date().toISOString()}</small>
  </div>
</body>
</html>`;
}

async function uploadToSharePoint(_file: Buffer): Promise<string> {
  console.log('Uploading to SharePoint...');
  return 'https://tenant.sharepoint.com/sites/secnotes/file.html';
}

app.listen(PORT, () => console.log(`Secure Note A service running on port ${PORT}`));
EOF

# --------------- apps/secure-note-b ---------------
print_status "Creating Secure Note B service…"
mkdir -p apps/secure-note-b/src
cat > apps/secure-note-b/package.json << 'EOF'
{
  "name": "@saas/secure-note-b",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev --respawn src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "@saas/kv-hsm": "workspace:*",
    "jsonwebtoken": "^9.0.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/express": "^4.17.0",
    "@types/jsonwebtoken": "^9.0.0",
    "ts-node-dev": "^2.0.0"
  }
}
EOF

cat > apps/secure-note-b/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > apps/secure-note-b/src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';

const app = express();
const PORT = process.env.PORT || 3003;

app.use(cors());
app.use(express.json());

// NOTE: For production, replace this with robust envelope encryption & KMS/HSM key handling
app.post('/secure-note-b', async (req, res) => {
  try {
    const { text, recipients } = req.body;
    const noteId = crypto.randomUUID();

    const key = crypto.randomBytes(32);
    const iv = crypto.randomBytes(12); // GCM best practice
    const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
    const ciphertext = Buffer.concat([cipher.update(text, 'utf8'), cipher.final()]);
    const tag = cipher.getAuthTag();

    // In reality, persist ciphertext and wrap 'key' for recipients
    const noteData = {
      noteId,
      ciphertext: ciphertext.toString('base64'),
      iv: iv.toString('base64'),
      tag: tag.toString('base64'),
      recipients,
      createdAt: new Date()
    };
    console.log('Created encrypted note:', noteId, noteData);

    res.json({ noteId, title: 'Secure Note', blobRef: `note-${noteId}` });
  } catch (error) {
    console.error('Error creating secure note:', error);
    res.status(500).json({ error: 'Failed to create secure note' });
  }
});

app.get('/secure-note-b/:noteId/view', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ error: 'No authorization header' });

    const token = authHeader.split(' ')[1];
    jwt.verify(token, process.env.JWT_SECRET || 'dev-secret');

    // Placeholder: fetch note + unwrap key for requester, then decrypt
    res.json({ plaintext: 'Decrypted content placeholder' });
  } catch (error) {
    console.error('Error decrypting note:', error);
    res.status(500).json({ error: 'Failed to decrypt note' });
  }
});

app.listen(PORT, () => console.log(`Secure Note B service running on port ${PORT}`));
EOF

# --------------- apps/issuer-api ---------------
print_status "Creating Issuer API…"
mkdir -p apps/issuer-api/src
cat > apps/issuer-api/package.json << 'EOF'
{
  "name": "@saas/issuer-api",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev --respawn src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "@saas/agent": "workspace:*",
    "did-jwt-vc": "^3.1.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/express": "^4.17.0",
    "ts-node-dev": "^2.0.0"
  }
}
EOF

cat > apps/issuer-api/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > apps/issuer-api/src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import { createDIDAgent } from '@saas/agent';

const app = express();
const PORT = process.env.PORT || 3004;

app.use(cors());
app.use(express.json());

const agent = createDIDAgent();

app.post('/issue', async (req, res) => {
  try {
    const { subject, claims, issuer } = req.body;
    const vc = await agent.createVerifiableCredential({
      credential: { issuer: { id: issuer }, credentialSubject: { id: subject, ...claims } },
      proofFormat: 'jwt'
    });
    res.json({ vc: vc.verifiableCredential });
  } catch (error) {
    console.error('Error issuing credential:', error);
    res.status(500).json({ error: 'Failed to issue credential' });
  }
});

app.listen(PORT, () => console.log(`VC Issuer API running on port ${PORT}`));
EOF

# --------------- apps/verifier-api ---------------
print_status "Creating Verifier API…"
mkdir -p apps/verifier-api/src
cat > apps/verifier-api/package.json << 'EOF'
{
  "name": "@saas/verifier-api",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev --respawn src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "@saas/agent": "workspace:*",
    "@saas/policy-engine": "workspace:*",
    "did-jwt-vc": "^3.1.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/express": "^4.17.0",
    "ts-node-dev": "^2.0.0"
  }
}
EOF

cat > apps/verifier-api/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > apps/verifier-api/src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import { createDIDAgent } from '@saas/agent';
import { PolicyEngine } from '@saas/policy-engine';

const app = express();
const PORT = process.env.PORT || 3005;

app.use(cors());
app.use(express.json());

const agent = createDIDAgent();
const policyEngine = new PolicyEngine();

app.post('/verify', async (req, res) => {
  try {
    const { presentation, context } = req.body;
    const verification = await agent.verifyPresentation({ presentation });
    if (!verification.verified) return res.status(400).json({ error: 'Invalid presentation' });

    const claims = extractClaims(presentation);
    const allowed = await policyEngine.evaluate({
      user: context.user,
      resource: context.resource,
      action: context.action,
      claims
    });

    res.json({ verified: true, allowed, claims });
  } catch (error) {
    console.error('Error verifying presentation:', error);
    res.status(500).json({ error: 'Failed to verify presentation' });
  }
});

function extractClaims(_presentation: any): Record<string, any> {
  // TODO: Parse VP to extract claims
  return {};
}

app.listen(PORT, () => console.log(`VC Verifier API running on port ${PORT}`));
EOF

# --------------- apps/signing-adapter ---------------
print_status "Creating Signing Adapter…"
mkdir -p apps/signing-adapter/src
cat > apps/signing-adapter/package.json << 'EOF'
{
  "name": "@saas/signing-adapter",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev --respawn src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "@saas/kv-hsm": "workspace:*"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/express": "^4.17.0",
    "ts-node-dev": "^2.0.0"
  }
}
EOF

cat > apps/signing-adapter/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > apps/signing-adapter/src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3006;

app.use(cors());
app.use(express.json());

app.post('/sign', async (req, res) => {
  try {
    const { pdfData, signingCertificate, timestampUrl } = req.body;
    console.log('Signing PDF with PAdES…', { hasPdf: !!pdfData, signingCertificate: !!signingCertificate, timestampUrl });
    res.json({ signedPdf: 'base64-encoded-signed-pdf', signatureId: 'signature-id' });
  } catch (error) {
    console.error('Error signing PDF:', error);
    res.status(500).json({ error: 'Failed to sign PDF' });
  }
});

app.listen(PORT, () => console.log(`Signing Adapter running on port ${PORT}`));
EOF

# --------------- apps/admin-portal ---------------
print_status "Creating Admin Portal…"
mkdir -p apps/admin-portal/pages/{api,policies,users} apps/admin-portal/public apps/admin-portal/styles
cat > apps/admin-portal/package.json << 'EOF'
{
  "name": "@saas/admin-portal",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "clean": "rm -rf .next"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "@azure/msal-react": "^2.0.0",
    "@azure/msal-browser": "^3.0.0",
    "tailwindcss": "^3.3.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0"
  }
}
EOF

cat > apps/admin-portal/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = { reactStrictMode: true, swcMinify: true }
module.exports = nextConfig
EOF

cat > apps/admin-portal/pages/_app.tsx << 'EOF'
import type { AppProps } from 'next/app'
import '../styles/globals.css'

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />
}
EOF

cat > apps/admin-portal/pages/index.tsx << 'EOF'
export default function AdminPortal() {
  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4">
          <h1 className="text-3xl font-bold text-gray-900">
            DID + Cloud Signature Admin Portal
          </h1>
        </div>
      </header>
      <main className="max-w-7xl mx-auto py-6 px-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Users</h2>
            <p>Manage user access and permissions</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Policies</h2>
            <p>Configure authorization policies</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Labels</h2>
            <p>Manage Purview sensitivity labels</p>
          </div>
        </div>
      </main>
    </div>
  );
}
EOF

cat > apps/admin-portal/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./pages/**/*.{js,ts,jsx,tsx,mdx}','./components/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: { extend: {} },
  plugins: []
}
EOF

cat > apps/admin-portal/postcss.config.js << 'EOF'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } }
EOF

cat > apps/admin-portal/styles/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

cat > apps/admin-portal/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

# --------------- Docker Compose ---------------
print_status "Creating Docker Compose configuration…"
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  mongodb:
    image: mongo:7
    container_name: saas-mongodb
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    volumes:
      - mongodb_data:/data/db
    networks:
      - saas-network

  redis:
    image: redis:7-alpine
    container_name: saas-redis
    ports:
      - "6379:6379"
    networks:
      - saas-network

volumes:
  mongodb_data:

networks:
  saas-network:
    driver: bridge
EOF

# --------------- .env template ---------------
print_status "Creating environment configuration…"
cat > .env.example << 'EOF'
# Azure Configuration
AZURE_TENANT_ID=your-tenant-id
AZURE_CLIENT_ID=your-client-id
AZURE_CLIENT_SECRET=your-client-secret

# Key Vault
VAULT_URL=https://your-vault.vault.azure.net/

# Database
DATABASE_URL=mongodb://admin:password@localhost:27017/saas-db?authSource=admin
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-jwt-secret-change-in-production

# Microsoft Graph
GRAPH_CLIENT_ID=your-graph-client-id
GRAPH_CLIENT_SECRET=your-graph-client-secret

# Microsoft Teams
TEAMS_APP_ID=your-teams-app-id
TEAMS_APP_SECRET=your-teams-app-secret

# Environment
NODE_ENV=development
LOG_LEVEL=info

# Service URLs (for development)
ADMIN_PORTAL_URL=http://localhost:3000
TEAMS_EXT_URL=http://localhost:3001
SECURE_NOTE_A_URL=http://localhost:3002
SECURE_NOTE_B_URL=http://localhost:3003
ISSUER_API_URL=http://localhost:3004
VERIFIER_API_URL=http://localhost:3005
SIGNING_ADAPTER_URL=http://localhost:3006
EOF

# --------------- Docs ---------------
print_status "Creating documentation…"
cat > docs/architecture/README.md << 'EOF'
# DID + Cloud Signature SaaS Architecture

This directory contains the architecture documentation for the DID + Cloud Signature SaaS project.

## Key Documents
- `architecture-v1.1.md` - Main architecture document
- `api-specs/` - OpenAPI specifications
- `diagrams/` - Architecture diagrams (Mermaid)
- `deployment/` - Deployment guides

## Quick Start
1. Review the main architecture document
2. Set up your development environment using the root setup script
3. Configure Azure services and environment variables
4. Start development with `yarn dev`
EOF

cat > docs/architecture/api-specs/README.md << 'EOF'
# API Specifications

This directory contains OpenAPI specifications for all services:

- `teams-ext.yaml`
- `secure-note-a.yaml`
- `secure-note-b.yaml`
- `issuer-api.yaml`
- `verifier-api.yaml`
- `signing-adapter.yaml`
- `admin-portal.yaml`
EOF

# --------------- Helper Scripts ---------------
print_status "Creating development scripts…"
mkdir -p tools/scripts

cat > tools/scripts/dev-start.sh << 'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
echo "Starting development databases…"
docker compose up -d mongodb redis
echo "Waiting for databases to be ready…"
sleep 5
echo "Starting all services…"
yarn dev
EOF
chmod +x tools/scripts/dev-start.sh

cat > tools/scripts/dev-stop.sh << 'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
echo "Stopping development databases…"
docker compose down
echo "Development environment stopped."
EOF
chmod +x tools/scripts/dev-stop.sh

cat > tools/scripts/build-all.sh << 'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
echo "Building packages…"
yarn build:packages
echo "Building applications…"
yarn build:apps
echo "Build complete!"
EOF
chmod +x tools/scripts/build-all.sh

# --------------- Install & Build ---------------
print_status "Installing dependencies (this may take a few minutes)…"
print_warning "Peer dependency warnings are normal in monorepos."
cp .env.example .env || true
yarn install

print_status "Building shared packages…"
yarn build:packages

print_status "Starting development databases with Docker…"
docker compose up -d mongodb redis

print_status "Starting MongoDB service via brew (optional; ignores errors if already running)…"
brew services start mongodb/brew/mongodb-community || true

print_success "🎉 Project setup complete!"

echo ""
echo "===================================================="
echo "  DID + Cloud Signature SaaS - Setup Complete!"
echo "===================================================="
echo ""
print_status "Project path: $(pwd)"
echo ""
print_status "Next steps:"
echo "1) Edit .env with your Azure configuration"
echo "2) Start all services: yarn dev"
echo "   - or use: ./tools/scripts/dev-start.sh"
echo ""
print_status "Service URLs (when running):"
echo "- Admin Portal:     http://localhost:3000"
echo "- Teams Extension:  http://localhost:3001"
echo "- Secure Note A:    http://localhost:3002"
echo "- Secure Note B:    http://localhost:3003"
echo "- VC Issuer API:    http://localhost:3004"
echo "- VC Verifier API:  http://localhost:3005"
echo "- Signing Adapter:  http://localhost:3006"
echo ""
print_status "Development databases:"
echo "- MongoDB:  localhost:27017 (admin/password)"
echo "- Redis:    localhost:6379"
echo ""
print_warning "Notes & fixes included:"
echo "- Uses Corepack (when available) or Yarn classic fallback"
echo "- Ensures jq is installed for safe JSON edits later"
echo "- Verifies Docker daemon is actually running"
echo "- Uses createCipheriv(AES-GCM) in Secure Note B (no deprecated API)"
echo "- Adds Tailwind globals import for Admin Portal"
echo ""
print_success "Happy coding! 🚀"
